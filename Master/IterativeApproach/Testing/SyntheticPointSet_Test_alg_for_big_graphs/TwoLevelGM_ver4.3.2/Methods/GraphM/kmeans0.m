function [IDX, centroid, Dis] = kmeans0(X,K)

[IDX, centroid, ~, Dis]= kmeans(X,K, 'emptyaction', 'drop');
