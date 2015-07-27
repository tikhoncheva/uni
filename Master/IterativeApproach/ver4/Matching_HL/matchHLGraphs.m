%% Matching of anchor graphs
%  We use Reweighted Random Walk Algorithm for the graph matching
%   (see Minsu Cho, Jungmin Lee, and Kyoung Mu Lee "Reweighted Random Walks
%   for Graph Matching")
%
% Input
%     corrmatrix  correspondence matrix between two graphs
%     affmatrix   affinity matrix between two graphs
%
% Output
%     HLMatches   structure, that contains information about results
%                 of the anchor graphs matching on the current iteration
%     .objval     match score
%     .matches    list of matched anchors
%     .corrmatrix correspondence matrix (nA1 x nA2)
%     .affmatrix  affinity matrix (nA1*nA2 x nA1*nA2)


function [HLMatches] = matchHLGraphs(corrmatrix, affmatrix, varargin)

display(sprintf('\n================================================'));
display(sprintf('Match Higher Level Graphs'));
display(sprintf('=================================================='));

try 
    nV1 = size(corrmatrix, 1);  % number of nodes in the first graph
    nV2 = size(corrmatrix, 2);  % number of nodes in the second graph
    
    % conflict groups
    [L12(:,1), L12(:,2)] = find(corrmatrix);
    [ group1, group2 ] = make_group12(L12);

    % run RRW Algorithm 
    tic
    x = RRWM(affmatrix, group1, group2);
    display(sprintf('  time spent for the RRWM on the anchor graph: %f sec', toc));
    display(sprintf('==================================================\n'));
        
    X = greedyMapping(x, group1, group2);
    objval = X'*affmatrix * X;

    matches = logical(reshape(X,nV1, nV2));
    [pairs(:,1), pairs(:,2)] = find(matches);       % matched pairs of anchor graphs
    
    
    if (nargin == 5)        % if we have information about previously matched anchors    
        HLG1 = varargin{1}; HLG2 = varargin{2};
        HLMatches_prev =  varargin{3};
        pairs_prev = HLMatches_prev.matched_pairs(:,1:2);
        
        [~, ind_same_matches ] = ismember(pairs, pairs_prev, 'rows');
        ind_same_matches = ind_same_matches.* HLG1.F(pairs(:,1));
        ind_same_matches = ind_same_matches.* HLG2.F(pairs(:,2));
        
        pairs(:,3) = ind_same_matches;
    else        
        pairs(:,3) = 0;
    end
    
    
    HLMatches = struct('objval', objval, 'matched_pairs', pairs);
%                        , 'corrmatrix', corrmatrix, 'affmatrix', affmatrix);
%     HLMatches.objval = objval;
%     HLMatches.matched_pairs = matched_pairs;
%     HLMatches.corrmatrix = corrmatrix;
%     HLMatches.affmatrix = affmatrix;

catch ME
    
    msg = 'Error occurred in Higher Level Graph Matching';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);
    
    rethrow(ME);   
end