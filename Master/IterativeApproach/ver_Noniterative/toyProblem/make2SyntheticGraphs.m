 
%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   G1 = (V,D,E,U)  first graph;  NOTE: D = []
%   G2 = (V,D,E,U) second graph; NOTE: D = [], U = []
%   GT = (LLpairs, HLpairs) ground thruth for matching on each of two
%                           levels

function [G1, G2,GT] = make2SyntheticGraphs()

    rng('default');
    setParameters_synthetic_graphs;
    
    % number of nodes in the first graph
    n1 = nIn;
    % number of nodes in the second graph
    n2 = nIn + nOut;

    G1.V = randn(nIn, 2);       % nIn standard normal distributed numbers
    
    G2.V = [];

    G1.D = [];                  % set of node descriptors of the first graph
    G2.D = [];                  % set of node descriptors of the second graph
    
       
    corr_G1G2 = [];            % correspondences between the nodes
    
    % rotate nodes of the first graphs
    rotMatrix = [cos(aff_transfo_angle) -sin(aff_transfo_angle); ... % rotation matrix
                 sin(aff_transfo_angle)  cos(aff_transfo_angle)]; 
   
    G2.V = aff_transfo_scale * G1.V * rotMatrix + sig*randn(n1, 2); 
    
    % add noise nodes
    G2.V = [G2.V; randn(nOut, 2)];
    assert(size(G2.V,1)==n2);
    

    % correspondences between the nodes of two graphs
    corr_G1G2 = [ [1:nIn]',  [1:nIn]' ];  
    

    % permute graph nodes
    if to_permute
        seq = randperm(n2);
        G2.V(seq,:) = G2.V;        
    else
        seq  = 1:n2;
    end
    
    % Ground Truth
    GT.LLpairs = [corr_G1G2(:,1)  , seq(corr_G1G2(:,2) )'];
    
    
    % Graph edges (kNN-connectivity)                                  
    
    [nodes_kNN, ~] = knnsearch(G1.V(:, 1:2), G1.V(:, 1:2), 'k', minDeg + 1); % nV x (minDeg+1) matrix                   
    nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
    nodes_kNN = reshape(nodes_kNN, n1*minDeg, 1);
    G1.E = [repmat([1:n1]', minDeg, 1) nodes_kNN];

    [nodes_kNN, ~] = knnsearch(G2.V(:, 1:2), G2.V(:, 1:2), 'k', minDeg + 1); % nV x (minDeg+1) matrix                   
    nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
    nodes_kNN = reshape(nodes_kNN, n2*minDeg, 1);
    G2.E = [repmat([1:n2]', minDeg, 1) nodes_kNN];
    

    % shift coordinates of the nodes to plot it nice
    
    N = 5;
    min_x = min([ min(G1.V(:,1)), min(G2.V(:,1)) ]);
    max_x = max([ max(G1.V(:,1)), max(G2.V(:,1)) ]);
    
    min_y = min([ min(G1.V(:,2)), min(G2.V(:,2)) ]);
    max_y = min([ max(G1.V(:,2)), max(G2.V(:,2)) ]);
    
    G1.V(:,1) = 1 + (G1.V(:,1) - min_x) * N / (max_x-min_x);
    G1.V(:,2) = 1 +(G1.V(:,2) - min_y) * N / (max_y-min_y);
    
    G2.V(:,1) = 1 + (G2.V(:,1) - min_x) * N / (max_x-min_x);
    G2.V(:,2) = 1 + (G2.V(:,2) - min_y) * N / (max_y-min_y);
    

end