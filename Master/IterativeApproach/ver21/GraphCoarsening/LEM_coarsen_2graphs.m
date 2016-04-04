%% Graph Coarsing Algorithm using Light Edge Matching 
% img           an input image
% G             fine graph of the image img
% nA            number of nodes in the coarse graph

% find geometrical mearest neighbor of the node

function [cG1, U1, cG2, U2] = LEM_coarsen_2graphs(img1, G1, img2, G2, nA)

rng(1);

nV1 = size(G1.V,1);
nV2 = size(G1.V,1);


cG1 = cGraph_init(G1);
cG2 = cGraph_init(G2);



matching1 = 1:nV1;  % save information about concatenated nodes of the initial graphs
tau1 = 1:nV1;       % mapping between node indices of a coarse and initial graphs

nmin_it = floor(log(nA/nV1)/log(3/4));

matching2 = 1:nV2;  % save information about concatenated nodes of the initial graphs
tau2 = 1:nV2;       % mapping between node indices of a coarse and initial graphs

it = 1;
while nV1>nA && it<(nmin_it + 1)
    [cG1, tau1, matching1, cG2, tau2, matching2] = LEM(nA, cG1, tau1, matching1, ...
                                                           cG2, tau2, matching2);
    nV1 = size(cG1.V,1);
    nV2 = size(cG2.V,1);
    it = it + 1;
    
end


U1 = anchor_nodes_connections(tau1, matching1);
G1.U = U1;

U2 = anchor_nodes_connections(tau2, matching2);
G2.U = U2;

% figure;
% plot_twolevelgraphs(img, G, cG);
% title(sprintf('HEM Coarsed graph with %d nodes (initial %d nodes)', size(cG.V,1), size(G.V,1)) );

    
end

%%
function [G1, init_indexing1, matching1, G2, init_indexing2, matching2 ] = LEM(nA, G1, init_indexing1, matching1, ...
                                                                                   G2, init_indexing2, matching2)

    nV1 = size(G1.V,1);
    nV2 = size(G2.V,1);

    % Vector, that shows which nodes were already matched
    not_matched1 = ones(1, nV1);
    not_matched2 = ones(1, nV2);

    % Light Edge Matching
    LEM1 = [];
    LEM2 = [];
    
    it1 = 0;
    it_max1 = 100;

    while (nV1>nA && it1<=it_max1)
        
        u1 = randi(nV1);  % random select a node
        
        [s1, u1v1, not_matched1] = LEM_search(u1, G1.eW, not_matched1);
        
        u2 = knnsearch(G2.V, G1.V(u1,:));
        [s2, u2v2, not_matched2] = LEM_search(u2, G2.eW, not_matched2);
                
        if s1
            LEM1 = [LEM1; u1v1];
            nV1 = nV1 -1;
            it1 = 0;
        else
            it1 = it1 + 1;
        end
        
        if s2
            LEM2 = [LEM2; u2v2];
        end
 

    end
    
    
    [G1, init_indexing1, matching1] = LEM_contracting(G1, LEM1, init_indexing1, matching1);
    [G2, init_indexing2, matching2] = LEM_contracting(G2, LEM2, init_indexing2, matching2);
    
 
end

function [s, pair, not_matched] = LEM_search(u, eW, not_matched)

    wneighbors_u = eW(u,:).* not_matched;

    % if u is not matched and there is an unmatched neighbor(s)
    if not_matched(u) && sum(wneighbors_u(~isnan(wneighbors_u)))>0

        wneighbors_u(wneighbors_u==0) = NaN;
        [~, v] = min(wneighbors_u(:));

        not_matched(u) = 0;
        not_matched(v) = 0;

        pair = [u,v];
    
        s = true;
    else
        s = false;
        pair = [];
        
    end

end

function [G, init_indexing, matching] = LEM_contracting(G, LEM_list, init_indexing, matching)

    G.eW(isnan(G.eW)) = 0;
    
    % Coarsen: contract edges, adjusting new weights to edges and nodes
    lines_to_del = [];
    
    for i = 1:size(LEM_list,1)
       u = LEM_list(i,1);
       v = LEM_list(i,2);    
       
       % Weight of the new node
       G.nW(u) = G.nW(u) + G.nW(v);
       
       % Coordinates of the new node
       G.V(v,:) = G.V(u,:);
       
       % Redefine weights of the edges between new node w and neighbors of
       % u and v
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

function [cG] = cGraph_init(G)

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

end
