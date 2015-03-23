function [ AG, DG, SP ] = buildCoarseFineGraphs( handles )
%BUILDCOARSEFINEGRAPHS Summary of this function goes here
%   Detailed explanation goes here
    display(sprintf('coarse graph of the %d image ...', 1));
    
    tic 
    
    img1 = handles.img1;
    nA = handles.nAnchors;
    
    edges = handles.features1.edges;
    descr = handles.features1.descr;

    
    [img1SP.num, img1SP.label, img1SP.boundary] = SLIC_Superpixels(im2uint8(img1), nA, 20);
    
    [AG, img1SP] = buildAGraph(img1, edges, descr, img1SP);
    
    [DG] = buildDGraph(img1, edges, descr, img1SP);
    
    SP = img1SP;
    
    display(sprintf(' ... finished (%f sec) ', toc));
end

