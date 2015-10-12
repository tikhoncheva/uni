 %% Initialization function for setting the iterative graph matching
 %
 %
 
function [indOfSubgraphsNodes, corrmatrix, affmatrix, ind_origin_vertices] = initialization_LLGM(LLG1, LLG2, ...
                                                                              U1, U2, ....
                                                                            HLG_matched_pairs)

fprintf('\n---- preprocessing: initialize %d subgraphs', size(HLG_matched_pairs,1));

try
%     tic 
    
    nVi = size(LLG1.V,1); 
    nVj = size(LLG2.V,1);

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nVi, nVi);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nVj, nVj);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;  

    % number of iterations is equal to number of found pairs in HLG
    ind_new_subgraphPairs  = find(HLG_matched_pairs(:,3) == 0);
    
    nPairs = numel(ind_new_subgraphPairs); 

    % build pairs of subgraph to match

    indOfSubgraphsNodes = zeros(nPairs, 1 + nVi + nVj); % indices of nodes, that can be matched parallel

    localAdjMatrices1 = cell(nPairs,1);
    localAdjMatrices2 = cell(nPairs,1);

    V1 = cell(nPairs,1);
    V2 = cell(nPairs,1);

    D1 = cell(nPairs,1);
    D2 = cell(nPairs,1);
    
    candM = cell(nPairs,1);
    
    corrmatrix = cell(nPairs,1);     
    affmatrix = cell(nPairs,1);
    
    ind_origin_vertices = cell(nPairs,1);
    
    for i = 1:nPairs % for each match ai<->aj on the High Level
        
        % indices of nodes, that belong to the anchor ai
        ai = HLG_matched_pairs(ind_new_subgraphPairs(i),1);
        
        ind_Vi = U1(:,ai);
        V1{i} = LLG1.V(ind_Vi,1:2)';
        if (~isempty(LLG1.D))
            D1{i} = LLG1.D(:, ind_Vi);
        else 
            D1{i} = [];
        end
        adjM1cut = adjM1(ind_Vi, ind_Vi');

        % indices of nodes, that belong to the anchor aj
        aj = HLG_matched_pairs(ind_new_subgraphPairs(i),2);
        
        ind_Vj = U2(:, aj);
        V2{i} = LLG2.V(ind_Vj,1:2)';
        if (~isempty(LLG2.D))
            D2{i} = LLG2.D(:, ind_Vj);
        else 
            D2{i} = [];
        end
        adjM2cut = adjM2(ind_Vj, ind_Vj');

        indOfSubgraphsNodes(i,1) = ind_new_subgraphPairs(i);
        indOfSubgraphsNodes(i,2:end) = [ind_Vi' ind_Vj'];
        localAdjMatrices1{i} = adjM1cut;
        localAdjMatrices2{i} = adjM2cut;
        
        ind_Vj = find(ind_Vj);
        candM_ViVj_cell = LLG1.candM(ind_Vi,1);
        candM_ViVj_pairs = [];
        for vi = 1:nnz(ind_Vi)
            cand_vj = candM_ViVj_cell{vi};
            ind_present = find(ismember(ind_Vj, cand_vj));
            
            cand_vivj = [repmat(vi, numel(ind_present),1), ind_present];
            candM_ViVj_pairs = [candM_ViVj_pairs; cand_vivj];
        end
        candM{i} = candM_ViVj_pairs;
       
        clear ind_Vi ind_Vj Vi Vj ai aj;
        clear adjM1cut adjM2cut;
        clear candM_ViVj_cell candM_ViVj_pairs
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
%     parfor i = 1:nPairs
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
%         corrmatrix{i} = ones(nVi,nVj);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all
        corrM = zeros(nVi,nVj);                                            % use candidate matches
        candM_pairs = candM{i};
        corrM(sub2ind([nVi, nVj], candM_pairs(:,1), candM_pairs(:,2))) = 1;
        corrmatrix{i} = corrM;
        

        % compute initial affinity matrix
%         if (nVi==0 || nVj==0 || nVi==1 || nVj==1)
%             affmatrix{i} = [];
%         else
        if (nVi>1 && nVj>1)
            affmatrix{i} = initialAffinityMatrix2(v1, v2, d1, d2, adjM1cut, adjM2cut, corrmatrix{i});
        end
        
        ind_origin_vertices{i} = [nVi, nVj, (1:nVi*nVj)];
        
       %% add dummy nodes into affinity matrix
%         dNi = max(0, nVj-nVi) ; dNj = max(0, nVi-nVj);
%         affmatrixD = 0.0*ones((nVi+dNi)*(nVj+dNj));
%         
%         I = repmat([1:nVi+dNi]', nVj+dNj, 1);
%         J = kron([1:nVj+dNj]', ones(nVj+dNj, 1));
%         
%         Io = repmat([1:nVi]', nVj, 1);
%         Jo = kron([1:nVj]', ones(nVi, 1));
%         
%         [~,ind_same] = ismember([Io,Jo], [I,J], 'rows');
%         [x,y] = meshgrid(ind_same, ind_same);
%         ind = sub2ind(size(affmatrixD), x(:), y(:));
%         
%         affmatrixD(ind) = affmatrix{i};
%         affmatrix{i} = affmatrixD;
%         corrmatrix{i} = ones(nVi+dNi, nVj+dNj); 
%     
%         ind_origin_vertices{i} = [nVi, nVj, ind_same'];
        % 
        
%         display(sprintf('matrix %d x %d ... finished', nVi, nVj));

        clear v1 v2 d1 d2 adjM1cut adjM2cut corrM candM_pairs;
    end

catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    % close parallel pool
    delete(gcp('nocreate'));

    rethrow(ME);
end



end