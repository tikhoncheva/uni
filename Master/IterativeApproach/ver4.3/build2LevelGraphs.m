%% Two-Level approach for Graph Construction
% Higher Level Graph: Graph of Superpixels based on superpixel segmentation
%                     of the entire image
% Lower Level Graph:  kNN - graph based on the extracted edge points
%
% Input 
%   img         given image
%   features   extracted edge points of the image and their descriptors
%   features = [edges, descriptors]
%   nSP_hl      number of superpixels for the higher level segmentation
%
function [ HLGraph, LLGraph, imgSP] = buildLowHighLevelGraphs( img, features, nSP_hl)

    display(sprintf('=================================================='));
    display(sprintf('Two-level graph structure for the given image...'));
    display(sprintf('=================================================='));
    t0 = tic ;    
   
    display(sprintf('\n - build lower level graph'));
    t1 = tic;
    LLGraph = buildLLGraph(features.edges, features.descr);
    display(sprintf('   finished in %f sec', toc(t1)));
    
    
    display(sprintf('\n - build higher level graph (anchor graph)'));
    t2 = tic;
    [HLGraph, U] = HEM_coarsen_2(LLGraph, nSP_hl);
    HLGraph.U  = U;
    HLGraph.F = ones(size(HLGraph.V,1),1);     % flags, that show if anchors were changed in previous iteration
    % F = 1 if the corresponding subgraph didn't changed 
    % F = 0, otherwise
    
%     % extract SIFT descriptors in nodes of HLGraph
%     binSize = 8;        % see VL_DSIFT documentation and conditions when result of vl_dsift
%     magnif = 3;         % is the same as one of vl_sift
% 
%     f = HLGraph.V';
%     f(3,:) = binSize/magnif;
%     f(4,:) = 0;
%     
%     [~, D] = vl_sift(single(rgb2gray(img)), 'frames', f) ;
%     HLGraph.D = D;  % 128x nV
    
    display(sprintf('   finished in %f sec', toc(t2)));
    
    display(sprintf('--------------------------------------------------'));
    display(sprintf('Summary (%f sec) ', toc(t0)));
    display(sprintf('--------------------------------------------------'));
end

