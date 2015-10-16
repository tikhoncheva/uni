function [ score_GM, X_sol, Xraw, cand_matchlist, affinityMatrix_final ] = wrapper_ProgGM_lite( pparam, method, cdata )
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

cand_matchlist_new = cell2mat({ cdata.matchInfo.match }');

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
        
    matchIdx_GM = find(X_sol);
    matchScore_GM = Xraw(matchIdx_GM);     matchScore_GM = matchScore_GM./sum(matchScore_GM);
    matchList_GM = cand_matchlist(matchIdx_GM,:);    nDetected = nnz(X_sol);  
    if iterGM == 1, score_GM_oneshot = score_GM;    end
    
    %% -----------------  show the current GM result
    % when it reaches to max iter, then quit
    if iterGM == maxIterGM, bStop = 1;  end
    
    if bShow, visMatches_ProgGM_lite;  end
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
        Ti2 = reshape(cdata.view(2).affMatrix(matchAnchor(2),:),[3 3])';
        inv_Ti1 = inv(Ti1);    inv_Ti2 = inv(Ti2);
        % Ti21: transform from R1 to R2,   Ti12: transform from R2 to R1
        Ti21 = Ti2*inv_Ti1;        Ti12 = Ti1*inv_Ti2; 

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
%     spy(voting_space)
    
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
    
    d1 = cdata.view(1).desc';
    d2 = cdata.view(2).desc';
    nodesim = nodeSimilarity(d1, d2, 'cosine');
    ind = (cand_matchlist_new(:,2)-1)*size(d1,2) + cand_matchlist_new(:,1);
    nodesim = nodesim(ind);
    cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = nodesim;
    
end



            
