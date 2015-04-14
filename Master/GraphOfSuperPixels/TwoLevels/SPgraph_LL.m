% Graph of Super Pixels

% Input
% img       given image
% edges     edge points on the image
% descr     descriptors of the edge points
% imgSP = [num, label, boundary] superpixel segemntation of the given image

% Output
% G         Graph of Super Pixels
% imgSP     same structure as in input with colored in black superpixels, that
%           were not used for graph building
% SPrect    rectangles around each used superpixel (#usedSP x 5)
% SPrect_i = [xmin,ymin, width, height, label] 
%           (xmin,ymin) left upper corner of the rectangle

function [ G, imgSP, SPrect ] = SPgraph_LL( img, edges, descr, imgSP, G)

% parameters of the HoG descriptor
s = 9; % size of cells the HoG descriptor
w = 36;  % width of the square region

% list of rectangles around SPs
SPrect = [];        % [x,y, width, height]

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

% labels of super pixel, which contain edge points
Labels = unique(Labels);
nLabels = numel(Labels);

correspondenceMatrix(all(~any(correspondenceMatrix, 2),2), :) = []; % remove zero rows

% compute coordinates of the centers of superpixels, coordinates of graph nodes
% we need the first to find out which SP should be connected

for i = 1:nLabels
    mask_SP = (imgSP.label == Labels(i));  % select one super pixel
    mask_img(mask_SP) = 1;
    
    % max width and height of the selected super pixel
    [SPxy(:,2), SPxy(:,1)] = find(mask_SP); 
    
    SPxmin = min(SPxy(:,1));
    SPymin = min(SPxy(:,2));
    
    max_width  = max(SPxy(:,1)) - SPxmin;   % maximal width of the rectangle around SP
    max_height = max(SPxy(:,2)) - SPymin;   % maximal height of the rectangle around SP
       
    % find edge points inside selected SP
    ind = find(correspondenceMatrix(i,:));
    
    SPrect = [SPrect; single(repmat([SPxmin, SPymin, max_width, max_height, Labels(i)], numel(ind),1))];
    
    AdjM_local = ones(numel(ind));
    AdjM_local = triu(AdjM_local,1);
    [v1,v2] = find(AdjM_local>0);
    E_local = [v1,v2];
    E_local = E_local + size(G.V,1);
    G.E = [G.E; E_local];
    
    G.V = [G.V; edges(1:2,ind)'];
    G.D = [G.D, descr(:,ind)]; 
    
    clear SPxy
    clear xy_hog
end
clear correspondenceMatrix;

assert(size(G.D,2)==size(descr,2), 'Wrong number of nodes in subgraph');

%
% connect super pixel that have a common edge    
n = size(SPrect,1);

% compute distances between "centers" of the super pixels
dist_x = abs( bsxfun(@minus, SPrect(:,1) + 0.5 * SPrect(:,3), SPrect(:,1)' + 0.5 * SPrect(:,3)') );   % n x n difference matrix
dist_y = abs( bsxfun(@minus, SPrect(:,2) + 0.5 * SPrect(:,4), SPrect(:,2)' + 0.5 * SPrect(:,4)') );   % n x n difference matrix

% distances between "centers" of super pixels if they would be neighbors
distR_x = 0.5 * ( diag(SPrect(:,3))*ones(n,n) + double(ones(n,n))*diag(SPrect(:,3)) );
distR_x(1:(n+1):end)= 0;
distR_y = 0.5 * ( diag(SPrect(:,4))*ones(n,n) + ones(n,n)*diag(SPrect(:,4)) );
distR_y(1:(n+1):end)= 0;

% connenct SP if the corresponding rectangels intersect
dist_x = distR_x - dist_x;             
distNeg = dist_x < 0;  %!!!
dist_x(distNeg) = 0;

dist_y = distR_y - dist_y; 
distNeg = dist_y < 0;  %!!!
dist_y(distNeg) = 0;

dist = dist_x .* dist_y;

% [v1,v2] = find(dist>0);
% G.E = [G.E; [v1,v2]];

% % % ------------------------------------------------------------
% figure, imagesc(imgSP.boundary), hold on;
% for v=1:size(SPrect,1)
% %     xmin = SPrect(v,1);
% %     ymin = SPrect(v,2);
% %     rectangle('Position', [xmin, ymin, SPrect(v,3), SPrect(v,4)]);
%     plot(edges(1,:),edges(2,:), 'b*');
% end
% hold on;
% 
% for i=1:size(G.E, 1)
%     line([G.V(G.E(i,1),1) G.V(G.E(i,2),1) ],...
%          [G.V(G.E(i,1),2) G.V(G.E(i,2),2) ], 'Color', 'g');  
% end
% hold off;
% % % ------------------------------------------------------------

% % color super pixel without edge points into black color
% imgSP.label(~mask_img) = -1 ;
% imgSP.boundary(repmat(~mask_img,[1 1 3]) ) = 0;


end

