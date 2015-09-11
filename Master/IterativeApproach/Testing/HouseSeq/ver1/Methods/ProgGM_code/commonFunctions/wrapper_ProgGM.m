function [ score_GM, X_sol, Xraw, cand_matchlist, perform_data, affinityMatrix_final ] = wrapper_ProgGM( pparam, method, cdata, extrapolation_dist )
% function to perform progressive graph matching
%
% Minsu Cho and Kyoung Mu Lee. 
% "Progressive Graph Matching: Making a Move of Graphs via Probabilistic Voting", 
% Proc. Computer Vision and Pattern Recognition (CVPR), 2012. 
% http://cv.snu.ac.kr/research/~ProgGM/
%
% written by Minsu Cho, Seoul National University, Korea
%                      INRIA - WILLOW / ENS, Paris, France
%                      http://www.di.ens.fr/~mcho/ 

%% params
bShow = pparam.bShow;
k_neighbor1 = pparam.k_neighbor1;           % k_1 
k_neighbor2 = pparam.k_neighbor2;           % k_2
%radius_neighbor1 = 50;                     % search radius in left
%radius_neighbor2 = radius_neighbor1/4;     % search radius in right
threshold_dissim = pparam.threshold_dissim; % SIFT distance threshold for candidates
maxIterGM = pparam.maxIterGM;               % max iteration
max_candidates = pparam.max_candidates;     % num of cand matches in use

perform_data = zeros(maxIterGM,5); % [ nCandMatch, nTrue, nDetected, nTP, score_GM];
cand_matchlist_new = cell2mat({ cdata.matchInfo.match }');

% generate null GT info.
if isempty(cdata.GT)
    cdata.GT = ones(1,cdata.nInitialMatches);
end

% Candidate features
all_feat1 = cdata.view(1).feat; % all the features in img1
all_feat2 = cdata.view(2).feat; % all the features in img2

% compute unary similarity of current candidate matches    
nCandMatch = size(cand_matchlist_new,1);
nDim = min( length(cdata.view(1).nFeatOfExt), length(cdata.view(1).nFeatOfExt));
nMaxG1 = sum( cdata.mparam.bFeatExtUse(1:nDim) .* cdata.view(1).nFeatOfExt(1:nDim));
nMaxG2 = sum( cdata.mparam.bFeatExtUse(1:nDim) .* cdata.view(2).nFeatOfExt(1:nDim));
% fprintf('\n- maximal case: %d by %d \n',nMaxG1,nMaxG2);
% fprintf('- initial candidates: %d \n\n',nCandMatch);

if bShow, hFig1 = figure;    clf; end
if cdata.bPair, imgInput = appendimages( rgb2gray(cdata.view(1).img), rgb2gray(cdata.view(2).img) );
else    imgInput = cdata.view(1).img;    end
imgInput = double(imgInput)./255;

% command to call a matching function
str = ['feval(@' func2str(method.fhandle)];
for j = 1:length(method.variable)
    str = [str ', cdata.' method.variable{j} ];
end
str = [str ')'];

bStop = 0; score_GM = 0;
% Progressive GM starts
for iterGM = 1:maxIterGM
    
    %% ------------------ Perform graph matching
%     tic;
    Xraw_new = eval(str);
%     runningTime = toc;
    X_sol_new = greedyMapping(Xraw_new, cdata.group1, cdata.group2);
    score_GM_new = X_sol_new'*cdata.affinityMatrix*X_sol_new;
    if score_GM_new <= score_GM %&& iterGM > 2
        iterGM = iterGM - 1;        bStop = 1;
    else
        X_sol = X_sol_new;
        Xraw = Xraw_new;
        score_GM = score_GM_new;
        cand_matchlist = cand_matchlist_new;
        affinityMatrix_final = cdata.affinityMatrix;
    end
        
    %% ----------------- Evaluate the solutions
%     X_GT = extrapolateGT( cdata.view, cand_matchlist, cdata.GT, extrapolation_dist ); % extrapolate the groundtruths
%     X_sol_EXT = extrapolateMatchIndicator( cdata.view, cand_matchlist, X_sol, extrapolation_dist ); % extrapolate the solutions
  
    X_GT = ismember(cand_matchlist, cdata.GT, 'rows')';
    X_sol_EXT =  X_sol';
    
    matchIdx_GM = find(X_sol);
    matchScore_GM = Xraw(matchIdx_GM);     matchScore_GM = matchScore_GM./sum(matchScore_GM);
    matchList_GM = cand_matchlist(matchIdx_GM,:);
    nDetected = nnz(X_sol_EXT);    nTrue = size(cdata.GT,1);%nnz(X_GT);  
    nTP = nnz(X_GT & X_sol_EXT );
    recall_GM = nTP/nTrue;
    
    perform_data(iterGM,1:5) = [ nCandMatch, nTrue, nDetected, nTP, score_GM];
    if iterGM == 1
        score_GM_oneshot = score_GM;        nTP_GM_oneshot = nTP;
    end
    
    %% -----------------  show the current GM result
    % when it reaches to max iter, then quit
    if iterGM == maxIterGM, bStop = 1;  end
    
    if bShow, visMatches_ProgGM;  end
    if bStop, break; end
    
     %% Growing candidate matches!
    kdtreeNS1 = kdtree_build(all_feat1(:,1:2));%KDTreeSearcher(all_feat1(:,1:2));
    kdtreeNS2 = kdtree_build(all_feat2(:,1:2));%KDTreeSearcher(all_feat2(:,1:2));
    
    % sparse voting matrix, to be modified for multiple types of features
    voting_space = sparse(size(all_feat1,1),size(all_feat2,1));
    nVote = 0;
    for iter_i = 1:length(matchIdx_GM) % for each match
        
%         if mod(iter_i,100)==0, fprintf('%3d.',iter_i);   end;
        scoreAnchor = matchScore_GM(iter_i);
        matchAnchor = matchList_GM(iter_i,:);
        
        % Ti1: transform from normalized domain to region R1 of match i
        Ti1 = reshape(cdata.view(1).affMatrix(matchAnchor(1),:),[3 3])';
        if ~cdata.bPair
            % Ti2: transform from normalized domain to region R2 of match i
            Ti2 = reshape(cdata.view(1).affMatrix(matchAnchor(2),:),[3 3])';
        else
            Ti2 = reshape(cdata.view(2).affMatrix(matchAnchor(2),:),[3 3])';
        end
        inv_Ti1 = inv(Ti1);    inv_Ti2 = inv(Ti2);
        % Ti21: transform from R1 to R2,   Ti12: transform from R2 to R1
        if 0%bReflective
            Ti21 = Ti2*[ 1 0 0; 0 -1 0; 0 0 1 ]*inv_Ti1;
            Ti12 = Ti1*[ 1 0 0; 0 -1 0; 0 0 1 ]*inv_Ti2;
        else
            Ti21 = Ti2*inv_Ti1;        Ti12 = Ti1*inv_Ti2; 
        end

        % forward voting
        ptAnchor1 = cdata.view(1).feat(matchAnchor(1),1:2);
        [ voting, nAddedVote ]= voteCandidate( kdtreeNS1, kdtreeNS2, all_feat1(:,1:2), all_feat2(:,1:2), ...
            matchList_GM, scoreAnchor, ptAnchor1, Ti21, k_neighbor1, k_neighbor2);
        
        voting_space = voting_space + voting;
        nVote = nVote + nAddedVote;
        
        % backward voting
        ptAnchor2 = cdata.view(2).feat(matchAnchor(2),1:2);
        [ voting, nAddedVote ]= voteCandidate( kdtreeNS2, kdtreeNS1, all_feat2(:,1:2), all_feat1(:,1:2),...
            matchList_GM(:,[2 1]), scoreAnchor, ptAnchor2, Ti12, k_neighbor1, k_neighbor2);
        voting_space = voting_space + voting';
        nVote = nVote + nAddedVote;
        %toc    
        %pause;
    end
    kdtree_delete(kdtreeNS1);
    kdtree_delete(kdtreeNS2);
%     fprintf('\n');
%     fprintf('Match-growing iter #%d: anchor %d , voting %d',iterGM, length(matchIdx_GM), nVote );
    %spy(voting_space)
    
    % make sure that the current GM matches are included
    for iter_i = 1:length(matchIdx_GM) % for each match        
        matchAnchor = matchList_GM(iter_i,:);
        voting_space(matchAnchor(1),matchAnchor(2)) = Inf;
    end
    % collect new candidate matches from the voting space
    cand_matchlist_new = selectCandidateMatch( voting_space, ...
        cdata.view(1).feat, cdata.view(1).desc,...
        cdata.view(2).feat, cdata.view(2).desc,...
        max_candidates, threshold_dissim, cdata.mparam );
    
    nCandMatch = size(cand_matchlist_new,1);
%     fprintf('-> new candidates %d\n',nCandMatch  );
    % caculate affinity matrix of initial matches by reprojection error
%     [ cdata.distanceMatrix cdata.flipMatrix ] = computeAffineTransferDistanceMEX( ...
    [ cdata.distanceMatrix, cdata.flipMatrix ] = computeEuclidDistance( ...
            cdata.view, cand_matchlist_new(:,1:2), 0 );
    
    %% Make the overlapping groups of initial matches
    [ cdata.group1, cdata.group2 ] = make_group12(cand_matchlist_new(:,1:2));
    cdata.affinityMatrix = dissim2affinity(cdata.distanceMatrix);
    
    % eliminate conflicting elements to prevent conflicting walks
    cdata.affinityMatrix = cdata.affinityMatrix.*~full(getConflictMatrix(cdata.group1, cdata.group2));
    cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = 0; % diagonal 0s
    
end
perform_data = perform_data(1:iterGM,:);


            
