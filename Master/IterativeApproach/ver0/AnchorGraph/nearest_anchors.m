% for each given point x_i \in X find k nearest anchors
% among given set A
%
% Input: matrix V (n x 2)   coordinates of the original vertices
%        matrix A (m x 2)   coordinates of the anchor points
%
% Output: boolean matrix U (n x m): U[i,j] = 1 if A_j is among k nearest neighbors of the point v_i,
%                                   U[i,j] = 0 otherwise
function U = nearest_anchors(V, A, k)

    n = size(V, 1);
    m = size(A, 1);
    
    U = zeros(n,m);
    
    for i=1:n
       diff = bsxfun(@minus,double(V(i,1:2)),...
                            double(A(:,1:2)));
       dist = sqrt(sum(diff.^2, 2));
       dist = dist./max(dist(:));
       [~,ind] = sort(dist); 
       ind = ind(1:min(k, m));
        
       U(i, ind) = 1;
    end
    
    U = logical(U);

end