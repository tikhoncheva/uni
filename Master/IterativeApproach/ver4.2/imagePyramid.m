%% create gaussian pyramid of images
%
% Input 
% img               original image
% ipparam           parameters
% ipparam.scalef    scale factor between pyramid levels
% ipparam.nLevels   number of the levels
% fparam            parameters of the feature detection
% igparam           parameters of the initial graph construction
function [I,M] = imagePyramid(ID, img, fparam, ipparam, igparam, agparam)

scalef = ipparam.scalef;
nLevels = ipparam.nLevels;

I = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);
GT.LLpairs = [];
GT.HLpairs = [];

M = repmat(struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, ...
                  'GT', GT, 'it', 1, 'affTrafo', []), nLevels,1);
              
for i = 1:nLevels
   fprintf('\nLevel %d: \n', i);
   
   [edges, descr] = computeDenseSIFT(img, fparam);
   zerocol_ind = all( ~any(descr), 1);
   descr(:, zerocol_ind) = []; % remove zero columns
   edges(:, zerocol_ind) = []; %  and corresponding points
    
   LLG = buildLLGraph(edges, descr, igparam);
   HLG = buildHLGraph(ID, LLG, agparam);

   I(i) = struct('img', img, LLG', LLG, 'HLG', HLG); 
   
   img = impyramid(img, 'reduce');
end

end