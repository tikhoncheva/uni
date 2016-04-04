addpath('./edges-master/');
addpath(genpath('./piotr_toolbox_V3.26/'));

radius = 2;
thr = 0.05;

I1 = imread('all_souls_000006.jpg');
I2 = imread('all_souls_000013.jpg');

% I1 = imread('sun_aafpznbwiqbmolft.jpg');
% I2 = imread('sun_aafpznbwiqbmolft_2.jpg');


load ./edges-master/edgesModel.mat
% find edge points
E1 = imresize(edgesDetect(imresize(I1,2), model),0.5);
E2 = imresize(edgesDetect(imresize(I2,2), model),0.5);
% apply non-maximum suppression
[subs1,vals1] = nonMaxSupr(double(E1), radius, thr);
bw1nms = false(size(E1));
bw1nms(sub2ind(size(bw1nms),subs1(:,1),subs1(:,2))) = true;

[subs2,vals2] = nonMaxSupr(double(E2), radius, thr);
% bw2nms = false(size(E2));
% bw2nms(sub2ind(size(bw2nms),subs2(:,1),subs2(:,2))) = true;

subs2 = 2*floor(subs2/2) + 1;

highthr = 0.1;
lowthr = 0.025;
E1(E1>highthr) = highthr;
E1(E1<lowthr) = lowthr;
E1 = 1/highthr * E1;
E2(E2>highthr) = highthr;
E2(E2<lowthr) = lowthr;
E2 = 1/highthr * E2;

% Extract PHOW-Features (dense SIFT at several resolutions)
[F1, D1] = vl_phow(single(E1), 'Sizes', [6,8,10,16]); % Scales 
[F2, D2] = vl_phow(single(E2), 'Sizes', [6,8,10,16]); % Scales 

lia = ismember(F2([2,1],:)', subs2, 'rows');
F2dec = F2(:,lia);
D2dec = D2(:,lia);

[d1, idx1] = bwdist(bw1nms); % distance transformatiion of the binary image 

% imshow(cat(2,I1,I2))

ihight = max(size(I1,1),size(I2,1));
if size(I1,1) < ihight
    I1(ihight,1,1) = 0;
end
if size(I2,1) < ihight
    I2(ihight,1,1) = 0;
end

img3 = cat(2,I1,I2);

imagesc(img3)

while (1)
    [X1, Y1] = ginput(1);
    [Y1, X1] = ind2sub(size(E1),idx1(round(Y1),round(X1)));
    
    X1 = 2*floor(X1/2) + 1; 
    Y1 = 2*floor(Y1/2) + 1;
    
    if (X1 <= size(I1,2))
        clf, % imshow(cat(2,I1,I2))
        
        ihight = max(size(I1,1),size(I2,1));
        if size(I1,1) < ihight
            I1(ihight,1,1) = 0;
        end
        if size(I2,1) < ihight
            I2(ihight,1,1) = 0;
        end

        img3 = cat(2,I1,I2);

        imagesc(img3)   
       
        ind = find(F1(1,:)==X1 & F1(2,:)==Y1)
        for j = 1:numel(ind)
            [val,nnInd] = sort(sum(abs(bsxfun(@minus,double(D2dec),double(D1(:,ind(j)))))));
            for k = 1:5
                X2 = F2dec(1,nnInd(k)) + size(I1,2);
                Y2 = F2dec(2,nnInd(k));
                line([X1,X2],[Y1,Y2],'LineWidth',2,'Color','g');
                rectangle('Position',[X2-5,Y2-5,10,10],'FaceColor','g');
            end
        end
        rectangle('Position',[X1-5,Y1-5,10,10],'FaceColor','r');        
    end
end
