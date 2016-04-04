%% Match SIFT Descriptors
% The function selects for each descr1(i) at most k nearest descriptors in
% descr2 according to distance between two feature points.
% delta = threshold


function [match, sim] = matchSIFTdescr(descr1, descr2, knn)

    n1 = size(descr1,2);
    n2 = size(descr2,2);

    match = [];
    sim = [];
    matchM = zeros(n1,n2);
    
    descr = [descr1';descr2'];  % (n1+n2) x 128
    distM = squareform(pdist(descr, 'euclidean')); % (n1+n2) x (n1+n2) distance matrix
    distM = distM(1:n1, n1+1:end);

%    thresh = 1.5;
%   threshDistM = distM * thresh;
    
    for i=1:n1

       [vals, ind] = sort(distM(i,:), 'ascend');
       
       match = [match [i*ones(1,knn); ind(1:knn)]];
       sim = [sim vals(ind(1:knn))];
       %matchM(i, ind(1:knn)) = 1;            
       
%        for j=1:n2
%           if (threshDistM(i,j) <= distM(i, setdiff(1:n2, j )) ) 
%               matchM(i,j) = 1;            
%           end
%        end
    end
    
    
end