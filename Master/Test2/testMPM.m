
clear all
close all
clc

%% add MPM-code
addpath(genpath(['..' filesep 'MPM_release_v1']));

%% add SIFT-descriptor
addpath(genpath(['..' filesep 'SIFT']));

%% add SIFT-descriptor 
addpath(genpath(['..' filesep 'MSER']));

%% read test images
 image_path = ['.' filesep 'churchSmall'];
%image_path = ['/home/kitty/Documents/Uni/Master/Databases/SUN/Images/c/church/outdoor/'];
imagefiles = dir([image_path filesep '*.jpg']) ;

N = length(imagefiles);   % number of images in the ordner
image = cell(1,N); % cell of the images

for i=1:N
    currentfilename = imagefiles(i).name;
    currentimage = imread([image_path filesep currentfilename]);
    
    % Convert the image to gray scale
    % image{i} = double(rgb2gray(currentimage))/256;
    % image{i} = currentimage;
    image{i} = rgb2gray(currentimage);
end


%%
%% SIFT descriptors

%% Parameters

%N = 2;
minDeg = 10;
nFeaturePoints = 50;

%%

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nP = zeros(N,1);

% Cell of the adjazent matrices on each image
adjCell = cell(1,N); % nP_i x nP_i

for i = 1 : N
    
    img = image{i};

%% Use Harris corner detector    
    corners = corner(img, 'Harris', nFeaturePoints);
%     figure
%         imagesc(img); colormap(gray); hold on;
%         plot(corners(:,1), corners(:,2), 'r*');
%     hold off;
    
    x = corners(:,1);
    y = corners(:,2);
    
%% use MSER feature detector
%     
%     [r, ell] = mser(img, 1) ;
%     r=double(r) ;
%     [x, y]=ind2sub(size(img),r) ;                    
%     x = double(x) ;
%     y = double(y) ;
%

%% SIFT descriptors
    nKeyPoints = length(x);
    nP(i,1) = nKeyPoints;
    
    sigma = ones(1, nKeyPoints);
    theta = zeros(1,nKeyPoints);
    % (4xK1) matrice
    framesCell{i} = [x'; y'; sigma; theta];
    
    img2 = double(img)/256;
    
    % (128xK1) matrice
    descrCell{i} = siftdescriptor(img2,framesCell{i}([1 2 4],:),0.3);
    
    %% build a dependency graph on each image
    
    [adjMatrixInd, ~] = knnsearch(descrCell{i}', descrCell{i}','k', minDeg+1);
    
    %% delete loops in each vertex (first column of the matrix)
    adjMatrixInd = adjMatrixInd(:,2:end);

    %%
%     % draw graph
%     f = figure ; 
%         imagesc(img) ;    % image
%         colormap(gray); 
%         hold on ;
%         plot(x, y, 'r*');   % corner points
%         line([x(:) x(adjMatrixInd(:,:))],[y(:) y(adjMatrixInd(:,:))],... % edges
%                                                             'Color', 'b');       
%     hold off;
%     print(f, '-r80', '-dtiff', fullfile(['.' filesep 'graphs'], ...
%                                      sprintf('%s.jpg',imagefiles(i).name)));
    %%
    adjMatrix = zeros(nP(i),nP(i));

    for v= 1 : nP(i)
        adjMatrix(v, adjMatrixInd(v,:)) =  1;
    end
    
    adjCell{i} = adjMatrix;
end

%%  MPM

% first image is a reference image
% second image is a target image

img1 = 1;
img2 = 11;

v1 = framesCell{img1}(1:2,:);
v1=v1';
nP1 = nP(img1,1);
 
Objective = zeros(1, N);

for img2 = 2:2
    v2 = framesCell{img2}(1:2,:);
    v2=v2';
    nP2 = nP(img2,1);

    %% initial correspondence Matrix nP1 x nP2
    nCorr = nFeaturePoints; %5;
    [corrMatrixInd, ~] = knnsearch(descrCell{img2}', descrCell{img1}','k', nCorr);

    corrMatrix = zeros(nP1,nP2);

    for v= 1 : nP1
        corrMatrix(v, corrMatrixInd(v,:)) =  1;
    end

%     plotMatches(double(image{img1})/256,double(image{img2})/256, v1, v2, corrMatrix, ...
%                                                 imagefiles(img2).name,1);


    %% conflict groups
    [I, A] = find(corrMatrix);
    L12 = [I, A];
    [group1, group2] = make_group12(L12);

    conflictMatrix = getConflictMatrix(group1, group2);

    %% affinity matrix

    nAffMatrix = nP1 * nP2;
    AffMatrix = zeros(nAffMatrix);

    % node similarity (diagonal elements of the affinity matrix)
    D = zeros(nAffMatrix,1);

    for it = 1 : size(L12,1)
            diffDescr = abs(descrCell{img1}(:,I(it)) - descrCell{img2}(:, A(it))); 
            var = sum(diffDescr(:,1).^2,1);  % sqrt(sum(diffDescr(:,1).^2,1)); 
            ind = (I(it)-1) * nP2 + A(it);
            D(ind,1) =  exp(-var/0.5); 
    end

    AffMatrix = AffMatrix + diag(D);

    % edge similarity (non-diagonal elements of the affinity matrix)

    Adj1 = adjCell{img1};
    Adj2 = adjCell{img2};

    [IJ(:,1), IJ(:,2)] = find(Adj1);
    [AB(:,1), AB(:,2)] = find(Adj2);

    for ij = 1 : size(IJ,1)
        for ab = 1 : size(AB,1)

            i = IJ(ij, 1);
            j = IJ(ij, 2);

            a = AB(ab, 1);
            b = AB(ab, 2);

            if (ismember([i, a], L12, 'rows') && ismember([j, b], L12, 'rows'))

                var1 = sum( (framesCell{img1}(1:2, i) - framesCell{img1}(1:2, j)).^2,1);
                e_ij = sqrt(var1);

                var2 = sum( (framesCell{img2}(1:2, a) - framesCell{img2}(1:2, b)).^2,1);
                e_ab = sqrt(var2);

                ia = (i-1)*nP2 + a;
                jb = (j-1)*nP2 + b;

                AffMatrix(ia, jb) =  exp(-(e_ij-e_ab)^2/0.5); 
            end
        end
    end


    %% run MPM 
    %
    x = MPM(AffMatrix, group1, group2);
    
    Objective(img2) = x'*AffMatrix * x;
    
    x = reshape(x, [nP1, nP2]);

    [XmaxRow, Ind]= max(x,[],2);
    newCorrMatrix = zeros(nP1, nP2);
    for i=1:nP1
        newCorrMatrix(i,Ind(i)) = XmaxRow(i);
    end;

    %% visialize results of matching
    plotMatches(image{img1},image{img2}, v1, v2, newCorrMatrix,...
                                            imagefiles(img2).name,2);
    

end
%%

%% save 5 best Matches

sourcePath = ['.' filesep 'results'];
bestMatchesPath = ['.' filesep 'results' filesep 'bestMatches'];

imwrite(image{img1}, fullfile(bestMatchesPath,...
            'ReferenceImage.jpg'));

[~, bestMatchesInd ] = sort(Objective,'descend');
    
for i=1:1
    copyfile ( ...
        fullfile(sourcePath, sprintf('result_%s-2.jpg',imagefiles(bestMatchesInd(i)).name)),...
        fullfile(bestMatchesPath, sprintf('%s.jpg',imagefiles(bestMatchesInd(i)).name)));
end

%%

pause

%%
close all
clear all
