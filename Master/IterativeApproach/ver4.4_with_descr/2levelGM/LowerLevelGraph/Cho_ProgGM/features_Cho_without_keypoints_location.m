function [featInfo] = features_Cho_without_keypoints_location(featInfo, filePathName)
    setParams;
    
%     nView = 1;
%     
%     iparam.bPair = 1;
%     iparam.nView = 2;
%     iparam.bShow = false;
%     
%     bShow = iparam.bShow;
% 
%     iparam.view(1).filePathName = fname1;
%     iparam.view(1).img = img1;

    featInfo = extract_localfeatures_mcho_without_keypoints_location(featInfo, filePathName, fparam);
    

    % eliminate patches for memory efficiency
    featInfo.patch = cell(0); 


end
