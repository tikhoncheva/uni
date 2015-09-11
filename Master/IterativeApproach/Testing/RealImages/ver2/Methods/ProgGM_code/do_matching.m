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

filepath = '../../data/img_trafo/set1/';

fname1 = 'sun_aafpznbwiqbmolft_a1.png'; % reference image
fname2 = 'sun_aafpznbwiqbmolft_b.png'; % reference image


%% storage for matching results
accuracy = zeros(1, length(methods));
score = zeros(1, length(methods));
time = zeros(1, length(methods));
X = cell(1, length(methods));
Xraw = cell(1, length(methods));
perform_data = cell(1, length(methods));
scoreGrowth = zeros(1, length(methods));
inlierGrowth = zeros(1, length(methods));



%% star matching

iparam.view(1).fileName = fname1(1:end-4);
iparam.view(1).filePathName = [filepath, fname1];

iparam.view(2).fileName = fname2(1:end-4);
iparam.view(2).filePathName = [filepath, fname2];

iparam.nView = 2;   iparam.bPair = 1;
  

resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
initPathnFile = [ filepath '/' 'fi_' resultTag '.mat' ];

%% make or load INITIAL matches
if exist(initPathnFile) == 2 
    disp ([ 'loading features from' initPathnFile ' and make new matches.']);
    load(initPathnFile);            
    cdata = initialmatch_main_re( iparam, cdata, mparam);
    cdata.bPair = 1;
else
    % initial matching routine
    cdata = initialmatch_main( iparam, fparam, mparam );
    cdata.GT = [];
end
%
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

for i = 1:length(methods)

    if ~aparam.bProgGM % one-shot graph matching
        [ score(i), time(i), X{i}, Xraw{i} ] = wrapper_GM(methods(i), cdata);
    else % progressive graph matching
        [  score(i), time(i), X{i}, Xraw{i}, cand_matchlist, perform_data{i} ]=...
            wrapper_ProgGM( pparam, methods(i), cdata, mparam.extrapolation_dist);
    end

    % Measure accuracy
%     X_GT = extrapolateGT( cdata.view, cand_matchlist, cdata.GT, mparam.extrapolation_dist ); % extrapolate the groundtruths
%     X_EXT = extrapolateMatchIndicator( cdata.view, cand_matchlist, X{i}, mparam.extrapolation_dist ); % extrapolate the solutions                
    
    X_GT = ismember(cand_matchlist, cdata.GT, 'rows')';
    X_EXT =  X{i}';
    
    accuracy(i)  = (X_EXT*X_GT')/nnz(X_GT);

    % Show the score values and visualize the result
    str_out = sprintf('%10s: %d matches- P: %.3f (%d/%d), R: %.3f (%d/%d) (Score:%.1f)'...
         , methods(i).strName, nnz(X_EXT), nnz(X_EXT&X_GT)/nnz(X_EXT),...
         nnz(X_EXT&X_GT), nnz(X_EXT), nnz(X_EXT&X_GT)/nnz(X_GT), nnz(X_EXT&X_GT), nnz(X_GT)...
         , score(i));     
    fprintf('%s\n',str_out);

    if bShowFig
        figure;
        showFeatureMatching(cdata, cand_matchlist, X_EXT, X_GT);
        %pause;  
    end
end

if aparam.bProgGM
    cImg = 1;
    visPerformPlot_ProgGM;
end
        



