%% Function to compute initial affinity matrix between two graphs
%
% v1 : 2 x nV1
% v2 : 2 x nV2
%
% AdjM1, AdjM2 adjancency matrices of two graphs
% 


function [D, ratio] = initialAffinityMatrix2(v1, v2, AdjM1, AdjM2, corrMatrix)

nV1 = size(v1,2);
nV2 = size(v2,2);

[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);

% conflictMatrix = getConflictMatrix(group1, group2)
conflictMatrix = getConflictMatrix2(group1, group2, AdjM1, AdjM2);

[L1(:,2), L1(:,1)] = find(AdjM1);
[L2(:,2), L2(:,1)] = find(AdjM2);

G1 = v1(:, L1(:,1))-v1(:, L1(:,2));
G2 = v2(:, L2(:,1))-v2(:, L2(:,2));

G1 = sqrt(G1(1,:).^2+G1(2,:).^2);
G2 = sqrt(G2(1,:).^2+G2(2,:).^2);

% distance matrix of the first graph
d1 = zeros(nV1, nV1);
for i=1:size(L1,1)
    d1(L1(i,2), L1(i,1)) = G1(i);
end
sigma1 = sum(d1(:))/nV1/nV1;
d1 = d1./sigma1;

% distance matrix of the second graph
d2 = zeros(nV2, nV2);
for i=1:size(L2,1)
    d2(L2(i,2), L2(i,1)) = G2(i);
end
sigma2 = sum(d2(:))/nV2/nV2;
d2 = d2./sigma2;

% Affinity Matrix
nAffMatrix = size(L12,1);
D = zeros(nAffMatrix);
D1 = zeros(nAffMatrix);
for ia=1:nAffMatrix
    i = L12(ia, 1);
    a = L12(ia, 2);
    for jb=1:nAffMatrix
        j = L12(jb, 1);
        b = L12(jb, 2);
        
        D(ia,jb) = (dotsimilarity(v1(:,i)', v2(:,a)') ...
                 + dotsimilarity(v1(:,j)', v2(:,b)') )/2.;  
        D1(ia,jb) = exp(-(d1(i,j)-d2(a,b))^2/4.);     
    end
end

% D = D1;
D1 = max(D1(:)) - D1;

D = D - D1;
D(find(D<0)) = 0;

D(1:(nAffMatrix+1):end)= zeros(nAffMatrix,1);
D = D.*~full(conflictMatrix);

% figure, imagesc(D)
end