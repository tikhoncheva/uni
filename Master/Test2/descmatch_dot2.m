function [ initialMatch, simdot ] = descmatch_dot( desc1, desc2, kNN)

%kNN = 50;

initialMatch = [];
simdot = [];

nMax = min(kNN, size(desc2,2));

for i = 1:size(desc1,2)

   [indx, vals] = knnsearch(desc2', desc1', 'k', nMax);  
   
   initialMatch = [ initialMatch [ i*ones(1,nMax); indx ] ];
   simdot = [ simdot vals ];
end


% [indx, vals] = knnsearch(desc2', desc1', 'k', nMax);  
% initialMatch = indx;
% simdot = vals;

