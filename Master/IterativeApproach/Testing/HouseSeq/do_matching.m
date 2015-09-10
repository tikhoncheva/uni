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

%% img_trafo
% filepath = '/export/home/etikhonc/Documents/UniGit/uni/Master/data/img_trafo/set1/';
% savepath = './Results/no_descr/using_ransac_afftrafo/img_trafo/';
% listOfimages = dir([ filepath '*_a*.png' ]);

% fnamelist = names(1:end-1);
% fnamelist(:,2) = repmat(names(end),5,1);
% nImagePairs = size(fnamelist,1);

%% house_seq
filepath = '../../../data/houseSmall/';
savepath = './Results/no_descr/using_ransac_afftrafo/house_seq/ext_solution/';

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
accuracy = zeros(nImagePairs, length(methods));
score = zeros(nImagePairs, length(methods));
time = zeros(nImagePairs, length(methods));

time_init1 = zeros(nImagePairs);
time_init2 = zeros(nImagePairs);

X = cell(nImagePairs, length(methods));
% Xraw = cell(nImagePairs, length(methods));
perform_data = cell(nImagePairs, length(methods));

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
    initPathnFile = [ filepath '/' 'fi_' resultTag '.mat' ];
    
    [problem, time_init1(cImg), time_init2(cImg)] = ...
                                        makeProblem(iparam, initPathnFile);
    disp('----------------------------------------------------------------');
    %% Test Methods
    for i = 1:length(methods)
        str = sprintf('run_algorithm(''%s'', problem);', func2str(methods(i).fhandle));
        [accuracy(cImg,i), score(cImg,i), time(cImg,i), ...
                       X{cImg,i}, perform_data{cImg,i}] = eval(str);

        fprintf('Algorithm:%s   Accuracy: %.3f Score: %.3f Time: %.3f\n',...
                func2str(methods(i).fhandle), accuracy(cImg,i), score(cImg,i), time(cImg,i));
        
        mname = func2str(methods(i).fhandle);
        
        f1 = plotMatches(mname, problem, ...
                     accuracy(cImg,i), score(cImg,i), X{cImg,i});                 
        print(f1, [savepath, 'fi_', num2str(cImg), '_', mname(9:end)],'-dpng');            
        close all;
    end

    %% Plot changes in Precision, Recall
%     visPerformPlot;

    %%
    clear iparam problem mname;
    disp('================================================================');disp(' ');
end     

%%
handleCount = 0;
yData = accuracy; yLabelText = 'accuracy'; plotResults;
yData = score; yLabelText = 'objective score'; plotResults;
yData = time; yLabelText = 'running time'; plotResults;
