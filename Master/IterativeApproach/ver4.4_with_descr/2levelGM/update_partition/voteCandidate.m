function [ voting nAddedVote ] = voteCandidate( kdtreeNS1, kdtreeNS2, all_pt1, all_pt2, matchList_GM, scoreAnchor, ptAnchor1, Ti21, k_neighbor1, k_neighbor2  )

lambda_anchor = 0.0; 
lambda_dist = 1.0;
% bounded search from all feat1 of the same type
ind_featCand1 = kdtree_k_nearest_neighbors( kdtreeNS1, ptAnchor1, k_neighbor1 );

% project the neighbors onto img2
tmp1 = Ti21 * [ all_pt1(ind_featCand1,:) ones(length(ind_featCand1),1) ]';
ptAnchor1_projected = tmp1(1:2,:)';

% make a lookup table of feat2 matching feat1 in matches of GM
ind_feat2_matching_feat1 = zeros(size(all_pt1,1),1);
ind_feat2_matching_feat1( matchList_GM(:,1), 1) = matchList_GM(:,2);

voting = sparse(size(all_pt1,1),size(all_pt2,1));
%size(voting)
nAddedVote = 0;
for iter_j = 1:length(ind_featCand1)
    
    ptCand1_projected = ptAnchor1_projected(iter_j,:);
    % bounded search from all feat2 of the same type
    [ ind_featCand2 dist_featCand2 ] = kdtree_k_nearest_neighbors( kdtreeNS2, ptCand1_projected, k_neighbor2 );
    likelihood_cand = exp(-lambda_dist*dist_featCand2); 
    %pause;
    iind_match_of_GM = find(ind_featCand2 == ind_feat2_matching_feat1(ind_featCand1(iter_j)));
    [ tmp, iind_max ] = max(likelihood_cand);
    % if the voting includes the match of the current GM
    if ~isempty(iind_match_of_GM) && ( iind_match_of_GM == iind_max )
        ind_featCand2 = ind_featCand2(iind_match_of_GM);
        likelihood_cand = 1; % obtain all the votes
    end
    if isempty(ind_featCand2), continue; end
    likelihood_cand=likelihood_cand./(sum(likelihood_cand)+eps);
    sim_cand = scoreAnchor^lambda_anchor*likelihood_cand;
    
    voting(ind_featCand1(iter_j), ind_featCand2) = voting(ind_featCand1(iter_j), ind_featCand2) + sim_cand';
    nAddedVote = nAddedVote + length(ind_featCand2);
    
end