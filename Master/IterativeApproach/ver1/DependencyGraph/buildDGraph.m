% Construct dependency graph of a given image
% subdivide each initial super pixel in n superpixels, which analog to the
% anchor graph represent a nodes of a fine graph
%
% Input 
% img     input image
% edges   coordinates of the edge points of img (2 x nEdgePoints)
% descr   descriptors of the edge points (128 x nEdgePoints)
% imgSP   super pixels of img  imgSP = (num, labels, boundary)
% m       m_i is the number of small super pixels inside given superpixel i
%
% Output
% DG = (V, D, E) dependency graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
% U     boolean matrix (n x nA): U[i,j] = 1 if v_i is inside super pixel of A_j
%                                U[i,j] = 0 otherwise


function [G, U] = buildDGraph(img, edges, descr, imgSP, m)

G.V = [];   % vertices
G.D = [];   % descriptors of the vertices
G.E = [];   % edges

nA = imgSP.num;
n = sum(m(:));

s = 1;

U = zeros(n, nA);

for label=0:imgSP.num-1
    
   SPxy = (imgSP.label == label);
   
   if sum(SPxy(:))>0
       
       nV = m(label + 1);
       
       img_shadowed = img;
       img_shadowed(repmat(~SPxy,[1 1 3]) ) = 0;
       
%        figure, imagesc(img_shadowed);

       [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img_shadowed), nV, 20);
       
       U( s : s+nV - 1, label + 1) = 1;
%        figure, imagesc(SP.boundary);
       
       subG.V = [];   % vertices
       subG.D = [];   % descriptors of the vertices
       subG.E = [];   % edges
       
       [subG, ~] = SPgraph( img_shadowed, edges, descr, SP, subG);
       
       G.V = [G.V; subG.V];  
       G.D = [G.D, subG.D];   
       G.E = [G.E; subG.E];   
       
       s = s + nV;
   end
   
end




end