%% read benchmark from the QAPLIB
function [problem, T_summary] = read_QAPLIB_test(bench_name, Set)
%%
fproblem_name =  [bench_name, '.dat'];
fsolution_name =  [bench_name, '.sln'];

prob_matrix = dlmread(fproblem_name);
sol_matrix = dlmread(fsolution_name);

n = prob_matrix(1,1);           % number of nodes in the graphs
assert(2*n+1 == size(prob_matrix,1), 'Error: wrong input file format');
G1 = prob_matrix(2:1+n,1:n);      % distance matrix of the first graph
G2 = prob_matrix(2+n:1+2*n,1:n);  % distance matrix of the first graph

assert(n==sol_matrix(1,1), 'Error: wrong input file format');
assert(n==size(sol_matrix,2), 'Error: wrong input file format');
seq = sol_matrix(2,:);

%%
t1 = tic; 
%% 2nd Order Matrix
E12 = ones(n,n);
[L12(:,1), L12(:,2)] = find(E12);
[group1, group2] = make_group12(L12);

%%
M = (repmat(G1, n, n)-kron(G2,ones(n))).^2;
M = exp(-M./Set.scale_2D);
M(1:(n+1):end)=0;

%% Ground Truth
GT.seq = seq;
GT.matrix = zeros(n, n);
for i = 1:n, GT.matrix(i,seq(i)) = 1; end
GT.bool = GT.matrix(:);


%% Return the value
problem.nP1 = n;
problem.nP2 = n;
problem.L12 = L12;
problem.E12 = E12;

problem.G1 = G1;
problem.G2 = G2;

problem.affinityMatrix = M;
problem.group1 = group1;
problem.group2 = group2;

problem.GTbool = GT.bool;

%%
T_summary = toc(t1);

end