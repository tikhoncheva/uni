%% Parameters for feature extraction
fparam.border = 0;		% border width of the image
% edge detection
fparam.nonMaxSupr_radius = 6;	% radius of the neighborhood (non maximum suppression)
fparam.nonMaxSupr_thr = 0.2;	% threshold (non maximum suppression)

fparam.edges_hightthr = 0.1;   % higher and lower threshold for values of detected edges
fparam.edges_lowthr = 0.025;   %

% SIFT descriptor (keypoint scale for vl_sift is equal (binSize/magnif) see http://www.vlfeat.org/matlab/vl_dsift.html)
fparam.SIFT.binSize = 8;	% size of a spatial bin
fparam.SIFT.magnif = 3;		% magnification factor

%% Parameters for image pyramid
ipparam.nLevels = 1;	% number of levels in the pyramid
ipparam.scalef = 2;	% scale factor

%% Parameters for initial graph construction

igparam.NNconnectivity = 0; 	% connecte each node with its minDeg- nearest neighbors
igparam.minDeg		   = 6; 	% minimal degree of a graph
igparam.DelaunayTriang = 1; 	% Delaunay Triangulation

%% Parameters for 2 Level Graph Matching algorithm

% anchor graphs
agparam.nA = 60;        % number of anchors
agparam.appSizeOfSubgraph = 30;  % approximate number of nodes in one subgraph
agparam.coarsAlg    = {'LEM_coarsen_2', 'HEM_coarsen_2'};
agparam.coarsAlgInd = logical([ 0, 1 ]);

% appearence descriptor of the anchors
agparam.nWordsPerc = 0.4;      % percentage of nodes to be taken into the codebook
% structural descriptor of the anchors
agparam.R = 30;                % radius of the local neighborhood around a node in the initial graphs
agparam.nbins = 50;            % number of bins in the structural descriptor of the

% algorithm
algparam.nMaxIt = 30;           % maximal number of iteration for each level of the image pyramid
algparam.nConst = 3;             % abort, if the matching score didn't change in last nConst iterationss


 
