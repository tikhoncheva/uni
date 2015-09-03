function [corr] = graphmAlg(A,B,s, method)
% This function calls the graph matching code writen in c
% method is a string which is the algorithm the graph matching will run
%            choices for method are: I U RANK QCV rand PATH s
% A, B are the graphs which will be matched
% s are the number of vertices which are seeds (which will be ignored)

% find out if this was run in parfor
% get the thread id

% etikhonc 03.09
if ~exist('./temp', 'dir')
    mkdir('./temp');
end
%
id = getThreadID();
path_ = './Methods/GraphM/graphm-0.52/lsgm/';

% clean up after running
cleanupobj = onCleanup(@() cleanup(id));

% save graphs without seeds
dlmwrite(['./temp/graph_A_' num2str(id) '.txt'], full(A(s+1:end,s+1:end)), '	');
dlmwrite(['./temp/graph_B_' num2str(id) '.txt'], full(B(s+1:end,s+1:end)), '	');

% create config file
copyfile( [path_ 'config.txt'], ['./temp/config' num2str(id) '.txt'] );
system(['sed -i ''s/&&&/' num2str(id) '/g'' ./temp/config'  num2str(id) '.txt']);
system(['sed -i ''s/|||/' method '/g'' ./temp/config'  num2str(id) '.txt']);

% run algorithm
system(['./algorithms/graphm-0.52/bin/graphm ./temp/config' num2str(id) '.txt > ./temp/output_' num2str(id)]);

% load results
system(['python ' path_ 'process_output.py ./temp/output_' num2str(id) ' ./temp/output_' num2str(id) '.csv']);

% create corr matrix
corr = load(['./temp/output_' num2str(id) '.csv']);
corr = [1:s corr'+s];

% function which performs clean up
function cleanup(id)
	delete( ['./temp/config'  num2str(id) '.txt'], ...
			['./temp/graph_A_' num2str(id) '.txt'], ...
			['./temp/graph_B_' num2str(id) '.txt'], ...
			['./temp/output_' num2str(id)], ...
			['./temp/output_' num2str(id) '.csv'], ...
			['./temp/gm_verbose_' num2str(id)]);
end
end
