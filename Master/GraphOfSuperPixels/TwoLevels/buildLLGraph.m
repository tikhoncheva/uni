% Construct lower level graph of a given image based on the higher level
% graph:
%
% subdivide each initial super pixel in n superpixels, which analog to the
% HL graph represent a nodes of a LL graph
%
% Input 
% img           input image
% edges         coordinates of the edge points of img (2 x nEdgePoints)
% descr         descriptors of the edge points (128 x nEdgePoints)
% imgSP         superpixels of img  imgSP = (num, labels, boundary)
% imgSPrect     rectangles around each superpixel from imgSP
% nSP_ll        number of small superpixels inside given coarse superpixel
%
% Output
% LLG = (V, D, E) lower level graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
%       U  correspondences between vertices of the G and those of HL graph
%          (boolean matrix (n x nA): U[i,j] = 1 if v_i\in V is inside super pixel of A_j
%                                    U[i,j] = 0 otherwise)


function [LLG, imgSP] = buildLLGraph(img, edges, descr, imgSP, imgSPrect, nSP_ll)

LLG.V = [];   % vertices
LLG.D = [];   % descriptors of the vertices
LLG.E = [];   % edges
LLG.U = [];   % dependencies between nodes of graphs on two levels

nSP_hl = size(imgSPrect, 1);  % number of nodes in the higher level graph

% figure, imagesc(imgSP.boundary)

for i=1:nSP_hl
    display(sprintf('build %dth Subgraph of Superpixels', i));
    
    xmin = imgSPrect(i,1);
    ymin = imgSPrect(i,2);
    width = imgSPrect(i,3);
    height = imgSPrect(i,4);
    label = imgSPrect(i,5);
    
    rect = [xmin, ymin, width, height];
    
    % crop part of the image around one coarse superpixel
    img_part = imcrop(img, rect);
    
    % select edges inside selected region
    ind1 = edges(1, :) >= xmin;
    ind2 = edges(1, :) <= xmin + width - 1;
    ind3 = edges(2, :) >= ymin;
    ind4 = edges(2, :) <= ymin + height - 1;
    
    ind = logical(ind1.*ind2.*ind3.*ind4);
        
    % local coordinates of edge points inside selected region
    edges_part = edges(:,ind);
    edges_part(1,:) = edges_part(1,:) - xmin + 1;
    edges_part(2,:) = edges_part(2,:) - ymin + 1;
    descr_part = descr(:,ind4);
    
    % segment the selected part in finer superpixels
    [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img_part), nSP_ll, 20);
    %
%     figure, imagesc(SP.boundary), hold on;
%     plot(edges_part(1,:),edges_part(2,:), 'b*'), hold off;
    
    % build local graph of superpixels for the selected region
    subG.V = [];   % vertices
    subG.D = [];   % descriptors of the vertices
    subG.E = [];   % edges
    
    % build graph
    [subG, SP, ~] = SPgraph_LL( img_part, edges_part, descr_part, SP, subG);
    
    % 
    imgSP.boundary(ymin:ymin+height, xmin:xmin+width, :) = SP.boundary;
%     figure, imagesc(imgSP.boundary)
    
    U = zeros(size(subG.V,1), nSP_hl);
    U(:, i) = 1;
    
    % global coordinates of edge points inside selected region
    subG.V(:,1) = subG.V(:,1) + xmin - 1;
    subG.V(:,2) = subG.V(:,2) + ymin - 1;
    
    subG.E(:,1) = subG.E(:,1) + size(LLG.E,1);
    subG.E(:,2) = subG.E(:,2) + size(LLG.E,1);
    
    % save local parts in global variables
    LLG.U = [LLG.U; U];   
    LLG.V = [LLG.V; subG.V];  
    LLG.D = [LLG.D, subG.D];   
    LLG.E = [LLG.E; subG.E]; 
   
    display('...finished');
    
%     SPxy = (imgSP.label == label);
%    
%    if sum(SPxy(:))>0
%        
%        img_shadowed = img;
%        img_shadowed(repmat(~SPxy,[1 1 3]) ) = 0;
% 
%        [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img_shadowed), nSP_ll, 20);
%        figure, imagesc(SP.label);
%        
%    end
   
end


end