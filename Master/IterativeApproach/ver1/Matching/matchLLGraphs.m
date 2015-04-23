 
%% Matching of dependency graphs
%
% Input
% DG1, DG2      two graphs with nV1 and nV2 nodes respectively
% AG1, AG2      corresponding anchor graphs
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchLLGraphs(nV1, nV2, indOfSubgraphsNodes, corrmatrices, affmatrices)

display(sprintf('\n================================================'));
display(sprintf('Match initial graphs'));
display(sprintf('=================================================='));


tic 

% number of local matchings to do
nIterations = size(indOfSubgraphsNodes, 1); 

objective = zeros(nIterations, 1);

nV = nV1 * nV2;
localMatches = zeros(nIterations, nV);

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
        
        corrMatrix = corrmatrices{it};
        affmatrix = affmatrices{it};

        % conflict groups
        [I, J] = find(corrMatrix);
        [ group1, group2 ] = make_group12([I, J]);

        % run RRW Algorithm 
        tic
        x = RRWM(affmatrix, group1, group2);
        fprintf('    RRWM: %f sec\n', toc);

        X = greedyMapping(x, group1, group2);

        objective(it) = x'*affmatrix * x;

        matchesL = zeros(nVi, nVj);
        for k=1:numel(I)
            matchesL(I(k), J(k)) = X(k);
        end  

        matches = zeros(nV1, nV2);
        matches(ai_x, aj_x') = matchesL;
        localMatches(it, :) = reshape(matches, [1 nV]);

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
matches = max(localMatches,[], 1);
matches = reshape(matches, nV1,nV2);
matches = logical(matches);

objval = sum(objective);

display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));

end