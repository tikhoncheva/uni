function [ G, imgSP ] = SPgraph( img, edges, descr, imgSP, G)

% parameters of the HoG descriptor
s = 9; % size of cells the HoG descriptor
w = 36;  % width of the square region

% Radii of the graph vertices
R = [];

% number of edge points
nEdgePoints = size(edges,2);

% mask of the image to eliminate SP without edge points
mask = false(size(imgSP.boundary(:,:,1)) );

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

% compute centers of superpixels and it' radii
for i = 1:nLabels
    SPxy = (imgSP.label == Labels(i));
    mask(SPxy) = 1;
    
    % find edge points inside selected SP
    ind = find(correspondenceMatrix(i,:));
    
    x = sum(edges(1,ind))/numel(ind);
    y = sum(edges(2,ind))/numel(ind);
    
    xy_hog = vl_hog( single(imcrop(im2uint8(img),[x-w/2 y-w/2 w w])), s) ;
    
    G.V = [G.V; [x,y]];
    G.D = [G.D, xy_hog];
    clear xy_hog
    
    % radius of the super pixel with the center (x,y)
    [sameSP(:,2), sameSP(:,1)] = find(imgSP.label == Labels(i)); 
    diff = bsxfun(@minus,double([x;y]), sameSP(:,1:2)');
    euclid_dist = sqrt(sum(diff.^2)); % sum(abs(diff));
    R = [R; max(euclid_dist(:))];
    
    clear sameSP
end
clear correspondenceMatrix;

%
% connect super pixel that have a common edge    
% !!!!!!!!!!!!!!!!!!! ToDo

n = size(G.V,1);

% compute distance matrix (euclidean distance)
dist = squareform(pdist(G.V, 'euclidean')); % n x n distance matrix

% compute distance matrix (sum of two radii)
distR = diag(R)*ones(n,n) + ones(n,n)*diag(R);
distR(1:(n+1):end)= 0;

dist = distR - dist;  clear distR;          
distNeg = dist<0;
dist(distNeg) = 0;

[v1,v2] = find(dist>0);
G.E = [v1,v2];

% color super pixel without edge point into black color
imgSP.label(~mask) = -1 ;
imgSP.boundary(repmat(~mask,[1 1 3]) ) = 0;

% % save adjacency matrix
% G.adjM = sparse(logical(dist));

% display('size of the adjacency matrix');
% size(G.adjM);


end

