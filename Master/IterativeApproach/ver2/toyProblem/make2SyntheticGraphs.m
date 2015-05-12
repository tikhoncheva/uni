 
%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   G1 = (V,D,E,U)  first graph;  NOTE: D = []
%   G2 = (V,D,E,U) second graph; NOTE: D = [], U = []
%   AG1 = (V,D,E)  first anchor graph; NOTE: D = []
%   AG2 = (V,D,E) second anchor graph; NOTE: D = []
%   GT = (LLpairs, HLpairs) ground thruth for matching on each of two
%                           levels

function [G1, G2, AG1, AG2, GT] = make2SyntheticGraphs()

    setParameters_synthetic_graphs;
    
    assert(numel(aff_transfo_angle)==nIn2, sprintf('Define rotation angle for each of %d anchors of the first graph', nIn2));
    assert(numel(aff_transfo_scale)==nIn2, sprintf('Define scale factor for each of %d anchors of the first graph', nIn2));

    % number of nodes in the first graph
    n1 = nIn;
    % number of nodes in the second graph
    n2 = nIn + nOut;


    % number of nodes in the first anchor graph
    na1 = nIn2;
    % number of nodes in the second anchor graph
    na2 = nIn2 + nOut2;


    G1.V = randn(nIn, 2);       % nIn standard normal distributed numbers
    
    G2.V = [];

    G1.D = [];                  % set of node descriptors of the first graph
    G2.D = [];                  % set of node descriptors of the second graph
    
    G1.U = false(n1, na1);
    G2.U = false(n2, na2);

    AG1.V = [];
    AG2.V = [];


    AG1.D = [];
    AG2.D = [];
    
    corr_G1G2 = [];
    corr_AG1AG2 = [];
    
    clusters = kmeans(G1.V, nIn2);   % cluster nodes in nIn2 groups % vl_kmeans

    nOut_per_cluster = repmat(floor(nOut/nIn2), 1, nIn2);
    remainder = zeros(1, nIn2);
    remainder(1:mod(nOut,nIn2)) = 1;
    nOut_per_cluster = nOut_per_cluster + remainder;
    
    nOut_per_cluster2 = repmat(floor(nOut2/nIn2), 1, nIn2);
    remainder = zeros(1, nIn2);
    remainder(1:mod(nOut2,nIn2)) = 1;
    nOut_per_cluster2 = nOut_per_cluster2 + remainder;
    

    for i=1:nIn2                     % each group is represented by one anchor node
        
        rotMatrix = [cos(aff_transfo_angle(i)) -sin(aff_transfo_angle(i)); ... % rotation matrix
                     sin(aff_transfo_angle(i))  cos(aff_transfo_angle(i))]; 
        
        ind = find(clusters==i);     % and underlies separate aff.transfo
        len = numel(ind);
        
        
        V = aff_transfo_scale(i) * G1.V(ind,:) * rotMatrix + sigma*randn(len, 2); 
        
        last = size(G2.V,1);   
        n_new_nodes = len + nOut_per_cluster(i);
   
        G2.V = [G2.V; V; randn(nOut_per_cluster(i), 2)];
        G1.U(ind, i) = true;                                                   % ToDo
        corr_G1G2 = [corr_G1G2; [ind,  (last+1 : last + len)' ] ];
        
              
        x = sum(G1.V(ind,1))/ numel(ind);
        y = sum(G1.V(ind,2))/ numel(ind);
        
        a = aff_transfo_scale(i) * [x,y] * rotMatrix + sigma*randn(1, 2);
        
        AG1.V = [AG1.V; [x,y] ];
        AG2.V = [AG2.V; a; randn(nOut_per_cluster2(i), 2)];
        
        G2.U(last+1 : last+n_new_nodes, i+sum(nOut_per_cluster2(1:i-1)): i+sum(nOut_per_cluster2(1:i))) = 1;  % ToDo
        corr_AG1AG2 = [corr_AG1AG2; [size(AG1.V,1), i+sum(nOut_per_cluster2(1:i-1)) ] ];
    end
    
%     AG2.V = [AG2.V; randn(nOut2,2)];

    assert(size(G2.V,1)==n2);
    assert(size(AG2.V,1)==na2);

    % graphs on the lower level have kNN-connectivity                                       

    [nodes_kNN, ~] = knnsearch(G1.V(:, 1:2), G1.V(:, 1:2), 'k', minDeg + 1); % nV x (minDeg+1) matrix                   
    nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
    nodes_kNN = reshape(nodes_kNN, n1*minDeg, 1);
    G1.E = [repmat([1:n1]', minDeg, 1) nodes_kNN];

    [nodes_kNN, ~] = knnsearch(G2.V(:, 1:2), G2.V(:, 1:2), 'k', minDeg + 1); % nV x (minDeg+1) matrix                   
    nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
    nodes_kNN = reshape(nodes_kNN, n2*minDeg, 1);
    G2.E = [repmat([1:n2]', minDeg, 1) nodes_kNN];
         

    % we consider fully connected anchor graphs                             % !!!!!!!!!!!!!!!!!!!!!!!!! 
    v1 = repmat([1:na1]', 1, na1);
    v2 = repmat([1:na1],  na1, 1);
    AG1.E = [v1(:), v2(:)];              

    v1 = repmat([1:na2]', 1, na2);
    v2 = repmat([1:na2],  na2, 1);
    AG2.E = [v1(:), v2(:)];              


    % permute graph nodes
    if to_permute
        seq = randperm(n2);
        G2.V(seq,:) = G2.V;
        
        G2.E(:,1) = seq(G2.E(:,1));
        G2.E(:,2) = seq(G2.E(:,2));
        
        G2.U(seq,:)   = G2.U;
%         seq = seq(1:n1);

        seq2 = randperm(na2);
        AG2.V(seq2,:) = AG2.V;
        AG2.E(:,1) = seq2(AG2.E(:,1));
        AG2.E(:,2) = seq2(AG2.E(:,2));
        
        G2.U(:, seq2) = G2.U;
%         seq2 = seq2(1:na1);
    else
        seq  = 1:n1;
        seq2 = 1:na1;
    end

    % Ground Truth
    GT.LLpairs = [corr_G1G2(:,1)  , seq(corr_G1G2(:,2) )'];
    GT.HLpairs = [corr_AG1AG2(:,1), seq2(corr_AG1AG2(:,2) )'];

    
    % shift coordinates of the nodes to plot it nice
    
    N = 5;
    min_x = min([ min(G1.V(:,1)), min(G2.V(:,1)) ])
    max_x = max([ max(G1.V(:,1)), max(G2.V(:,1)) ])
    
    min_y = min([ min(G1.V(:,2)), min(G2.V(:,2)) ])
    max_y = min([ max(G1.V(:,2)), max(G2.V(:,2)) ])
    
    G1.V(:,1) = 1 + (G1.V(:,1) - min_x) * N / (max_x-min_x);
    G1.V(:,2) = 1 +(G1.V(:,2) - min_y) * N / (max_y-min_y);
    
    AG1.V(:,1) = 1 + (AG1.V(:,1) - min_x) * N / (max_x-min_x);
    AG1.V(:,2) = 1 + (AG1.V(:,2) - min_y) * N / (max_y-min_y);
    
    G2.V(:,1) = 1 + (G2.V(:,1) - min_x) * N / (max_x-min_x);
    G2.V(:,2) = 1 + (G2.V(:,2) - min_y) * N / (max_y-min_y);
    
    AG2.V(:,1) = 1 + (AG2.V(:,1) - min_x) * N / (max_x-min_x);
    AG2.V(:,2) = 1 + (AG2.V(:,2) - min_y) * N / (max_y-min_y);

    
    
end