%% Parameters of the graphs

nIn  = 500;                       % number of inliers
nOut = 50;                        % number of outliers
edge_den = 1.0;                   % density of edge connections

% Parameters of affine transformation
aff_transfo_scale = 1;          % scale factor
aff_transfo_angle = 0;          % rotation angle
sig = 0.03;                      % deformation

F = 10;                         % multiplication factor to push nodes away from each other    
s = 1000;                       % size of the images, where the graphs will be drawn
b = 50;                         % border on the image boundaries

% Permute nodes in the second graph
bPermute = 1;                 % boolean, permute the nodes of the second graph
bOutBoth = 0;                 %             
bDisplacement = 0;            %
typeDistribution = 'normal';  % distributeion of the nodes
% typeDistribution = 'uniform';  % distributeion of the nodes