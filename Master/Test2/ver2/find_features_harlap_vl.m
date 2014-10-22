% Katja

function [tmpFrames, tmpDescr, nV ] = find_features_harlap_vl(img, varargin)

    %% Set parameters
    SetParameters;

    detectorId = 4;   % default detector heslap_vl
    % descriptor = 'sift'
    
    switch nargin
        case 4
            nSel = varargin{1} ;    % reduce number of features to nSe
            xmin = varargin{2} ;    % and find features inside selected region
            ymin = varargin{3} ;

            [tmpFrames] = loadfeatures_harlap_vl(img);
            tmpFrames(1,:) = tmpFrames(1,:) + xmin;
            tmpFrames(2,:) = tmpFrames(2,:) + ymin;
            
        case 3
            xmin = varargin{1} ;    % find features inside selected region
            ymin = varargin{2} ;

            [tmpFrames] = loadfeatures_harlap_vl(img);
            tmpFrames(1,:) = tmpFrames(1,:) + xmin;
            tmpFrames(2,:) = tmpFrames(2,:) + ymin;
        case 2
            nSel = varargin{1} ;    % reduce number of features to nSel
            [tmpFrames] = loadfeatures_harlap_vl(img);
        case 1
            [tmpFrames] = loadfeatures_harlap_vl(img);
        otherwise
            error('Error in find_features: wrong number of input parameters');  
    end
    
    
    % rescaling for each detector
%     tmpFrames(3:6,:) = tmpFrames(3:6,:) * fparam.bFeatScale(detectorId);
    
%     % eleminate too small or large features
%     
    minAreaRatio = 5*10^(-5);
    maxAreaRatio = 7*10^(-4);

    areaimg = prod(size(img));
    area = pi * abs(tmpFrames(3,:).*tmpFrames(6,:) - tmpFrames(4,:).*tmpFrames(5,:)); % area of ellipse
    
    idxValid = ( area > minAreaRatio * areaimg ) & ( area < maxAreaRatio * areaimg );
    
%      idxValid = ( area < minAreaRatio * areaimg ); 
%      idxValid = ( area > maxAreaRatio * areaimg );
    
    tmpFrames = tmpFrames(:,idxValid);
    
    
    nV = size(tmpFrames, 2);
 
    %% descriptor extraction (SIFT)
    
    if nV > 0  
	 [tmpFrames, tmpDescr] = vl_covdet(single(img), 'frames', tmpFrames) ;
	 if size(tmpFrames,2) ~= size(tmpDescr,2) 
	    error('Frames dim is not consistent with Descrs dim!');
	 end
%         [ tmpFrames, tmpDescr ] = extractSIFT(img, tmpFrames,...
%             'contrastInsensitive', fparam.bContrastInsenstive, 'NBP', fparam.nBP,...
%             'descScale', fparam.descScale, 'estimateOrientation', fparam.bEstimateOrientation);
%         %[ tmpFrame tmpDesc ] = extractSIFT(featInfo.img_gray, tmpFrame, 'estimateOrientation', true);
    end
    
    nV = size(tmpFrames, 2);
    
    %% Sort descriptors according to their magnitude
    
    % calculate norm od each descriptor
    
    tmpDescrNorm = zeros(1, nV);
    for i=1:nV
        tmpDescrNorm(1,i) = norm(tmpDescr(:,i),2);
    end
    
    [~, indx] = sort(tmpDescrNorm);
    
    
    tmpFrames = tmpFrames(:, indx);
    tmpDescr  = tmpDescr(:,  indx);
    
    
    %% Optional: Reduce number of features on the reference image
    if nargin==2 || nargin==4 % i.e. first image
        
       nV = nSel;
       tmpFrames = tmpFrames(:,1:nV);
       tmpDescr = tmpDescr(:,1:nV);
       
%         [~,indx] = sort(tmpDescr,'descend');      
%         tmpDescr  = tmpDescr(:,indx(1:nV));
%         tmpFrames = tmpFrames(:,indx(1:nV));

    end


end