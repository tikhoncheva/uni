function [F,D] = features_Cho(fname1, img1)
    setParams;
    
    nView = 1;
    
    iparam.bPair = 1;
    iparam.nView = 2;
    iparam.bShow = false;
    
    bShow = iparam.bShow;

    iparam.view(1).filePathName = fname1;
    iparam.view(1).img = img1;

    for j=1:nView
        viewInfo = extract_localfeatures_mcho( iparam.view(j).img, ...
                                               iparam.view(1).filePathName, fparam, bShow );
        view(j) = viewInfo;
    end
    

    % eliminate patches for memory efficiency
    view.patch = cell(0); 
    view.desc_ref = [];
    
    F = view.feat(:,1:2);
    D = view.desc';

end
