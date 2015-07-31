%% ramdomly shift p percentage of nodes in LLG to the other anchors

% select next nearest anchor

function [U1, U2, v1_ind, v2_ind] = randomly_shift_nodes(LLG1, LLG2, HLG1, HLG2, ...
                                         LLGmatches, HLGmatches)

U1 = HLG1.U;
U2 = HLG2.U;

nA1 = size(HLG1.V,1);     % number of anchors
nV1 = size(LLG1.V,1);     % number of nodes in the first graph
nV2 = size(LLG1.V,1);     % number of nodes in the second graph

nMatchedNodes = size(LLGmatches,1);

sel_node_pair = datasample(1:nMatchedNodes, 1);

v1_ind = LLGmatches(sel_node_pair, 1);
v2_ind = LLGmatches(sel_node_pair, 2);

diffx = repmat(LLG1.V(v1_ind,1), 1, nA1) - repmat(HLG1.V(:,1)', 1, 1);
diffy = repmat(LLG1.V(v1_ind,2), 1, nA1) - repmat(HLG1.V(:,2)', 1, 1);
dist_to_anchors = sqrt(diffx.^2 + diffy.^2);
dist_to_anchors(U1(v1_ind, :)) = Inf;

not_matched = ~ismember([1:nA1]', HLGmatches(:,1));
dist_to_anchors(not_matched) = Inf;

[~, anchor_ind_sorted] = min(dist_to_anchors);
a1 = anchor_ind_sorted; % select next closest anchor

a2_ind = HLGmatches(:,1)==a1;
a2 = HLGmatches(a2_ind,2);

U1(v1_ind, :) = 0;
U1(v1_ind, a1) = 1;

U2(v2_ind, :) = 0;
U2(v2_ind, a2) = 1;


assert(sum(U1(:))==nV1, 'Error: by the random shifting of graph nodes, not all nodes were assigned');
assert(sum(U2(:))==nV2, 'Error: by the random shifting of graph nodes, not all nodes were assigned');


end