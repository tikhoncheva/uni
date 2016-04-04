% MATLAB demo code of Progressive Graph Matching, CVPR 2012
%
% Minsu Cho and Kyoung Mu Lee. 
% "Progressive Graph Matching: Making a Move of Graphs via Probabilistic Voting", 
% Proc. Computer Vision and Pattern Recognition (CVPR), 2012. 
% http://cv.snu.ac.kr/research/~ProgGM/
%
% written by Minsu Cho, Seoul National University, Korea
%                      INRIA - WILLOW / ENS, Paris, France
%                      http://www.di.ens.fr/~mcho/ 

clear all;
init_path;

%% params for GM
bShowFig = true;
bReInitialization = true;
aparam.bProgGM = true;    % true for ProgGM, and false for conventional GM
setParams; % params for feature extraction and matching

pparam.bShow = 1;                              % visualize the process? 
pparam.k_neighbor1 = 25;                       % k_1 
pparam.k_neighbor2 = 5;                        % k_2
pparam.threshold_dissim = 1.0;                 % SIFT distance threshold for candidates
pparam.maxIterGM = 10;                         % max iteration of progression
pparam.max_candidates = mparam.nMaxMatch;      % num of max cand matches in progression

%% set GM methods to run
setMethods;

%% set input and output data
iparam.bShow = false;  % show detected features and initial matches ( it can takes long... )  
iparam.dataFolder = './data_demo';

listOfModelDataFile = dir([ iparam.dataFolder '/*_a.png' ]);
nModelDataFile = size(listOfModelDataFile,1);
nTestDataFile = nModelDataFile;
fprintf('Input: %d reference images\n', nModelDataFile);

%% storage for matching results
accuracy = zeros(nModelDataFile, length(methods));
score = zeros(nModelDataFile, length(methods));
time = zeros(nModelDataFile, length(methods));
X = cell(nModelDataFile, length(methods));
Xraw = cell(nModelDataFile, length(methods));
perform_data = cell(nModelDataFile, length(methods));
scoreGrowth = zeros(nModelDataFile, length(methods));
inlierGrowth = zeros(nModelDataFile, length(methods));

%% main loop start
for cImg=1:nModelDataFile
        disp([ '=>>> ' num2str(cImg) '/' num2str(nModelDataFile) ' - processing ' listOfModelDataFile(cImg).name ]);
       %% load FILE names
        iparam.view(1).fileName = listOfModelDataFile(cImg).name(1:end-4);
        iparam.view(1).filePathName = [ iparam.dataFolder '/' iparam.view(1).fileName '.png'];
        iparam.nView = 1;   iparam.bPair = 0;
        
        if strcmp(listOfModelDataFile(cImg).name(end-4:end),'a.png')
            % check the existence of its pairing file
            testDataFile = [ listOfModelDataFile(cImg).name(1:end-5) 'b.png'] ;        
            iparam.bPair = ( exist([ iparam.dataFolder '/' testDataFile ]) == 2 );
            iparam.view(2).fileName = testDataFile(1:end-4);
            iparam.view(2).filePathName = [ iparam.dataFolder '/' iparam.view(2).fileName '.png'];
            iparam.nView = 2;
        end 
        if iparam.bPair
            resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
            initPathnFile = [ iparam.dataFolder '/' 'fi_' resultTag '.mat' ];
        else
            resultTag = [ iparam.view(1).fileName ];
            initPathnFile = [ iparam.dataFolder '/' 'fi_' resultTag '.mat' ];
        end        
        
        
        %% make or load INITIAL matches
        if exist(initPathnFile) == 2 
            disp ([ 'loading features from' initPathnFile ' and make new matches.']);
            load(initPathnFile);            
            cdata = initialmatch_main_re( iparam, cdata, mparam);
        else
            % initial matching routine
            cdata = initialmatch_main( iparam, fparam, mparam );
            cdata.GT = [];
        end
        fprintf('- computing an affine symmetric transfer errors of %d by %d combination pairs...\n',cdata.nInitialMatches,cdata.nInitialMatches);
        % caculate affinity matrix of initial matches by reprojection error
        cand_matchlist = cell2mat({ cdata.matchInfo.match }');
        [ cdata.distanceMatrix cdata.flipMatrix ] = computeAffineTransferDistanceMEX( cdata.view, cand_matchlist, 0 );
        fprintf('>>> affinity matrix calculation done for %d initial matches.\n', cdata.nInitialMatches);
        save (initPathnFile, 'cdata');
        disp([ initPathnFile ' file saved for initial information']);
        
       %% perform GM
        cdata.affinityMatrix = dissim2affinity( cdata.distanceMatrix ); % make an affinity matrix
        [ cdata.group1 cdata.group2 ] = make_group12(cand_matchlist(:,1:2));
        
        % eliminate conflicting elements
        cdata.affinityMatrix = cdata.affinityMatrix.*~(getConflictMatrix(cdata.group1, cdata.group2));
        cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = 0; % diagonal 0s
        
        for i = 1:length(methods)
            
            if ~aparam.bProgGM % one-shot graph matching
                [ score(cImg,i) time(cImg,i) X{cImg,i} Xraw{cImg,i} ] = wrapper_GM(methods(i), cdata);
            else % progressive graph matching
                [  score(cImg,i) time(cImg,i) X{cImg,i} Xraw{cImg,i} cand_matchlist perform_data{cImg,i} ]=...
                    wrapper_ProgGM( pparam, methods(i), cdata, mparam.extrapolation_dist);
            end

            % Measure accuracy
            X_GT = extrapolateGT( cdata.view, cand_matchlist, cdata.GT, mparam.extrapolation_dist ); % extrapolate the groundtruths
            X_EXT = extrapolateMatchIndicator( cdata.view, cand_matchlist, X{cImg,i}, mparam.extrapolation_dist ); % extrapolate the solutions                
            accuracy(cImg,i)  = (X_EXT*X_GT')/nnz(X_GT);
            
            % Show the score values and visualize the result
            str_out = sprintf('%10s: %d matches- P: %.3f (%d/%d), R: %.3f (%d/%d) (Score:%.1f)'...
                 , methods(i).strName, nnz(X_EXT), nnz(X_EXT&X_GT)/nnz(X_EXT),...
                 nnz(X_EXT&X_GT), nnz(X_EXT), nnz(X_EXT&X_GT)/nnz(X_GT), nnz(X_EXT&X_GT), nnz(X_GT)...
                 , score(cImg,i));     
            fprintf('%s\n',str_out);
            
            if bShowFig
                figure;
                showFeatureMatching(cdata, cand_matchlist, X_EXT, X_GT);
                %pause;  
            end
        end
        
        if aparam.bProgGM
            visPerformPlot_ProgGM;
        end
        
        disp('press any key to process the next image pair...');
        pause;
end

%% show average accuracy and score of each method
fprintf('-------------\n');
% score normalization
for j = 1:nModelDataFile
    score(j,:) = score(j,:)./max(score(j,:));
end
accuracy_t = accuracy;  accuracy_t(isnan(accuracy_t)) = 0;
inlierGrowth_t = inlierGrowth;  inlierGrowth_t(isnan(inlierGrowth_t)) = 0;
for i = 1:length(methods)
    fprintf('%12s: accuracy %5.2f  score %5.2f  /  inlier %5.1f  score %5.1f\n',...
        methods(i).strName, mean(accuracy_t(:,i))*100, mean(score(:,i))*100,...
        mean(inlierGrowth_t(:,i))*100, mean(scoreGrowth(:,i))*100 );
end



