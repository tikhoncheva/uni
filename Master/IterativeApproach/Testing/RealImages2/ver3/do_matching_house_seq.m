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
filepath = '../../../../data/houseSmall/';
savepath1 = './Results/HouseSeq/descr/using_cpd_afftrafo/solution2/';
% savepath = './Results/HouseSeq/descr/using_cpd_afftrafo/solution/';
savepath2 = './Results/HouseSeq/descr/using_cpd_afftrafo/ext_solution2/';
% savepath = './Results/HouseSeq/descr/using_cpd_afftrafo/init_GT/';

if ~exist(savepath1, 'dir')
   mkdir(savepath1);
end
if ~exist([savepath1, 'performance/'], 'dir')
   mkdir([savepath1, 'performance/']);
end
if ~exist(savepath2, 'dir')
   mkdir(savepath2);
end
if ~exist([savepath2, 'performance/'], 'dir')
   mkdir([savepath2, 'performance/']);
end

listOfimages = dir([ filepath 'house.seq*.png' ]);

% sort file names
for i = 1:size(listOfimages,1);
    names{i} = str2double(listOfimages(i).name(10:end-4));
end
[~, ind] =  sort(cell2mat(names));
names = {listOfimages.name}';
names = names(ind);

fnamelist = names(2:end);
fnamelist(:,2) = repmat(names(1), size(names,1) - 1,1);
fnamelist = [fnamelist(:,2), fnamelist(:,1)];
nImagePairs = size(fnamelist,1);

%% storage for matching results
accuracy1 = zeros(nImagePairs, length(methods));
accuracy2 = zeros(nImagePairs, length(methods));
accuracy3 = zeros(nImagePairs, length(methods));

score1 = zeros(nImagePairs, length(methods));
score2 = zeros(nImagePairs, length(methods));
time = zeros(nImagePairs, length(methods));

time_init1 = zeros(nImagePairs,1);
time_init2 = zeros(nImagePairs,1);

X1 = cell(nImagePairs, length(methods));
X2 = cell(nImagePairs, length(methods));
% Xraw = cell(nImagePairs, length(methods));
perform_data = cell(nImagePairs, length(methods));

%% start parallel pool
poolobj = parpool(3);       
%% main loop start
for cImg=1:nImagePairs
%     cImg = 1;
    fname1 = fnamelist{cImg,1};
    fname2 = fnamelist{cImg,2};
%     fname1 = 'sun_aafpznbwiqbmolft_a2.png';
%     fname2 = 'sun_aafpznbwiqbmolft_b.png';
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
    initPathnFile = [ filepath 'GT/' 'fi_' resultTag '.mat' ];
    
    [problem, time_init1(cImg), time_init2(cImg)] = ...
                                        makeProblem(iparam, initPathnFile);
    disp('----------------------------------------------------------------');
    %% Test Methods
    for i = 1:length(methods)
        str = sprintf('run_algorithm_house_seq(''%s'', problem);', func2str(methods(i).fhandle));
        [accuracy1(cImg,i), accuracy2(cImg,i), accuracy3(cImg,i), ...
            score1(cImg,i),    score2(cImg,i),      time(cImg,i), ...
                X1{cImg,i}, X2{cImg,i}, perform_data{cImg,i}] = eval(str);

        fprintf('Algorithm:%s   Accuracy: %.3f (%.3f) Score: %.3f (%.3f) Time: %.3f\n',...
                func2str(methods(i).fhandle), accuracy1(cImg,i), accuracy2(cImg,i), ...
                score1(cImg,i), score2(cImg,i), time(cImg,i));
        
        mname = func2str(methods(i).fhandle);        
        f1 = plotMatches(mname, problem, ...
                     accuracy1(cImg,i), score1(cImg,i), X1{cImg,i});                 
        print(f1, [savepath1, 'fi_', num2str(cImg), '_', mname(9:end)],'-dpng');         
        
        f2 = plotMatches(mname, problem, ...
                     accuracy2(cImg,i), score2(cImg,i), X2{cImg,i});                 
        print(f1, [savepath2, 'fi_', num2str(cImg), '_', mname(9:end)],'-dpng');    
        
        close all;
    end

    %% Plot changes in Precision, Recall
%     visPerformPlot;

    %%
    clear iparam problem mname;
    disp('================================================================');disp(' ');
end     

%% close parallel pool
delete(poolobj);  
%%
names = {'accuracy', 'score', 'time', 'time_summary'};
handleCount = 0;
xData = [1, (10:10:100)];
E = zeros(size(accuracy1));
% Time with initialization
time_summary = time + [time_init1, time_init2, zeros(nImagePairs,1)];

%%
savepath = savepath1;
yData = accuracy1; yLabelText = 'accuracy'; plotResults;
yData = score1; yLabelText = 'objective score'; plotResults;
yData = time; yLabelText = 'running time'; plotResults;
yData = time_summary; yLabelText = 'running time + initialization'; plotResults;

% Save mat files
save([savepath, 'performance/' 'accuracy.mat'], 'accuracy1');
save([savepath, 'performance/' 'score.mat'], 'score1');
save([savepath, 'performance/' 'time.mat'], 'time');
save([savepath, 'performance/' 'time_summary.mat'], 'time_summary');
save([savepath, 'performance/' 'perform_data.mat'], 'perform_data');

%%
savepath = savepath2;

yData = accuracy2; yLabelText = 'accuracy'; plotResults;
yData = score2; yLabelText = 'objective score'; plotResults;
yData = time; yLabelText = 'running time'; plotResults;
yData = time_summary; yLabelText = 'running time + initialization'; plotResults;

% Save mat files
save([savepath, 'performance/' 'accuracy.mat'], 'accuracy2');
save([savepath, 'performance/' 'score.mat'], 'score2');
save([savepath, 'performance/' 'time.mat'], 'time');
save([savepath, 'performance/' 'time_summary.mat'], 'time_summary');
save([savepath, 'performance/' 'perform_data.mat'], 'perform_data');