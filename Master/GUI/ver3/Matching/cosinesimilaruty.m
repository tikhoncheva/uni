function [initialMatch, simdot] = cosinesimilaruty( desc1, desc2, kNN )
 
initialMatch = [];
simdot = [];

nMax = min(kNN, size(desc2,2));
% For each descriptor in the first image, select its match to second image.
desc1t = desc1';                          % Precompute matrix transpose
for i = 1:size(desc1,2)
   dotprods = desc1t(i,:) * desc2;        % Computes vector of dot products
   dotprods(:) = dotprods(:)/norm(desc1t(i,:))/norm(desc2(1:end,:));
   [vals,indx] = sort(dotprods,'descend');
   initialMatch = [ initialMatch, indx(1:nMax) ];
   simdot = [ simdot vals(1:nMax) ];
end
