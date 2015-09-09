function [featIdx feat_aug angle shscMatrix affMatrix ]= compute_norm_trans_image( feat, img, scaling, szPatch, nMaxOri )
% extract oriented regions from features
% pt is matrix of (21 x 21 x 3 x n) dimension, where n is number of features.
% each row of tr_matrix contains [ a11, a21, a31, a12, a22, a32, a31, a32, a33 ]
%
% scaling: Scaling factor measurement region/distinguished region
%
% Developed by Young Min Shin  SNU CVLAB
% 2007.8.3 modified by Minsu Cho 
% upon codes provided by http://www.robots.ox.ac.uk/~vgg/research/affine/descriptors.html

if nargin < 3,  scaling = 2;    end
if nargin < 4, szPatch = 41;   end
if nargin < 5,  nMaxOri = 1;   end

nFeat = size(feat,1); % number of features
nBuff = nFeat * max(nMaxOri,1);
featIdx = zeros(nBuff, 1);
feat_aug = zeros(nBuff, size(feat,2));
angle = zeros(nBuff, 1);
affMatrix = zeros(nBuff, 9);
shscMatrix = zeros(nBuff, 4);
fixed_angle = 0; % when nMaxOri = 0

iAugFeat = 0;
for iFeat=1:nFeat
    % 먼저 feature point 를 이용하여 기본 transform matrix 를 만들어준다.
    % patch -> image 로 가는 transformaion 임.
    A = [feat(iFeat,3),feat(iFeat,4);feat(iFeat,4),feat(iFeat,5)]^(-0.5); % [ a b; b c ]^0.5
    t_affMatrix = [A(1,1), A(1,2) , feat(iFeat,1), A(2,1), A(2,2), feat(iFeat,2), 0, 0, 1];
    t_shscMatrix = [A(1,1), A(1,2), A(2,1), A(2,2)];
   
    if nMaxOri <= 0
        iAugFeat = iAugFeat + 1;
        R=[cos(fixed_angle), -sin(fixed_angle); sin(fixed_angle),cos(fixed_angle)];
        AR = A*R;
            
        featIdx(iAugFeat) = iFeat;
        feat_aug(iAugFeat,:) = feat(iFeat,:);
        angle(iAugFeat) = fixed_angle;
        affMatrix(iAugFeat,:) = [AR(1,1), AR(1,2), feat(iFeat,1), AR(2,1), AR(2,2), feat(iFeat,2), 0, 0, 1];
        shscMatrix(iAugFeat,:) = t_shscMatrix;      
    else
        % orientation estimation?
        % 만든 matrix 를 가지고 patch 를 뽑고 orinetation 을 얻는다.
        [ t_normRegion bOutside ]= normalize_patchCMEX2(img, t_affMatrix, scaling, szPatch);
        if bOutside, continue; end % if the region is outside of image domain, skip
        t_angle = dominant_orientation(t_normRegion,nMaxOri);
    %     clf; subplot(131); 
    %     imshow(normalizedRegion{iFeat}); axis equal;
    %     title( [ 'Feature ' num2str(iFeat) ' : ' num2str(angle(iFeat)*180/3.14159) ] );   
    %     subplot(132); 
    %     imshow(imrotate(normalizedRegion{iFeat},angle(iFeat)*180/3.14159) ); axis equal;

        for iAngle = 1:length(t_angle) 
            iAugFeat = iAugFeat + 1;
            % 얻어진 orientation 이 적용된 transformation matrix 를 만든다.
            %[ affineMatrix(iFeat,:) shscMatrix(iFeat,:) ] = computeNormTransform( 
            R=[cos(t_angle(iAngle)), -sin(t_angle(iAngle)); sin(t_angle(iAngle)),cos(t_angle(iAngle))];
            AR = A*R;

            featIdx(iAugFeat) = iFeat;
            feat_aug(iAugFeat,:) = feat(iFeat,:);
            angle(iAugFeat) = t_angle(iAngle);
            affMatrix(iAugFeat,:) = [AR(1,1), AR(1,2), feat(iFeat,1), AR(2,1), AR(2,2), feat(iFeat,2), 0, 0, 1];
            shscMatrix(iAugFeat,:) = t_shscMatrix;
        end
        
    end
        
end

if iAugFeat < nBuff
    featIdx(iAugFeat+1:end) = [];
    feat_aug(iAugFeat+1:end,:) = [];
    angle(iAugFeat+1:end) = [];
    affMatrix(iAugFeat+1:end,:) = [];
    shscMatrix(iAugFeat+1:end,:) = [];
end

end


% 
% %%%%%% normalize_patch
% function [imout]=normalize_patch(img, conf ,normalized_patch_size)
% 
% A = [conf(1), conf(2), conf(3);
%      conf(4), conf(5), conf(6);
%      conf(7), conf(8), conf(9) ];
% 
% 
% imout=zeros(normalized_patch_size,normalized_patch_size,3);
% [h w c]=size(img);
% half_size=floor(normalized_patch_size/2);
% 
% %compute the transformed region with bilinear interpolation
% for j=-half_size:half_size
%   for i=-half_size:half_size
% 
%       pt=A*[i j]';
%       pts=floor(pt);
%       xt=int32(pts(1));
%       yt=int32(pts(2));
%       dx=pt(1)-pts(1);
%       dy=pt(2)-pts(2);
% 
%       if x+xt>0 && x+xt+1<w && y+yt>0 && y+yt+1<h
% 
%         imout(half_size+1+j,half_size+1+i,:)= img(y+yt,x+xt,:)*(1-dx)*(1-dy)+  img(y+yt+1,x+xt,:)*(1-dx)*(dy)+  img(y+yt,x+xt+1,:)*(dx)*(1-dy)+  img(y+yt+1,x+xt+1,:)*(dx)*(dy); 
%       else imout(half_size+1+j,half_size+1+i,:)=0;
%       end
% 
%   end
% end
% imout = imout/255;
% 
% 
% 
% 
