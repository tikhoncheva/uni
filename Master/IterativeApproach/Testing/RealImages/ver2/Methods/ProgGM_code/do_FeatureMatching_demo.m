% MATLAB demo code of Reweighted Random Walks Graph Matching of ECCV 2010
% 
% Minsu Cho, Jungmin Lee, and Kyoung Mu Lee, 
% Reweighted Random Walks for Graph Matching, 
% Proc. European Conference on Computer Vision (ECCV), 2010
% http://cv.snu.ac.kr/research/~RRWM/

%% Rwrite by E.Tikhoncheva on 07.09 to and save GT for the given sequenxe

%% MATLAB demo code for image matching by graph matching algorithms
close all; clear all; clc;
setPath;    % path addition code goes here
setMethods; % algorithms go here (for comparison)

addpath('./utils_FM')

%% Options & parameters for experiment
bDisplayMatching = 0;            % Display image feature matching results or not
extrapolate_thres = 15;          % Extrapolation of matches for flexible evaluation
affinity_max = 50;               % maximum value of affinity 
matchDataPath = '../../data/houseSmall/';  % Path for 'mat' files

%% Storage for Matching Results
fileList = dir([matchDataPath '*.mat']);      % Load all 'mat' files
accuracy = zeros(length(fileList), nMethods); % Matching accuracy
score = zeros(length(fileList), nMethods);    % Objective score
time = zeros(length(fileList), nMethods);     % Running time
X = cell(length(fileList), nMethods);         % Soft assignment
Xraw = cell(length(fileList), nMethods);      % Hard assignment

%% Image Matching Loop
for cImg = 1:length(fileList)
    clear cdata GT; close all
    %% Load match data (cdata)
    matchDataPathnFile = [matchDataPath fileList(cImg).name];
    disp ([matchDataPathnFile ' file loading.']); load(matchDataPathnFile);
    
    %% Perform MATCHING
    % Make affinity matrix
    cdata.affinityMatrix = max(affinity_max - cdata.distanceMatrix,0); % dissimilarity -> similarity conversion
    %cdata.affinityMatrix = exp(-cdata.distanceMatrix/25); % dissimilarity -> similarity conversion
    cdata.affinityMatrix(1:(length(cdata.affinityMatrix)+1):end) = 0; % diagonal zeros
    % Extrapolate the given ground truths for flexible evaluation
    cdata.GTbool = extrapolateGT(cdata.view, cell2mat({cdata.matchInfo.match}'), cdata.GT, extrapolate_thres)';
    cdata.extrapolate_thres = extrapolate_thres;
    % Algorithm evaluation
    for cMethod = 1:nMethods
        [accuracy(cImg,cMethod) score(cImg,cMethod) time(cImg,cMethod) X{cImg,cMethod} Xraw{cImg,cMethod}] ... 
            = wrapper_FM(methods(cMethod), cdata);
        % Display feature matching results
        if bDisplayMatching
            str = [methods(cMethod).strName ...
                   '  Accuracy: ' num2str(accuracy(cImg, cMethod)) ...
                   ' (' num2str(accuracy(cImg,cMethod)*sum(cdata.GTbool)) '/' num2str(sum(cdata.GTbool)) ')'...
                   '  Score: ' num2str(score(cImg, cMethod)) ];
            figure('NumberTitle', 'off', 'Name', str);
            displayFeatureMatching(cdata, X{cImg,cMethod}, cdata.GTbool);
        end
    end
    if bDisplayMatching, drawnow; if cImg ~= length(fileList), pause; end; end       
end
%% Calculate performance
% Average of accuracy
meanAccuracy = 100*mean(accuracy); % avg. of (# of correct match) / (# of GT match)
% Average of relative score
maxScore = max(score,[],2); relScore = score./repmat(maxScore, 1, nMethods);
meanScore = 100*mean(relScore); % avg. of relative score
% Average of time
meanTime = mean(time); % avg. of computation time
%% Display
fprintf('---------------------------------------------------\n');
fprintf('|%10s\t\tAccuracy(%%)\tScore(%%)\tTime(s)   |\n', 'Methods');
for cMethod = 1:nMethods
    fprintf('|%10s\t\t%3.2f\t\t%3.2f\t\t%3.2f      |\n', ...
        methods(cMethod).strName, meanAccuracy(cMethod), meanScore(cMethod), meanTime(cMethod));
end
fprintf('---------------------------------------------------\n');
