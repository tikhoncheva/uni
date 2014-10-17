
clear all
close all


%% Set parameters

% MPM code
addpath(genpath(['..' filesep 'MPM_release_v1_2']));

% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
addpath(genpath(VLFEAT_Toolbox));

run vl_setup.m

clc;

SetParameters;

%%
%% read images

[image, imagefiles] = readImages();  % cell of the images

%% Reference image
% Select a reference image
img1 = 1;

% select rectangle region on the reference image

f = figure;
    imagesc(image{img1}),colormap(gray);
    title('Reference Image');
    hold on;     
    rect = getrect;    
hold off;

close all;

img1cut = imcrop(image{img1},rect);

xmin = rect(1,1);
ymin = rect(1,2);


%%

N = 2;

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

% cell of the descriptors-matrices
matchInfoCell = cell(1,N); % Nx(128xK1) matrices


% Cell of the adjazent matrices on each image
adjMatrixCell = cell(1,N); % nV_i x nV_i

% Min Degree of the image graphs
minDeg = 10;


%% Find Features

for i = 1 : N
    
    img = image{i};     

    %% find point of interest (nodes of the graph)
    tic
    
    if (i==1)
        %[ framesCell{i}, descrCell{i}, nV(i) ] = find_features(img1cut, xmin, ymin, 20);
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features_harlap_vl(img1cut,xmin,ymin, 20);
    else
        %[ framesCell{i}, descrCell{i}, nV(i) ] = find_features(img);
        [ framesCell{i}, descrCell{i}, nV(i) ] = find_features_harlap_vl(img);
    end
    
    fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        toc, nV(i) , i);
    
%     %% build a dependency graph on each image
%     
%     adjMatrixCell{i} = buildGraph(framesCell{i}, minDeg);
%     
%     %%  draw graph
%     
%     if i==1
%          draw_graph(img, imagefiles(i).name, framesCell{i}, adjMatrixCell{i}, 1:nV(i),...
%                                                      'saveImage', 'false');
%     end

end

%% Reference image
% The first image is a reference image
% second image in a pair is a target image  

img1 = 1;

v1 = framesCell{img1}(1:2,:);
% v1=v1';
nV1 = nV(img1,1);

%% Build a dependency graph on the first image 
% V = {set of the interest points}
% minDeg = 10
adjMatrixCell{1} = buildGraph(framesCell{1}, minDeg);

%% For all other images
for img2 = 2:N
    
    v2 = framesCell{img2}(1:2,:);
    nV2 = nV(img2,1);
    
    % 1. Reduce number of nodes
    %    first find (#param.kNN) nearest neighbors in the second image 
    %    for all nodes on the first image
    
    matchInfo = matchSIFTdescr(descrCell{img1},descrCell{img2}, mparam.kNN);
    
    corrMatrix = zeros(nV(img1),nV(img2));
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end

    plotMatches(double(image{1})/256,double(image{2})/256, v1', v2', corrMatrix, ...
                                                imagefiles(2).name,1);
                                            
    [ uniq_feat2, tmp, new_feat2 ] = unique(matchInfo.match(2,:));
    
    nV(img2) = size(uniq_feat2, 2);

    framesCell{img2} = framesCell{img2}(:, uniq_feat2);
    descrCell{img2}  =  descrCell{img2}(:, uniq_feat2);
    
     %% rebuild a dependency graph on each image
    
    adjMatrixCell{img2} = buildGraph(framesCell{i}, minDeg);
    
    draw_graph(image{img2}, imagefiles(img2).name, framesCell{img2}(1:2,:), adjMatrixCell{img2}, 1:nV(img2),...
                                                     'saveImage', 'false'); 
    
    
    
end



%% reduce number of features

for img2 = 2:N
    
    matchInfo =  make_initialmatches(descrCell{img1}, descrCell{img2}, mparam); 
   
    corrMatrix = zeros(nV(img1),nV(img2));
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end
    
    plotMatches(double(image{img1})/256,double(image{img2})/256, v1', framesCell{img2}(1:2,:)', corrMatrix, ...
                                                imagefiles(img2).name,1);
                                            
    [ uniq_feat2, tmp, new_feat2 ] = unique(matchInfo.match(2,:));
    
    nV(img2) = size(uniq_feat2, 2);

    framesCell{img2} = framesCell{img2}(:, uniq_feat2);
    descrCell{img2}  =  descrCell{img2}(:, uniq_feat2);
    
     %% rebuild a dependency graph on each image
    
    adjMatrixCell{img2} = buildGraph(framesCell{i}, minDeg);
    
    draw_graph(image{img2}, imagefiles(img2).name, framesCell{img2}(1:2,:), adjMatrixCell{img2}, 1:nV(img2),...
                                                     'saveImage', 'false');                                                
end





pause

%%
close all
