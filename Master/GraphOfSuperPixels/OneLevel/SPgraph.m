function [ G, imgSP ] = SPgraph( img, edges, descr, imgSP, G)

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
    
    diff_x = abs( bsxfun(@minus, SPxy(:,1), SPxy(:,1)') );
    diff_y = abs( bsxfun(@minus, SPxy(:,2), SPxy(:,2)') );
    
    max_width = max(diff_x(:)); % maximal width of the rectangle around SP
    max_height = max(diff_y(:));% maximal height of the rectangle around SP
    
    SPx = min(SPxy(:,1)) + max_width/2;
    SPy = min(SPxy(:,2)) + max_height/2;
    
    SPrect = [SPrect; [SPx, SPy, max_width, max_height]];
       
    % find edge points inside selected SP
    ind = find(correspondenceMatrix(i,:));

    x = round(sum(edges(1,ind))/numel(ind));
    y = round(sum(edges(2,ind))/numel(ind));
    
    xy_hog = vl_hog( single(imcrop(im2uint8(img),[x-w/2 y-w/2 w w])), s) ;
    
    G.V = [G.V; [x,y]];
    G.D = [G.D, xy_hog]; 
    
    clear SPxy
    clear xy_hog
end
clear correspondenceMatrix;


% % % ------------------------------------------------------------
% % % figure, imagesc(imgSP.boundary), hold on;
% % % for v=1:size(G.V,1)
% % %     x = SPrect(v,1);
% % %     y = SPrect(v,2);
% % %     rectangle('Position', [x-0.5*SPrect(v,3), y-0.5*SPrect(v,4), SPrect(v,3), SPrect(v,4)]);
% % %     plot(x,y, 'b*');
% % % end
% % % hold off;
% % % ------------------------------------------------------------

%
% connect super pixel that have a common edge    
n = size(G.V,1);

% compute distances between "centers" of the super pixels
dist_x = abs( bsxfun(@minus, SPrect(:,1), SPrect(:,1)') );   % n x n difference matrix
dist_y = abs( bsxfun(@minus, SPrect(:,2), SPrect(:,2)') );   % n x n difference matrix

% distances between "centers" of super pixels if they would be neighbors
distR_x = 0.5 * ( diag(SPrect(:,3))*ones(n,n) + ones(n,n)*diag(SPrect(:,3)) );
distR_x(1:(n+1):end)= 0;
distR_y = 0.5 * ( diag(SPrect(:,4))*ones(n,n) + ones(n,n)*diag(SPrect(:,4)) );
distR_y(1:(n+1):end)= 0;

% connenct SP if the corresponding rectangels intersect
dist_x = distR_x - dist_x;             
distNeg = dist_x < 0;
dist_x(distNeg) = 0;

dist_y = distR_y - dist_y; 
distNeg = dist_y < 0;
dist_y(distNeg) = 0;

dist = dist_x .* dist_y;

[v1,v2] = find(dist>0);
G.E = [v1,v2];

% color super pixel without edge points into black color
imgSP.label(~mask_img) = -1 ;
imgSP.boundary(repmat(~mask_img,[1 1 3]) ) = 0;
imgSP.num = nLabels;    % we do not count negative labels


% % save adjacency matrix
% G.adjM = sparse(logical(dist));

% display('size of the adjacency matrix');
% size(G.adjM);


end

function circle(x,y,r)
ang=0:0.01:2*pi; 
xp=r*cos(ang);
yp=r*sin(ang);
plot(x+xp,y+yp, 'LineWidth', 2);
end
