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
function [I1, I2, M] = imagePyramid_imageTr(img2, fparam, ipparam, igparam, agparam)

scalef = ipparam.scalef;
nLevels = ipparam.nLevels;

I1 = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);
I2 = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);                      

M = repmat(struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, ...
                  'GT', [], 'it', 0, 'affTrafo', []), nLevels,1);

for i = 1:nLevels
   fprintf('\nLevel %d: \n', i);
   
   [edges, ~] = computeDenseSIFT(img2,fparam);        % Extract keypoitns
   [img1, features1, features2, GT] = transform_image(img2, edges); 

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
   
   GT.LLpairs = [GT.LLpairs(:,2), GT.LLpairs(:,1)];
   M(i).GT = GT;
   
   img2 = impyramid(img2, 'reduce');
end

end