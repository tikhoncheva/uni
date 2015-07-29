%% Parameters of the graphs

nIn  = 20;                         % number of nodes in the first graph G1 = number of inliers in
                                   % the second graph G2
nOut = 0;                         % number of outliers in the second graph G2

minDeg = 6;                        % minimal degree of nodes in the graphs on lower level


% Parameters of affine transformation
aff_transfo_angle = 0;          % rotation angle
aff_transfo_scale = 1;          % scale factor

% Noise
sig = 0;                       % standard deviation of the noise nodes

% Permute nodes in the second graph
to_permute = true;                 % boolean variable, according to that nodes of the second
                                   % graph will be permuted
