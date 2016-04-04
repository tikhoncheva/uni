% Katja

function [frames]=loadfeatures_harlap_vl(img_gray)
% Load local features using vlfeat library
     
     
    [ frames ] = vl_covdet(single(img_gray), 'Method', 'HarrisLaplace',...
                'EstimateAffineShape', false,...
                'EstimateOrientation', false);
            
% [ frames ] = vl_covdet(single(img_gray), 'Method', 'HarrisLaplace',...
%             'EstimateAffineShape', param.EstimateAffineShape,...
%             'EstimateOrientation', param.EstimateOrientation,...
%             'PeakThreshold', param.HarrisLaplace_PeakThreshold ); %,...'verbose') ;
   
     
end
