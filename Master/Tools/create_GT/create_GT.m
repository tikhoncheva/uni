% Created by E.Tikhoncheva
% on 07.09.2015
% based on do_demo_CVRP2012.m by Minsu Cho and Kyoung Mu Lee. 

% "Progressive Graph Matching: Making a Move of Graphs via Probabilistic Voting", 
% Proc. Computer Vision and Pattern Recognition (CVPR), 2012. 
% http://cv.snu.ac.kr/research/~ProgGM/
%
% written by Minsu Cho, Seoul National University, Korea
%                      INRIA - WILLOW / ENS, Paris, France
%                      http://www.di.ens.fr/~mcho/ 

clear all; close all; clc;
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
% iparam.dataFolder = './data_demo';
iparam.dataFolder = '/export/home/etikhonc/Documents/Databases/house2/';

switch 1
    %% for the house test sequence
    case 1 
        file_to_load = [iparam.dataFolder, 'house.mat'];
        load(file_to_load); % load data
        listOfModelDataFile = dir([ iparam.dataFolder '/*seq*.png' ]);  
        
        for i = 1:size(listOfModelDataFile,1);
            name{i} = str2double(listOfModelDataFile(i).name(10:end-4));
        end
        [~, ind] =  sort(cell2mat(name));

    %% for the RRWM_exp3    
    case 2 
        listOfModelDataFile = dir([ iparam.dataFolder '/*a.png' ]);  
        ind = (1:size(listOfModelDataFile,1));
end
name = {listOfModelDataFile.name};
name = name(ind);


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
for cImg=2:nModelDataFile
        disp([ '=>>> ' num2str(cImg) '/' num2str(nModelDataFile) ' - processing ' listOfModelDataFile(cImg).name ]);
       %% load FILE names
        iparam.view(1).fileName = name{1}(1:end-4);
        iparam.view(1).filePathName = [ iparam.dataFolder '/' iparam.view(1).fileName '.png'];
        iparam.nView = 1;   iparam.bPair = 1;

        iparam.view(2).fileName = name{cImg}(1:end-4);
        iparam.view(2).filePathName = [ iparam.dataFolder '/' iparam.view(2).fileName '.png'];
        iparam.nView = 2;
                   
        if iparam.bPair
            resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
            initPathnFile = [ iparam.dataFolder '/' 'fi_' resultTag '.mat' ];
        else
            resultTag = [ iparam.view(1).fileName ];
            initPathnFile = [ iparam.dataFolder '/' 'fi_' resultTag '.mat' ];
        end        
        
        if exist('data', 'var')
            F1 = data{1,1};
            F2 = data{1, cImg};
            GT = [(1:size(F1,1))', (1:size(F2,1))'];
        end
        
        
        %% make or load INITIAL matches
        if exist(initPathnFile) == 2 
            disp ([ 'loading features from' initPathnFile ' and make new matches.']);
            load(initPathnFile);            
        end
        
        F{1} = F1;
        F{2} = F2;
        % initial matching routine
        cdata = initialmatch_main( iparam, fparam, mparam, false, F);
        cdata.GT = [];
             
        cdata.GT = assignGT_etikhonc(cdata.view, F1, F2, GT);
        
        fprintf('- computing an affine symmetric transfer errors of %d by %d combination pairs...\n',cdata.nInitialMatches,cdata.nInitialMatches);
        % caculate affinity matrix of initial matches by reprojection error
        cand_matchlist = cell2mat({ cdata.matchInfo.match }');
        [ cdata.distanceMatrix cdata.flipMatrix ] = computeAffineTransferDistanceMEX( cdata.view, cand_matchlist, 0 );
        fprintf('>>> affinity matrix calculation done for %d initial matches.\n', cdata.nInitialMatches);
        save (initPathnFile, 'cdata');
        disp([ initPathnFile ' file saved for initial information']);
end



