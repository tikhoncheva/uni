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
function [ HLG, U] = buildHLGraph(img, nodes, nSuperPixels)

% parameters of the HoG descriptor
s = 9; % size of cells for the HoG descriptor
w = 37;  % width of the square region

HLG.V = [];   % vertices
HLG.D = [];   % descriptors of the vertices
HLG.E = [];   % edges

m = nSuperPixels;

clusters = kmeans(nodes, m);   % cluster nodes in nIn2 groups % vl_kmeans

U = false(size(nodes,1), m);

for i=1:nSuperPixels           
        
    ind = find(clusters==i);     % and underlies separate aff.transfo
    len = numel(ind);
    
    x = sum(nodes(ind,1))/ len;
    y = sum(nodes(ind,2))/ len;
    
    x = max((w-1)/2+1, min(x, size(img,1)-(w-1)/2) );
    y = max((w-1)/2+1, min(y, size(img,2)-(w-1)/2) );
    
    xy_hog = vl_hog( single(imcrop(im2uint8(img),[x-(w-1)/2 y-(w-1)/2 w w])), s) ;
    
    HLG.V = [HLG.V; [x,y]];
    HLG.D = [HLG.D, reshape(xy_hog, numel(xy_hog),1)]; % 4x4x31 descriptor
    
    U(ind, i) = true;  

end

minDeg = 5;
[nodes_kNN, ~] = knnsearch(HLG.V(:, 1:2), HLG.V(:, 1:2), 'k', minDeg + 1); % nV x (minDeg+1) matrix                   
nodes_kNN = nodes_kNN(:,2:end);                                          % delete loops in each vertex
nodes_kNN = reshape(nodes_kNN, m*minDeg, 1);
HLG.E = [repmat([1:m]', minDeg, 1) nodes_kNN];

    

end