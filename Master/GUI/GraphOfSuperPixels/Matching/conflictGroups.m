%% Conflict groups
%
function [ group1, group2 ] = conflictGroups(nV1, nV2, matchInfo)

corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end

[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);

end