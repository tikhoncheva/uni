% Construction of Higher Level Graph (HLGraph) of a given image
% each of the given superpixels from superpixel segmentation of the image 
% represents a node of HLGraph
% Each node is a center of mass of the edge points inside corresponding 
% superpixel
% Two nodes are connected with an edge if the corresponding superpixels
% have a common edge
%
% Input 
% img     input image
% edges   coordinates of the edge points of the image (2 x nEdgePoints)
% nSuperPixels number of superpixel in the image segmentation
% 
%
% Output
% HLG = (V, D, E) Higher Level Graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
% imgSP     superpixel segmentation of the given image
%   imgSP = (num, labels, boundary)
% SPrect    list of rectangles around each used superpixel (#usedSP x 5)
%   SPrect_i = [x,y, width, height, label] 
%              (x,y) coordinates of the center of the rectangle
%
function [ HLG, imgSP, SP_rect] = buildHLGraph(img, edges, nSuperPixels)

HLG.V = [];   % vertices
HLG.D = [];   % descriptors of the vertices
HLG.E = [];   % edges

% Superpixel segmentation of the entire image
t = tic;
[imgSP.num, ... 
 imgSP.label, ...
 imgSP.boundary] = SLIC_Superpixels(im2uint8(img), nSuperPixels, 20);
display(sprintf('\t Superpixel segmentation took %f sec', toc(t) ));

% Build Graph of Super Pixels given superpixel segmentation
[HLG, imgSP, SP_rect] = SPgraph_HL( img, edges, imgSP, HLG);

end