 
%% make 2 synthetic graphs for testing graph matching algorithm
%
% Input
%   img         given image
%   keypoints   extracted keypoints of the image img, 4xn array
%
% Output
%   img_new     new image obtained from the given image
%   features    extracted features of a new image (edge points +
%               descriptors)
%   GT = (LLpairs, HLpairs) ground thruth between two images,
%                HLpairs = [] !!!!!

function [img_new, features, GT] = transform_image(img, keypoints)
    
    rng('default');
    
    assert(size(keypoints,1)==4);

    setParameters_transformation_ri;
    theta = 2*pi + theta;
    
    img = imnoise(img,'gaussian', noise_m, noise_var);
    
    m = size(img,1);
    n = size(img,2);      
    
    img_new = repmat(img,1);
    img_new(:) = 0;
    
    % Rotation matrix of the affine transformation
    M = [ cos(theta) -sin(theta); ... 
          sin(theta)  cos(theta) ]; 

    M_inv = [ cos(theta)  sin(theta); ... 
             -sin(theta)  cos(theta) ]; 
    
    % new rotated image   
    [x(:,1), x(:,2)] = find(img_new(:,:,1)==0);
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
    
    ind_x = sub2ind( size(img), repmat(x(mask,1),3,1), repmat(x(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    ind_y = sub2ind( size(img), repmat(y(mask,1),3,1), repmat(y(mask,2),3,1), [ones(k,1);2*ones(k,1); 3*ones(k,1)]);
    
    img_new(ind_x) = img(ind_y);
    
%     for i=1:m
%         for j=1:n
%             
%             x = ([i - m/2; j - n/2]-t)' * M_inv;
%             x = x/aff_transfo_scale;
%             
%             x(1) = round(x(1) + m/2);
%             x(2) = round(x(2) + n/2);
% 
%             if (x(1)>=1 && x(2)>=1 && x(1)<=m && x(2)<=n)
%                  img_new(i,j,:)=img(x(1),x(2),:);
%             end
% 
%         end
%     end
    
    % Coordinates of the transformed keypoints
    keypoints(1:2,:) = keypoints(1:2,:) - repmat([n/2;m/2], 1, size(keypoints,2));
    keypoints_new = scale * M * keypoints(1:2,:) + repmat(t, 1, size(keypoints, 2));
    keypoints_new = round(keypoints_new + repmat([n/2;m/2], 1, size(keypoints,2)) );
    
    ind_feasible = keypoints_new(1,:)>=1 & keypoints_new(1,:)<=n ...
                 & keypoints_new(2,:)>=1 & keypoints_new(2,:)<=m;  
    
    % SIFT descriptors in the keypoints   
    F_in = [keypoints_new(:, ind_feasible); ...
            keypoints(3, ind_feasible) + theta ; ...
            keypoints(4, ind_feasible)]; 
    [F, D] = vl_sift(single(rgb2gray(img_new)), 'frames', F_in);
    
    features.edges = F;
    features.descr = D;
    
    % Ground Truth
    ind_keyp1 = [1:size(keypoints, 2)];
    ind_keyp1 = ind_keyp1(ind_feasible);
    [~, ind_keyp2] = ismember(single(F_in'), single(F'), 'rows');
    
    assert(numel(find(ind_keyp2>0)) == size(ind_keyp1,2), ...
        'fct transform_image: error in extraction of descriptors in defined keypoints');
    
    GT.LLpairs = [ind_keyp1; ind_keyp2']';
    GT.HLpairs = [];
 
end