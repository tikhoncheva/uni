% Construct lower level graph of a given image based extracted edge points
%
%
% Input 
% img           input image
% edges         coordinates of the edge points of img (2 x nEdgePoints)
% descr         descriptors of the edge points (128 x nEdgePoints)
%
%
% Output
% LLG = (V, D, E, U) lower level graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies 
%       E  list of the edges
%       U  correspondences between vertices of the graph and those of HL graph (anchors)
%       U = [] here !!!!!!

function [LLG] = buildLLGraph(edges, descr)

V = edges(1:2,:)';   % vertices
D = descr;          % descriptors of the vertices
U = [];             % correspondence matrix between nodes of graphs on two levels

nV = size(V,1);

% kNN - graph with given minimal degree minDeg
minDeg = 6;

[nodes_kNN, ~] = knnsearch(V(:, 1:2), ....
                           V(:, 1:2), 'k', minDeg + 1);    % nV x (minDeg+1) matrix                   
nodes_kNN = nodes_kNN(:,2:end); % delete loops in each vertex (first column of the matrix)

nodes_kNN = reshape(nodes_kNN, nV*minDeg, 1);
E = [repmat([1:nV]', minDeg, 1) nodes_kNN];

LLG.V = V;
LLG.D = D;
LLG.E = E;
LLG.U = U;

end