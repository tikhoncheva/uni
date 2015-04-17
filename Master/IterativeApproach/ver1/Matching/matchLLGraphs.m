 
%% Matching of dependency graphs
%
% Input
% DG1, DG2      two graphs with nV1 and nV2 nodes respectively
% AG1, AG2      corresponding anchor graphs
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchLLGraphs(LLG1, LLG2, HLG1, HLG2, HLGmatches)

display(sprintf('\n================================================'));
display(sprintf('Match initial graphs'));
display(sprintf('=================================================='));

try
    nV1 = size(LLG1.V,1);
    nV2 = size(LLG2.V,1);

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nV1, nV2);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nV1, nV2);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;



    display(sprintf(' -------------------------------------------------- '));
    display(sprintf('              Start Parallel Pool                   '));
    display(sprintf(' -------------------------------------------------- '));

    try
        % ----------------------------------------------------------------
        % Preprocessing : collect global inforamtion
        % ----------------------------------------------------------------
        tic 
        % global variables
        nIterations = size(LLG1.U, 2);      % number of iterations is equal to number of matched anchor pairs on High Level

        objective = zeros(nIterations, 1);

        nV = nV1 * nV2;
        localMatches = zeros(nIterations, nV);
        
        % save separately indices of nodes, that should be matched parallel on the Lower Level
        nodeCorresp = zeros(nIterations, nV1 + nV2);
        
        localAdjMatrices1 = cell(nIterations);
        localAdjMatrices2 = cell(nIterations);
        
        V1 = cell(nIterations);
        V2 = cell(nIterations);
        
        for it = 1:nIterations % for each match ai<->aj on the High Level
            
            % indices of nodes, that belong to the anchor ai
            ai_x = LLG1.U(:,it);
            V1{it} = LLG1.V(ai_x,:)';
            adjM1cut = adjM1(ai_x, ai_x');
            
            % indices of nodes, that belong to the anchor aj
            aj_x = LLG2.U(:, HLGmatches(it,:)');
            V2{it} = LLG2.V(aj_x,:)';
            adjM2cut = adjM2(aj_x, aj_x');
            
            nodeCorresp(it,:) = [ai_x' aj_x'];
      
            localAdjMatrices1{it} = adjM1cut;
            localAdjMatrices2{it} = adjM2cut;
            
            display(sprintf(' %d x %d', size(V1{it},2), size(V2{it},2)));
        end
        
        display(sprintf('Preprocessing took %f sec', toc));
        
        
        
        poolobj = parpool(3);                           

        if isempty(poolobj)
            poolsize = 0;
        else
            poolsize = poolobj.NumWorkers;
        end
        display(sprintf('Number of workers: %d', poolsize));
        
        % ----------------------------------------------------------------
        % Run parallel
        % ----------------------------------------------------------------
        % in each step we match points corresponding to the anchor match ai<->aj
        parfor it = 1:1
            node_ind = nodeCorresp(it,:);
            % node, that belong to the anchor ai
            ai_x = logical(node_ind(1:nV1));

            v1 = V1{it};          
            nVi = size(v1,2);
            display(sprintf('nVi = %d', nVi));
            
            adjM1cut = localAdjMatrices1{it};

            % node, that belong to the anchor aj
            aj_x = logical(node_ind(nV1+1:end));
            
            v2 = V2{it};
            nVj = size(v2,2);
            display(sprintf('nVj = %d', nVj));
            
            adjM2cut = localAdjMatrices2{it};

            % correspondence matrix (!!!!!!!!!!!!!!!!!!!!!! now: all-to-all)
            corrMatrix = ones(nVi,nVj);

            % compute initial affinity matrix
            AffMatrix = initialAffinityMatrix2(v1, v2, adjM1cut, adjM2cut, corrMatrix);

            % conflict groups
            [I, J] = find(corrMatrix);
            [ group1, group2 ] = make_group12([I, J]);

            % run RRW Algorithm 
            tic
            x = RRWM(AffMatrix, group1, group2);
            fprintf('    RRWM: %f sec\n', toc);

            X = greedyMapping(x, group1, group2);

            objective(it) = x'*AffMatrix * x;

            matchesL = zeros(nVi, nVj);
            for k=1:numel(I)
                matchesL(I(k), J(k)) = X(k);
            end  

            %     w = HLG1.Z(a1_x, it);
            %     matchesL =  matchesL.*repmat(w, 1, nV2);
            matches = zeros(nV1, nV2);
            matches(ai_x, aj_x') = matchesL;
            localMatches(it, :) = reshape(matches, [1 nV]);
            
        end

    catch ME
        msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
        causeException = MException(ME.identifier, msg);
        ME = addCause(ME, causeException);

        % close parallel pool
        delete(gcp('nocreate'));

        rethrow(ME);
    end

    delete(poolobj); 
    display(sprintf('Delete parallel pool %d', poolsize));
    display(sprintf(' -------------------------------------------------- '));

    % % matches = matchesW;
    % matchesW = zeros(nV1, nV2);
    matches = max(localMatches,[], 1);
    matches = reshape(matches, nV1,nV2);

    % for i=1:nV1
    %    [val, ind] = max(matchesW(i,:));
    %    if val>0
    %        matches(i,ind) = 1;
    %    end
    % end

    matches = logical(matches);
    
    objval = sum(objective);

    display(sprintf('=================================================='));

catch
    msg = 'Error occurred in Lower Level Graph Matching';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);
    
    rethrow(ME);   
end

end