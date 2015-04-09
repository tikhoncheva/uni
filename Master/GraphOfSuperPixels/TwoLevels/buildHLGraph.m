% Construct anchor graph of a given image
% each of the given superpixels from superpixel segmentation of an image 
% represents a node of corresponding higher level graph
% Each node is a center of mass of the edge points inside corresponding 
% superpixel
%
% Input 
% img     input image
% edges   coordinates of the edge points of img (2 x nEdgePoints)
% descr   descriptors of the edge points (128 x nEdgePoints)
% imgSP   super pixels of img  imgSP = (num, labels, boundary)
%
% Output
% HLG = (V, D, E) higher level graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
% imgSP     superpixel segemntation of the given image
% SPrect    rectangles around each used superpixel (#usedSP x 5)
%           SPrect_i = [x,y, width, height, label] 
%                      (x,y) coordinates of the center of the rectangle
function [ HLG, imgSP, SP_rect] = buildHLGraph(img, edges, descr, nSuperPixels)

HLG.V = [];   % vertices
HLG.D = [];   % descriptors of the vertices
HLG.E = [];   % edges

display('Superpixel extraction HLGraph');
tic
[imgSP.num, ... 
 imgSP.label, ...
 imgSP.boundary] = SLIC_Superpixels(im2uint8(img), nSuperPixels, 20);
display('..finished in \n');

% HLG is Graph of Super Pixels of the whole image
[HLG, imgSP, SP_rect] = SPgraph_HL( img, edges, imgSP, HLG);

end