function [image, imagefiles] = readImages

    %% Path to the Dataset

    image_path = ['..' filesep 'churchSmall'];
%     image_path = ['/home/kitty/Documents/Uni/Master/Databases/SUN/Images/c/church/outdoor/'];
    
      image_path = ['..' filesep 'oxbuild_small'];
    

    imagefiles = dir([image_path filesep '*.jpg']) ;

    N = length(imagefiles);   % number of images in the ordner
    image = cell(1,N); % cell of the images

    for i=1:N
        currentfilename = imagefiles(i).name;
        currentimage = imread([image_path filesep currentfilename]);
        if i==1
            B = imresize(currentimage,2);
            imwrite(B, [image_path filesep sprintf('%s_2.jpg', strtok(currentfilename,'.'))]);
        end
        % Convert the image to gray scale
        image{i} = single(rgb2gray(currentimage));
    end
end