%% ramdomly shift p percentage of nodes in LLG to the other anchors

% select next nearest anchor

function [U, picked_nodes_ind] = randomly_shift_nodes(LLG, HLG, W)
U = HLG.U;

k = 3;  % number of nearest anchors a node can be moved to

nA = size(HLG.V,1);     % number of anchors
nV = size(LLG.V,1);     % number of nodes

m = 1;
fprintf('Number of nodes to move %d \n', m);

% ind_nodes_in_bad_subg = find(W>1);
% picked_nodes_ind = datasample(ind_nodes_in_bad_subg, m,'Replace',false)';

picked_nodes_ind = datasample(1:nV, m,'Replace',false)';

dist_to_anchors = repmat(LLG.V(picked_nodes_ind,1:2), nA,1) ...
                - kron  (HLG.V(:,1:2), ones(m,1));
dist_to_anchors = sqrt(dist_to_anchors(:,1).^2 + dist_to_anchors(:,2).^2);
dist_to_anchors = reshape(dist_to_anchors , m, nA);
dist_to_anchors(U(picked_nodes_ind, :)) = Inf;


[~, nn_anchors_ind] = sort(dist_to_anchors, 2);

nn_anchors_ind = nn_anchors_ind(:, datasample(1:k, 1)); % select one of the k nearest neighbors

U(picked_nodes_ind, :) = 0;
ind = sub2ind(size(U), picked_nodes_ind, nn_anchors_ind);
U(ind) = 1;

assert(sum(U(:))==nV, 'Error: by the random shifting of graph nodes, not all nodes were assigned');

% HLG.U = U;
% figure,
% plot_twolevelgraphs([], LLG, HLG, false, false); 

end