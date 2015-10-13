%% Graph Matching Algorithm

function [objval, X, x] = GraphMatching(corrmatrix, affmatrix)

% conflict groups
[I, J] = find(corrmatrix);
[ group1, group2 ] = make_group12([I, J]);

% run RRW Algorithm 
% tic;
x = RRWM(affmatrix, group1, group2);
%             fprintf('    RRWM: %f sec\n', toc);

X = greedyMapping(x, group1, group2);

objval = X' * affmatrix * X;
% objval = sum(X'.* affmatrix(1:size(affmatrix)+1:end));

end