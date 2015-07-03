% use idea of simulated annealing to rearrange nodes in subgraphs 
function [HLG1_new, HLG2_new] = simulated_annealing(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, p)
rng('default');

U11 = HLG1.U;   % assignment matrix of the first graph by the first clustering
U21 = HLG2.U;   % assignment matrix of the second graph by the first clustering

% Step 1: calculate weights of the nodes in both graphs based on estimated
% affine transformation


[T, inverseT] = affine_transformation_estimation(LLG1, LLG2, U11, U21, ...
                                                 LLGmatches, HLGmatches);
[WG11, WG21] = rearrange_subgraphs(LLG1, LLG2, U11, U21, ...
                                   LLGmatches, HLGmatches, ...
                                   T, inverseT);
                               

% Step 2: randomly select p precentage of nodes in both graphs and shift
% them to the new anchors
U12 = randomly_shift_nodes(LLG1, HLG1, p);
U22 = randomly_shift_nodes(LLG2, HLG2, p);



% Step 3: calculate weights of nodes according to the new assignment

[T_prime, inverseT_prime] = affine_transformation_estimation(LLG1, LLG2, U12, U22, ...
                                                 LLGmatches, HLGmatches);

[WG12, WG22] = rearrange_subgraphs(LLG1, LLG2, U12, U22, ...
                                   LLGmatches, HLGmatches, ...
                                   T_prime, inverseT_prime);
                               

% Step 4: decide for each noden in both graphs, to which anchor it should belong based on the
% weights from two different assignments

% First graph
nV1 = size(LLG1.V,1);
% accept initial clustering
U1_new = U11;


% find nodes, for that the initial clustering was worse then the second
ind_change = WG11>WG12;

% for other nodes accept the new clustering with the probability exp(-(W1-W1_prime)/p)
pAccept = exp(-(WG11-WG12)/p); pAccept(isnan(pAccept)) = 0;
pAccept = pAccept.* ind_change;

rand_vec = rand(nV1,1);

ind_select_U22 = pAccept>rand_vec;
U1_new(ind_select_U22, :) = U12(ind_select_U22, :);

assert(sum(U1_new(:))==nV1, 'Error in the step 4 in simulated annealing: first graph had got wrong clustering');

HLG1_new = HLG1;
HLG1_new.U = U1_new;


% Second graph
nV2 = size(LLG2.V,1);
% accept initial clustering
U2_new = U21;

% find nodes, for that the initial clustering was worse then the second
ind_change = WG21>WG22;

% for other nodes accept the new clustering with the probability exp(-(W1-W1_prime)/p)
pAccept = exp(-(WG21-WG22)/p); pAccept(isnan(pAccept)) = 0;
pAccept = pAccept.* ind_change;

rand_vec = rand(nV2,1);

ind_select_U22 = pAccept>rand_vec;
U2_new(ind_select_U22, :) = U22(ind_select_U22, :);

assert(sum(U2_new(:))==nV2, 'Error in the step 4 in simulated annealing: second graph had got wrong clustering');

HLG2_new = HLG2;
HLG2_new.U = U2_new;


end
