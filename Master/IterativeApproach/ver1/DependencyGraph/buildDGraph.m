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


function G = buildDGraph(img, edges, descr, imgSP)

G.V = [];   % vertices
G.D = [];   % descriptors of the vertices
G.E = [];   % edges

for label=0:imgSP.num-1
   SPxy = (imgSP.label == label);
   if sum(SPxy(:))>0
   
       nV = 30;
       
       img_shadowed = img;
       img_shadowed(repmat(~SPxy,[1 1 3]) ) = 0;

       G2.V = [];   % vertices
       G2.D = [];   % descriptors of the vertices
       G2.E = [];   % edges

       [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img_shadowed), nV, 20);
       
       [G2, ~] = SPgraph( img_shadowed, edges, descr, SP, G2);
       
       G.V = [G.V; G2.V];  
       G.D = [G.D, G2.D];   
       G.E = [G.E; G2.E];   
       
   end
    
end




end