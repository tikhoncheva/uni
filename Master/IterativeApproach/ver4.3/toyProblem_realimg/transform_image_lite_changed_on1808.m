 
%% make 2 synthetic graphs for testing graph matching algorithm
%
% Input
%   I             given image
%   keypoints_I   extracted keypoints of the given image img, 4xn array
%
% Output
%   trI         new image obtained from the given image
%   features1   extracted features of the new image (edge points + descriptors)
%   features2   extracted features of the given image (keypoints + descriptors)
%   GT = (LLpairs, HLpairs) ground thruth between two images,
%                HLpairs = [] !!!!!

function [trI, featInfo_trI, GT] = transform_image_lite(I, featInfo_I)
    
    rng('default');
    
    keypoints_I = featInfo_I.feat';

    setParameters_transformation_ri;
    theta = mod(2*pi + theta, 2*pi);
    
    I_noise = imnoise(I,'gaussian', noise_m, noise_var);
    
    m = size(I_noise,1);
    n = size(I_noise,2);      
    
    trI = repmat(I_noise,1);
    trI(:) = 0;
    
    % Rotation matrix of the affine transformation
    M = [ cos(theta) -sin(theta); ... 
          sin(theta)  cos(theta) ]; 

    M_inv = [ cos(theta)  sin(theta); ... 
             -sin(theta)  cos(theta) ]; 
    
    % new rotated image   
    [x(:,1), x(:,2)] = find(trI(:,:,1)==0);
    x = x - repmat([m/2, n/2] , m*n, 1);
    x = x - repmat(t', m*n, 1);
    y = x*M_inv;
    y = y/scale;
    y = round(y + repmat([m/2, n/2] , m*n, 1));
    x = round(x + repmat([m/2, n/2] , m*n, 1));
    
    mask1 = y(:,1)>=1 & y(:,1)<=m;
    mask2 = y(:,2)>=1 & y(:,2)<=n;
    mask = logical(mask1.* mask2);
    
    k = size(x(mask,:),1);
    
    ind_x = sub2ind( size(I_noise), repmat(x(mask,1),3,1), repmat(x(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    ind_y = sub2ind( size(I_noise), repmat(y(mask,1),3,1), repmat(y(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    
    trI(ind_x) = I_noise(ind_y);
           
    
    % transform each type of features separately
    keypoints_trI = [];
    typeFeat = [];
    nFeatOfExt = zeros(length(featInfo_I.nFeatOfExt),1);
    corresp = [];            % correspondcences between features of the two images
    for j=1:length(featInfo_I.nFeatOfExt)
        if featInfo_I.nFeatOfExt(j)>0
            
            ind_feat_j = featInfo_I.typeFeat==j;
            
            keypoints_I_j = keypoints_I(:, ind_feat_j);
            keypoints_I_j(1:2,:) = keypoints_I_j(1:2,:) - repmat([n/2;m/2], 1, size(keypoints_I_j,2)); % shift coord.center
            
            keypoints_trI_j = scale * M * keypoints_I_j(1:2,:) + repmat(t, 1, size(keypoints_I_j, 2));
            keypoints_trI_j = keypoints_trI_j + repmat([n/2;m/2], 1, size(keypoints_I_j,2));
            keypoints_trI_j(3:7, :) = keypoints_I_j(3:7,:);
            keypoints_trI_j(6, :) = keypoints_I_j(6,:) + theta; % orientation

            ind_feasible = keypoints_trI_j(1,:)>=1 & keypoints_trI_j(1,:)<=n ...
                         & keypoints_trI_j(2,:)>=1 & keypoints_trI_j(2,:)<=m;  
            keypoints_trI_j = keypoints_trI_j(:, ind_feasible);  
            
            nFeatOfExt(j) = size(keypoints_trI_j,2);
            typeFeat = [typeFeat; ones(nFeatOfExt(j),1)*j];
            keypoints_trI = [keypoints_trI, keypoints_trI_j];
            
            lpair = [(size(corresp,1)+1):(size(corresp,1)+nFeatOfExt(j))]';
            rpair = [1:length(ind_feat_j)]';
            rpair = rpair(ind_feasible);
            
            corresp = [corresp; [lpair rpair]];
        end 
    end

    % collect information for featInfo_trI
    featInfo_trI.img = trI;
    if size(featInfo_trI.img,3) > 1
        featInfo_trI.img_gray = rgb2gray(featInfo_trI.img);
    end
    featInfo_trI.feat = keypoints_trI';
    featInfo_trI.typeFeat = typeFeat;
    featInfo_trI.nFeatOfExt = nFeatOfExt;
    featInfo_trI.nFeat = sum(featInfo_trI.nFeatOfExt);

    nFeat_old = sum(nFeatOfExt);
    featInfo_trI = features_Cho_without_keypoints_location(featInfo_trI, 'transformed_image');
    
    % if some feature were deleted, delete them from the GT pairs and
    ind_del = false(nFeat_old,1);
    ind_del(featInfo_trI.delIdx) = true;
    
    new_ind_V = zeros(nFeat_old,1);
    new_ind_V(~ind_del) = [1:featInfo_trI.nFeat];
    
    corresp(:,1) = new_ind_V(corresp(:,1));
    corresp(featInfo_trI.delIdx,:) = [];
    
    featInfo_trI = rmfield(featInfo_trI, 'delIdx');
    

    % Ground Truth
    GT.LLpairs = corresp;
    GT.HLpairs = [];
 
end