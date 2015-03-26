function [ featInfo ] = extract_localfeatures_mcho( filePathName, fparam, bShowFeat )
%   extract local features, frames, and their patches
%
%   input:   filename and parameters
%   output:  
%   featInfo.typeFeat( featIdx )
%   featInfo.feat( featIdx, :) - x y a b c orientation scale
%   featInfo.shscMatrix( featIdx, :)
%   featInfo.affMatrix( featIdx, :)
%   featInfo.patch(featIdx)

featExt = fparam.featExt;

%% Load features from each image
featInfo.img = imread(filePathName);
if size(featInfo.img,3) > 1
    featInfo.img_gray = rgb2gray(featInfo.img);
end

featInfo.feat = []; featInfo.typeFeat = [];
for i=1:length(featExt)
    if fparam.bFeatExtUse(i)
        [tmpFeat, nTmpFeat ] = loadfeatures_v2( filePathName, featExt{i}, fparam );
        %[tmpFeat, nTmpFeat ] = purifyFeat(tmpFeat, nTmpFeat);
        %disp([ filePathName ' ' featExt{i} ': ' num2str(nTmpFeat)]);
        if bShowFeat
            figure('Name',[ featExt{i} ': ' filePathName ],'NumberTitle','off')
            imshow(featInfo.img_gray);
            hold on; drawEllipse3(tmpFeat(:,1:5), 1, 'r'); hold off;
        end
        featInfo.feat = [ featInfo.feat; tmpFeat ];            featInfo.nFeatOfExt(i) = nTmpFeat;
        featInfo.typeFeat = [ featInfo.typeFeat; i*ones(nTmpFeat,1) ];
    else
        featInfo.nFeatOfExt(i) = 0;
    end 
end
featInfo.nFeat = sum(featInfo.nFeatOfExt);

%% Acquire region patches and descriptors from the features
disp('-- Extracting feature regions from image');
if fparam.bEstimateOrientation
    nMaxOri = fparam.nMaxOri;
else
    nMaxOri = 0;
end
    
[featIdx feat_aug tmpOri shscMatrix affMatrix ] = ...
    compute_norm_trans_image( featInfo.feat, featInfo.img, fparam.featureScale, fparam.patchSize, nMaxOri );
% reinitialize feat information
featInfo.feat = [ feat_aug tmpOri ];
featInfo.shscMatrix = shscMatrix;
featInfo.affMatrix = affMatrix;
featInfo.typeFeat = featInfo.typeFeat(featIdx);

% obtain local patches using the features
featInfo.patch = cell(length(featIdx),1);
bOutOfImage = zeros(length(featIdx),1);
for j=1:length(featIdx)
    [ featInfo.patch{j} bOutOfImage(j) ] = normalize_patchCMEX2(featInfo.img, affMatrix(j,:), fparam.featureScale, fparam.patchSize);
end

% delete features which are out of the image
delIdx = find(bOutOfImage);
featInfo.typeFeat( delIdx ) = [];
featInfo.feat( delIdx, :) = [];
featInfo.shscMatrix( delIdx, :) = [];
featInfo.affMatrix( delIdx, :) = [];
featInfo.patch(delIdx) = [];

for j=1:length(featExt)
    featInfo.nFeatOfExt(j) = sum( featInfo.typeFeat == j );
end
featInfo.nFeat =  size(featInfo.feat,1);
fprintf('   %d normalized regions are extracted from image %s\n',  featInfo.nFeat, filePathName );

% make descriptors for features
tmpDet = zeros(featInfo.nFeat,1);
featInfo.desc = zeros(featInfo.nFeat, 128);       % initial sift descriptor. all 0.
featInfo.desc_ref = zeros(featInfo.nFeat, 128);

for j=1:featInfo.nFeat
    tmpDet(j) = det([ featInfo.affMatrix(j,[1 2]); featInfo.affMatrix(j,[4 5]) ]);
    featInfo.desc(j,:) = gensiftdesc( featInfo.patch{j} )';
    featInfo.desc_ref(j,:) = gensiftdesc( flipdim(featInfo.patch{j},1) )';
    %featInfo.desc_ref(j,:) = mirror_SIFT_descriptor(featInfo.desc(j,:))';
end

featInfo.feat = [ featInfo.feat tmpDet];
%featInfo.patch = cell(0); % delete patches for memory efficiency
