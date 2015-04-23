 %% Initialization function for setting the iterative graph matching
 %
 %
 
function [indOfSubgraphsNodes, corrmatrix, affmatrix] = initialization_LLGM(LLG1, LLG2, HLGmatches)

display(sprintf('\n================================================'));
display(sprintf('Initialization for Lower Level Graph Matching (LLGM)'));
display(sprintf('=================================================='));



try
    tic 
    
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

    % number of iterations is equal to number of nodes in the first HLGraph 
    nIterations = size(LLG1.U, 2); 

    % save separately indices of nodes, that should be matched parallel on the Lower Level
    indOfSubgraphsNodes = zeros(nIterations, nV1 + nV2);

    localAdjMatrices1 = cell(nIterations);
    localAdjMatrices2 = cell(nIterations);

    % according to matches of anchor node build a colelction of
    % corresponding subgraphs on the lower level
    
    V1 = cell(nIterations);
    V2 = cell(nIterations);

    D1 = cell(nIterations);
    D2 = cell(nIterations);
    
    corrmatrix = cell(nIterations);     
    affmatrix = cell(nIterations);
    

    for it = 1:nIterations % for each match ai<->aj on the High Level

        % indices of nodes, that belong to the anchor ai
        ai_x = LLG1.U(:,it);
        V1{it} = LLG1.V(ai_x,:)';
        D1{it} = LLG1.D(:, ai_x);
        adjM1cut = adjM1(ai_x, ai_x');

        % indices of nodes, that belong to the anchor aj
        aj_x = LLG2.U(:, HLGmatches(it,:)');
        V2{it} = LLG2.V(aj_x,:)';
        D2{it} = LLG2.D(:, aj_x);
        adjM2cut = adjM2(aj_x, aj_x');

        indOfSubgraphsNodes(it,:) = [ai_x' aj_x'];

        localAdjMatrices1{it} = adjM1cut;
        localAdjMatrices2{it} = adjM2cut;

        display(sprintf(' %d x %d', size(V1{it},2), size(V2{it},2)));
    end

    % ----------------------------------------------------------------
    % Run parallel
    % ----------------------------------------------------------------

    poolobj = parpool(3);                           

    if isempty(poolobj)
        poolsize = 0;
    else
        poolsize = poolobj.NumWorkers;
    end
    display(sprintf('Number of workers: %d', poolsize));

    % in each step we consider subgraphs of the LLgraphs, which correspond to the anchor match ai<->aj
    parfor it = 1:nIterations

        v1 = V1{it};
        d1 = D1{it};
        nVi = size(v1,2);
        adjM1cut = localAdjMatrices1{it};

        v2 = V2{it};
        d2 = D2{it};
        nVj = size(v2,2);
        adjM2cut = localAdjMatrices2{it};
                
        display(sprintf('matrix %d x %d ', nVi, nVj));

        % correspondence matrix 
        corrmatrix{it} = ones(nVi,nVj);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
        
        % compute initial affinity matrix
        affmatrix{it} = initialAffinityMatrix2(v1, v2, d1, d2, adjM1cut, adjM2cut, corrmatrix{it});
    end
    
    delete(poolobj); 
    display(sprintf('Delete parallel pool %d', poolsize));
    
    % ----------------------------------------------------------------

catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    % close parallel pool
    delete(gcp('nocreate'));

    rethrow(ME);
end


display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));


end