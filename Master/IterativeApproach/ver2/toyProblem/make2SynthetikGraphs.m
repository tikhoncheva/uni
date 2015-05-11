 
%% make 2 synthetic graphs for testing graph matching algorithm

function [G1, G2, AG1, AG2] = make2SyntheticGraphs(nIn, nOut, nIn2, nOut2, rotAngle, rotScale, sigmaNoise)

assert(numel(rotAngle)==nIn2, sprintf('Define rotation angle for each of %d anchors of the first graph', nI2));
assert(numel(rotScale)==nIn2, sprintf('Define scale constant for each of %d anchors of the first graph', nI2));

% number of nodes in the first graph
n1 = nIn;
% number of nodes in the second graph
n2 = nIn + nOut;

% construct first graph

G1.V = randn(2, nIn);       % nIn standard normal distributed numbers

G1.D = [];                  % set of node descriptors of the first graph

AdjMatrix1 = ones(n1, n1);  % we consider fully connected graphss           % ToDo
[I, J] = find(AdjMatrix1);
G1.E = [I, J];              % list of edges of the first graph

G1.U = zeros(nIn, nIn2);

% construct anchor graph for the first graph
AG1.V = [];
clusters = kmeans(G1.V, nIn2);   % cluster nodes in nIn2 groups
for i=1:nIn2                     % each group is represented by one anchor node
    ind = find(clusters==i);     % and underlies separate aff.transfo
    
    x = sum(G1.V(ind,1))/ numel(ind);
    y = sum(G1.V(ind,2))/ numel(ind);

    AG1.V = [AG1.V; [x,y] ];
    
    G1.U(ind, i) = 1;
end

G1.U = logical(G1.U);

% construct second graph and corresponding anchor graph

rotMatrix = [cos(rotAngle) -sin(rotAngle); ... % rotation matrix
             sin(rotAngle)  cos(rotAngle)]; 
G2.V = rotMatrix * G1.V * rotScale + sigmaNoise*randn(2, nIn); 
G2.V = [G2.v; randn(2, nOut)];

G2.D = [];                  % set of node descriptors of the second graph

AdjMatrix2 = ones(n2, n2);
[I, J] = find(AdjMatrix2);
G1.E = [I, J];              % list of edges of the second graph





end