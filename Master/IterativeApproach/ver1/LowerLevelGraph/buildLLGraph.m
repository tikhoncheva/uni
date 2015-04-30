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
% imgSPrect     rectangles around each superpixel from higher level
%               segmentation
% nSP_ll        number of superpixels for the segmentation of an croped image
%
% Output
% LLG = (V, D, E) lower level graph
%       V  coordinates of the vertices
%       D  decriptors of the vertcies (HoG)
%       E  list of the edges
%       U  correspondences between vertices of the G and those of HL graph (anchors)
%          (boolean matrix (n x nA): U[i,j] = 1 if v_i\in V is inside super pixel of A_j
%                                    U[i,j] = 0 otherwise)


function [LLG, imgSP] = buildLLGraph(img, edges, descr, imgSP, imgSPrect, nSP_ll)

V = [];   % vertices
D = [];   % descriptors of the vertices
E = [];   % edges
U = [];   % dependencies between nodes of graphs on two levels

nSP_hl = size(imgSPrect, 1);  % number of nodes in the higher level graph

% figure, imagesc(imgSP.boundary)

for i=1:nSP_hl
    display(sprintf('\t - build %dth Subgraph of Superpixels', i));
    ti = tic;
    
    % rectangle around superpixel i in the higher level segmentation
    xmin = imgSPrect(i,1);
    ymin = imgSPrect(i,2);
    width = imgSPrect(i,3);
    height = imgSPrect(i,4);
    label = imgSPrect(i,5);
    
    rect = [xmin, ymin, width, height];
    
    % crop part of the image inside the rectangle rect
    img_part = imcrop(img, rect);
    
    % select edge points inside selected region
    ind1 = edges(1, :) >= xmin;
    ind2 = edges(1, :) <= xmin + width - 1;
    ind3 = edges(2, :) >= ymin;
    ind4 = edges(2, :) <= ymin + height - 1;
    
    ind = logical(ind1.*ind2.*ind3.*ind4);
        
    % local coordinates of edge points inside selected region
    edges_part = edges(:,ind);
    edges_part(1,:) = edges_part(1,:) - xmin + 1;
    edges_part(2,:) = edges_part(2,:) - ymin + 1;
    descr_part = descr(:,ind);
    
    % superpixel segmentation of the croped image
    t = tic;
    [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img_part), nSP_ll, 20);
    display(sprintf('\t\t Superpixel segmentation took %f sec', toc(t) ));
%
%     figure, imagesc(SP.boundary), hold on;
%     plot(edges_part(1,:),edges_part(2,:), 'b*'), hold off;
    
   % build local Graph of Super Pixels given superpixel segmentation
    subG.V = [];   % vertices
    subG.D = [];   % descriptors of the vertices
    subG.E = [];   % edges
    
    [subG, SP, ~] = SPgraph_LL( img_part, edges_part, descr_part, SP, subG);
    
    % save local superpixel segmentation into global segmentation
    imgSP.boundary(ymin:ymin+height, xmin:xmin+width, :) = SP.boundary;
%     figure, imagesc(imgSP.boundary)
    
    % local matrix of correspondences between edge points in selected
    % region and anchor node of this region
    subG.U = zeros(size(subG.V,1), nSP_hl);
    subG.U(:, i) = 1;
    
    % global coordinates of edge points inside selected region
    subG.V(:,1) = subG.V(:,1) + xmin - 1;
    subG.V(:,2) = subG.V(:,2) + ymin - 1;
    
    if (~isempty(subG.E))
        subG.E(:,1) = subG.E(:,1) + size(V,1);
        subG.E(:,2) = subG.E(:,2) + size(V,1);
    end

    
    % save local parts in global variables
    U = [U; subG.U];   
    V = [V; subG.V];  
    D = [D, subG.D];   
    E = [E; subG.E]; 
   
    display(sprintf('\t   finished in %f sec', toc(ti) ));
    
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

    clear subG;
   
end

% The global matrices V and D may have same repetitions. This can happen,
% because rectangle regions around superpixel (and corr. anchor nodes) in the 
% higher level graph intersect. If there is an edge point inside of such 
% intersection, than it will be arranged to the both anchor nodes and
% repeated in sets V and D

% Delete repetitions: real number of nodes is equal to number of unique
% descriptors
[uniqueD, ia, ic] = unique(D', 'rows');
uniqueD = uniqueD';

newE = E;           % new list od edges
newU = U(ia, :);    % new matrix of correspondenes between nodes and anchor nodes

for i=1:size(V,1)
    j = ic(i);
     
    ind = (E(:,1) == i);
    newE(ind, 1) = j;

    ind = (E(:,2) == i);
    newE(ind, 2) = j;   
    
    newU(j,:) = newU(j,:) + U(i,:);
    
end

LLG.V = V(ia, :);  
LLG.D = uniqueD;   
LLG.E = newE; 
LLG.U = logical(newU); 

end