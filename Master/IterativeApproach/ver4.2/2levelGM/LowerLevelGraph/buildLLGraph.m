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
% LLG = (V, D, E) lower level graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies 
%       E  list of the edges

function [LLG] = buildLLGraph(edges, descr, igparam)

fprintf(' - build lower level graph');     t1 = tic;

V = edges(1:2,:)';   % vertices
D = descr;          % descriptors of the vertices

nV = size(V,1);


if igparam.NNconnectivity % nearest neighbor relations between nodes
    minDeg = igparam.minDeg; %6; % minimal degree of the graph

    [nodes_kNN, ~] = knnsearch(V(:, 1:2), V(:, 1:2), 'k', minDeg + 1);    % nV x (minDeg+1) matrix                   
    nodes_kNN = nodes_kNN(:,2:end); % delete loops in each vertex (first column of the matrix)
    nodes_kNN = reshape(nodes_kNN, nV*minDeg, 1);
    E = [repmat([1:nV]', minDeg, 1) nodes_kNN];
end

if igparam.DelaunayTriang % Delaunay triangulation
    DT = delaunayTriangulation(V);
    E = [DT(:,1), DT(:,2)];
    E = [E; DT(:,2), DT(:,3)];
    E = [E; DT(:,3), DT(:,1)];
end

LLG.V = V;
LLG.D = D;
LLG.E = E;
% % LLG.W = ones(nV,1)*Inf;
% LLG.W = ones(nV,1)*NaN;
fprintf('   finished in %f sec\n', toc(t1));
end