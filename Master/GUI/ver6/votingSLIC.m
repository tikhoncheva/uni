function [best_neighbors, vals] = votingSLIC( point, edges, edgeDescr, SP1, SP2, mparam)

% selected point
x = point(1);
y = point(2);
% label of this point
point_label = SP1.label(y,x);


% SP the point belongs to
[SPxy(:,1), SPxy(:,2)] = find(SP1.label == point_label);


% find edge points inside selected SP
ind = [];
for i=1:size(SPxy,1)
    ind = [ind, find(edges{1}(1,:) == SPxy(i,2) & ...
                     edges{1}(2,:) == SPxy(i,1)) ]; 
end

edgeSPxy = edges{1}(1:2,ind);

% find kNN nearest neighbors of edge points inside selected SP
neighborlist = [];
vallist = []; 
    
for j = 1:numel(ind)
    % Euclidian distance between descriptors
    diff = bsxfun(@minus,double(edgeDescr{2}),...
                         double(edgeDescr{1}(:,ind(j))));
    dist = sqrt(sum(diff.^2));
    dist = dist./max(dist(:));
    [val,nnInd] = sort(dist); 

    sim = val(1:mparam.kNN);
    matches = nnInd(1:mparam.kNN);
    
    neighborlist = [neighborlist, matches];
    vallist = [vallist, sim];
end

% coordinates of the nearest neighbors
neighbors_coord = edges{2}(1:2, neighborlist);

% find SP(labels) that contain nearest neighbors
linearInd = sub2ind(size(SP2.label), neighbors_coord(2,:), neighbors_coord(1,:)); 
label_list = SP2.label(linearInd);

% delete multiple SP
unique_labels = unique(label_list);
% calculate votes
votes = zeros(1, numel(unique_labels));
for i = 1:numel(unique_labels)
    votes(i) = numel( find(label_list==unique_labels(i)));
end

% select top kNN candidates
[~, I] = sort(votes, 'descend');
best_votes = unique_labels(I(1:min(mparam.kNN, numel(I))));

best_neighbors_ID = [];
for i = 1:numel(best_votes)    
    best_neighbors_ID = [best_neighbors_ID, find(label_list == best_votes(i) )];
end

best_neighbors = neighborlist(best_neighbors_ID);
vals = vallist (best_neighbors_ID);

end