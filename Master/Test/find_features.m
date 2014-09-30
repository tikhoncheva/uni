function [tmpFrames, tmpDescr, nV ] = find_features(img, varargin)

    %% Set parameters
    SetParameters;

    detectorId = find(fparam.bFeatExtUse);  
    detector = fparam.featExt{detectorId};  %default 'hes_vl'

    % descriptor = 'sift';

    minAreaRatio = 0.01;
    maxAreaRatio = 0.3;
    thresholdlevel = 1; % 0: low, 1: normal, 2: high


    % minDeg = 1 ;
    
    switch nargin
        case 3
            xmin = varargin{1} ;
            ymin = varargin{2} ;

            %[tmpFrames, descrCell{1}] = vl_sift(img1cut,'PeakThresh', 10);
            [tmpFrames, tmpDescr ] = loadfeatures_vlfeat( img, detector, thresholdlevel);
            tmpFrames(1,:) = tmpFrames(1,:) + xmin;
            tmpFrames(2,:) = tmpFrames(2,:) + ymin;
        case 1
            %[tmpFrames, tmpDescr] = vl_sift(img,'PeakThresh', 13);
             [tmpFrames, tmpDescr ] = loadfeatures_vlfeat( img, detector, thresholdlevel);
        otherwise
            error('Error in find_features: wrong number of input parameters');  
    end
     % rescaling for each detector
    tmpFrames(3:6,:) = tmpFrames(3:6,:) * fparam.bFeatScale(detectorId);
    
    % eleminate too small or large features
    areaimg = prod(size(img));
    area = pi * abs(tmpFrames(3,:).*tmpFrames(6,:) - tmpFrames(4,:).*tmpFrames(5,:)); % area of ellipse
    idxValid = ( area > minAreaRatio * areaimg ) & ( area < maxAreaRatio * areaimg );
    tmpFrames = tmpFrames(:,idxValid);
    
    nV = size(tmpFrames, 2);
    
%     
    if nargin==3
        nV = 20;
        tmpFrames = tmpFrames(:,1:nV);
    end
        
    %% descriptor extraction (SIFT)
    
    if size(tmpFrames,2) > 0 && ( isempty(tmpDescr) || size(tmpFrames,2) ~= size(tmpDescr,2) ) 
        [ tmpFrames, tmpDescr ] = extractSIFT(img, tmpFrames,...
            'contrastInsensitive', fparam.bContrastInsenstive, 'NBP', fparam.nBP,...
            'descScale', fparam.descScale, 'estimateOrientation', fparam.bEstimateOrientation);
        %[ tmpFrame tmpDesc ] = extractSIFT(featInfo.img_gray, tmpFrame, 'estimateOrientation', true);
    end


end