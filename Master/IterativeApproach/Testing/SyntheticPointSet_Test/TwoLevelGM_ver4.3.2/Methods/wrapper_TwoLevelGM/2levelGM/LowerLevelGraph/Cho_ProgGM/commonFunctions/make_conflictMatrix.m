function [conflictMatrix1 conflictMatrix2] = make_conflictMatrix(matchList)

nMatch = size(matchList,1);

% make sets of unique indexes
featIdx1 = unique(matchList(:,1));
featIdx2 = unique(matchList(:,2)); 

conflictMatrix1 = logical(sparse(nMatch,nMatch));
conflictMatrix2 = logical(sparse(nMatch,nMatch));

for i = 1:length(featIdx1)
    tmp_idx = find(matchList(:,1) == featIdx1(i));
    conflictMatrix1(tmp_idx,tmp_idx) = 1;
end
for i = 1:length(featIdx2)
    tmp_idx = find(matchList(:,2) == featIdx2(i));
    conflictMatrix2(tmp_idx,tmp_idx) = 1;
end