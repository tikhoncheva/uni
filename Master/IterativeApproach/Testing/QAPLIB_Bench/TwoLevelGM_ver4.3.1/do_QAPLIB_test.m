% MATLAB demo code for testing different matching algorithm on benchmark
% from QAPLIB library
% E.Tikhoncheva, 27.08.2015

% BASED ON: MATLAB demo code of Max-Pooling Matching CVPR 2014
%
% M. Cho, J. Sun, O. Duchenne, J. Ponce
% Finding Matches in a Haystack: A Max-Pooling Strategy for Graph Matching in the Presence of Outliers 
% Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (2014) 
% http://www.di.ens.fr/willow/research/maxpoolingmatching/
%
% Please cite our work if you find this code useful in your research. 
%
% written by Minsu Cho, Inria - WILLOW / Ecole Normale Superieure 
% http://www.di.ens.fr/~mcho/

clear all; close all; clc;
disp('************************ Point Matching Test ************************');disp(' ');

%% Settings Evaluations
setPath;
setPointMatching;
setMethods;

%% Benchmark
bench_name = {'chr12c'; 'chr15a'; 'chr15c'; 'chr20b'; 'chr22b'; 'esc16b'; 
              'rou12'; 'rou15'; 'rou20'; ...
              'tai15a'; 'tai17a'; 'tai20a'};
% bench_name = {'chr12c'};      
n_test = size(bench_name,1); 

%%
plotSet.lineWidth = 3; % Line width
plotSet.markerSize = 10; % Marker Size
plotSet.fontSize = 15; % Font Size
%plotSet.font = '\fontname{times new roman}'; % Font default
plotSet.font = '\fontname{Arial}'; % Font default

%% Test Methods
Accuracy = zeros(n_test, length(methods));
MatchScore = zeros(n_test, length(methods));

% etikhonc, 25.08.2015, time for initialization of the problem
Time_init = zeros(n_test, 1);

Time = zeros(n_test, length(methods));
MatchScoreRaw = zeros(n_test, length(methods));
MatchScoreMP = zeros(n_test, length(methods));
X = cell(n_test, length(methods));

t_start = clock;
fprintf(['Experiment starts: ' num2str(t_start(4)) ':' num2str(t_start(5)) ':' num2str(round(t_start(6))) '\n']);

for kk = 1:n_test
    fprintf('Benchmark: %s, %d(th) from %d ', bench_name{kk,1}, kk, n_test);
    
    [problem, time_init] = read_QAPLIB_test(bench_name{kk,1}, Set);
    Time_init(kk,1) = time_init;
     
    for j = 1:length(methods)
        [Accuracy(kk,j), MatchScore(kk,j), Time(kk,j), X{kk,j}] ...
            = wrapper_GM(methods(j), problem);
    end
    
    fprintf('.');
        
%     clf; handleCount = 0;
%     yData = mean(Accuracy(:,:,1:kk),3);
%     L = yData-min(Accuracy(:,:,1:kk),[],3);
%     U = max(Accuracy(:,:,1:kk),[],3)-yData;
%     yLabelText = 'Accuracy'; plotResults;
%     str = ['Average accuracy from test 1 to test ' num2str(kk)]; title(str, 'FontSize', 16); drawnow;

    t_now = clock; elap = etime(t_now, t_start); t_end = add_time(t_start, elap/(kk)*(Set.nTest));
    fprintf(['  expected time to end' num2str(t_end(4)) ':' num2str(t_end(5)) ':' num2str(round(t_end(6))) '\n']);
end
clear i j k temp Xbin ind p val str
close all

%% Plot Results
% meanAccuracy = mean(Accuracy,3);
% meanMatchScore = mean(MatchScore,3);
% meanTime = mean(Time,3);
% meanMatchScoreRaw = mean(MatchScoreRaw,3);
% meanMatchScoreMP = mean(MatchScoreMP,3);
% 
% %%
% handleCount = 0;
% yData = meanAccuracy; yLabelText = 'accuracy'; plotResults;
% yData = meanMatchScore; yLabelText = 'objective score'; plotResults;
% yData = meanTime; yLabelText = 'running time'; plotResults;
% 
% %%
% T1 = repmat(Time_init(:,1), 1, length(methods),1);
% Time1 = Time + T1;
% meanTime1 = mean(Time1,3);
% yData = meanTime1; yLabelText = 'running time + initialization'; plotResults;
