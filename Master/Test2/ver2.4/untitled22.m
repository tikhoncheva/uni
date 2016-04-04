clc; clear all;
% MPM code
addpath(genpath(['..' filesep '..' filesep 'MPM_release_v3']));

nV1 = 3;
nV2 = 4;

matchInfo.match = [[1,1,1,1,2,2,2,2,3,3,3,3];
                   [1,2,3,4,1,2,3,4,1,2,3,4]];
matchInfo.sim = [0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25, 0.25];

v1 = [[0,1,0];
      [0,0,1]];
  
v2 = [[0,1,1,0];
      [0,0,1,1]];

Adj1 = [[0,1,1];[1,0,1];[1,1,0]];

Adj2 = [[0,1,0,1];
        [1,0,1,1];
        [0,1,0,1];
        [1,1,1,0]];

% conflict groups
corrMatrix = zeros(nV1,nV2);
for ii = 1:size(matchInfo.match,2)
    corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
end

[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);


D = initialAffinityMatrix(v1, v2, Adj1, Adj2, matchInfo);

x = MPM(D, group1, group2);
Objective = x'*D * x;

CorrMatrix = zeros(nV1, nV2);
for i=1:size(L12,1)
    CorrMatrix(L12(i,1), L12(i,2)) = x(i);
end    

newCorrMatrix = roundMatrix(CorrMatrix)
