function [IDX, centroid, Dis] = kmeansAlgr(X0, numclust, nonseeds)

% remove seeds
X = X0(nonseeds,:);

% cluster without seeds
[IDX, centroid] = kmeans2(X', numclust);
IDX = IDX';
centroid = centroid';

% make sure at least 2 non-empty clusters
while (length(unique(IDX)) == 1)
	[IDX, centroid, ~, Dis] = kmeans(X, numclust, 'emptyaction', 'drop');
end

% compute distances for seeds and nonseeds
Dis = zeros(size(X0,1), size(centroid,1));
for c = 1:size(centroid,1)
	Dis(:,c) = sum( (X0 -repmat(centroid(c,:), [size(X0,1),1])).^2, 2 );
end
% compute labels for seeds and nonseeds
[~, IDX] = min(Dis,[],2);
