 %% Initialization function for setting the iterative graph matching
 %
 %
 
function [indOfSubgraphsNodes, corrmatrix, affmatrix] = initialization_LLGM(LLG1, LLG2, ...
                                                                              U1, U2, ....
                                                                            HLG_matched_pairs)

fprintf('\n---- preprocessing: initialize %d subgraphs', size(HLG_matched_pairs,1));

try
%     tic 
    
    nV1 = size(LLG1.V,1); 
    nV2 = size(LLG2.V,1);

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nV1, nV1);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nV2, nV2);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;  

    % number of iterations is equal to number of found pairs in HLG
    ind_new_subgraphPairs  = find(HLG_matched_pairs(:,3) == 0);
    
    nPairs = numel(ind_new_subgraphPairs); 

    % build pairs of subgraph to match

    indOfSubgraphsNodes = zeros(nPairs, 1 + nV1 + nV2); % indices of nodes, that can be matched parallel

    localAdjMatrices1 = cell(nPairs,1);
    localAdjMatrices2 = cell(nPairs,1);

    V1 = cell(nPairs,1);
    V2 = cell(nPairs,1);

    D1 = cell(nPairs,1);
    D2 = cell(nPairs,1);
    
    corrmatrix = cell(nPairs,1);     
    affmatrix = cell(nPairs,1);
    
    for i = 1:nPairs % for each match ai<->aj on the High Level
        
        % indices of nodes, that belong to the anchor ai
        ai = HLG_matched_pairs(ind_new_subgraphPairs(i),1);
        
        ai_x = U1(:,ai);
        V1{i} = LLG1.V(ai_x,1:2)';
        if (~isempty(LLG1.D))
            D1{i} = LLG1.D(:, ai_x);
        else 
            D1{i} = [];
        end
        adjM1cut = adjM1(ai_x, ai_x');

        % indices of nodes, that belong to the anchor aj
        aj = HLG_matched_pairs(ind_new_subgraphPairs(i),2);
        
        aj_x = U2(:, aj);
        V2{i} = LLG2.V(aj_x,1:2)';
        if (~isempty(LLG2.D))
            D2{i} = LLG2.D(:, aj_x);
        else 
            D2{i} = [];
        end
        adjM2cut = adjM2(aj_x, aj_x');

        indOfSubgraphsNodes(i,1) = ind_new_subgraphPairs(i);
        indOfSubgraphsNodes(i,2:end) = [ai_x' aj_x'];
        localAdjMatrices1{i} = adjM1cut;
        localAdjMatrices2{i} = adjM2cut;

%         display(sprintf(' %d x %d', size(V1{i},2), size(V2{i},2)));
    end

    % ----------------------------------------------------------------
    % Run parallel
    % ----------------------------------------------------------------
% 
%     poolobj = parpool(3);                           
% 
%     if isempty(poolobj)
%         poolsize = 0;
%     else
%         poolsize = poolobj.NumWorkers;
%     end
%     display(sprintf('Number of workers: %d', poolsize));

    % in each step we consider subgraphs of the LLgraphs, which correspond to the anchor match ai<->aj
    for i = 1:nPairs
        
        v1 = V1{i};
        d1 = D1{i};
        nVi = size(v1,2);
        adjM1cut = localAdjMatrices1{i};

        v2 = V2{i};
        d2 = D2{i};
        nVj = size(v2,2);
        adjM2cut = localAdjMatrices2{i};

        % correspondence matrix 
        corrmatrix{i} = ones(nVi,nVj);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
        
        % compute initial affinity matrix
        if (nVi==0 || nVj==0 || nVi==1 || nVj==1)
            affmatrix{i} = [];
        else
            affmatrix{i} = initialAffinityMatrix2(v1, v2, d1, d2, adjM1cut, adjM2cut, corrmatrix{i});
        end
        
%         display(sprintf('matrix %d x %d ... finished', nVi, nVj));
    end
    
%     delete(poolobj); 
%     display(sprintf('Delete parallel pool %d', poolsize));
    
    % ----------------------------------------------------------------

catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    % close parallel pool
    delete(gcp('nocreate'));

    rethrow(ME);
end


% display(sprintf('Summary %f sec', toc));


end