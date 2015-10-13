 
%% Matching of Lower Level Graphs
%
% Input
% nV1, nV2              number of node in two graph
% indOfSubgraphNodes    binary matrix (#matchedSubgraphs x (nV1+nV2))
%                       each ith row has 1-entries for the nodes of matched
%                       subgraph pair i
% corrmatrices          cell of correspondence matrices between matched subgraphs
% affmatrices           cell of affinity matrices beween matched subgraphs
%
% Output
%   LLMatches           structure, that contains information about results
%                       of the anchor graphs matching on the current iteration
%     .objval           match score
%     .lobjval           match score
%     .matches          list of matched anchors
%     .corrmatrix       correspondence matrix (nV1 x nV2)
%     .affmatrix        affinity matrix (nV1*nV2 x nV1*nV2)


% function [objval, pairs, ...
%           local_objval, local_weights] = matchLLGraphs(nV1, nV2, indOfSubgraphNodes, corrmatrices, affmatrices)
function [LLMatches] = matchLLGraphs(LLG1, LLG2, indOfSubgraphNodes, corrmatrices, affmatrices, ind_origin_vertices, HLG_matched_pairs, varargin)      

nV1 = size(LLG1.V,1);   nV2 = size(LLG2.V,1);  

nMatches = size(HLG_matched_pairs,1);
nV = nV1 * nV2;


% number of local matchings to do
nIterations = size(indOfSubgraphNodes, 1);
objval = 0;
pairs = [];
lobjval = zeros(nMatches, 1);

corr_matches = cell(nIterations,1);
matchScores = [];

if (nIterations>0)

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
        parfor it = 1:nIterations

            % nodes, that belong to the anchor ai
            ind_Vi = logical(indOfSubgraphNodes(it, 2:1+nV1));
            nVi = size(corrmatrices{it},1);

            % nodes, that belong to the anchor aj
            ind_Vj = logical(indOfSubgraphNodes(it, nV1+2:end));        
            nVj = size(corrmatrices{it},2);

            corrmatrix = corrmatrices{it};
            affmatrix = affmatrices{it};

            [nVi, nVj] = size(corrmatrices{it});

            if (nVi==0 || nVj==0 || sum(affmatrix(:))==0)  % if the affinity matrix is a zero matrix or one subgraph is empty !!!!!!!!!!!!
                local_weights(it,:) = reshape(zeros(nV1, nV2), [1 nV]);
                local_objval(it,1) = 0.;
                continue; 
            end
            
            [objval, X_prime, Xraw_prime] = GraphMatching(corrmatrix, affmatrix);
            
%             ind_same = ind_origin_vertices{it}; 
%             nVi = ind_same(1,1); nVj = ind_same(1,2);
%             ind_same = ind_same(3:end)';
            
%             X = X(ind_same);
%             objval = X' * affmatrix(ind_same, ind_same) * X;
            
            [corr_matches{it}(:,1), corr_matches{it}(:,2)] = find(corrmatrix);
            all_matches = [repmat((1:nVi)', nVj,1), kron((1:nVj)', ones(nVi,1))];
            ind_same = ismember(all_matches, corr_matches{it}, 'rows');
            
            X = zeros(size(all_matches,1), 1);     X(ind_same) = X_prime;
            Xraw = zeros(size(all_matches,1), 1);  Xraw(ind_same) = Xraw_prime;
            
            W_local = reshape(Xraw.*X, [nVi, nVj]);
            W = zeros(nV1, nV2);
            W(ind_Vi, ind_Vj') = W_local;

            local_weights(it,:) = reshape(W, [1 nV]);
            local_objval(it,1) = objval;

%             clear ai_x aj_x;
%             clear X Xraw X_prime Xraw_prime corr_matches;
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
    
    [matches_tmp, matches_HLind] = max(local_weights, [], 1);        % maximum in each column 
    matches_tmp = matches_HLind.*logical(matches_tmp);
    matches_tmp = reshape(matches_tmp, nV1,nV2);  

    % not 1-to-1 matching
    [pairs1, pairs2] = find(matches_tmp); 
    matchScores = matches_tmp(sub2ind([nV1, nV2], pairs1, pairs2));
    
    % for each node pair save ind of the corresponding anchor match
    ind = sub2ind(size(matches_tmp), pairs1, pairs2);
    anchor_match_id = indOfSubgraphNodes(:,1);
    pairs = [pairs1, pairs2, anchor_match_id(matches_tmp(ind))];

    lobjval(anchor_match_id) = local_objval;
%     objval = sum(local_objval);
%     objval = sum(lobjval) + matching_score_LL(LLG1, LLG2, pairs);
    objval = matching_score_LL(LLG1, LLG2, pairs);
end % if nIterations>0


LLMatches.objval = objval;
LLMatches.matchScores = matchScores;
LLMatches.matched_pairs = pairs;
LLMatches.lobjval = lobjval;

% LLMatches.lweights = lweights;
% LLMatches.subgraphNodes = indOfSubgraphNodes;
% LLMatches.corrmatrices = corrmatrices;
% LLMatches.affmatrices  = affmatrices;
    
if (nargin == 8)
    
%    HLG_matched_pairs = varargin{1};
% LLG_matched_pairs_prev = varargin{1};

   LLMatched_prev = varargin{1};
   LLG_matched_pairs_prev = LLMatched_prev.matched_pairs;
   
   % for unachanged subraphs copy matching results from prev iterations
   I = [HLG_matched_pairs(:,3), (1:size(HLG_matched_pairs,1))']; % first column : indices of the unchanged anchor matches in prev iteration
   I(I(:,1)==0,:) = [];                                          % second column: indices of the unchanged anchor matches in curr iteration
   
   ind_same_matches = ismember(LLG_matched_pairs_prev(:,3), I(:,1));       
   same_matches_prev_it = LLG_matched_pairs_prev(ind_same_matches,1:3);
   [~, indI] = ismember(same_matches_prev_it(:,3), I(:,1));
   same_matches_prev_it(:,3) = I(indI,2);                       % replace old indices (prev it) with the new one
   
   same_matchScores_prev_it = LLMatched_prev.matchScores(ind_same_matches);
   
   lobjval(I(:,2)) = LLMatched_prev.lobjval(I(:,1));
    % combine both results
   LLMatches.lobjval = lobjval;
   LLMatches.matched_pairs = [LLMatches.matched_pairs; same_matches_prev_it];
   LLMatches.matchScores = [LLMatches.matchScores; same_matchScores_prev_it];
%    LLMatches.objval = sum(lobjval);
%    LLMatches.objval = sum(lobjval)+ matching_score_LL(LLG1, LLG2, LLMatches.matched_pairs);
    LLMatches.objval = matching_score_LL(LLG1, LLG2, LLMatches.matched_pairs);
end
    
% display(sprintf('Summary %f sec', toc));

end