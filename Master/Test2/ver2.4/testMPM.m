
clear all
close all


%% Set parameters

% MPM code
addpath(genpath(['..' filesep '..' filesep 'MPM_release_v3']));

% VL_Library

%VLFEAT_Toolbox = ['..' filesep '..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
%VLFEAT_Toolbox = [ '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' filesep 'mex' filesep 'mexa64' ];
VLFEAT_Toolbox = '/home/kitty/Documents/Uni/Master/vlfeat-0.9.19/toolbox/';

addpath(genpath(VLFEAT_Toolbox));

run vl_setup.m

clc;

SetParameters;

%%
%% read images

[image, imagefiles] = readImages();  % cell of the images

%% Setup

% Select a reference image
img1 = 1;

 N = 2;
%N = size(image, 2);

% cell of the keypoints on the each image
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

% cell of the descriptors-matrices
initialmatchesCell = cell(1,N); % Nx(128xK1) matrices

% Cell of the dependency graphs
DG = cell(1,N); % nV_i x nV_i

%%

for i = 1 : N
    
    img = image{i};          
   
    %% find point of interest (nodes of the graph)
    
    if i==1
        [ framesCell{i}, descrCell{i}, nV(i),runtime ] = ...
                                    find_features_harlap_vl(img, true, 10);
    else
        [ framesCell{i}, descrCell{i}, nV(i),runtime ] = ...
                                        find_features_harlap_vl(img, false);
    end
    
    fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        runtime, nV(i) , i);
%     f = figure;
%         imagesc(img),colormap(gray);
%         title(sprintf('Image %d', i));
%         hold on;     
%         h1 = vl_plotframe(framesCell{i});
%         set(h1,'color','y','linewidth', 2) ;
%         
%         h3 = vl_plotsiftdescriptor(descrCell{i},framesCell{i}) ;
%         set(h3,'color','g') ;
%     hold off;

end

%% Reduce number of keypoints on the second image in each pair of images
% For each keypoint on the ref image find theirs k nearest neighbors on 
% the second image
% The points that are not neighbors of some point on the ref image will be
% deleted

v1 = framesCell{img1}(1:2,:);
nV1 = nV(img1,1);

for i = 2 : N
    
    matchInfo = make_initialmatches2(descrCell{1},descrCell{i}, mparam); 
    
%     corrMatrix = zeros(nV(1),nV(i));
%     for ii = 1:size(matchInfo.match,2)
%         corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
%     end
% 
%     plotMatches(double(image{1})/256,double(image{i})/256, v1', v2', corrMatrix, ...
%                                                 imagefiles(i).name,1);  
    
    % delete all features that are not neighbors of some point on the
    % reference image
    [ uniq_feat2, tmp, ~ ] = unique(matchInfo.match(2,:));
    
    nV(i) = size(uniq_feat2, 2);
    framesCell{i} = framesCell{i}(:, uniq_feat2);
    descrCell{i}  =  descrCell{i}(:, uniq_feat2); 
    
    v2 = framesCell{i}(1:2,:);
    
%     mparam.kNN = 1;
    matchInfo = make_initialmatches2(descrCell{1},descrCell{i}, mparam); 
    
    corrMatrix = zeros(nV(1),nV(i));
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end

    initialmatchesCell{i} = matchInfo;
    plotMatches(double(image{1})/256,double(image{i})/256, v1', v2', corrMatrix, ...
                                                imagefiles(i).name,1);       
    

end  

%% Build Dependency Graph (DG) on each image
minDeg = 30;    % Min Degree of the graph


DG{1} = buildDependGraph_RefImage(framesCell{1}, minDeg);

for i= 2 : N
    img = image{i}; 
    %DG{i} = buildDependGraph_RefImage(framesCell{i}, minDeg);
    DG{i} = buildDependGraph(framesCell{i}, DG{1}, initialmatchesCell{i});
%     draw_graph(img, imagefiles(i).name, framesCell{i}(1:2,:), DG{i},...
%                                                      'saveImage', 'false'); 
end

%%  Max-Pooling Strategy
 
Objective = zeros(1, N);

for img2 = 2:N
    
    v2 = framesCell{img2}(1:2,:);
    nV2 = nV(img2,1);

    matchInfo = initialmatchesCell{img2};                                       
   
    Adj1 = DG{img1};
    Adj2 = DG{img2};

    
    % compute initial affinity matrix
    AffMatrix = initialAffinityMatrix(v1, v2, Adj1, Adj2, matchInfo);
  
    

    % run MPM  
%     L12(:,1) = matchInfo.match(1,:).';
%     L12(:,2) = matchInfo.match(2,:).';
%     [ group1, group2 ] = make_group12(L12);

    % conflict groups
    corrMatrix = zeros(nV1,nV2);
    for ii = 1:size(matchInfo.match,2)
        corrMatrix(matchInfo.match(1,ii), matchInfo.match(2,ii) ) = 1;
    end
    [L12(:,1), L12(:,2)] = find(corrMatrix);
    [ group1, group2 ] = make_group12(L12);

    x = MPM(AffMatrix, group1, group2);
    Objective(img2) = x'*AffMatrix * x;
    
    CorrMatrix = zeros(nV1, nV2);
    for i=1:size(L12,1)
        CorrMatrix(L12(i,1), L12(i,2)) = x(i);
    end    

    newCorrMatrix = roundMatrix(CorrMatrix);

    % visialize results of matching
    plotMatches(image{img1},image{img2}, v1', v2', newCorrMatrix,...
                                            imagefiles(img2).name,2);
end


