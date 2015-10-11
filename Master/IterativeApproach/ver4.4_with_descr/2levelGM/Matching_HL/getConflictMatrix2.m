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

[x1,y1] = find (cAdjM1);
for i=1:size(x1,1)
    conflict = double(group1(:,x1(i))) * double(group1(:,y1(i))');
    conflictMatrix = conflictMatrix | conflict;
end


[x2,y2] = find (cAdjM2);
for i=1:size(x2,1)
    conflict = double(group2(:,x2(i))) * double(group2(:,y2(i))');
    conflictMatrix = conflictMatrix | conflict;
end

% set the diagonal elements to zero
conflictMatrix(1:size(conflictMatrix,1)+1:end) = false; 
     