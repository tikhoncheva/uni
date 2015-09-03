%% Make test problem
function [ problem] = makePointMatchingProblem( Set )

%% Get values from structure
strNames = fieldnames(Set);
for i = 1:length(strNames), eval([strNames{i} '= Set.' strNames{i} ';']); end
%% Set number of nodes
if bOutBoth, nP1 = nInlier + nOutlier; else nP1 = nInlier; end
nP2 = nInlier + nOutlier;
%% Generate Nodes
switch typeDistribution
    case 'normal', P1 = F*randn(2, nP1); Pout = F*randn(2,nOutlier); % Points in Domain 1
    case 'uniform', P1 = F*rand(2, nP1); Pout = F*rand(2,nOutlier); % Points in Domain 1
    otherwise, disp(''); error('Insert Point Distribution');
end
% point transformation matrix
Mrot = [cos(transRotate) -sin(transRotate) ; sin(transRotate) cos(transRotate) ];
P2 = Mrot*P1*transScale+deformation*F*randn(2,nP1); % Points in Domain 2
if bOutBoth, P2(:,(nInlier+1):end) = Pout; else P2 = [P2 Pout]; end
% permute graph sequence (prevent accidental good solution)
if bPermute, seq = randperm(nP2); P2(:,seq) = P2; seq = seq(1:nP1); else seq = 1:nP1; end
%0
P1 = P1'; P2 = P2';


%% Create two initial (lower level) graphs (Changes E.Tikhonc)
E1 = ones(nP1); %E1(1:size(E1,1)+1:end) = 0;
[L1(:,1), L1(:,2)] = find(E1);
L1 = unique(sort(L1,2), 'rows');  % delete same edges

% omit (1-edgeDen)% of edges
nOmit1 = round(nP1*(nP1-1)*(1-edge_den)/2); 
ind_omit1 = datasample(1:size(L1,1), nOmit1, 'Replace',false)';
E1(sub2ind([nP1, nP1], L1(ind_omit1,1), L1(ind_omit1,2))) = 0;
E1(sub2ind([nP1, nP1], L1(ind_omit1,2), L1(ind_omit1,1))) = 0;
L1(ind_omit1,:) = [];

E2 = ones(nP2); %E2(1:size(E2,1)+1:end) = 0;
[L2(:,1), L2(:,2)] = find(E2);
L2 = unique(sort(L2,2), 'rows');  % delete same edges

% omit (1-edgeDen)% of edges
nOmit2 = round( nP2*(nP2-1)*(1-edge_den)/2); 
ind_omit2 = datasample(1:size(L2,1), nOmit2, 'Replace',false)';
E2(sub2ind([nP2, nP2], L2(ind_omit2,1), L2(ind_omit2,2))) = 0;
E2(sub2ind([nP2, nP2], L2(ind_omit2,2), L2(ind_omit2,1))) = 0;
L2(ind_omit2,:) = [];

LLG1 = struct('V', P1,'D', [], 'E', L1, 'W', Inf*ones(nP1,1));
LLG2 = struct('V', P2,'D', [], 'E', L2, 'W', Inf*ones(nP2,1));

clear L1; clear L2;

%% 2nd Order Matrix
E12 = ones(nP1,nP2);
n12 = nnz(E12);
[L12(:,1), L12(:,2)] = find(E12);
[group1, group2] = make_group12(L12);

%%
% E1f = ones(nP1); E2f = ones(nP2);
% [L1(:,1), L1(:,2)] = find(E1f);
% [L2(:,1), L2(:,2)] = find(E2f);
% [L1(:,1), L1(:,2)] = find(E1);
% [L2(:,1), L2(:,2)] = find(E2);
% [L1(:,1), L1(:,2)] = find(E1);
% [L2(:,1), L2(:,2)] = find(E2);
% 
% G1 = P1(L1(:,1),:)-P1(L1(:,2),:);
% G2 = P2(L2(:,1),:)-P2(L2(:,2),:);

% %%
% 
% if bDisplacement
%     G1_x = reshape(G1(:,1), [nP1 nP1]);
%     G1_y = reshape(G1(:,2), [nP1 nP1]);
%     G2_x = reshape(G2(:,1), [nP2 nP2]);
%     G2_y = reshape(G2(:,2), [nP2 nP2]);
%     M = (repmat(G1_x, nP2, nP2)-kron(G2_x,ones(nP1))).^2 + (repmat(G1_y, nP2, nP2)-kron(G2_y,ones(nP1))).^2;
% else
%     G1 = sqrt(G1(:,1).^2+G1(:,2).^2);
%     G2 = sqrt(G2(:,1).^2+G2(:,2).^2);
%     G1 = reshape(G1, [nP1 nP1]);
%     G2 = reshape(G2, [nP2 nP2]);
%     M = (repmat(G1, nP2, nP2)-kron(G2,ones(nP1))).^2;
% end
% 
% M = exp(-M./scale_2D);
% M(1:(n12+1):end)=0;

%% Ground Truth
GT.seq = seq;
GT.matrix = zeros(nP1, nP2);
for i = 1:nP1, GT.matrix(i,seq(i)) = 1; end
GT.bool = GT.matrix(:);

corr = [(1:100)', seq'];
GT.optscore = matching_score_LL(LLG1, LLG2, corr);

%% Return the value
problem.nP1 = nP1;
problem.nP2 = nP2;
% problem.P1 = P1;
% problem.P2 = P2;
% problem.L12 = L12;
% problem.E12 = E12;

%
problem.A = E1;
problem.B = E2;
problem.s = 2;  % number of seeds

%
problem.FAQ_nIt = 10;
% problem.affinityMatrix = M;
% problem.group1 = group1;
% problem.group2 = group2;

problem.GTbool = GT.bool;
problem.GToptscore = GT.optscore;

%% new
problem.LLG1 = LLG1;
problem.LLG2 = LLG2;

end
