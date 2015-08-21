%% Parameters of the graphs

nIn  = 100;                       % number of inliers
nOut = 50;                         % number of outliers

% Parameters of affine transformation
aff_transfo_scale = 1;          % scale factor
aff_transfo_angle = 0;          % rotation angle
sig = 0.03;                     % deformation

% Permute nodes in the second graph
bPermute = 1;                 % boolean, permute the nodes of the second graph
bOutBoth = 0;                 %             
bDisplacement = 0;            %
typeDistribution = 'normal';  % distributeion of the nodes
% typeDistribution = 'uniform';  % distributeion of the nodes