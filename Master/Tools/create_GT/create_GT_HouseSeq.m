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

%% set input and output data
iparam.bShow = false;  % show detected features and initial matches ( it can takes long... )  
% iparam.dataFolder = './data_demo';
iparam.inputDataFolder = '/export/home/etikhonc/Documents/Databases/house2/';
iparam.outputDataFolder = '/export/home/etikhonc/Documents/GIT/uni/Master/data/houseSmall/GT_all_to_all/';

switch 1
    %% for the house test sequence
    case 1 
        file_to_load = [iparam.inputDataFolder, 'house.mat'];
        load(file_to_load); % load data
        listOfModelDataFile = dir([ iparam.inputDataFolder '/*seq*.png' ]);  
        
        for i = 1:size(listOfModelDataFile,1);
            name{i} = str2double(listOfModelDataFile(i).name(10:end-4));
        end
        [~, ind] =  sort(cell2mat(name));

    %% for the RRWM_exp3    
    case 2 
        listOfModelDataFile = dir([ iparam.inputDataFolder '/*a.png' ]);  
        ind = (1:size(listOfModelDataFile,1));
end
name = {listOfModelDataFile.name};
name = name(ind);


nModelDataFile = size(listOfModelDataFile,1);
nTestDataFile = nModelDataFile;
fprintf('Input: %d reference images\n', nModelDataFile);

%% main loop start
for gap = (10:10:110)
    disp([ '=>>> actual gap ', num2str(gap)]);
    for nPairs = 1:min(nModelDataFile-gap,10)
        
            nimg1 = nPairs;
            nimg2 = nimg1+gap;    
            disp([ '=>>> house.seq.' num2str(nimg1) '_vs_house.seq.' num2str(nimg2) ' - processing ']);
            
           %% load FILE names
            iparam.view(1).fileName = name{nimg1}(1:end-4);
            iparam.view(1).filePathName = [ iparam.inputDataFolder '/' iparam.view(1).fileName '.png'];
            iparam.nView = 1;   iparam.bPair = 1;

            iparam.view(2).fileName = name{nimg2}(1:end-4);
            iparam.view(2).filePathName = [ iparam.inputDataFolder '/' iparam.view(2).fileName '.png'];
            iparam.nView = 2;

            if iparam.bPair
                resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
                initPathnFile = [ iparam.outputDataFolder '/' 'fi_' resultTag '.mat' ];
            else
                resultTag = [ iparam.view(1).fileName ];
                initPathnFile = [ iparam.outputDataFolder '/' 'fi_' resultTag '.mat' ];
            end        

            if exist('data', 'var')
                F1 = data{1, nimg1};
                F2 = data{1, nimg2};
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
            
            cdata = rmfield(cdata, 'matchInfo');
            cdata = rmfield(cdata, 'overlapMatrix'); 
            cdata = rmfield(cdata, 'nInitialMatches'); 

            save (initPathnFile, 'cdata');
            disp([ initPathnFile ' file saved for initial information']);
    end
end


