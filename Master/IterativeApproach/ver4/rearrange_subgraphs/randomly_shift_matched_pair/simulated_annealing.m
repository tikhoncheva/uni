% use idea of simulated annealing to rearrange nodes in subgraphs 
function [HLG1_new, HLG2_new] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, p)
                                           
display(sprintf('\n================================================'));
display(sprintf(' Simulated annealing'));
display(sprintf('=================================================='));

tic;

nIterations = 2;

rng('default');

HLG1_new = HLG1;
HLG2_new = HLG2;
      
for it = 1:nIterations

    U11 = HLG1_new.U;   % assignment matrix of the first graph (given partition)
    U21 = HLG2_new.U;   % assignment matrix of the second graph (given partition)
    
    % Step 1: calculate weights of the nodes in both graphs based on estimated
    % affine transformation
    [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, U11, U21, ...
                                                     LLGmatches, HLGmatches);
    [WG11, WG21] = rearrange_subgraphs(LLG1, LLG2, U11, U21, ...
                                       LLGmatches, HLGmatches, ...
                                       T, inverseT);
                                   
    % Step 2: randomly select one matched pair and move it to the next
    % nearest anchor

    [U12, U22, sel_node_LLG1, sel_node_LLG2] = randomly_shift_nodes(LLG1, LLG2, HLG1_new, HLG2_new, ...
                                                                    LLGmatches.matched_pairs, HLGmatches.matched_pairs);

% %     nHLG1 = HLG1_new;
% %     nHLG1.U = U12;
% % 
% %     nHLG2 = HLG2_new;
% %     nHLG2.U = U22;

% %     % Step 3: match graphs on the LL ones again
% %     [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
% %                                                                       nHLG1.U, nHLG2.U,...
% %                                                                       HLGmatches.matched_pairs);
% %     nV1 = size(LLG1.V,1);
% %     nV2 = size(LLG2.V,1);
% % 
% %     [objval, matched_pairs, ...
% %      lobjval, lweights] = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices);
% % 
% %     % new matches on the LL
% %     nLLGmatches.objval = objval;
% %     nLLGmatches.matched_pairs = matched_pairs;
% %     nLLGmatches.lobjval = lobjval;
% %     nLLGmatches.lweights = lweights;
% %     nLLGmatches.subgraphsNodes = subgraphsNodes;
% %     nLLGmatches.corrmatrices = corrmatrices;
% %     nLLGmatches.affmatrices  = affmatrices;


    % Step 4: calculate transformation error of the new matching
% %     [T_prime, inverseT_prime] = affine_transformation_estimation(LLG1, LLG2, U12, U22, ...
% %                                                      nLLGmatches, HLGmatches);
% %     [WG12, WG22] = rearrange_subgraphs(LLG1, LLG2, U12, U22, ...
% %                                        nLLGmatches, HLGmatches, ...
% %                                        T_prime, inverseT_prime);

    [T_prime, inverseT_prime] = affine_transformation_estimation(LLG1, LLG2, U12, U22, ...
                                                     LLGmatches, HLGmatches);
    [WG12, WG22] = rearrange_subgraphs(LLG1, LLG2, U12, U22, ...
                                       LLGmatches, HLGmatches, ...
                                       T_prime, inverseT_prime);


    % Step 5: decide for each node (in both graphs), to which anchor it should belong based on the
    % weights from two different assignments

    % First graph
      nV1 = size(LLG1.V,1);
      % accept initial clustering
      U1_new = U11;

      dE = WG12 - WG11;
      pA = min(1, exp(-dE/p) ); % acception probability
    %   pA(isnan(dE)) = 1.0;
    %   pA( abs(dE)<0.1) = 0.0;
       ind = zeros(nV1, 1); ind(sel_node_LLG1) = 1;
       pA(~ind) = 0.0;

      dE_npos = dE<0;
      dE_pos = ~dE_npos;

      % accept states with smaller error
      U1_new(dE_npos, :) = U12(dE_npos,:);

      % for the states with bigger error accept state with the probability pA
      q = rand(nV1,1);
      accept_ind = pA > q;
      accept_ind = accept_ind & dE_pos;

      U1_new(accept_ind, :) = U12(accept_ind,:);
      assert(sum(U1_new(:))==nV1, 'Error in the step 4 in simulated annealing: first graph had got wrong clustering');

      HLG1_new.U = U1_new;


    % Second graph
      nV2 = size(LLG2.V,1);
      % accept initial clustering
      U2_new = U21;

      dE = WG22 - WG21;
      pA = min(1, exp(-dE/p) ); % acception probability
    %   pA(isnan(dE)) = 1.0;
    %   pA( abs(dE)<0.1) = 0.0;
       ind = zeros(nV2, 1); ind(sel_node_LLG2) = 1;
       pA(~ind) = 0.0;

      dE_npos = dE<0;
      dE_pos = ~dE_npos;

      % accept states with smaller error
      U2_new(dE_npos, :) = U22(dE_npos,:);

      % for the states with bigger error accept state with the probability pA
      q = rand(nV2,1);
      accept_ind = pA > q;
      accept_ind = accept_ind & dE_pos;

      U2_new(accept_ind, :) = U22(accept_ind,:);
      assert(sum(U2_new(:))==nV2, 'Error in the step 4 in simulated annealing: second graph had got wrong clustering');

      HLG2_new.U = U2_new;

end

fprintf( 'Time %0.3f \n', toc);
display(sprintf('=================================================='));                          

end
