 
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
        poolobj = parpool;                           

        if isempty(poolobj)
            poolsize = 0;
        else
            poolsize = poolobj.NumWorkers;
        end

        display(sprintf('Number of workers: %d', poolsize));

        % global variables
        nIterations = size(LLG1.U, 2);      % number of iterations is equal to number of matched anchor pairs on High Level

        objective = zeros(nIterations, 1);

        nV = nV1 * nV2;
        localMatches = zeros(nIterations, nV);
        
        
        

        % in each step we match points corresponding to the anchor match ai<->aj
        parfor it=3:3

            % node, that belong to the anchor ai
            ai_x = LLG1.U(:,it);
            
            

            LLG1.U(it,:)

            v1 = LLG1.V(ai_x,:)';          
            nVi = size(v1,2);
            display(sprintf('nVi = %d', nVi));
            
            adjM1cut = adjM1(ai_x, ai_x');

            % node, that belong to the anchor aj
            aj_x = LLG2.U(:, HLGmatches(it,:)');
            v2 = LLG2.V(aj_x,:)';
            nVj = size(v2,2);
            display(sprintf('nVj = %d', nVj));
            
            adjM2cut = adjM2(aj_x, aj_x');

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

            %     clear L12;
            %     clear corrMatrix;
            %     clear adjM1cut;
            %     clear adjM2cut;
            %     clear w;
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