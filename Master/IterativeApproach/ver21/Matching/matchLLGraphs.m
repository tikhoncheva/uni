 
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
        
        [nVi, nVj] = size(corrmatrices{it});
        
        if (nVi==0 || nVj==0 || sum(affmatrix(:))==0)  % if affinity matrix is zero matrix or one subgraph is empty !!!!!!!!!!!!
            local_weights(it,:) = reshape(zeros(nV1, nV2), [1 nV]);
            local_objval(it,1) = 0.;
            continue; 
        end

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
        
      
        local_weights(it,:) = reshape(W, [1 nV]);
        local_objval(it,1) = ceil(X)' * affmatrix * ceil(X);
        
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


matches_tmp = max(local_weights, [], 1);        % maximum in each column
matches_tmp = reshape(matches_tmp, nV1,nV2);   

% force 1-to-1 matching
% [maxval, maxpos] = max(matches_tmp, [], 2);
% pairs1 = find(maxval>0);
% pairs2 = maxpos(pairs1);

% not 1-to-1 matching
[pairs1, pairs2] = find(matches_tmp); 

pairs = [pairs1, pairs2];

objval = sum(local_objval);

display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));

end