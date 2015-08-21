function [featInfo] = features_Cho(fname1, img1)
    setParams;
    
    nView = 1;
    
    iparam.bPair = 1;
    iparam.nView = 2;
    iparam.bShow = false;
    
    bShow = iparam.bShow;

    iparam.view(1).filePathName = fname1;
    iparam.view(1).img = img1;

    featInfo = extract_localfeatures_mcho(iparam.view(1).filePathName, fparam, bShow );
    

    % eliminate patches for memory efficiency
    featInfo.patch = cell(0); 


end
