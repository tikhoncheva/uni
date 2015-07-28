
% use idea of simulated annealing to rearrange nodes in subgraphs 
function [HLG1_new, HLG2_new] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, p)
                                           
display(sprintf('\n================================================'));
display(sprintf(' Simulated annealing'));
display(sprintf('=================================================='));

% tic;

nIterations = 1;

rng('default');

HLG1_new = HLG1;
HLG2_new = HLG2;
      
F1 = HLG1.F;
F2 = HLG2.F;

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
    % Step 2: randomly select one node in each of two graphs and shift
    % them to the new anchors

    [U12, affected_anchors1] = randomly_shift_nodes(LLG1, HLG1_new, WG11);
    [U22, affected_anchors2] = randomly_shift_nodes(LLG2, HLG2_new, WG21);
    
    F1(affected_anchors1) = 0;
    F2(affected_anchors2) = 0;
    
    affected_pairs1_ind = find(ismember(HLGmatches.matched_pairs(:,1), affected_anchors1));
    affected_pairs2_ind = find(ismember(HLGmatches.matched_pairs(:,2), affected_anchors2));    
    affected_pairs_ind = unique([affected_pairs1_ind; affected_pairs2_ind]);
    
    HLGmatches.matched_pairs(affected_pairs_ind,3) = 0;
    affected_pairs = HLGmatches.matched_pairs(affected_pairs_ind,:);

    nHLG1 = HLG1_new;
    nHLG1.U = U12;

    nHLG2 = HLG2_new;
    nHLG2.U = U22;

    % Step 3: match by the shifting affected subgraphs on the LL
    
%     [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
%                                                                   nHLG1.U, nHLG2.U,...
%                                                                   HLGmatches.matched_pairs);
%     nV1 = size(LLG1.V,1);
%     nV2 = size(LLG2.V,1);
%     [~, matched_pairs0, ~, ~] = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices); 
    
    
    [subgraphsNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                      nHLG1.U, nHLG2.U,...
                                                                      affected_pairs);
    nV1 = size(LLG1.V,1);
    nV2 = size(LLG2.V,1);

    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    LLMatches = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices, HLGmatches.matched_pairs ); 
    matched_pairs = LLMatches.matched_pairs;
%     [~, matched_pairs, ~, ~] = matchLLGraphs(nV1, nV2, subgraphsNodes, corrmatrices, affmatrices); 
    matched_pairs(:,3) = affected_pairs_ind(matched_pairs(:,3));

    % new matches on the LL
    nLLGmatches = LLGmatches;
    ind_old_matches = ismember(nLLGmatches.matched_pairs(:,3), matched_pairs(:,3));
    nLLGmatches.matched_pairs(ind_old_matches,:) = [];
    nLLGmatches.matched_pairs = [nLLGmatches.matched_pairs; matched_pairs];



    % Step 4: calculate transformation error of the new matching
    [T_prime, inverseT_prime] = affine_transformation_estimation(LLG1, LLG2, U12, U22, ...
                                                     nLLGmatches, HLGmatches);
    [WG12, WG22] = rearrange_subgraphs(LLG1, LLG2, U12, U22, ...
                                       nLLGmatches, HLGmatches, ...
                                       T_prime, inverseT_prime);

%     [T_prime, inverseT_prime] = affine_transformation_estimation(LLG1, LLG2, U12, U22, ...
%                                                      LLGmatches, HLGmatches);
%     [WG12, WG22] = rearrange_subgraphs(LLG1, LLG2, U12, U22, ...
%                                        LLGmatches, HLGmatches, ...
%                                        T_prime, inverseT_prime);


    % Step 5: decide for each node (in both graphs), to which anchor it should belong based on the
    % weights from two different assignments

    dE1 = sum(WG12(:) - sum(WG11(:)));
    
    % First graph
%       nV1 = size(LLG1.V,1);
%       % accept initial clustering
%       U1_new = U11;

%       dE1 = WG12 - WG11;
      pA1 = min(1, exp(-dE1/p) ); % acception probability
%     %   pA(isnan(dE)) = 1.0;
%     %   pA( abs(dE)<0.1) = 0.0;
%       ind = zeros(nV1, 1); ind(sel_nodes_LLG1) = 1;
%       pA(~ind) = 0.0;

%       dE_npos = dE1<0;
%       dE_pos = ~dE_npos;
% 
%       % accept states with smaller error
%       U1_new(dE_npos, :) = U12(dE_npos,:);
% 
%       % for the states with bigger error accept state with the probability pA
%       q = rand(nV1,1);
%       accept_ind = pA > q;
%       accept_ind = accept_ind & dE_pos;
% 
%       U1_new(accept_ind, :) = U12(accept_ind,:);
%       assert(sum(U1_new(:))==nV1, 'Error in the step 4 in simulated annealing: first graph had got wrong clustering');

      HLG1_new.U = U11;
      if dE1<0
        HLG1_new.U = U12;
      else
        if pA1 > rand(1,1)
            HLG1_new.U = U12;
        end
      end
%       HLG1_new.U = U1_new;


    % Second graph
    
      dE2 = sum(WG22(:) - sum(WG21(:)));
      
%       nV2 = size(LLG2.V,1);
      % accept initial clustering
%       U2_new = U21;

%       dE1 = WG22 - WG21;
      pA2 = min(1, exp(-dE2/p) ); % acception probability
    %   pA(isnan(dE)) = 1.0;
    %   pA( abs(dE)<0.1) = 0.0;
%       ind = zeros(nV2, 1); ind(sel_nodes_LLG2) = 1;
%       pA(~ind) = 0.0;

%       dE_npos = dE1<0;
%       dE_pos = ~dE_npos;

      % accept states with smaller error
%       U2_new(dE_npos, :) = U22(dE_npos,:);

      % for the states with bigger error accept state with the probability pA
%       q = rand(nV2,1);
%       accept_ind = pA > q;
%       accept_ind = accept_ind & dE_pos;

%       U2_new(accept_ind, :) = U22(accept_ind,:);
%       assert(sum(U2_new(:))==nV2, 'Error in the step 4 in simulated annealing: second graph had got wrong clustering');
% 
%       HLG2_new.U = U2_new;

      HLG2_new.U = U21;
      if dE2<0
        HLG2_new.U = U22;
      else
        if pA2 > rand(1,1)
            HLG2_new.U = U22;
        end
      end        

end

HLG1.F = F1;
HLG1.F = F2;

% fprintf( 'Time %0.3f \n', toc);
display(sprintf('=================================================='));                          

end
