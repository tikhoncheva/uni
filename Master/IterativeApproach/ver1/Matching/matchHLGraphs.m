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
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchHLGraphs(corrmatrix, affmatrix)

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

    objval = x'*affmatrix * x;

    matches = zeros(nV1, nV2);
    for i=1:size(L12,1)
        matches(L12(i,1), L12(i,2)) = X(i);
    end  

    matches = logical(matches);
    
catch ME
    
    msg = 'Error occurred in Higher Level Graph Matching';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);
    
    rethrow(ME);   
end