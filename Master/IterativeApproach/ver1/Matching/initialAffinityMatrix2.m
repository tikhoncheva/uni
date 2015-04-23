%% Function to compute initial affinity matrix between two graphs
%
% v1 : 2 x nV1
% v2 : 2 x nV2

% d1: d x nV1
% d2: d x nV2
%
% d - size of vectorized HoG - descriptor around node
%
% AdjM1, AdjM2 adjancency matrices of two graphs
% 


function [D, ratio] = initialAffinityMatrix2(v1, v2, d1, d2, AdjM1, AdjM2, corrMatrix)

nV1 = size(v1,2);
nV2 = size(v2,2);

[L12(:,1), L12(:,2)] = find(corrMatrix);
[ group1, group2 ] = make_group12(L12);

% Conflict Matrix
tic
% conflictMatrix = getConflictMatrix(group1, group2)
conflictMatrix = getConflictMatrix2(group1, group2, AdjM1, AdjM2);
display(sprintf('    Conflict matrix: %f sec', toc));


% Affinity matrix (non-diagonal elements: edge similarity)

G1 = squareform(pdist(v1', 'euclidean'));
G1(~AdjM1) = 0;
sigma1 = sum(G1(:))/nV1/nV1;
G1 = G1./sigma1;

G2 = squareform(pdist(v2', 'euclidean'));
G2(~AdjM2) = 0;
sigma2 = sum(G2(:))/nV2/nV2;
G2 = G2./sigma2;

D = (repmat(G1, nV2, nV2)-kron(G2,ones(nV1))).^2;
D = exp(-D./4.);
D(isnan(D)) = 0;

% Affinity matrix (non-diagonal elements: cosine node similarity)
node_cossimilarity = nodeSimilarity(v1, v2, 'cosine');
D1 = repmat(node_cossimilarity, numel(node_cossimilarity), 1);
D1 = (D1 + D1')/2;

% combine two matrices
D = max(D(:)) - D;
D1 = D1 - D;
D1(D1<0) = 0;
D = D1;


% Affinity matrix (diagonal elements: node similarity)

% node_eusimilarity = nodeSimilarity(d1, d2, 'euclidean');
% D(1:(length(D)+1):end) = node_eusimilarity;

D(1:(length(D)+1):end) = 0;

D = D.*~full(conflictMatrix);

figure, imagesc(D);

end