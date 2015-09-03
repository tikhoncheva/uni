function [IDX, centroid, Dis] = kmeansAlg(X, numclust)

[IDX, centroid] = kmeans2(X', numclust);
IDX = IDX';
centroid = centroid';
Dis = zeros(size(X,1), size(centroid,2));
for c = 1:numclust
	Dis(:,c) = sum( (X -repmat(centroid(c,:), [size(X,1),1])).^2, 2 );
end
