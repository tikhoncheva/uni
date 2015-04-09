%%
%
function [ AG, DG, SP_hl, SP_ll ] = buildLowHighLevelGraphs( img, features, nSP_hl, nSP_ll)

    display(sprintf('two-level graph structure for the first image...\n'));
    
    tic 
    % build higher level graph (anchor graph)
    [AG, SP_hl, SP_rectangles]   = buildHLGraph(img, features.edges, features.descr, nSP_hl);
    display(sprintf('%f sec to build higher level graph', toc));
    
    tic
    % build lower level graph
    [DG, SP_ll] = buildLLGraph(img, features.edges, features.descr, SP_hl, SP_rectangles, nSP_ll);
    display(sprintf('%f sec to build lower level graph', toc));
    
    display(sprintf(' ... finished (%f sec) ', toc));
end

