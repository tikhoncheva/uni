% Given an image construct graph of super pixel for it
% 
function [G, imgSP] = buildGraph(img, edges, descr, nSuperPixels)
% edges 2x nEdgePoints
% descr 128 x nEdgePoints
% imgSP. boundary
%      . labels

% G = ((V,D),E) dependency graph
G.V = [];   % vertices
G.D = [];   % descriptors of the vertices
G.E = [];   % edges


[imgSP.num, ... 
 imgSP.label, ...
 imgSP.boundary] = SLIC_Superpixels(im2uint8(img), nSuperPixels, 20);

[G, imgSP] = SPgraph(img, edges, descr, imgSP, G);

end