clc; clear all;
% MPM code
addpath(genpath(['..' filesep '..' filesep 'MPM']));

nV1 = 3;
nV2 = 3;

matchInfo.match = [[1,1,2,2,3,3,3];[1,2,1,2,1,2,3]];
matchInfo.sim = [0.4, 0.6, 0.8, 0.2, 0.6, 0.2, 0.2];

v1 = [[0,1,0];[0,0,1]];
v2 = [[0,1,1];[0,0,1]];

Adj1 = [[0,1,1];[1,0,1];[1,1,0]];
Adj2 = [[0,0,1];[0,0,1];[1,1,0]];

% conflict groups
L12(:,1) = matchInfo.match(1,:).';
L12(:,2) = matchInfo.match(2,:).';
[ group1, group2 ] = make_group12(L12);
conflictMatrix = getConflictMatrix2(group1, group2, Adj1, Adj2);

% nAffMatrix = nnz(E12);
nAffMatrix = size(matchInfo.match, 2);

[L1(:,2), L1(:,1)] = find(Adj1);

[L2(:,2), L2(:,1)] = find(Adj2);

G1 = v1(:, L1(:,1))-v1(:, L1(:,2));
G2 = v2(:, L2(:,1))-v2(:, L2(:,2));

G1 = sqrt(G1(1,:).^2+G1(2,:).^2);
G2 = sqrt(G2(1,:).^2+G2(2,:).^2);

d1 = zeros(nV1, nV2);
for i=1:size(L1,1)
    d1(L1(i,2), L1(i,1)) = G1(i);
end    

d2 = zeros(nV1, nV2);
for i=1:size(L2,1)
    d2(L2(i,2), L2(i,1)) = G2(i);
end 

% repmat(G1, nV2, nV2)
% kron(G2,ones(nV1))
% M = (repmat(G1, nV2, nV2)-kron(G2,ones(nV1)) ).^2;

nAffMatrix = size(L12,1);
D = zeros(nAffMatrix);
for ia=1:nAffMatrix
    i = L12(ia, 1);
    a = L12(ia, 2);
    for jb=1:nAffMatrix
        j = L12(jb, 1);
        b = L12(jb, 2);
        
        D(ia,jb) = (d1(i,j)-d2(a,b))^2;
    end
end

D(1:(nAffMatrix+1):end)=matchInfo.sim;

scale_2D = sum(D(:))/size(find(D(:)>0),1);
D = exp(-(D)./scale_2D);

D = D.*~full(conflictMatrix)

D = initialAffinityMatrix(v1, v2, Adj1, Adj2, matchInfo)

x = MPM(D, group2, group1);
Objective = x'*D * x;

CorrMatrix = zeros(nV1, nV2);
for i=1:size(L12,1)
    CorrMatrix(L12(i,2), L12(i,1)) = x(i);
end    

newCorrMatrix = roundMatrix(CorrMatrix)
