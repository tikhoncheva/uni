% MATLAB demo code for testing different matching algorithm on two images
% written by E.Tikhoncheva, 08.09.2015

% BASED ON: MATLAB demo code of Max-Pooling Matching CVPR 2014
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
disp('************************ Image Matching Test ************************');disp(' ');

%% Settings Evaluations
setPath;
setMethods;

%% 
plotSet.lineWidth = 3; % Line width
plotSet.markerSize = 10; % Marker Size
plotSet.fontSize = 15; % Font Size
plotSet.font = '\fontname{Arial}'; % Font default

%% house_seq
filepath = '../../../../data/houseBigger/';
% savepath = './Results/HouseSeq/descr/using_cpd_afftrafo/solution/';
savepath = './Results/HouseSeq2/descr/using_cpd_afftrafo/ext_solution/';
% savepath = './Results/HouseSeq/descr/using_cpd_afftrafo/init_GT/';

if ~exist(savepath, 'dir')
   mkdir(savepath);
end
if ~exist([savepath, 'performance/'], 'dir')
   mkdir([savepath, 'performance/']);
end

listOfimages = dir([ filepath 'house.seq*.png' ]);

% sort file names
for m = 1:size(listOfimages,1);
    names{m} = str2double(listOfimages(m).name(10:end-4));
end
[~, ind] =  sort(cell2mat(names));
names = {listOfimages.name}';
names = names(ind);

nImg = size(names,1);

%%
nTests = 3;
gap = [1, (10:10:110)];

%% storage for matching results
accuracy = zeros(numel(gap), length(methods), nTests);
score    = zeros(numel(gap), length(methods), nTests);
score2   = zeros(numel(gap), length(methods), nTests);
time     = zeros(numel(gap), length(methods), nTests);

time_init1 = zeros(numel(gap), nTests);
time_init2 = zeros(numel(gap), nTests);

X = cell(numel(gap), length(methods), nTests);

perform_data = cell(numel(gap), length(methods), nTests);

%% start parallel pool
poolobj = parpool(3);       

%% main loop start

t_start = clock;
fprintf(['Experiment starts: ' num2str(t_start(4)) ':' num2str(t_start(5)) ':' num2str(round(t_start(6))) '\n']);


for k = 1:numel(gap)
    gap_k = gap(k);
    fprintf('Test: %d of %d, current gap %d \n', k, numel(gap), gap_k);
        
    for test_i =1:min(nImg-gap_k, nTests)
        
        nimg1 = test_i;
        nimg2 = nimg1+gap_k;   
            
        fname1 = names{nimg1};
        fname2 = names{nimg2};
            
        disp('----------------------------------------------------------------');
        display(sprintf('%s',fname1));
        display(sprintf('%s',fname2));
        disp('----------------------------------------------------------------');

        %% Preprocessing
        iparam.view(1).fileName = fname1(1:end-4);
        iparam.view(1).filePathName = [filepath, fname1];

        iparam.view(2).fileName = fname2(1:end-4);
        iparam.view(2).filePathName = [filepath, fname2];

        iparam.nView = 2;   iparam.bPair = 1; iparam.bShow = 0;

        % file with the saved GT
        resultTag = [ iparam.view(1).fileName '+' iparam.view(2).fileName ];
        initPathnFile = [ filepath 'GT_all_to_all/' 'fi_' resultTag '.mat' ];

        [problem, time_init1(k, test_i), time_init2(test_i)] = ...
                                            makeProblem(iparam, initPathnFile);
        disp('----------------------------------------------------------------');
        %% Test Methods
        for m = 1:length(methods)
            str = sprintf('run_algorithm_house_seq(''%s'', problem);', func2str(methods(m).fhandle));
            [accuracy(k,m,test_i), ...
               score(k,m, test_i), ...
              score2(k,m, test_i), ...
                 time(k,m,test_i), ...
                   X{k,m, test_i}, ...
         perform_data{k,m,test_i}] = eval(str);

%             mname = func2str(methods(m).fhandle);
%             f1 = plotMatches(mname, problem, ...
%                          accuracy(k,m,test_i), score(k,m,test_i), X{k,m,test_i});                 
%             print(f1, [savepath, 'fi_', num2str(test_i), '_', mname(9:end)],'-dpng');            
%             close all;
        end
                
        %%
        
        clear iparam problem mname;
        disp('================================================================');disp(' ');
    end     
end
%% close parallel pool
delete(poolobj);  

%% Plot results

% Mean
meanAccuracy = mean(accuracy,3);
meanScore = mean(score,3);
meanTime = mean(time,3);

% Std
stdAccuracy = sqrt( sum( (accuracy - repmat(meanAccuracy, 1, 1, nTests)).^2, 3)./nTests );
stdScore = sqrt( sum((score - repmat(meanScore, 1, 1, nTests)).^2, 3)./nTests );
stdTime = sqrt( sum((time - repmat(meanTime, 1, 1, nTests)).^2, 3)./nTests );

names = {'accuracy', 'score', 'time', 'time_summary'};

handleCount = 0;
xData = gap;
yData = meanAccuracy; E = stdAccuracy; yLabelText = 'accuracy'; plotResults;
yData = meanScore; E = stdScore; yLabelText = 'objective score'; plotResults;
yData = meanTime; E = stdTime; yLabelText = 'running time'; plotResults;

%% Time with initialization
time1 = zeros(numel(gap), length(methods), nTests);
time1(:, 1, :) = time_init1;
time1(:, 2, :) = time_init2;
time1 = time + time1;

meanTime1 = mean(time1,3);
stdTime1 = sqrt( sum((time1 - repmat(meanTime1, 1, 1, nTests)).^2, 3)./nTests );

yData = meanTime1; E = stdTime1; yLabelText = 'running time + initialization'; plotResults;

%% Save mat files
save([savepath, 'performance/' 'accuracy.mat'], 'accuracy');
save([savepath, 'performance/' 'score.mat'], 'score');
save([savepath, 'performance/' 'time.mat'], 'time');
save([savepath, 'performance/' 'time_summary.mat'], 'time1');
save([savepath, 'performance/' 'perform_data.mat'], 'perform_data');