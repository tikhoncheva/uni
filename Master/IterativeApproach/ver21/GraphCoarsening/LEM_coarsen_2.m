%% Graph Coarsing Algorithm using Light Edge Matching 
% img           an input image
% G             fine graph of the image img
% nA            number of nodes in the coarse graph

function [cG, U] = LEM_coarsen(img, G, nA)

rng(1);

nV = size(G.V,1);

% adjacency matrix
adjM = zeros(nV, nV);
E = G.E;
E = [E; [E(:,2) E(:,1)]];
ind = sub2ind(size(adjM), E(:,1), E(:,2));
adjM(ind) = 1;

% Edge Weights Matrix
eW = squareform(pdist(G.V, 'euclidean'));
sigma = sum(eW(:))/nV/nV;
eW = eW./sigma;

eW(~adjM) = NaN;

% Node Weights Vector
nW = ones(1, nV);


cG.V = G.V;
cG.E = G.E;
cG.nW = nW;
cG.eW = eW;

matching = 1:nV;  % save information about concatenated nodes of the initial graphs
tau = 1:nV;       % mapping between node indices of a coarse and initial graphs

nmin_it = floor(log(nA/nV)/log(3/4));

it = 1;
while nV>nA && it<(nmin_it + 1)
    [cG, tau, matching] = LEM(nA, cG, tau, matching);
    nV = size(cG.V,1);
    it = it + 1;
    
%     figure;
%     plot_twolevelgraphs(img, G, cG);

end

U = anchor_nodes_connections(tau, matching);
G.U = U;

% figure;
% plot_twolevelgraphs(img, G, cG);
% title(sprintf('LEM Coarsed graph with %d nodes (initial %d nodes)', size(cG.V,1), size(G.V,1)) );

    
end

%%
function [G, init_indexing, matching] = LEM(nA, G, init_indexing, matching)

    nV = size(G.V,1);

    % Vector, that shows which nodes were already matched
    not_matched = ones(1, nV);

    % Light Edge Matching
    LEM = [];
    it = 0;
    it_max = 100;
    
    u = randi(nV);  % random select a node
    W = squareform(pdist(G.V, 'euclidean'));

    while (nV>nA && it<=it_max)
        
        [~,u] = max(W(u,:).* not_matched); % u = randi(nV);  % random select a node

        wneighbors_u = G.eW(u,:).* not_matched;
        
        % if u is not matched and there is an unmatched neighbor(s)
        if not_matched(u) && sum(wneighbors_u(~isnan(wneighbors_u)))>0
            
            wneighbors_u(wneighbors_u==0) = NaN;
            [~, v] = min(wneighbors_u(:));

            not_matched(u) = 0;
            not_matched(v) = 0;
            
            LEM = [LEM; [u,v]];

            nV = nV - 1;       
            it = 0;
        else
            it = it + 1;
        end

    end
    
    G.eW(isnan(G.eW)) = 0;
    
    % Coarsen: contract edges, adjusting new weights to edges and nodes
    lines_to_del = [];
    
    for i = 1:size(LEM,1)
       u = LEM(i,1);
       v = LEM(i,2);    
       
       % Weight of the new node
       G.nW(u) = G.nW(u) + G.nW(v);
       
       % Coordinates of the new node
       G.V(u,:) = (G.V(u,:) + G.V(v,:))/2;
%        G.V(v,:) = G.V(u,:);
       
       % Redefine weights of the edges between new node w and neighbors of
       % u and v
%        line_u_nonzeros = ~isnan(G.eW(u, :) );
%        line_v_nonzeros = ~isnan(G.eW(v, :) );
%        
%        common_neighbors = line_u_nonzeros & line_v_nonzeros;
%        
%        G.eW(u, common_neighbors) = G.eW(u, common_neighbors) + G.eW(v, common_neighbors);
%        G.eW(common_neighbors, u) = G.eW(common_neighbors, u) + G.eW(common_neighbors, v);

       G.eW(u, :) = G.eW(u, :) + G.eW(v, :);
       G.eW(:, u) = G.eW(:, u) + G.eW(:, v);

       % save indormation about contracted nodes
       matching(init_indexing(v)) = init_indexing(u);
       
       lines_to_del = [lines_to_del; v];
      
    end
    
    G.V(lines_to_del, :) = [];
    
    G.nW(lines_to_del) = [];
    
    G.eW(lines_to_del, :) = [];
    G.eW(:, lines_to_del) = [];
    G.eW(1:(size(G.eW,1)+1):end) = NaN;
    
    init_indexing(lines_to_del) = [];
    
    [I,J] = find(G.eW);
    G.E = [I,J];
    
    G.eW(G.eW==0) = NaN;
    
end


%% Define conenctions between nodes of the finest and coarsest levels
function U = anchor_nodes_connections(tau, concatenate_with)

nF = numel(concatenate_with);  % #nodes on the finest level

ind = (( [1:nF] - concatenate_with) ~= 0);

nE = sum(ind(:));                % # eliminated nodes
nC = nF - nE;                    % # nodes on the coarsest level

U = false(nF, nC);

for i = 1:nF
    
    j = concatenate_with(i);
    
    while j ~= concatenate_with(j)
        j = concatenate_with(j);
    end
    
    U(i, tau==j) = true;
end


end

