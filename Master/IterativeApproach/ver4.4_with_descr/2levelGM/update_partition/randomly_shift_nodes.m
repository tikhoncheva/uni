%% ramdomly shift m nodes in LLG to the other anchors

% select one of k next nearest anchors

function [U, ind_picked_node, affected_anchors] = randomly_shift_nodes(LLG, HLG)

    nA = size(HLG.V,1);     % number of anchors
    nV = size(LLG.V,1);     % number of nodes

    U = HLG.U;

    k = 3;  % number of nearest anchors a node can be moved to
    m = 1;  % numer of nodes to move

    ind_picked_node = datasample(1:nV, m,'Replace',false)';

    dist_to_anchors = repmat(LLG.V(ind_picked_node,1:2), nA,1) ...
                    - kron  (HLG.V(:,1:2), ones(m,1));
    dist_to_anchors = sqrt(dist_to_anchors(:,1).^2 + dist_to_anchors(:,2).^2);
    dist_to_anchors = reshape(dist_to_anchors , m, nA);
    dist_to_anchors(U(ind_picked_node, :)) = Inf;

    [~, nn_anchors_ind] = sort(dist_to_anchors, 2);
    nn_anchors_ind = nn_anchors_ind(:, datasample(1:k, 1)); % select one of the k nearest neighbors

    [~, affected_anchors] = find(U(ind_picked_node, :));
    affected_anchors = unique(affected_anchors);
    affected_anchors = [affected_anchors; nn_anchors_ind];

    U(ind_picked_node, :) = 0;
    ind = sub2ind(size(U), ind_picked_node, nn_anchors_ind);
    U(ind) = 1;

    assert(sum(U(:))==nV, 'Error: by the random shifting of graph nodes, not all nodes were assigned');

end