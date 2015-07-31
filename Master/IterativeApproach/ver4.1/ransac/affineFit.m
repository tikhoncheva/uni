% Estimate the Transformation matrix T between the images A and B by using
% the SIFT feature based matches.

% Arguments: frames1 and frames2 are here 2xK Matrizen
% Result:   Matrix T is 3x3 Matrix

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