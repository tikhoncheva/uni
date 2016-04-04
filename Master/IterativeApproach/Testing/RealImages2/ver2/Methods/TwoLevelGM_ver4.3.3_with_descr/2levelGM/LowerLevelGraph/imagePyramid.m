%% create gaussian pyramid of images
%
% Input 
% img               original image
% ipparam           parameters
% ipparam.scalef    scale factor between pyramid levels
% ipparam.nLevels   number of the levels
% fparam            parameters of the feature detection
% igparam           parameters of the initial graph construction
function [I,M] = imagePyramid(view)

setParameters;

scalef = ipparam.scalef;
nLevels = ipparam.nLevels;

HLGmatches = struct('objval', 0, 'matched_pairs', []);
LLGmatches = struct('objval', 0., 'matched_pairs', [], 'lobjval', []);
 
GT.LLpairs = [];
GT.HLpairs = [];

M = repmat(struct('HLGmatches', HLGmatches, 'LLGmatches', LLGmatches, ...
                  'GT', GT, 'it', 0, 'affTrafo', []), nLevels,1);

I = repmat(struct('img', [], 'LLG', [], 'HLG', []), nLevels,1);

img = view.img;
for i = 1:nLevels
   fprintf('\nLevel %d: \n', i);
   
%    [edges, descr] = computeDenseSIFT(img, fparam);
%    zerocol_ind = all( ~any(descr), 1);
%    descr(:, zerocol_ind) = []; % remove zero columns
%    edges(:, zerocol_ind) = []; %  and corresponding points

   if i>1
       setParams;
       if ~exist('./tmp', 'dir')
           mkdir('./tmp');
       end
       iparam.view(1).fileName = sprintf('%s_level%d.png',view.fileName, i);
       iparam.view(1).filePathName = ['./tmp/', iparam.view(1).fileName];
       imwrite(img, iparam.view(1).filePathName);
       iparam.nView = 1; iparam.bPair = 0;
       iparam.bShow = 0;
       
       cdata = features_Cho( iparam, fparam, mparam );
       view = cdata.view;
%        featInfo = features_Cho(filePathName, img);
       clear iparam fparam mparam;
   end    
   edges = view.feat(:,1:2)';
   descr = view.desc';
   
   nV = size(edges,2);
   if nV>500
       ind_rand = datasample(1:nV,500,'Replace',false);
       edges = edges(:, ind_rand);
       descr = descr(:, ind_rand);
   end
    
   LLG = buildLLGraph(edges, descr, igparam);
%    HLG = buildHLGraph(ID, LLG, agparam);

%     HLG = buildHLGraph(i, LLG, agparam);
   HLG = [];

   I(i) = struct('img', img, 'LLG', LLG, 'HLG', HLG); 
   
   img = impyramid(img, 'reduce');
end

end