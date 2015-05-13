%% Parameters of the graphs

nIn  = 20;                         % number of nodes in the first graph G1 = number of inliers in
                                   % the second graph G2
nOut = 10;                         % number of outliers in the second graph G2

nIn2  = 4;                         % number of nodes in the first anchor graph AG1 = number of 
                                   % inliers in the second anchor graph AG2
nOut2 = 0;                         % number of outliers in the second anchor graph G2

minDeg = 6;                        % minimal degree of nodes in the graphs on lower level

% Parameters of affinity transformation
aff_transfo_angle = [0, 0, 0, 0];          % rotation angles for each of nIn2 groups of nodes
aff_transfo_scale = [1, 1, 1, 1];          % scale factor for each of nIn2 groups of nodes

% Noise
sigma = 0;                       % standard deviation of the noise nodes

% Permute nodes in the second graph
to_permute = true;                 % boolean variable, according to that nodes of the second
                                   % graph will be permuted
