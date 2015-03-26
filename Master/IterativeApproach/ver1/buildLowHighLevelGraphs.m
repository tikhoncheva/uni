%%
%
function [ AG, DG, SP ] = buildLowHighLevelGraphs( img, features, nA, nNodes)

    display(sprintf('coarse graph of the %d image ...', 1));
    
    tic 
    % extract super pixels
    [SP.num, SP.label, SP.boundary] = SLIC_Superpixels(im2uint8(img), nA, 20);
    % build coarse graph (anchor graph)
    [AG, SP]   = buildAGraph(img, features.edges, features.descr, SP);
    % build fine graph
    [DG, AG.U] = buildDGraph(img, features.edges, features.descr, SP, nNodes);
    
    display(sprintf(' ... finished (%f sec) ', toc));
end

