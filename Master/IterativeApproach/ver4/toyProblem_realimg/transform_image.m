 
%% make 2 synthetic graphs for testing graph matching algorithm
%
% Input
%   img           given image
%   keypoints_I   extracted keypoints of the given image img, 4xn array
%
% Output
%   img1        new image obtained from the given image
%   features1   extracted features of the new image (edge points + descriptors)
%   features2   extracted features of the given image (keypoints + descriptors)
%   GT = (LLpairs, HLpairs) ground thruth between two images,
%                HLpairs = [] !!!!!

function [trI, features_trI, features_I, GT] = transform_image(I, keypoints_I)
    
    % Piotr Dollar toolbox
    addpath(genpath('../../Tools/piotr_toolbox_V3.26/'));
    % Edge extraction
    addpath(genpath('../../Tools/edges-master/'));

    load '../../Tools/edges-master/edgesModel.mat'   % model

    rng('default');
    
    assert(size(keypoints_I,1)==4);

    setParameters_transformation_ri;
    theta = mod(2*pi + theta, 2*pi);
    
    I = imnoise(I,'gaussian', noise_m, noise_var);
    
    m = size(I,1);
    n = size(I,2);      
    
    trI = repmat(I,1);
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
    
    ind_x = sub2ind( size(I), repmat(x(mask,1),3,1), repmat(x(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    ind_y = sub2ind( size(I), repmat(y(mask,1),3,1), repmat(y(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    
    trI(ind_x) = I(ind_y);
    
    
    % Coordinates of the transformed keypoints
    keypoints_I(1:2,:) = keypoints_I(1:2,:) - repmat([n/2;m/2], 1, size(keypoints_I,2)); % new coordinate center
    
    keypoints_trI = scale * M * keypoints_I(1:2,:) + repmat(t, 1, size(keypoints_I, 2));
    keypoints_trI = round(keypoints_trI + repmat([n/2;m/2], 1, size(keypoints_I,2)) );
    keypoints_trI(3, :) = keypoints_I(3,:);         % scale
    keypoints_trI(4, :) = keypoints_I(4,:) + theta; % orientation
    
    ind_feasible = keypoints_trI(1,:)>=1 & keypoints_trI(1,:)<=n ...
                 & keypoints_trI(2,:)>=1 & keypoints_trI(2,:)<=m;  
    keypoints_trI = keypoints_trI(:, ind_feasible);             
    
    keypoints_I(1:2,:) = keypoints_I(1:2,:) + repmat([n/2;m/2], 1, size(keypoints_I,2)); % return to the old coordinate center             
    
    % calculate descriptors of the keypoints
    % given image
    E = imresize(edgesDetect(imresize(I,2), model),0.5);
    [~, D2] = vl_sift(single(E), 'frames', keypoints_I);        
    
    % new transformed image
    E = imresize(edgesDetect(imresize(trI,2), model),0.5);
    [~, D1] = vl_sift(single(E), 'frames', keypoints_trI);
%     [F, D] = vl_sift(single(rgb2gray(trI)), 'frames', keypoints_new);
    
    features_trI.edges = keypoints_trI;
    features_trI.descr = D1;
    
    features_I.edges = keypoints_I;
    features_I.descr = D2;
    
    % Ground Truth
    ind_keyp1 = [1:size(keypoints_I, 2)];
    ind_keyp1 = ind_keyp1(ind_feasible);
    ind_keyp2 = [1:size(keypoints_trI,2)];
    
    assert(numel(find(ind_keyp2>0)) == size(ind_keyp1,2), ...
        'fct transform_image: error in extraction of descriptors in defined keypoints');
    
    GT.LLpairs = [ind_keyp1; ind_keyp2]';
    GT.HLpairs = [];
 
end