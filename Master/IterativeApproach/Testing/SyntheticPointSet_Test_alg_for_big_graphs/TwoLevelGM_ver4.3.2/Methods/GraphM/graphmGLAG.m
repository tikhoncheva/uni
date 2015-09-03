function corr = graphmGLAG(A,B,s)
% this function runs the graph matching algorithm GLAG
% it removes the seeds before running the algorithm

% run GLAG
addpath './algorithms/glag'
param.verbose = 0;
[Pm Pp] = graph_matching( A(s+1:end,s+1:end), B(s+1:end,s+1:end), param);

% change output to conform to what we use
[I corr] = sortrows(-Pp');
corr = [1:s (corr'+s)];
