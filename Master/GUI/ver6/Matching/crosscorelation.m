function [initialMatch, simdot] = crosscorelation( desc1, desc2, kNN )
 
initialMatch = [];
simdot = [];

nMax = min(kNN, size(desc2,2));
% For each descriptor in the first image, select its match to second image.
desc1t = desc1';                          % Precompute matrix transpose
for i = 1:size(desc1,2)

   dotprods = (desc1t(i,:)-mean(desc1t(i,:))) ...
            * (desc2(1:end,:)-repmat(mean(desc2(1:end,:)),size(desc2,1),1) );      

   dotprods =   dotprods./std(desc1t(i,:),1);
   dotprods = dotprods./std(desc2(1:end,:),1);
   
   [vals,indx] = sort(dotprods,'descend');
   
   initialMatch = [ initialMatch, indx(1:nMax) ];
   simdot = [ simdot vals(1:nMax) ];
end
