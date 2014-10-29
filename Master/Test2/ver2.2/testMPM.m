
clear all
close all


%% Set parameters

% MPM code
addpath(genpath(['..' filesep '..' filesep 'MPM_release_v1_2']));

% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
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
%N = size(image, 2)

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
                                    find_features_harlap_vl(img, true, 30);
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
    
%     v2 = framesCell{i}(1:2,:);
    
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
    
    %mparam.kNN = 1;
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
minDeg = 10;    % Min Degree of the graph

for i = 1 : N
    img = image{i}; 
    DG{i} = buildDependGraph(framesCell{i}, minDeg);
%     draw_graph(img, imagefiles(i).name, framesCell{i}(1:2,:), DG{i},...
%                                                      'saveImage', 'false'); 
end

%%  Max-Pooling Strategy
 
Objective = zeros(1, N);

for img2 = 2:N
    
    v2 = framesCell{img2}(1:2,:);
    nV2 = nV(img2,1);

    matchInfo = initialmatchesCell{i};                                       
   
    [ uniq_feat2, tmp, new_feat2 ] = unique(matchInfo.match(2,:));
    cand_matchlist_uniq = [ matchInfo.match(1,:); new_feat2' ]; % pairs (feat1, feat2) for each match   
                                            

    % conflict groups
    [ group1, group2 ] = make_group12(matchInfo.match(1:2,:));
    conflictMatrix = getConflictMatrix(group1, group2);

    % affinity matrix

    nAffMatrix = size(matchInfo.match, 2);
    AffMatrix = zeros(nAffMatrix);

%     edge similarity (non-diagonal elements of the affinity matrix)

    Adj1 = DG{img1};
    Adj2 = DG{img2};

    [IJ(:,1), IJ(:,2)] = find(Adj1);
    [AB(:,1), AB(:,2)] = find(Adj2);
    
    D = zeros(nAffMatrix);

    for ia = 1:nAffMatrix
        i = cand_matchlist_uniq(1, ia);
        a = cand_matchlist_uniq(2, ia);
        
        for jb = 1:nAffMatrix
            j = cand_matchlist_uniq(1, jb);
            b = cand_matchlist_uniq(2, jb);
            
            if (ismember([i, j], IJ, 'rows') && ismember([a, b], AB, 'rows'))
                
                var1 = sum( (v1(1:2, i) - v1(1:2, j)).^2,1);
                e_ij = sqrt(var1);

                var2 = sum( (v2(1:2, a) - v2(1:2, b)).^2,1);
                e_ab = sqrt(var2);

                D(ia, jb) =  abs(e_ij-e_ab); 
                
            end
            
        end
    end

    meanD = mean(D(:));
    
    for ia = 1:nAffMatrix 
        i = cand_matchlist_uniq(1, ia);
        a = cand_matchlist_uniq(2, ia);
        for jb = 1:nAffMatrix
            j = cand_matchlist_uniq(1, jb);
            b = cand_matchlist_uniq(2, jb);  
            if (ismember([i, j], IJ, 'rows') && ismember([a, b], AB, 'rows'))         
                AffMatrix(ia, jb) =  exp(-D(ia,jb)^2/meanD^2);        
            end
        end
    end
    clear('AB'); 
    
    %     node similarity (diagonal elements of the affinity matrix)
    AffMatrix(1:nAffMatrix+1:end) = matchInfo.sim(:);
    
    
    % run MPM  
    x = MPM(AffMatrix, group1, group2);
    Objective(img2) = x'*AffMatrix * x;
    
    x = reshape(x, [nV1, nAffMatrix/nV1]);

    newCorrMatrix = roundMatrix(x);
    
%     [XmaxRow, Ind]= max(x,[],2);
%     
%     newCorrMatrix = zeros(nV1, nV2);
%     
%     for i=1:nV1
%         newCorrMatrix(i,cand_matchlist_uniq(2,Ind(i))) = XmaxRow(i);
%     end;

    % visialize results of matching
    plotMatches(image{img1},image{img2}, v1', v2', newCorrMatrix,...
                                            imagefiles(img2).name,2);
end


