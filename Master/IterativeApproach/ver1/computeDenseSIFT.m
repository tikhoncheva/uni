function [F,D] = computeDenseSIFT(img)
    
clc

border = 9;

radius = 6; %2;
thr = 0.2; %0.05;

img = imcrop(img, [border border size(img, 1)-border size(img,2)-border]);
load ../../Tools/edges-master/edgesModel.mat   % model

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

% Extract PHOW-Features (dense SIFT at several resolutions)
% [F, D] = vl_phow(single(E), 'Sizes', [6,8,10,16]); % Scales 
[F, D] = vl_phow(single(E), 'Sizes', [8]); % Scales 
F(:,1) = F(:,1) + border;
F(:,2) = F(:,2) + border;

lia = ismember(F([2,1],:)', subs, 'rows');

F = F(:,lia);
D = D(:,lia);

end    