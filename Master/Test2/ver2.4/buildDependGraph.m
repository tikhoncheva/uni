function [adjMatrix]  = buildDependGraph(Frames, DG_RefImage, matchInfo)

    tic
    
    nV = size(Frames, 2);
    adjMatrix = zeros(nV, nV);
     
    [i, j] = find(DG_RefImage);
    
    for p=1: size(i,1)
        neighbors_i = (matchInfo.match(1,:)==i(p));
        neighbors_j = (matchInfo.match(1,:)==j(p));
        
        [p1,p2] = meshgrid(matchInfo.match(2,neighbors_i),...
                           matchInfo.match(2,neighbors_j));
        
        pairs = [p1(:), p2(:)];
        
        adjMatrix(pairs(:,1),pairs(:,2)) = 1;
        
    end
   
    fprintf(' %f secs elapsed for building an image graph with %d nodes\n', ...
                        toc, nV);

end