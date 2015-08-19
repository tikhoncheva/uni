 
%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   G1 = (V,D,E) first graph;  NOTE: D = []
%   G2 = (V,D,E) second graph; NOTE: D = []
%   GT = (LLpairs) ground thruth for matching on each of two
%                           levels

function [img1, img2, G1, G2, GT] = make2SyntheticGraphs(igparam)

    rng('default');
    
    % create two empty images
    s = 6;                                      % size of the images
    img1 = repmat(ones(s,s),1,1,3);
    img2 = repmat(ones(s,s),1,1,3);
    
    
    setParameters_synthetic_graphs;
    n1 = nIn;           % number of nodes in the first graph
    n2 = nIn + nOut;    % number of nodes in the second graph
    
    % rotation matrix
    rotMatrix = [cos(aff_transfo_angle) -sin(aff_transfo_angle); ... 
                 sin(aff_transfo_angle)  cos(aff_transfo_angle)];    
             

    % create first graphs
    G1.V = randn(nIn, 2);       % nIn standard normal distributed numbers
    G1.D = [];                  % set of node descriptors of the first graph
    G1.W = Inf*ones(n1,1);

      
    % create second graphs
    V = aff_transfo_scale * G1.V * rotMatrix + sig*randn(n1, 2); % apply transformation to the nodes of the first graph
    G2.V = [V; randn(nOut, 2)]; % + nOut oitliers
    assert(size(G2.V,1)==n2);
    G2.D = [];                  % set of node descriptors of the second graph
    G2.W = Inf*ones(n2,1);
    
    % permute graph nodes
    if to_permute
        seq = randperm(n2);
        G2.V(seq,:) = G2.V;
    else
        seq  = 1:n2;
    end
    
    
    % Add edges
    G1 = buildLLGraph(G1.V', G1.D, igparam);
    G2 = buildLLGraph(G2.V', G2.D, igparam);
    
%     [nodes_kNN, ~] = knnsearch(G1.V(:, 1:2), G1.V(:, 1:2), 'k', minDeg + 1); % n1 x (minDeg+1) matrix                   
%     nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
%     nodes_kNN = reshape(nodes_kNN, n1*minDeg, 1);
%     G1.E = [repmat([1:n1]', minDeg, 1) nodes_kNN];
% 
%     [nodes_kNN, ~] = knnsearch(G2.V(:, 1:2), G2.V(:, 1:2), 'k', minDeg + 1); % n2 x (minDeg+1) matrix                   
%     nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
%     nodes_kNN = reshape(nodes_kNN, n2*minDeg, 1);
%     G2.E = [repmat([1:n2]', minDeg, 1) nodes_kNN];  

    % Ground Truth
    corr_G1G2 = [[1:n1]', [1:n1]'];
    GT.LLpairs = [corr_G1G2(:,1)  , seq(corr_G1G2(:,2) )'];
    GT.HLpairs = [];
    
    % shift coordinates of the nodes to plot it nicer    
    min_x = min([ min(G1.V(:,1)), min(G2.V(:,1)) ]);
    max_x = max([ max(G1.V(:,1)), max(G2.V(:,1)) ]);
    
    min_y = min([ min(G1.V(:,2)), min(G2.V(:,2)) ]);
    max_y = min([ max(G1.V(:,2)), max(G2.V(:,2)) ]);
    
    G1.V(:,1) = 1 + (G1.V(:,1) - min_x) * (s-1) / (max_x-min_x);
    G1.V(:,2) = 1 +(G1.V(:,2) - min_y) * (s-1) / (max_y-min_y);
    
    G2.V(:,1) = 1 + (G2.V(:,1) - min_x) * (s-1) / (max_x-min_x);
    G2.V(:,2) = 1 + (G2.V(:,2) - min_y) * (s-1) / (max_y-min_y);
    
    
end