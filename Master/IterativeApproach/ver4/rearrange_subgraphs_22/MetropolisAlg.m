
% use idea of simulated annealing to rearrange nodes in subgraphs 
function [LLG1, LLG2,HLG1_new, HLG2_new] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2, ...
                                               LLMatches, HLMatches)                                           
fprintf('\n---- Metropolis Algorithm');

p = 1/it;   % temperature

nV = round((size(LLG1.V,1) + size(LLG1.V,2))/2);
L = 1; %round(nV*0.3*0.95^(it-1));      % repeat L time by fixed temperature p

nV1 = size(LLG1.V,1); 
nV2 = size(LLG2.V,1);

HLG1_new = HLG1;
HLG2_new = HLG2;

HLG1.F = ones(size(HLG1.V,1),1); 
HLG2.F = ones(size(HLG2.V,1),1);

% Step1: weigh nodes of the graphs LLG1, LLG2 on the current iteration
[affTrafo, W1, W2] = weighNodes(LLG1, LLG2, HLG1.U, HLG2.U, LLMatches.matched_pairs, ...
                                                            HLMatches.matched_pairs);
LLG1.W = [LLG1.W, W1];
LLG2.W = [LLG2.W, W2];

% Step2: expand subgraphs with small transformation errors and eliminate
% subgraphs with less then three nodes
% [LLG1, LLG2, HLG1, HLG2] = rearrange_subgraphs10(LLG1, LLG2, HLG1, HLG2, ...
%                                      LLMatches, HLMatches, affTrafo);

% save current weights of the nodes
W1_old = LLG1.W(:, end);
W2_old = LLG2.W(:, end);


F1 = HLG1.F;  
F2 = HLG2.F;
                                 
% % Step3:        
% % rng('default');
% for i = 1:L
%     
%     old_node_matches = LLMatches.matched_pairs;
% 
%     % randomly shift one node in each graph no another anchor
%     [U1_new, ind_u, aa1] = randomly_shift_nodes(LLG1, HLG1); % affected anchors 1
%     [U2_new, ind_v, aa2] = randomly_shift_nodes(LLG2, HLG2);
%     
%     F1(aa1) = 0; F2(aa2) = 0;
%     
%     ind_aap1 = find(ismember(HLMatches.matched_pairs(:,1), aa1)); % indices of the affected anchor pairs
%     ind_aap2 = find(ismember(HLMatches.matched_pairs(:,2), aa2));    
%     ind_aap = unique([ind_aap1; ind_aap2]);  
%     
%     HLMatches.matched_pairs(ind_aap,3) = 0;
%     aap = HLMatches.matched_pairs(ind_aap,:); % affected anchor pairs
%     
%         
%     [ind_an1, ~] = find(U1_new(:, aap(:,1) )); % indices of the affected nodes
%     ind_an1 = unique(ind_an1);
%     [ind_an2, ~] = find(U2_new(:, aap(:,2) ));
%     ind_an2 = unique(ind_an2);
% 
%     % Step 4: recalculate correspondences in changed subgraphs
%     [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
%                                                                       U1_new, U2_new,...
%                                                                       aap);
% %     partLLMatches = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, HLMatches.matched_pairs ); 
%     LLMatches_an = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, aap ); 
%     new_matches_an = LLMatches_an.matched_pairs;
%     new_matches_an(:,3) = ind_aap(new_matches_an(:,3));
%     
%     % combine matches of changed subgraphs with matches of unchanged subgraph
%     new_node_matches = old_node_matches;
%     
%     ind_matches_to_replace = ismember(old_node_matches(:,3), new_matches_an(:,3)); % replace old matches
%     old_matches_an = old_node_matches(ind_matches_to_replace,:);
%     
%     new_node_matches(ind_matches_to_replace,:) = [];                              % with the new one
%     new_node_matches = [new_node_matches; new_matches_an];      
% 
% 
%     % Step 5: reweigh new matches
%     [affTrafo, W1, W2] = weighNodes(LLG1, LLG2, U1_new, U2_new, new_node_matches, ...
%                                                                 HLMatches.matched_pairs);
% 
%     % Step 6: decide for each node (in both graphs), to which anchor it should belong based on the
%     % weights from two different assignments
% 
% 
%     dE1 = mean(W1(new_matches_an(:,1))) - mean(W1_old(old_matches_an(:,1)));
%     pA1 = min(1, exp(-dE1/p) ); % acception probability
%  
%     LLG1.W(ind_an1, end) = W1_old(ind_an1);
%     if dE1<0
%         HLG1_new.U(ind_an1, :) = U1_new(ind_an1, :);
%         LLG1.W(ind_an1,end) = W1(ind_an1);
%     end
%     W1_old = LLG1.W(:, end);    
%  
%     
%     dE2 = mean(W2(new_matches_an(:,2))) - mean(W2_old(old_matches_an(:,2)));
%     pA2 = min(1, exp(-dE2/p) ); % acception probability
%     
%     LLG2.W(ind_an2, end) = W2_old(ind_an2);
%     if dE2<0
%         HLG2_new.U(ind_an2, :) = U2_new(ind_an2, :);
%         LLG2.W(ind_an2,end) = W2(ind_an2);
%     end
%     W2_old = LLG2.W(:, end);    
% 
% end

% Step7

% HLG1_new.F = F1;
% HLG2_new.F = F2;  
% 
% [LLG1, LLG2, HLG1_new, HLG2_new] = rearrange_subgraphs10(LLG1, LLG2, HLG1_new, HLG2_new, ...
%                                      LLMatches, HLMatches, affTrafo);


% HLG1_new = HLG1;
% HLG2_new = HLG2;  

end
