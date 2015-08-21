 
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
function [LLMatches] = matchLLGraphs(LLG1, LLG2, indOfSubgraphNodes, corrmatrices, affmatrices, HLG_matched_pairs, varargin)      

% fprintf('\n---- LLGM');

nV1 = size(LLG1.V,1);   nV2 = size(LLG2.V,1);  

nMatches = size(HLG_matched_pairs,1);
nV = nV1 * nV2;


% number of local matchings to do
nIterations = size(indOfSubgraphNodes, 1);
objval = 0;
pairs = [];
lobjval = zeros(nMatches, 1);

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
        for it = 1:nIterations

            % nodes, that belong to the anchor ai
            ai_x = logical(indOfSubgraphNodes(it, 2:1+nV1));
            nVi = size(corrmatrices{it},1);

            % nodes, that belong to the anchor aj
            aj_x = logical(indOfSubgraphNodes(it, nV1+2:end));        
            nVj = size(corrmatrices{it},2);

%             fprintf('\n     matrix size %d x %d ', nVi, nVj);

            corrmatrix = corrmatrices{it};
            affmatrix = affmatrices{it};

            [nVi, nVj] = size(corrmatrices{it});

            if (nVi==0 || nVj==0 || sum(affmatrix(:))==0)  % if the affinity matrix is a zero matrix or one subgraph is empty !!!!!!!!!!!!
                local_weights(it,:) = reshape(zeros(nV1, nV2), [1 nV]);
                local_objval(it,1) = 0.;
                continue; 
            end

            % conflict groups
            [I, J] = find(corrmatrix);
            [ group1, group2 ] = make_group12([I, J]);

            % run RRW Algorithm 
%             tic
            x = RRWM(affmatrix, group1, group2);
%             fprintf('    RRWM: %f sec\n', toc);

            X = greedyMapping(x, group1, group2);

            W_local = reshape(X, [nVi, nVj]);
            W = zeros(nV1, nV2);
            W(ai_x, aj_x') = W_local;


            local_weights(it,:) = reshape(W, [1 nV]);
%             local_objval(it,1) = X' * affmatrix * X;
            local_objval(it,1) =sum(X'.* affmatrix(1:size(affmatrix)+1:end));

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

    % for each node pair save ind of the corresponding anchor match
    ind = sub2ind(size(matches_tmp), pairs1, pairs2);
    anchor_match_id = indOfSubgraphNodes(:,1);
    pairs = [pairs1, pairs2, anchor_match_id(matches_tmp(ind))];

    lobjval(anchor_match_id) = local_objval;
%     objval = sum(local_objval);
    objval = sum(lobjval) + matching_score_LL(LLG1, LLG2, pairs);
    
end % if nIterations>0


LLMatches.objval = objval;
LLMatches.matched_pairs = pairs;

LLMatches.lobjval = lobjval;
% LLMatches.lweights = lweights;
% LLMatches.subgraphNodes = indOfSubgraphNodes;
% LLMatches.corrmatrices = corrmatrices;
% LLMatches.affmatrices  = affmatrices;
    
if (nargin == 7)
    
%    HLG_matched_pairs = varargin{1};
% LLG_matched_pairs_prev = varargin{1};
   LLMatched_prev = varargin{1};
   LLG_matched_pairs_prev = LLMatched_prev.matched_pairs;
   
   % for unachanged subraphs copy matching results from prev iterations
   ind_same_anchor_matches = HLG_matched_pairs(:,3);
   ind_same_anchor_matches(ind_same_anchor_matches==0) = [];   
   ind_same_matches = ismember(LLG_matched_pairs_prev(:,3), ind_same_anchor_matches);                                       
   matched_pairs_prev_it = LLG_matched_pairs_prev(ind_same_matches,1:3);
   
   lobjval(ind_same_anchor_matches) = LLMatched_prev.lobjval(ind_same_anchor_matches);
    
    % combine both results
   LLMatches.lobjval = lobjval;
   LLMatches.matched_pairs = [LLMatches.matched_pairs; matched_pairs_prev_it];
%    LLMatches.objval = sum(lobjval);
   LLMatches.objval = sum(lobjval)+ matching_score_LL(LLG1, LLG2, LLMatches.matched_pairs);
    
end
    
% display(sprintf('Summary %f sec', toc));

end