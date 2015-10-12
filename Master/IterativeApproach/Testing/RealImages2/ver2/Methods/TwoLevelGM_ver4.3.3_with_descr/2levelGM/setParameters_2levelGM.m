%% Parameters for feature extraction
fparam_2lGM.border = 0;		% border width of the image
% edge detection
fparam_2lGM.nonMaxSupr_radius = 6;	% radius of the neighborhood (non maximum suppression)
fparam_2lGM.nonMaxSupr_thr = 0.2;	% threshold (non maximum suppression)

fparam_2lGM.edges_hightthr = 0.1;   % higher and lower threshold for values of detected edges
fparam_2lGM.edges_lowthr = 0.025;   %

% SIFT descriptor (keypoint scale for vl_sift is equal (binSize/magnif) see http://www.vlfeat.org/matlab/vl_dsift.html)
fparam_2lGM.SIFT.binSize = 8;	% size of a spatial bin
fparam_2lGM.SIFT.magnif = 3;		% magnification factor

%% Parameters for image pyramid
ipparam_2lGM.nLevels = 1;	% number of levels in the pyramid
ipparam_2lGM.scalef = 2;	% scale factor

%% Parameters for initial graph construction

igparam_2lGM.NNconnectivity = 0; 	% connecte each node with its minDeg- nearest neighbors
igparam_2lGM.minDeg  = 6; 		% minimal degree of a graph
igparam_2lGM.DelaunayTriang = 0; 	% Delaunay Triangulation
igparam_2lGM.Complete       = 1; 	% Delaunay Triangulation

%% Parameters for 2 Level Graph Matching algorithm

% anchor graphs
% agparam.nA = 60;        % number of anchors
agparam_2lGM.appSizeOfSubgraph = 30;  % approximate number of nodes in one subgraph
agparam_2lGM.grid_nr = 2;      % number of rows in a grid over a graph
agparam_2lGM.grid_nc = 2;      % number of columns -//- 
                          % #subgraphs = grid_nr x grid_nc
agparam_2lGM.ncand = 3;        % number of candidate matches of each anchor

agparam_2lGM.coarsAlg    = {'LEM_coarsen_2', 'HEM_coarsen_2'};
agparam_2lGM.coarsAlgInd = logical([ 0, 1 ]);

% appearence descriptor of the anchors
agparam_2lGM.nWordsPerc = 0.4;      % percentage of nodes to be taken into the codebook
% structural descriptor of the anchors
agparam_2lGM.R = 30;                % radius of the local neighborhood around a node in the initial graphs
agparam_2lGM.nbins = 50;            % number of bins in the structural descriptor of the

% algorithm
algparam_2lGM.nMaxIt = 15;           % maximal number of iteration for each level of the image pyramid
algparam_2lGM.nConst = 3;            % abort, if the matching score didn't change in last nConst iterationss


 
