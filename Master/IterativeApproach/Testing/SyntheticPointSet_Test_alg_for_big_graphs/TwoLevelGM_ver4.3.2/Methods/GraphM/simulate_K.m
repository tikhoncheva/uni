% add path of other files
addpath './algorithms/'

%% compile methods (eg. PATH)
%cd './algorithms/graphm-0.52'
%system('make clean');
%system('./graphm_install');
%cd '../../'

%% compile GLAG
%cd './algorithms/glag'
%mex vector_th_alpha_beta.cpp;
%cd '../../'

matlabpool(2);

% simulation parameters
num_runs = 20;
num_exp = 2;

% we use the same parameters in Figure 2 in the LSGM paper
% vector of vertices in each block

% matrix for vector of N for each experiment

K = 2:4;
%num_blocks = 10;
% each column of Ns is one experiment ie. N = Ns(:,i)
% Ns is size of the block
%Ns = repmat([50, 100, 150, 200], [num_blocks,1]);
%Ns = repmat([250, 300, 400, 500], [2,1]);
%max_clust_vec = 1.1*[100, 200, 300, 400, 500];
max_clust = 500;
num_params = length(K);%max_clust_vec);%size(Ns,2);
% number of seed vertices
%ms = 2*ones(num_blocks,1);
m = 20;
%nonseeds = m+1:m+sum(N);
% correlation between graphs
corrln = .9;
% make lambda matrix
%lam=  .3*eye(num_blocks)+.3*ones(num_blocks);

save_file_name = 'lsgm-sim-corr_9-K_2_4_500.mat';


%alpha=.5;
%lam=alpha*[.5,.3,.4;.3,.8,.6;.4,.6,.3]+.5*(1-alpha)*ones(3);
%lam = [0.6 0.3 0.2; 0.3 0.7 0.3; 0.2 0.3 0.7];

% random block model
%K = 3;
%N = 30 * ones(K,1);
%lam = rand(K);
%lam=  triu(lam) + triu(lam,1)';


%numdim = rank(lam);
%numdim = 10;
%num_clust = size(Ns,1);
acc = zeros(num_exp, num_params, num_runs);
runtime = zeros(num_exp, num_params, num_runs);
for r = 1:num_runs
  % initalize
  acc_ = zeros(num_exp, num_params);
  runtime_ = zeros(num_exp, num_params);
  for i = 1:num_params
	% make experiments reproducable
	rng(r*num_params+i);
	
	% extract parameters
	num_blocks = K(i);
	fprintf('\nnumber of blocks = %d\n', num_blocks)
	N = 500*ones(num_blocks,1);
%	m = ms(i);
	nonseeds = m+1:m+sum(N);
	
	lam=  .3*eye(num_blocks)+.3*ones(num_blocks);
	numdim = rank(lam);
%	max_clust = max_clust_vec(i);
	
	% generate correlated graphs
	[A, B, shuffle] = sampleGraphs(m, N, corrln, lam);
	ex = 1;
	
	% lsgm
	start = tic;
	[match clust_labels] = BigGM( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlg, @seedgraphmatchell2);
	runtime_(ex,i)  = toc(start);
	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
	ex = ex+1;
	
%	start = tic;
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, @graphmatchell2);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%
%	% lsgmm
%	% choices for method: I U RANK QCV rand PATH s
%	start = tic;
%	gmAlg = @(A,B,s) graphmAlg(A,B,s,'rand');
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
	
	% oracle accuracy
	acc_(ex,i) = mean(clust_labels(nonseeds,1)==clust_labels(shuffle(nonseeds),2));
	ex = ex+1;
	
%	start = tic;
%	gmAlg = @(A,B,s) graphmAlg(A,B,s,'U');
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%	
%	start = tic;
%	gmAlg = @(A,B,s) graphmAlg(A,B,s,'RANK');
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%	
%	start = tic;
%	gmAlg = @(A,B,s) graphmAlg(A,B,s,'QCV');
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%	
%	start = tic;
%	gmAlg = @(A,B,s) graphmAlg(A,B,s,'PATH');
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, gmAlg);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%	
%	% GLAG algorithm
%	start = tic;
%	[match clust_labels] = BigGMr( A,B,m, numdim, max_clust, @spectralEmbed, @kmeansAlgr, @graphmGLAG);
%	runtime_(ex,i) = toc(start);
%	acc_(ex,i) = mean(shuffle(nonseeds)==match(nonseeds));
%	ex = ex+1;
%	
%	% oracle accuracy
%	acc_(ex,i) = clust_labels;
%	ex = ex+1;
	
	% remeber to change num_exp when adding an experiment
  end
  runtime(:,:,r) = runtime_;
  acc(:,:,r) = acc_;
end

save(save_file_name, 'K', 'm', 'N', 'max_clust', 'corrln', 'lam', 'acc', 'runtime');
