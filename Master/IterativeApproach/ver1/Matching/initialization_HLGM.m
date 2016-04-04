 %% Initial correspondence and affinity matrices for higher level graph matching
 %
 %
 
function [corrmatrix, affmatrix] = initialization_HLGM(HLG1, HLG2)

display(sprintf('\n================================================'));
display(sprintf('Initialization for higher level graph matching'));
display(sprintf('=================================================='));

% initial affinity matrix for matching Higher Level Graphs
tic

v1 = HLG1.V';  %2xnV1
v2 = HLG2.V';  %2xnV2

d1 = HLG1.D;   % d x nV1 
d2 = HLG2.D;   % d x nV2
               % d - size of vectorized HoG - descriptor around node

nV1 = size(v1,2);
nV2 = size(v2,2);

% adjacency matrix of the first anchor graph
adjM1 = zeros(nV1, nV1);
E1 = HLG1.E;
E1 = [E1; [E1(:,2) E1(:,1)]];
ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
adjM1(ind) = 1;

% adjacency matrix of the second anchor graph
adjM2 = zeros(nV2, nV2);
E2 = HLG2.E;
E2 = [E2; [E2(:,2) E2(:,1)]];
ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
adjM2(ind) = 1;

% correspondence matrix 
corrmatrix = ones(nV1,nV2);                                                 %  !!!!!!!!!!!!!!!!!!!!!! now: all-to-all

% compute initial affinity matrix
affmatrix = initialAffinityMatrix2(v1, v2, d1, d2, adjM1, adjM2, corrmatrix);
% affmatrix = initialAffinityMatrix3(v1, v2, adjM1, adjM2, HLG1.W, HLG2.W, corrMatrix);

display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));


end