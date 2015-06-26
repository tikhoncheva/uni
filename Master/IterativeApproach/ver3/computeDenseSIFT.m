function [F,D] = computeDenseSIFT(img)
    
clc

border = 0;

radius = 6; %2;
thr = 0.2; %0.05;

% img = imcrop(img, [border border size(img, 1)-2*border size(img,2)-2*border]);

% Piotr Dollar toolbox
addpath(genpath('../../Tools/piotr_toolbox_V3.26/'));
% Edge extraction
addpath(genpath('../../Tools/edges-master/'));

load /export/home/etikhonc/Documents/Tools/edges-master/edgesModel.mat   % model

% find edge points
E = imresize(edgesDetect(imresize(img,2), model),0.5);

% apply non-maximum suppression
[subs, ~] = nonMaxSupr(double(E), radius, thr);
subs = 2*floor(subs/2) + 1;

highthr = 0.1;
lowthr = 0.025;
E(E>highthr) = highthr;
E(E<lowthr) = lowthr;
E = 1/highthr * E;


binSize = 8;        % see VL_DSIFT documentation and conditions when result of vl_dsift
magnif = 3;         % is the same as one of vl_sift

% Extract PHOW-Features (dense SIFT at several resolutions)
% [F, D] = vl_phow(single(Es), 'Sizes', [6,8,10,16]); % Scales 
% [F1, D1] = vl_phow(single(E), 'Sizes', [8], 'Magnif', magnif, 'Step',1); % Scales [8]

Es = vl_imsmooth(E, sqrt((binSize/magnif)^2 - .25));
[F, D] = vl_dsift(single(Es), 'size', binSize, 'Bounds', [1+border, 1+border, size(E, 1)-border, size(E,2)-border]); % single scale 
% F(1,:) = F(1,:) + border;
% F(2,:) = F(2,:) + border;
F(3,:) = binSize/magnif ;
F(4,:) = 0 ;

lia = ismember(F([2,1],:)', subs, 'rows');

F = F(:,lia);
D = D(:,lia);

rmpath(genpath('../../Tools/piotr_toolbox_V3.26/'))
rmpath(genpath('../../Tools/edges-master/'))
end    