
clear all
close all


%% Set parameters


% VL_Library

VLFEAT_Toolbox = ['..' filesep '..' filesep 'vlfeat-0.9.19' filesep 'toolbox' ];
addpath(genpath(VLFEAT_Toolbox));

run vl_setup.m

clc;

SetParameters;

%%
%% read images

[image, imagefiles] = readImages();  % cell of the images

% %% Reference image
% % Select a reference image
% img1 = 1;
% 
% % select rectangle region on the reference image
% 
% f = figure;
%     imagesc(image{img1}),colormap(gray);
%     title('Reference Image');
%     hold on;     
%     rect = getrect;    
% hold off;
% 
% close all;
% 
% img1cut = imcrop(image{img1},rect);
% 
% xmin = rect(1,1);
% ymin = rect(1,2);
% %%

N = 2;

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nV= zeros(N,1);

%%

perm = randperm(10) ;
sel = perm(1:10) ;

for i = 1 : N
    
    img = image{i};      
   
    %% find point of interest (nodes of the graph)
    tic
    [ framesCell{i}, descrCell{i}, nV(i) ] = find_features_harlap_vl(img);

    fprintf(' %f secs elapsed for finding %d interest points on the image %d \n', ...
                        toc, nV(i) , i);
    
%     sel = 1:size(framesCell{i},2);
%     
%     f = figure;
%         imagesc(img),colormap(gray);
%         title(sprintf('Image %d', i));
%         hold on;     
%         h1 = vl_plotframe(framesCell{i}(:,sel));
%         set(h1,'color','y','linewidth', 2) ;
%         
%         h3 = vl_plotsiftdescriptor(descrCell{i}(:,sel),framesCell{i}(:,sel)) ;
%         set(h3,'color','g') ;
%     hold off;
    
    %% select 10 features on each image
    
        nV = 10;
        nV(i) = nV*i;

        [~,indx] = sort(descrCell{i},'descend');

        descrCell{i} = descrCell{i}(:,indx(1:nV*i));
        framesCell{i} = framesCell{i}(:,indx(1:nV*i));  
        
    f = figure;
        imagesc(img),colormap(gray);
        title(sprintf('Image %d', i));
        hold on;     
        h1 = vl_plotframe(framesCell{i});
        set(h1,'color','y','linewidth', 2) ;
        
        h3 = vl_plotsiftdescriptor(descrCell{i},framesCell{i}) ;
        set(h3,'color','g') ;
    hold off;

end


 %% try to match

    v1 = framesCell{1}(1:2,:);
    v2 = framesCell{2}(1:2,:);

%     [matches, scores] = vl_ubcmatch(descrCell{1}, descrCell{2});
%     
%     corrMatrix = zeros(nV(1), nV(2) );
%     for i= 1 : size(matches, 2)
%         corrMatrix(matches(1,i), matches(2,i)) =  1;
%     end 
%     
%     
%     plotMatches(double(image{1})/256,double(image{2})/256, v1', v2', corrMatrix, ...
%                                                 imagefiles(2).name,1);    
      
%     kNN = 3;
%     [corrMatrixInd, ~ ] = knnsearch(descrCell{1}', descrCell{2}','k', kNN,...
%                           'NSMethod', 'exhaustive', 'Distance', 'euclidean');
% 
%     corrMatrix = zeros(nV(1), nV(2) );
%     for v= 1 : nV(1)
%         corrMatrix(v, corrMatrixInd(v,:)) =  1;
%     end
% 
%     plotMatches(double(image{1})/256,double(image{2})/256, v1', v2', corrMatrix, ...
%                                                 imagefiles(2).name,1);

    [matchMatrix, distMatrix] = matchSIFTdescr(descrCell{1},descrCell{2}, 5);

    plotMatches(double(image{1})/256,double(image{2})/256, v1', v2', matchMatrix, ...
                                                imagefiles(2).name,1);    