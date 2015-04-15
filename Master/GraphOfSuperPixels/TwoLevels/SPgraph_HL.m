% Graph of Super Pixels (for higher level graph construction)

% Input
% img       given image
% edges     edge points on the image
% imgSP = [num, label, boundary] superpixel segemntation of the given image

% Output
% G = (V,E) Graph of Super Pixels
%    V      each vertex corresponds to one superpixels and represent center
%           of mass of edge points inside the superpixel
%    E      two vertices are connected if corresonding superpixels have a
%           common edge
% imgSP     same structure as in input with colored in black superpixels, that
%           were not used for graph building
% SPrect    rectangles around each used superpixel (#usedSP x 5)
% SPrect_i = [xmin,ymin, width, height, label] 
%           (xmin,ymin) left upper corner of the rectangle

function [ G, imgSP, SPrect ] = SPgraph_HL( img, edges,imgSP, G)

% parameters of the HoG descriptor
s = 9; % size of cells for the HoG descriptor
w = 36;  % width of the square region

% list of rectangles around SPs
SPrect = [];        % [xmin,ymin, width, height, label of SP]

% number of edge points
nEdgePoints = size(edges,2);

% mask of the image to eliminate SP without edge points
mask_img = false(size(imgSP.boundary(:,:,1)) );

% labels of edge points
Labels = [];

% correspondeces between super pixel and edge points
correspondenceMatrix = zeros(imgSP.num, nEdgePoints); 
for i=1:nEdgePoints
    label_i = imgSP.label(edges(2,i), edges(1,i));    
    Labels = [Labels, label_i];
    correspondenceMatrix(label_i + 1, i) = 1;
end
correspondenceMatrix(all(~any(correspondenceMatrix, 2),2), :) = []; % remove zero rows

% list of labels of the super pixel, which contain edge points
Labels = unique(Labels);
nLabels = numel(Labels);


% define rectangle around each superpixel that contain edge points
% compute coordinates of graph nodes

for i = 1:nLabels
    % select one super pixel ( one SP <-> one node )
    mask_SP = (imgSP.label == Labels(i));  
    mask_img(mask_SP) = 1;
    
    % coordinates of the pixels inside selected SP
    [SPxy(:,2), SPxy(:,1)] = find(mask_SP); 
    
    % rectangle around selected SP [xmin,ymin, width, height, label of the SP]
    SPxmin = min(SPxy(:,1));
    SPymin = min(SPxy(:,2));
    
    max_width  = max(SPxy(:,1)) - SPxmin;   % maximal width of the rectangle around SP
    max_height = max(SPxy(:,2)) - SPymin;   % maximal height of the rectangle around SP
    
    SPrect = [SPrect; single([SPxmin, SPymin, max_width, max_height, Labels(i)])];
       
    % list of edge points inside selected SP
    ind = find(correspondenceMatrix(i,:));

    % calculate center of mass of the edge points inside selected SP (new node)
    x = round(sum(edges(1,ind))/numel(ind));
    y = round(sum(edges(2,ind))/numel(ind));
    
    % HoG descriptor around new node of the graph
    xy_hog = vl_hog( single(imcrop(im2uint8(img),[x-w/2 y-w/2 w w])), s) ;
    
    % save node ant it's descriptor
    G.V = [G.V; [x,y]];
    G.D = [G.D, reshape(xy_hog, numel(xy_hog),1)]; % 4x4x31 descriptor
    
    clear SPxy
    clear xy_hog
end
clear correspondenceMatrix;

% At the end |V| = number of superpixels that contain edge points

% % % ------------------------------------------------------------
% figure, imagesc(imgSP.boundary), hold on;
% for v=1:size(G.V,1)
%     xmin = SPrect(v,1);
%     ymin = SPrect(v,2);
%     rectangle('Position', [xmin, ymin, SPrect(v,3), SPrect(v,4)]);
%     plot(x,y, 'b*');
% end
% hold off;
% % % ------------------------------------------------------------

% find out which nodes should be connected:
% two superpixels(nodes) will be conencted of the rectangles around them intersect
n = size(SPrect,1);

% compute distances between centers of the rectangles around superpixels 
dist_x = abs( bsxfun(@minus, SPrect(:,1) + 0.5 * SPrect(:,3), SPrect(:,1)' + 0.5 * SPrect(:,3)') );   % n x n matrix
dist_y = abs( bsxfun(@minus, SPrect(:,2) + 0.5 * SPrect(:,4), SPrect(:,2)' + 0.5 * SPrect(:,4)') );   % n x n matrix

% distnace between centers of the rectangles if they have an common edge
distOfIntersection_x = 0.5 * ( diag(SPrect(:,3))*ones(n,n) + double(ones(n,n))*diag(SPrect(:,3)) );
distOfIntersection_x(1:(n+1):end)= 0; % zeros on the diagonal
distOfIntersection_y = 0.5 * ( diag(SPrect(:,4))*ones(n,n) + ones(n,n)*diag(SPrect(:,4)) );
distOfIntersection_y(1:(n+1):end)= 0; % zeros on the diagonal

% Calculate difference between two ditanes 
dist_x = distOfIntersection_x - dist_x;     
dist_y = distOfIntersection_y - dist_y; 

% Replace negative values with zeros
distNeg = dist_x < 0;  %!!!
dist_x(distNeg) = 0;

distNeg = dist_y < 0;  %!!!
dist_y(distNeg) = 0;

% We are only interested in pairs for which distances in both x and y
% dimensions are not zero
dist = dist_x .* dist_y;

% Find pairs of nodes, that should be connected
[v1,v2] = find(dist>0);
G.E = [v1,v2];

% color super pixel without edge points into black color
imgSP.label(~mask_img) = -1 ;
imgSP.boundary(repmat(~mask_img,[1 1 3]) ) = 0;

end

