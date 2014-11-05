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

[p,~] = find (cAdjM1);
[i,~] = find(group1(:,p));
j = i;
conflictMatrix(i,j) = true; 


[p,~] = find (cAdjM2);
[i,~] = find(group2(:,p));
j = i;
conflictMatrix(i,j) = true; 


% set the diagonal elements to zero
conflictMatrix(1:size(conflictMatrix,1)+1:end) = false; 
     