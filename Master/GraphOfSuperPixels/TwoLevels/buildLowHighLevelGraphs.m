%%
%
function [ AG, DG, SP ] = buildLowHighLevelGraphs( img, features, nSP_hl, nSP_ll)

    display(sprintf('two-level graph structure for the first image...'));
    
    tic 
    % build higher level graph (anchor graph)
    [AG, SP]   = buildHLGraph(img, features.edges, features.descr, nSP_hl);
    
    % build lower level graph
    [DG, AG.U] = buildLLGraph(img, features.edges, features.descr, SP, nSP_ll);
    
    display(sprintf(' ... finished (%f sec) ', toc));
end

