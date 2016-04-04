function [adjMatrix]  = buildDependGraph_RefImage(Frames, minDeg)

    tic
    
    nV = size(Frames, 2);
    [adjMatrixInd, ~] = knnsearch(Frames(1:2,:)', ....
                                  Frames(1:2,:)', 'k', minDeg + 1);                       
    adjMatrixInd = adjMatrixInd(:,2:end); % delete loops in each vertex (first column of the matrix)
    
    adjMatrix = zeros(nV, nV);
    
    for v= 1 : nV
        adjMatrix(v, adjMatrixInd(v,:)) =  1;
    end
    
    
    fprintf(' %f secs elapsed for building an image graph with %d nodes and minDeg = %d\n', ...
                        toc, nV, minDeg);

end