% Construct anchor graph of a given image
% each of the given super pixels represent a node of an anchor graph
% anchor node is a center of mass of the edge points inside corresponding 
% super pixel
%
% Input 
% img     input image
% edges   coordinates of the edge points of img (2 x nEdgePoints)
% descr   descriptors of the edge points (128 x nEdgePoints)
% imgSP   super pixels of img  imgSP = (num, labels, boundary)
%
% Output
% AG = (V, D, E, U, Z, W) anchor graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
%       U  correspondences between vertices of the DG and anchor points (logical matrix)
%       Z  regression matrix (weights of the correspondences between vertices of
%           the initial graph DG and anchors)
%       W   weights of the edges}

function [AG, imgSP] = buildAGraph(img, edges, descr, imgSP)
% edges 2x nEdgePoints
% descr 128 x nEdgePoints
% imgSP. boundary
%      . labels

AG.V = [];   % vertices
AG.D = [];   % descriptors of the vertices
AG.E = [];   % edges
AG.U = [];
AG.Z = [];
AG.W = [];


[AG, imgSP] = SPgraph( img, edges, descr, imgSP, AG);


end