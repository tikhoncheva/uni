%% MPM code
addpath(genpath(['..' filesep 'MPM_release_v1']));

%% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
addpath(genpath(VLFEAT_Toolbox));

run vl_setup.m

clc;

%% Path to the Dataset

image_path = ['.' filesep 'churchSmall'];
%image_path = ['/home/kitty/Documents/Uni/Master/Databases/SUN/Images/c/church/outdoor/'];



N = 2;
minDeg = 5;
nFeaturePoints = 10;

% peak_thresh = 30;
thresholdlevel = 2;

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nP = zeros(N,1);

% Cell of the adjazent matrices on each image
adjCell = cell(1,N); % nP_i x nP_i

%% Param for feature extraction : model!
fparam.descScale = 1.5;        % scaling factor for descriptor
fparam.patchSize = 31;            % patch size for descriptor
fparam.marginRatio = 0.1;          % ignore the features in this margin length of image ( ratio * min( lx, ly ) )
fparam.nMaxOri = 3;               % maximum num of dominant orientations
fparam.nBO = 8;                % # of SIFT orientation bins  (currently, not used)
fparam.nBP = 4;                % # of SIFT spatial bins (currently, not used)
fparam.bContrastInsenstive = false;
fparam.featExt =  { 'dog_vl', 'mser_vl', 'hes_vl', 'heslap_vl', 'harlap_vl', 'mser_b', 'haraff_b', 'hesaff_b', 'dog_b', 'harlap_b', 'heslap_b' }; % feature types possible
fparam.bFeatExtUse = [ 0         0          1          0             0         0          0          0           0       0            0      ]; % feature types used for *** feature detection! ***
fparam.bFeatScale =  [ 6.0     3.0         6.0        8.0           12.0       1.5        0.75        0.75         2.0      4.0        4.0      ]; % feature types used for *** feature detection! ***
fparam.bEstimateOrientation = false; % estimate dominant orientations or not

 
%% for initial matchin
mparam.kNN = 50;                            % max num of NN matches for EACH feature
mparam.distThres = 0.95;                % threshold value of SIFT distance, when not using, set 0  
mparam.distRatio = 0.0;                % use Lowe's unambiguous NN; when not using, set 0

mparam.bFeatExtUse = fparam.bFeatExtUse;
mparam.nMaxMatch = 5000;                   % max num of initial matches
mparam.thresholdScaleDiff = 1000;            % eliminate matches with large scale diff
mparam.bMatchDistribution = 1;             % 1: best of max num 2: equally distrubuted for each feat type
mparam.selfmatching_dist_thres = 0.03;     % in the case of initial matching within a sigle image, 
                                           % prevent self-matching by distance ratio w.r.t image size
mparam.bReflective = 0;                    % enable reflective matching
mparam.bFilterMatch = 0;                   % filter out overlapping matches (very similar, redundant matchs)
mparam.redundancy_thres = 1.0;             % criterion to filter out overlapping matches (pixel distance)


mparam.extrapolation_dist = 0.01; % not used
