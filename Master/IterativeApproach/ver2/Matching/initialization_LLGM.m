 %% Initialization function for setting the iterative graph matching
 %
 %
 
function [indOfSubgraphsNodes, corrmatrix, affmatrix] = initialization_LLGM(LLG1, LLG2, HLG_matched_pairs, varargin)

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

    % number of iterations is equal to number of found pairs in HLG
    nIterations = size(HLG_matched_pairs,1); 

    % save separately indices of nodes, that should be matched parallel on the Lower Level
    indOfSubgraphsNodes = zeros(nIterations, nV1 + nV2);

    localAdjMatrices1 = cell(nIterations,1);
    localAdjMatrices2 = cell(nIterations,1);

    % according to matches of anchor node build a colelction of
    % corresponding subgraphs on the lower level
    
    V1 = cell(nIterations,1);
    V2 = cell(nIterations,1);

    D1 = cell(nIterations,1);
    D2 = cell(nIterations,1);
    
    corrmatrix = cell(nIterations,1);     
    affmatrix = cell(nIterations,1);
    
    
    % check if we have same matches as in the iteration before, than we just
    % copy necessary matrices
    
    if (nargin == 5)
        HLG_prev_matched_pairs =  varargin{1};
        prev_LLGmatches =  varargin{2};
        [~, ref_ind] = ismember(HLG_matched_pairs, HLG_prev_matched_pairs, 'rows');
        
        newpairs_ind = find(ref_ind==0);
        
        for k=1:size(ref_ind, 1)
           if ref_ind(k) > 0
               indOfSubgraphsNodes(k,:) = prev_LLGmatches.subgraphsNodes(ref_ind(k),:);
               corrmatrix{k} = prev_LLGmatches.corrmatrices{ref_ind(k) };
               affmatrix{k} = prev_LLGmatches.affmatrices{ref_ind(k) };
           end
        end    
    else
        newpairs_ind = [1:nIterations]';
    end

    % reduce number of iterations, if it is possible
    nIterations = size(newpairs_ind,1);
    

    for i = 1:nIterations % for each match ai<->aj on the High Level
        k = newpairs_ind(i);
        % indices of nodes, that belong to the anchor ai
        ai = HLG_matched_pairs(k,1);
        ai_x = LLG1.U(:,ai);
        V1{k} = LLG1.V(ai_x,:)';
        if (~isempty(LLG1.D))
            D1{k} = LLG1.D(:, ai_x);
        else 
            D1{k} = [];
        end
        adjM1cut = adjM1(ai_x, ai_x');

        % indices of nodes, that belong to the anchor aj
        aj = HLG_matched_pairs(k,2);
        aj_x = LLG2.U(:, aj);
        V2{k} = LLG2.V(aj_x,:)';
        if (~isempty(LLG2.D))
            D2{k} = LLG2.D(:, aj_x);
        else 
            D2{k} = [];
        end
        adjM2cut = adjM2(aj_x, aj_x');

        indOfSubgraphsNodes(k,:) = [ai_x' aj_x'];

        localAdjMatrices1{k} = adjM1cut;
        localAdjMatrices2{k} = adjM2cut;

        display(sprintf(' %d x %d', size(V1{k},2), size(V2{k},2)));
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
    for i = 1:nIterations

        k = newpairs_ind(i);
        
        v1 = V1{k};
        d1 = D1{k};
        nVi = size(v1,2);
        adjM1cut = localAdjMatrices1{k};

        v2 = V2{k};
        d2 = D2{k};
        nVj = size(v2,2);
        adjM2cut = localAdjMatrices2{k};
                
        display(sprintf('matrix %d x %d ', nVi, nVj));

        % correspondence matrix 
        corrmatrix{k} = ones(nVi,nVj);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
        
        % compute initial affinity matrix
        if (nVi==0 || nVj==0 || nVi==1 || nVj==1)
            affmatrix{k} = [];
        else
            affmatrix{k} = initialAffinityMatrix2(v1, v2, d1, d2, adjM1cut, adjM2cut, corrmatrix{k});
        end
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


display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));


end