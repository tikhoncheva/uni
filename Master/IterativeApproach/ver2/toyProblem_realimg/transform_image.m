 
%% make 2 synthetic graphs for testing graph matching algorithm
% Output
%   newimg      new image obtained from the given image
%   features    extracted features of a new image (edge points +
%               descriptors)
%   GT = (LLpairs, HLpairs) ground thruth for matching on each of two
%                           levels, HLpairs = []

function [new_img, features, GT] = transform_image(img, keypoints)
    setParameters_transformation_ri;
 
    img = imnoise(img,'gaussian', noise_m, noise_var);
    
    m = size(img,1);
    n = size(img,2);      
    
    new_img = repmat(img,1);
    new_img(:) = 0;
    
    % rotation matrix
    M_inv = [ cos(aff_transfo_angle)  sin(aff_transfo_angle); ... 
            -sin(aff_transfo_angle)  cos(aff_transfo_angle) ]; 

    for i=1:m
        for j=1:n
            
            x = ([i + m/2; j + n/2]-t)' * M_inv;
            x(1) = round(x(1) - m/2);
            x(2) = round(x(2) - n/2);

            if (x(1)>=1 && x(2)>=1 && x(1)<=m && x(2)<=n)
                 new_img(i,j,:)=img(x(1),x(2),:);
            end

        end
    end
    
    figure, imshow(new_img);
    
end