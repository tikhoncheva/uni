 
%% Matching of Lower Level Graphs
%
% Input
% nV1, nV2          number of node in two graph

% corrmatrix      correspondence matrix
% affmatrix       affinity matrix
%
% Output
%   objval      riched match score
%  matches      boolean matrix of matches if the size (nV1 x nV2)


function [objval, matches] = matchLLGraphs(nV1, nV2, corrmatrix, affmatrix)

display(sprintf('\n================================================'));
display(sprintf('Match initial graphs'));
display(sprintf('=================================================='));

tic 

try    
    % conflict groups
    [I, J] = find(corrmatrix);
    [ group1, group2 ] = make_group12([I, J]);

    % run RRW Algorithm 
    tic
    x = RRWM(affmatrix, group1, group2);
    fprintf('    RRWM: %f sec\n', toc);

    X = greedyMapping(x, group1, group2);    
    objval = X' * affmatrix * X;
    
    X = reshape(X, nV1, nV2);
    
    [pairs1, pairs2] = find(X);
    matches = [pairs1, pairs2];
    
catch ME
    msg = 'Error occurred in Lower Level Graph Matching in parallel pool';
    causeException = MException(ME.identifier, msg);
    ME = addCause(ME, causeException);

    rethrow(ME);
end

display(sprintf('Summary %f sec', toc));
display(sprintf('=================================================='));

end