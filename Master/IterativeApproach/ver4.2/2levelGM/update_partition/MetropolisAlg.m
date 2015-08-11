
% use idea of simulated annealing to rearrange nodes in subgraphs 
function [HLG1, HLG2, affTrafo] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2, ...
                                               LLMatches, HLMatches, affTrafo)                                           
fprintf('\n---- Metropolis Algorithm');

p = 1/it;   % temperature

nV = round((size(LLG1.V,1) + size(LLG1.V,2))/2);
L = 1; %round(nV*0.3*0.95^(it-1));      % repeat L time by fixed temperature p

nV1 = size(LLG1.V,1); 
nV2 = size(LLG2.V,1);

HLG1.F = ones(size(HLG1.V,1),1); 
HLG2.F = ones(size(HLG2.V,1),1);

% Step1: weigh nodes of the graphs LLG1, LLG2 on the current iteration
[affTrafo] = weighNodes(LLG1, LLG2, HLG1.U, HLG2.U, LLMatches.matched_pairs, ...
                                                            HLMatches.matched_pairs, affTrafo);


% Step2: expand subgraphs with small transformation errors and eliminate
% subgraphs with less then three nodes

[HLG1, HLG2] = update_subgraphs(LLG1, LLG2, HLG1, HLG2, ...
                                LLMatches, HLMatches, affTrafo);

% Step3:        
% rng('default');
for i = 1:L
    % randomly shift one node in each graph no another anchor
    [U1_new, ind_v1, aa1] = randomly_shift_nodes(LLG1, HLG1); % affected anchors 1
    [U2_new, ind_v2, aa2] = randomly_shift_nodes(LLG2, HLG2);
    
    ind_aap1 = find(ismember(HLMatches.matched_pairs(:,1), aa1)); % indices of the affected anchor in matched anchor pairs
    ind_aap2 = find(ismember(HLMatches.matched_pairs(:,2), aa2));    
    ind_aap = unique([ind_aap1; ind_aap2]);  
    
    HLMatches.matched_pairs(ind_aap,3) = 0;
    aap = HLMatches.matched_pairs(ind_aap,:); % affected anchor pairs

    % Step 4: recalculate correspondences in changed subgraphs
    [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                      U1_new, U2_new,...
                                                                      aap);
%     partLLMatches = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, HLMatches.matched_pairs ); 
    LLMatches_new = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, aap ); 
    new_matches = LLMatches_new.matched_pairs;
    new_matches(:,3) = ind_aap(new_matches(:,3));
    
    % combine matches of changed subgraphs with matches of unchanged subgraph
    old_node_matches = LLMatches.matched_pairs;
    new_node_matches = old_node_matches;
    ind_matches_to_replace = ismember(old_node_matches(:,3), new_matches(:,3)); % replace old matches  
    new_node_matches(ind_matches_to_replace,:) = [];                              % with the new one
    new_node_matches = [new_node_matches; new_matches];      


    % Step 5: reweigh new matches
    [affTrafo_new] = weighNodes(LLG1, LLG2, U1_new, U2_new, new_node_matches, ...
                                                                HLMatches.matched_pairs, ...
                                                                affTrafo);
    affTrafo_new{it} = affTrafo_new{it+1};
    affTrafo_new(it+1) = [];
    
    % Step 6: decide for each moved node, if the change is accepted based
    % on the error of the new subgraphs
    err_aa1 = affTrafo{it}(ind_aap1,3);
    err_aa2 = affTrafo{it}(ind_aap2,3);
    
    err_aa1_new = affTrafo_new{it}(ind_aap1,3);
    err_aa2_new = affTrafo_new{it}(ind_aap2,3);

    dErr_aa1 = err_aa1_new - err_aa1; % improvement, when the error in both new subgraphs is negative
    dErr_aa2 = err_aa2_new - err_aa2;
    
    % acception probability
    pA1 = min(1, exp(-max(dErr_aa1)/p) );   % use the biggest of two errors
    pA2 = min(1, exp(-max(dErr_aa2)/p) );   % use the biggest of two errors
 

    if all(dErr_aa1<0) % both errors in the first graph are negative
        HLG1.U(ind_v1, :) = U1_new(ind_v1, :);
        affTrafo{it}(ind_aap1,:) = affTrafo_new{it}(ind_aap1,:);
        HLG1.F(aa1) = 0;
    end

    if all(dErr_aa2<0) % both errors in the second graph are negative
        HLG2.U(ind_v2, :) = U2_new(ind_v2, :);
        affTrafo{it}(ind_aap2,:) = affTrafo_new{it}(ind_aap2,:);
        HLG2.F(aa2) = 0;
    end
    
    
    if any(dErr_aa1<0) && pA1>rand(1,1) % at leat one error is negative
        HLG1.U(ind_v1, :) = U1_new(ind_v1, :);
        affTrafo{it}(ind_aap1,:) = affTrafo_new{it}(ind_aap1,:);
        HLG1.F(aa1) = 0;
    end

    if any(dErr_aa2<0) && pA2>rand(1,1) % at leat one error is negative
        HLG2.U(ind_v2, :) = U2_new(ind_v2, :);
        affTrafo{it}(ind_aap2,:) = affTrafo_new{it}(ind_aap2,:);
        HLG2.F(aa2) = 0;
    end
    
    

end

% Step7

[HLG1, HLG2] = update_subgraphs(LLG1, LLG2, HLG1, HLG2, ...
                                LLMatches, HLMatches, affTrafo);



end
