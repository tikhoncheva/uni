%% Estimation of affine transformation using RANSAC algorithm
% We want to estimate affine transformation between two groups of points
% based on the given matches between points of the sets

% Input
%   V1          fisrt set of points (n1 x 2)
%   V2          fisrt set of points (n2 x 2)
%   matches     list of correspondences between points
%
% Output    
%   group_ind1  n1x1 column vector, that for each point from V1 contains
%               index of a group the point belong to
%   group_ind2  n2x1 column vector, that for each point from V2 contains
%               index of a group the point belong to

function ransac_aff_trafo(V1, V2)



end



function T=affineFit(frames1, frames2)
% x =[m1 m2 m3 m4 t1 t2];
% Number of lines in the matrix A is equal to the number of matched pairs
A = zeros (2*size(frames1, 2) , 6);
b = zeros (2*size(frames1, 2),1);

for i=1:size(frames1, 2)
    A(2*i,:)    = [frames1(1,i) frames1(2,i) 0 0 1 0];
    A(2*i+1,:)  = [0 0 frames1(1,i) frames1(2,i) 0 1];
    b(2*i)      = frames2(1,i);
    b(2*i+1)    = frames2(2,i);
end;
% solve Ax=b using pseduo-inverse
x = pinv(A)*b;

% return matrix T
T = [x(1), x(2), x(5); 
     x(3), x(4), x(6);
        0,    0,    1];
end