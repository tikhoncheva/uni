 
%% Matching of dependency graphs
%
% Input
% DG1, DG2      two graphs with nV1 and nV2 nodes respectively
% AG1, AG2      corresponding anchor graphs
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, pairs, ...
          local_objval, local_weights] = matchLLGraphs(nV1, nV2, indOfSubgraphsNodes, corrmatrices, affmatrices)

display(sprintf('\n================================================'));
display(sprintf('Match initial graphs'));
display(sprintf('=================================================='));


tic 

nV = nV1 * nV2;

% number of local matchings to do
nIterations = size(indOfSubgraphsNodes, 1); 

local_objval = zeros(nIterations, 1);
local_weights = zeros(nIterations, nV);

% global_corrmatrix = zeros(nIterations, nV);

% localMatches = zeros(nIterations, nV);

try
    % ----------------------------------------------------------------
    % Run parallel
    % ----------------------------------------------------------------
    
%     poolobj = parpool(3);                           
% 
%     if isempty(poolobj)
%         poolsize = 0;
%     else
%         poolsize = poolobj.NumWorkers;
%     end

    % in each step we match points corresponding to the anchor match ai<->aj
    for it = 1:nIterations
        node_ind = indOfSubgraphsNodes(it,:);

        % nodes, that belong to the anchor ai
        ai_x = logical(node_ind(1:nV1));
        nVi = size(corrmatrices{it},1);

        % nodes, that belong to the anchor aj
        aj_x = logical(node_ind(nV1+1:end));        
        nVj = size(corrmatrices{it},2);

        display(sprintf('matrix size %d x %d', nVi, nVj));
        
        corrmatrix = corrmatrices{it};
        affmatrix = affmatrices{it};

        % conflict groups
        [I, J] = find(corrmatrix);
        [ group1, group2 ] = make_group12([I, J]);

        % run RRW Algorithm 
        tic
        x = RRWM(affmatrix, group1, group2);
        fprintf('    RRWM: %f sec\n', toc);
        
        X = greedyMapping_weights(x, group1, group2);
        
        W_local = reshape(X, [nVi, nVj]);
        W = zeros(nV1, nV2);
        W(ai_x, aj_x') = W_local;
        
%         M = zeros(nV1, nV2);
%         M(ai_x, aj_x') = corrmatrix;
%         
%         global_corrmatrix(it, :) = reshape(M, [1 nV]);
        
        local_weights(it,:) = reshape(W, [1 nV]);
        local_objval(it,1) = X' * affmatrix * X;

%         X = greedyMapping(x, group1, group2);
% 
%         objective(it) = x'*affmatrix * x;
% 
%         matchesL = zeros(nVi, nVj);
%         for k=1:numel(I)
%             matchesL(I(k), J(k)) = X(k);
%         end  
% 
%         matches = zeros(nV1, nV2);
%         matches(ai_x, aj_x') = matchesL;
%         localMatches(it, :) = reshape(matches, [1 nV]);

    end

%     delete(poolobj); 
%     display(sprintf('Delete parallel pool %d', poolsize));
%     display(sprintf(' -------------------------------------------------- '));

catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    % close parallel pool
    delete(gcp('nocreate'));

    rethrow(ME);
end

% global matrix of matches

% corrmatrix = max(global_corrmatrix,[],1);
% corrmatrix = reshape(corrmatrix, nV1, nV2);
% 
% [I, J] = find(corrmatrix);
% [ group1, group2 ] = make_group12([I, J]);
% 

matches_tmp = max(local_weights, [], 1);        % maximum in each column
% matches = greedyMapping(matches, group1, group2);
matches_tmp = reshape(matches_tmp, nV1,nV2);    % maximum in each row
% force 1-to-1 matching
[maxval, ind] = max(matches_tmp, [], 2);
matches = zeros(size(matches_tmp));
for i=1:size(matches,1)
    matches(i,ind(i)) = maxval(i);
end

% matches = logical(matches);

% matches = max(localMatches,[], 1);
% matches = reshape(matches, nV1,nV2);
% matches = logical(matches);

[pairs(:,1), pairs(:,2)] = find(matches);


objval = sum(local_objval);

display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));

end