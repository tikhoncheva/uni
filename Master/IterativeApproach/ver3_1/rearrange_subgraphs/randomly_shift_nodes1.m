%% ramdomly shift p percentage of nodes in LLG to the other anchors

% select new anchors randomly
function [U] = randomly_shift_nodes(LLG, HLG, p)

U = HLG.U;

nA = size(HLG.V,1);     % number of anchors
nV = size(LLG.V,1);     % number of nodes

m = round(p*nV);        % number of nodes to shift

V_to_shift_ind = datasample(1:nV, m,'Replace',false)'; %randi([1 nV1], m, 1);
random_anchors = datasample(1:nA, m)'; %randi([1 nA1], m, 1);

U(V_to_shift_ind, :) = 0;

ind = sub2ind(size(U), V_to_shift_ind, random_anchors);
U(ind) = 1;

assert(sum(U(:))==nV, 'Error: by the random shifting of graph nodes, not all nodes were assigned');

% HLG.U = U;
% figure,
% plot_twolevelgraphs([], LLG, HLG, false, false); 

end