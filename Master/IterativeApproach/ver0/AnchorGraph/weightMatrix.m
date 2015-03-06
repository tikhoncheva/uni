% Calculate weights of the edges in the constructed anchor graph
%
% E         list of edges of the given DG graph
% U         correspondences between vertices of the DG and anchor points
%
% W         weights of the edges of the anchor graph

%
% Weight of the edge between anchors ai and aj is equal
% e(ai, aj) = #{sigma(ai) cut sigma(aj)}/ C
% C = sum(#{sigma(ai) cut sigma(aj)}, i)
% 
% sigma(ai) = edges between ai and vertices of the dependency graph, that
%             belong to ai
function W = weightMatrix(E, U)

    tic
    
    n = size(U, 1);      % number of vertices
    m = size(U, 2);      % number of anchor points 
    
    % adjacency matrix based on the given list of edges E
    adjM = zeros(n,n);
    E = [E; [E(:,2) E(:,1)]];   % add symmetrical edges
    ind = sub2ind(size(adjM), E(:,1), E(:,2));
    adjM(ind) = 1;
    
    W = zeros(m,m);   
    
    for i=1:m
        ai_xind = find(U(:,i)>0);
        for j=i+1:m
            aj_xind = find(U(:,j)>0);
            
            [v1,v2] = meshgrid(ai_xind, aj_xind);
            % delete same edges, e.g. x1x3 and x3x1
            v12 = [v1(:) v2(:)];
            v21 = [v2(:) v1(:)];
            
            for k=1:size(v12,1);
               equal_entries = all(bsxfun(@eq, v12(k,1:2), v21(:,1:2)),2);
               if numel(find(equal_entries>0))
                   v21(k - (size(v12,1)-size(v21,1)), :) = v12(k,1:2);
                   v21(equal_entries>0, :) = [];
               end
            end
          
            % linear index of the edges
            cutedges_ind = sub2ind(size(adjM),v21(:,1), v21(:,2));
    
            num = sum(adjM(cutedges_ind)); % here sum of the existing edges in DG, that connect clusters ai and aj
            W(i,j) = num;   
            W(j,i) = num;
        end 
    end
    
    % normalise rows of the weight matrix
    for i=1:m
        W(i,:) = W(i,:)/ sum(W(i,:)); 
    end

    sprintf('time spent to calculate weight matrix: %f sec ', toc)
    
end