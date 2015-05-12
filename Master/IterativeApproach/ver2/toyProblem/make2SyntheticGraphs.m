 
%% make 2 synthetic graphs for testing graph matching algorithm
%
%
% Input
%   nIn         number of nodes in the first graph G1 = number of inliers in
%               the second graph G2
%   nOut        number of outliers in the second graph G2
%   nIn2        number of nodes in the first anchor graph AG1 = number of 
%               inliers in the second anchor graph AG2
%   nOut2       number of outliers in the second anchor graph G2
%   rotAngle    rotation angles for each of nIn2 groups of nodes
%   rotScale    scale factor for each of nIn2 groups of nodes
%   sigmaNoise  standard deviation of the noise nodes
%   to_permute  boolean variable, according to that nodes of the second
%               graph will be permuted
%
% Output
%   G1 = (V,D,E,U)  first graph;  NOTE: D = [], U = []
%   G2 = (V,D,E,U) second graph; NOTE: D = [], U = []
%   AG1 = (V,D,E)  first anchor graph; NOTE: D = []
%   AG2 = (V,D,E) second anchor graph; NOTE: D = []
%   GT = (LLpairs, HLpairs) ground thruth for matching on each of two
%                           levels

function [G1, G2, AG1, AG2, GT] = make2SyntheticGraphs(nIn, nOut, nIn2, nOut2, ...
                                                       rotAngle, rotScale, sigmaNoise, ...
                                                       to_permute)

    assert(numel(rotAngle)==nIn2, sprintf('Define rotation angle for each of %d anchors of the first graph', nIn2));
    assert(numel(rotScale)==nIn2, sprintf('Define scale factor for each of %d anchors of the first graph', nIn2));

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

    AG1.V = [];
    AG2.V = [];


    AG1.D = [];
    AG2.D = [];

    clusters = kmeans(G1.V, nIn2);   % cluster nodes in nIn2 groups

    nOut_per_cluster = repmat(floor(nOut/nIn2), 1, nIn2);
    remainder = zeros(1, nIn2);
    remainder(1:mod(nOut,nIn2)) = 1;
    nOut_per_cluster = nOut_per_cluster + remainder;

    for i=1:nIn2                     % each group is represented by one anchor node
        ind = find(clusters==i);     % and underlies separate aff.transfo

        x = sum(G1.V(ind,1))/ numel(ind);
        y = sum(G1.V(ind,2))/ numel(ind);

        AG1.V = [AG1.V; [x,y] ];

        rotMatrix = [cos(rotAngle(i)) -sin(rotAngle(i)); ... % rotation matrix
                     sin(rotAngle(i))  cos(rotAngle(i))]; 

        V = rotScale(i) * G1.V(ind,:) * rotMatrix + sigmaNoise*randn(numel(ind), 2); 
        G2.V = [G2.V; V; randn(nOut_per_cluster(i), 2)];

        AG2.V = [AG2.V; rotScale(i) * [x,y] * rotMatrix + sigmaNoise*randn(1, 2)];
    end

    AG2.V = [AG2.V; randn(nOut2,2)];

    assert(size(G2.V,1)==n2);
    assert(size(AG2.V,1)==na2);

    % we consider fully connected graphs                                      % !!!!!!!!!!!!!!!!!!!!!!!!! 

    v1 = repmat([1:n1]', 1, n1);    
    v2 = repmat([1:n1],  n1, 1);
    G1.E = [v1(:), v2(:)];              

    v1 = repmat([1:n2]', 1, n2);    
    v2 = repmat([1:n2],  n2, 1);
    G2.E = [v1(:), v2(:)];      

    v1 = repmat([1:na1]', 1, na1);
    v2 = repmat([1:na1],  na1, 1);
    AG1.E = [v1(:), v2(:)];              

    v1 = repmat([1:na1]', 1, na2);
    v2 = repmat([1:na1],  na2, 1);
    AG2.E = [v1(:), v2(:)];              


    % permute graph sequence (prevent accidental good solution)
    if to_permute
        seq = randperm(n2);
        G2.V(seq,:) = G2.V;
        seq = seq(1:n1);

        seq2 = randperm(na2);
        AG2.V(seq2,:) = AG2.V;
        seq2 = seq(1:na1);
    else
        seq  = 1:n1;
        seq2 = 1:na1;
    end

    % Ground Truth
    corrmatrix = zeros(n1, n2);
    for i = 1:n1
        corrmatrix(i,seq(i)) = 1;
    end
    [I,J] = find(corrmatrix);
    GT.LLpairs = [I,J];

    corrmatrix_HL = zeros(na1, na2);
    for i = 1:na1
        corrmatrix_HL(i,seq2(i)) = 1;
    end
    [I,J] = find(corrmatrix_HL);
    GT.HLpairs = [I,J];

end