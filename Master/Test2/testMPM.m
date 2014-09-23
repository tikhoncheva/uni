
clear all
close all
clc
%% Set parameters
SetParameters;

%% read images
imagefiles = dir([image_path filesep '*.jpg']) ;

N = length(imagefiles);   % number of images in the ordner
image = cell(1,N); % cell of the images

for i=1:N
    currentfilename = imagefiles(i).name;
    currentimage = imread([image_path filesep currentfilename]);
    
    % Convert the image to gray scale
    image{i} = single(rgb2gray(currentimage));
end


%%
%% SIFT descriptors

%% Reference image
% The first image is a reference image
img1 = 1;
% The first image is a reference image

% select rectangle region on the first image

f = figure;
    imagesc(image{img1}),colormap(gray);
    title('Reference Image');
    hold on;     
    rect = getrect;    
hold off;

img1cut = imcrop(image{img1},rect);

xmin = rect(1,1);
ymin = rect(1,2);


%%

detectorId = find(fparam.bFeatExtUse);
detector = fparam.featExt{detectorId};

descriptor = 'sift';



minAreaRatio = 0.01;
maxAreaRatio = 0.3;
thresholdlevel = 1; % 0: low, 1: normal, 2: high


%%

N = 2;

minDeg = 5;
nFeaturePoints = 10;

% peak_thresh = 30;
thresholdlevel = 2;

% cell of the keypoints-matrices
framesCell = cell(1,N); % Nx(4xK1) matrices

% cell of the descriptors-matrices
descrCell = cell(1,N); % Nx(128xK1) matrices

% number of interest points in each image
nP = zeros(N,1);

% Cell of the adjazent matrices on each image
adjCell = cell(1,N); % nP_i x nP_i

%%

for i = 1 : N
    
    img = image{i};     

    if i==1
%         [framesCell{1}, descrCell{1}] = vl_sift(img1cut,'PeakThresh', 10);
        [framesCell{i}, descrCell{i} ] = loadfeatures_vlfeat( img1cut, detector, thresholdlevel);
        framesCell{1}(1,:) = framesCell{1}(1,:) + xmin;
        framesCell{1}(2,:) = framesCell{1}(2,:) + ymin;

    else
        %[framesCell{i}, descrCell{i}] = vl_sift(img,'PeakThresh', 13);
        [framesCell{i}, descrCell{i} ] = loadfeatures_vlfeat( img, detector, thresholdlevel);
    end
    
     % rescaling for each detector
    framesCell{i}(3:6,:) = framesCell{i}(3:6,:) * fparam.bFeatScale(detectorId);
    
    % eleminate too small or large features
    areaimg = prod(size(img));
    area = pi * abs(framesCell{i}(3,:).*framesCell{i}(6,:) - framesCell{i}(4,:).*framesCell{i}(5,:)); % area of ellipse
    idxValid = ( area > minAreaRatio * areaimg ) & ( area < maxAreaRatio * areaimg );
    framesCell{i} = framesCell{i}(:,idxValid);
    
    nP(i,1) = size(framesCell{i}, 2);
    
    %% descriptor extraction (SIFT)
    
    if size(framesCell{i},2) > 0 && ( isempty(descrCell{i}) || size(framesCell{i},2) ~= size(descrCell{i},2) ) 
        [ framesCell{i} descrCell{i} ] = extractSIFT(img, framesCell{i},...
            'contrastInsensitive', fparam.bContrastInsenstive, 'NBP', fparam.nBP,...
            'descScale', fparam.descScale, 'estimateOrientation', fparam.bEstimateOrientation);
        %[ tmpFrame tmpDesc ] = extractSIFT(featInfo.img_gray, tmpFrame, 'estimateOrientation', true);
    end
    
    %% build a dependency graph on each image
    
    [adjMatrixInd, ~] = knnsearch(framesCell{i}(1:2,:)', ....
                                  framesCell{i}(1:2,:)', 'k', minDeg+1);
    
    %% delete loops in each vertex (first column of the matrix)
    adjMatrixInd = adjMatrixInd(:,2:end);

    %%  draw graph
%     f = figure ; 
%         imagesc(img) ;    % image
%         colormap(gray); 
%         hold on ;
%         vl_plotframe(framesCell{i});
%         line([framesCell{i}(1,:) framesCell{i}(1,adjMatrixInd(:,:))],[...
%             framesCell{i}(2,:) framesCell{i}(2,adjMatrixInd(:,:))],... % edges
%                                                             'Color', 'b');       
%     hold off;
%     print(f, '-r80', '-dtiff', fullfile(['.' filesep 'graphs'], ...
%                                       sprintf('%s',imagefiles(i).name)));
    %%
    adjMatrix = zeros(nP(i),nP(i));

    for v= 1 : nP(i)
        adjMatrix(v, adjMatrixInd(v,:)) =  1;
    end
    
    adjCell{i} = adjMatrix;
end

close all;

 

%%  MPM

% first image is a reference image
% second image is a target image

img1 = 1;

v1 = framesCell{img1}(1:2,:);
v1=v1';
nP1 = nP(img1,1);
 
Objective = zeros(1, N);

for img2 = 2:N
    
    v2 = framesCell{img2}(1:2,:);
    v2=v2';
    nP2 = nP(img2,1);

    %% initial correspondence Matrix nP1 x nP2
    nCorr = nP2; %5;
    [corrMatrixInd, ~] = knnsearch(descrCell{img2}', descrCell{img1}','k', nCorr);

    corrMatrix = zeros(nP1,nP2);

    for v= 1 : nP1
        corrMatrix(v, corrMatrixInd(v,:)) =  1;
    end

    plotMatches(double(image{img1})/256,double(image{img2})/256, v1, v2, corrMatrix, ...
                                                imagefiles(img2).name,1);


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

    clear('AB'); 
    
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
    
for i=1:5
    copyfile ( ...
        fullfile(sourcePath, sprintf('result_%s-2.jpg',imagefiles(bestMatchesInd(i)).name)),...
        fullfile(bestMatchesPath, sprintf('%s.jpg',imagefiles(bestMatchesInd(i)).name)));
end

%%

pause

%%
close all
