% Katja

function [tmpFrames, tmpDescr, nV, runtime ] = find_features_harlap_vl(img, cut_image, varargin)

    %% Set parameters
    SetParameters;

    % default detector heslap_vl
    % descriptor = 'sift'
    
    %% Detect points of interest
    
    if cut_image
        % select rectangle region on the reference image
        figure
            imagesc(img),colormap(gray);
            title('Reference Image');
            hold on;     
            rect = getrect;   
            plot(rect)
        hold off;

        close all;
                
        % cut a selected part from the image
        img_cut = imcrop(img,rect);

        xmin = rect(1,1);
        ymin = rect(1,2);
        
        tic
        [tmpFrames,Info] = loadfeatures_harlap_vl(img_cut);
        tmpFrames(1,:) = tmpFrames(1,:) + xmin;
        tmpFrames(2,:) = tmpFrames(2,:) + ymin;
    else
        tic
        [tmpFrames,Info] = loadfeatures_harlap_vl(img);
    end
    
%     figure;
%         imagesc(img),colormap(gray);
%         title('Feature detector');
%         hold on;     
%         h1 = vl_plotframe(tmpFrames);
%         set(h1,'color','y','linewidth', 2) ;
%     hold off;
    
    %% Sort descriptors according to their magnitude
    % use for this info.peakScores information  from vl_covdet function
    % and threshold the picks
    
    [detectorsPicks, indx] = sort(Info.peakScores);
    meanPick = mean(detectorsPicks);
    indxDel = (detectorsPicks < 0.7*meanPick);
    indx(indxDel) = [];
    tmpFrames = tmpFrames(:, indx);
    detectorsPicks = detectorsPicks(:, indx);

%     figure;
%         imagesc(img),colormap(gray);
%         title('After suppression');
%         hold on;     
%         h1 = vl_plotframe(tmpFrames);
%         set(h1,'color','y','linewidth', 2) ;
%     hold off;

    %% Eleminate too small or large features according to the area of the hole image
     
    minAreaRatio = 1*10^(-5);
    maxAreaRatio = 1*10^(-4);

    areaimg = prod(size(img));
    area = pi * abs(tmpFrames(3,:).*tmpFrames(6,:) - tmpFrames(4,:).*tmpFrames(5,:)); % area of ellipse
    
    idxValid = ( area > minAreaRatio * areaimg ) & ( area < maxAreaRatio * areaimg );
   
    tmpFrames = tmpFrames(:,idxValid);
    nV = size(tmpFrames, 2);
%     figure;
%         imagesc(img),colormap(gray);
%         title('Delete too small or large features');
%         hold on;     
%         h1 = vl_plotframe(tmpFrames);
%         set(h1,'color','y','linewidth', 2) ;
%     hold off;
%     display(sprintf('%d feautures', nV))

    %% Eliminate Picks that are to close to each other
%     % Calculate the distance between each pair of features.
%     % Find features which are close to one other and leave
%     
%     indx_remaining = eliminate_closed_features(tmpFrames(1:2,:), detectorsPicks);
%     
%     tmpFrames = tmpFrames(:, indx_remaining);
%     
%     figure;
%         imagesc(img),colormap(gray);
%         title('Delete close features');
%         hold on;     
%         h1 = vl_plotframe(tmpFrames);
%         set(h1,'color','y','linewidth', 2) ;
%     hold off;
%     
%     display(sprintf('Deleted %d feautures', nV-size(tmpFrames, 2)))
    
    %% Extract SIFT descriptors in the detected keypoints
    
    if size(tmpFrames, 2) > 0  
        [tmpFrames, tmpDescr] = vl_covdet(single(img), 'frames', tmpFrames) ;
        if size(tmpFrames,2) ~= size(tmpDescr,2) 
            error('Frames dim is not consistent with Descrs dim!');
        end
    end
    
    nV = size(tmpFrames, 2);
      
    %% Optional: Reduce number of features on the reference image
    if nargin==3 
        
       nV = min(nV,varargin{1}) ;    % reduce number of features to the given number;
       tmpFrames = tmpFrames(:,1:nV);
       tmpDescr = tmpDescr(:,1:nV);
       
%         [~,indx] = sort(tmpDescr,'descend');      
%         tmpDescr  = tmpDescr(:,indx(1:nV));
%         tmpFrames = tmpFrames(:,indx(1:nV));

    end
   
    runtime = toc;


end