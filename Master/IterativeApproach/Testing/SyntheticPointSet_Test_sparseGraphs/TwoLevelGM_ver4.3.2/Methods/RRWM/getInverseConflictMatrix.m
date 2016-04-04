function conflictMatrix = getInverseConflictMatrix(group1, group2)
% get the symmetric conflict matrix from group1 and group2
% group1 = ( # of matches ) by ( # of groups in feat1 )
% group2 = ( # of matches ) by ( # of groups in feat2 )

group = [ group1 group2 ];
nMatch = size(group,1);
conflictMatrix = sparse(true(nMatch,nMatch));
% conflictMatrix = ones(nMatch,nMatch);

for i = 1:size(group,2)
    conflictMatrix(group(:,i),group(:,i)) = false;
end
conflictMatrix(1:size(conflictMatrix,1)+1:end) = true; 

     