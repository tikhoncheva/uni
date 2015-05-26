 
%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   img_new     new image obtained from the given image
%   features    extracted features of a new image (edge points +
%               descriptors)
%   GT = (LLpairs, HLpairs) ground thruth for matching on each of two
%                           levels, HLpairs = []

function [img_new, features, GT] = transform_image(img, keypoints)
    setParameters_transformation_ri;
    
    img = imnoise(img,'gaussian', noise_m, noise_var);
    
    m = size(img,1);
    n = size(img,2);      
    
    img_new = repmat(img,1);
    img_new(:) = 0;
    
    % rotation matrix
    M_inv = [ cos(aff_transfo_angle)  sin(aff_transfo_angle); ... 
            -sin(aff_transfo_angle)  cos(aff_transfo_angle) ]; 

    for i=1:m
        for j=1:n
            
            x = ([i - m/2; j - n/2]-t)' * M_inv;
            x = x/aff_transfo_scale;
            
            x(1) = round(x(1) + m/2);
            x(2) = round(x(2) + n/2);

            if (x(1)>=1 && x(2)>=1 && x(1)<=m && x(2)<=n)
                 img_new(i,j,:)=img(x(1),x(2),:);
            end

        end
    end
    
    % coordinates of the transformed keypoints
    keypoints_new = aff_transfo_scale * M * keypoints' + t;
    keypoints_new = keypoints_new';
    
    % ground truth
    GT = [];
    
    
    % SIFT descriptors in the keypoints
    % [F, D] = vl_phow(single(E), 'Sizes', [6,8,10,16]); % Scales 
    [F, D] = vl_phow(single(E), 'Sizes', [8]); % Scales 
    
    features.edges = F;
    features.descr = D;
    
    figure, imshow(img_new);
    
end