% Calculate weights of the edges in the constructed anchor graph
%
% E         list of edges of the given DG graph
% U         correspondences between vertices of the DG and anchor points (logical matrix)
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
        adjM_cutrows = adjM(U(:,i), :);
        for j=i+1:m
            adjM_cut = adjM_cutrows(:, U(:,j)');
            adjM_cut = triu(adjM_cut);
            
            num = sum(adjM_cut(:));

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