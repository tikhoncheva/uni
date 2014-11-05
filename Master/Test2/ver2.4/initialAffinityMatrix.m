%% Function to compute initial affinity matrix between two graphs
%
%

function D = initialAffinityMatrix(v1, v2, AdjM1, AdjM2, matchInfo)

nV1 = size(v1,2);
nV2 = size(v2,2);
% conflict groups
L12(:,1) = matchInfo.match(1,:).';
L12(:,2) = matchInfo.match(2,:).';
[ group1, group2 ] = make_group12(L12);
conflictMatrix = getConflictMatrix(group1, group2);%2(group1, group2, AdjM1, AdjM2);


[L1(:,2), L1(:,1)] = find(AdjM1);
[L2(:,2), L2(:,1)] = find(AdjM2);

G1 = v1(:, L1(:,1))-v1(:, L1(:,2));
G2 = v2(:, L2(:,1))-v2(:, L2(:,2));

G1 = sqrt(G1(1,:).^2+G1(2,:).^2);
G2 = sqrt(G2(1,:).^2+G2(2,:).^2);

distM1 = zeros(nV1, nV2);
for i=1:size(L1,1)
    distM1(L1(i,2), L1(i,1)) = G1(i);
end    

distM2 = zeros(nV1, nV2);
for i=1:size(L2,1)
    distM2(L2(i,2), L2(i,1)) = G2(i);
end 

nAffMatrix = size(L12,1);
D = zeros(nAffMatrix);
for ia=1:nAffMatrix
    i = L12(ia, 1);
    a = L12(ia, 2);
    for jb=1:nAffMatrix
        j = L12(jb, 1);
        b = L12(jb, 2);
        
        D(ia,jb) = (distM1(i,j)-distM2(a,b))^2;
    end
end

D(1:(nAffMatrix+1):end)=matchInfo.sim;


scale_2D = sum(D(:))/size(find(D(:)>0),1);
D = exp(-(D)./scale_2D);


D = D.*~full(conflictMatrix);

% figure, imagesc(D)
end