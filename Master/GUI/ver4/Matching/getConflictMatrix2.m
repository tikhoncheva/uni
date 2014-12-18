function conflictMatrix = getConflictMatrix2(group1, group2, AdjM1, AdjM2)
% get the symmetric conflict matrix from group1 and group2
% group1 = ( # of matches ) by ( # of groups in feat1 )
% group2 = ( # of matches ) by ( # of groups in feat2 )

group = [ group1 group2 ];
nMatch = size(group,1);

conflictMatrix = zeros(nMatch,nMatch);

for i = 1:size(group,2)
    conflictMatrix(group(:,i),group(:,i)) = true;
end

% complement of AdjMi (diagonal elements setted to zero)
cAdjM1 = ~full(AdjM1);
cAdjM1(1:size(cAdjM1,1)+1:end) = false; 

cAdjM2 = ~full(AdjM2);
cAdjM2(1:size(cAdjM2,1)+1:end) = false;

[x,y] = find (cAdjM1);
for l=1:size(x,1)
    [i,~] = find(group1(:,x(l)));
    [j,~] = find(group1(:,y(l)));
    [X,Y] = meshgrid(i,j);
    conflictMatrix(X(:),Y(:)) = true; 
end


[x,y] = find (cAdjM2);
for l=1:size(x,1)
    [i,~] = find(group2(:,x(l)));
    [j,~] = find(group2(:,y(l)));
    [X,Y] = meshgrid(i,j);
    conflictMatrix(X(:),Y(:)) = true; 
end

% set the diagonal elements to zero
conflictMatrix(1:size(conflictMatrix,1)+1:end) = false; 
     