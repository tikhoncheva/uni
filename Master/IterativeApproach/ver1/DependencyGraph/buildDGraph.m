% Construct dependency graph of a given image
% 
function G = buildDGraph(edges, descr, imgSP)
% edges 2x nEdgePoints
% descr 128 x nEdgePoints
% imgSP. boundary
%      . labels

% G = ((V,D),E) dependency graph
G.V = [];   % vertices
G.D = [];   % descriptors of the vertices
G.E = [];   % edges
% Radii of the graph vertices
R = [];

nEdgePoints = size(edges,2);

% all labels of the image
Labels = unique(imgSP.label);
nLabels = numel(Labels);
Labels = [];

correspondenceMatrix = zeros(nLabels, nEdgePoints);

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
    
    % find edge points inside selected SP
    ind = find(correspondenceMatrix(i,:));
    
    x = sum(edges(1,ind))/numel(ind);
    y = sum(edges(2,ind))/numel(ind);
    
    d = sum(descr(:,ind),2)/size(descr,1);
    
    G.V = [G.V; [x,y]];
    G.D = [G.D, d];
    clear d
    
    % radius of the super pixel with the center (x,y)
    [sameSP(:,2), sameSP(:,1)] = find(imgSP.label == Labels(i)); 
    diff = bsxfun(@minus,double([x;y]), sameSP(:,1:2)');
    cityblock_dist = sqrt(sum(diff.^2)); % sum(abs(diff));
    R = [R; max(cityblock_dist(:))];
    
    clear sameSP
end
clear correspondenceMatrix;

%
% connect super pixel that have a common edge

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

% % save adjacency matrix
% G.adjM = sparse(logical(dist));

% display('size of the adjacency matrix');
% size(G.adjM);


end