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

%% params for ProgGM
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

fname1 = './data_demo/building_a.png'; % reference image
fname2 = './data_demo/building_b.png'; % test image
%fname1 = './data_demo/motor_a.png'; % reference image
%fname2 = './data_demo/motor_b.png'; % test image

iparam.view(1).fileName = 'ref';
iparam.view(1).filePathName = fname1;
iparam.view(2).fileName = 'test';
iparam.view(2).filePathName = fname2;
iparam.bPair = 1;
iparam.nView = 2;

%% initial matching
cdata = initialmatch_main( iparam, fparam, mparam, true ); % initial matching with a bounding box
fprintf('- computing an affine symmetric transfer errors of %d by %d combination pairs...\n',cdata.nInitialMatches,cdata.nInitialMatches);
% caculate affinity matrix of initial matches by reprojection error
cand_matchlist = cell2mat({ cdata.matchInfo.match }');
[ cdata.distanceMatrix cdata.flipMatrix ] = computeAffineTransferDistanceMEX( cdata.view, cand_matchlist, 0 );
fprintf('>>> affinity matrix calculation done for %d initial matches.\n', cdata.nInitialMatches);

%% perform GM
cdata.affinityMatrix = dissim2affinity( cdata.distanceMatrix ); % make an affinity matrix
[ cdata.group1 cdata.group2 ] = make_group12(cand_matchlist(:,1:2));

% eliminate conflicting elements
cdata.affinityMatrix = cdata.affinityMatrix.*~(getConflictMatrix(cdata.group1, cdata.group2));
cdata.affinityMatrix(1:(size(cdata.affinityMatrix,1)+1):end) = 0; % diagonal 0s

% note that the graph matching module #1 is used here (see setMethod.m)
[  score time X Xraw cand_matchlist affMat_final ]=  wrapper_ProgGM_lite( pparam, methods(1), cdata );

% final matches
matchlist = cand_matchlist(find(X),:);             % n by 2 match list
matchscore = Xraw(find(X));                        % score based on GM confidence
matchscore = matchscore / sum(matchscore);

%% show results
figure;
showFeatureMatching_lite(cdata, matchlist, matchscore);
        




