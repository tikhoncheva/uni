
% use idea of simulated annealing to rearrange nodes in subgraphs 
function [LLG1, LLG2,HLG1_new, HLG2_new] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2, ...
                                               LLMatches, HLMatches)                                           
fprintf('\n---- Metropolis Algorithm');

p = 1/it;   % temperature
L = 1;      % repeat L time by fixed temperature p

% nV1 = size(LLG1.V,1); 
% nV2 = size(LLG2.V,1);

% HLG1_new = HLG1;
% HLG2_new = HLG2;

% % save old weight of the nodes
% W1_old = LLG1.W(:, end);
% W2_old = LLG2.W(:, end);


% Step1: weigh nodes of the graphs LLG1, LLG2 on the current iteration
[affTrafo, W1, W2] = weighNodes(LLG1, LLG2, HLG1.U, HLG2.U, LLMatches, HLMatches);
LLG1.W = [LLG1.W, W1];
LLG2.W = [LLG2.W, W2];

% Step2: expand subgraphs with small transformation errors and eliminate
% subgraphs with less then three nodes
[LLG1, LLG2, HLG1, HLG2] = rearrange_subgraphs10(LLG1, LLG2, HLG1, HLG2, ...
                                     LLMatches, HLMatches, affTrafo);

% F1 = HLG1.F;  
% F2 = HLG2.F;
                                 
% Step3:        
% rng('default');
for it = 1:L

%     % randomly shift one node in each graph no another anchor
%     [U1_new, affected_anchors1] = randomly_shift_nodes(LLG1, HLG1);
%     [U2_new, affected_anchors2] = randomly_shift_nodes(LLG2, HLG2);
%     
%     F1(affected_anchors1) = 0; F2(affected_anchors2) = 0;
%     
%     affected_pairs1_ind = find(ismember(HLMatches.matched_pairs(:,1), affected_anchors1));
%     affected_pairs2_ind = find(ismember(HLMatches.matched_pairs(:,2), affected_anchors2));    
%     affected_pairs_ind = unique([affected_pairs1_ind; affected_pairs2_ind]);
%     
%     HLMatches.matched_pairs(affected_pairs_ind,3) = 0;
%     affected_pairs = HLMatches.matched_pairs(affected_pairs_ind,:);
% 
%     % Step 4: recalculate correspondences in changed subgraphs
%     [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
%                                                                       U1_new, U2_new,...
%                                                                       affected_pairs);
%     partLLMatches = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, HLMatches.matched_pairs ); 
%     matched_pairs = partLLMatches.matched_pairs;
%     matched_pairs(:,3) = affected_pairs_ind(matched_pairs(:,3));
%     
%     % combine matches of changed subgraphs with matches of unchanged subgraph
%     newLLGmatches = LLMatches;
%     ind_old_matches = ismember(newLLGmatches.matched_pairs(:,3), matched_pairs(:,3)); % replace old matches
%     newLLGmatches.matched_pairs(ind_old_matches,:) = [];                              % with the new one
%     newLLGmatches.matched_pairs = [newLLGmatches.matched_pairs; matched_pairs];      
% 
% 
% 
%     % Step 5: reweigh new matches
%     [~, W1, W2] = weighNodes(LLG1, LLG2, U1_new, U2_new, newLLGmatches, HLMatches);
% 
%     % Step 6: decide for each node (in both graphs), to which anchor it should belong based on the
%     % weights from two different assignments
%     
%     dE1 = W1 - W1_old;
%     pA1 = min(1, exp(-dE1/p) ); % acception probability
% 
%     ind_accept = dE1<0;
%     ind_accept = logical(ind_accept + (pA1-rand(nV1,1) > 0));
%     HLG1_new.U(ind_accept, :) = U1_new(ind_accept, :);  
% 
% 
%     dE2 = W2 - W2_old;
%     pA2 = min(1, exp(-dE2/p) ); % acception probability
%     
%     ind_accept = dE2<0;
%     ind_accept = logical(ind_accept + (pA2-rand(nV2,1) > 0));
%     HLG2_new.U(ind_accept, :) = U2_new(ind_accept, :);       

end

% Step7:
% 
% HLG1_new.F = F1;
% HLG2_new.F = F2;  

HLG1_new = HLG1;
HLG2_new = HLG2;  

end
