%% create a gaussian pyramid of images
%
% Input 
% img               original image
% ipparam           parameters
% ipparam.scalef    scale factor between pyramid levels
% ipparam.nLevels   number of the levels
% fparam            parameters of the feature detection
% igparam           parameters of the initial graph construction
%
% Output
%
function [I1, I2, M] = imagePyramid_imageTr(view)

setParameters;

scalef = ipparam.scalef;
nLevels = ipparam.nLevels;

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);                      

M = repmat(struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, ...
                  'GT', [], 'it', 0, 'affTrafo', []), nLevels,1);
              
I1 = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);
I2 = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);

img2 = view.img;
for i = 1:nLevels
   fprintf('\nLevel %d: \n', i);

   %    [edges, ~] = computeDenseSIFT(img2,fparam);        % Extract keypoitns
%    [img1, features1, features2, GT] = transform_image(img2, edges); 
   
   if i>1
       setParams;
       if ~exist('./tmp', 'dir')
           mkdir('./tmp');
       end
       iparam.view(1).fileName = sprintf('%s_level%d.png',view.fileName, i);
       iparam.view(1).filePathName = ['./tmp/', iparam.view(1).fileName];
       imwrite(img2, iparam.view(1).filePathName);
       iparam.nView = 1; iparam.bPair = 0;
       iparam.bShow = 0;
       
       cdata = features_Cho( iparam, fparam, mparam );
       view = cdata.view;
       clear iparam fparam mparam;
   end
   features2.edges = view.feat(:,1:2)';
   features2.descr = view.desc';  
   
   [img1, featInfo1, GT] = transform_image_lite(img2, view); 
   features1.edges = featInfo1.feat(:,1:2)';
   features1.descr = featInfo1.desc';
   
   LLG1 = buildLLGraph(features1.edges, features1.descr, igparam);
   LLG2 = buildLLGraph(features2.edges, features2.descr, igparam);
   
   % build anchor graphs   
%    HLG1 = buildHLGraph(1, LLG1, agparam);
%    HLG2 = buildHLGraph(2, LLG2, agparam);

%    HLG1 = buildHLGraph(i, LLG1, agparam);
%    HLG2 = buildHLGraph(i, LLG2, agparam);
   HLG1 = [];
   HLG2 = [];

   I1(i) = struct('img', img1, 'LLG', LLG1, 'HLG', HLG1); 
   I2(i) = struct('img', img2, 'LLG', LLG2, 'HLG', HLG2); 
   
%    GT.LLpairs = [GT.LLpairs(:,2), GT.LLpairs(:,1)];
   M(i).GT = GT;
   
   img2 = impyramid(img2, 'reduce');
end

end