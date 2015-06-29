%% Function for compairing two graphs according to their structure
%
%  Input
%     G1 = (V,D,E)    first subgraph
%     G2 = (V,D,E)   second subgraph
%
% Output
%    sim    similarity value between two graphs

% Use distance histogram as descriptor of the nodes

function [sim] = compair_subgraphs(G1, G2)
    
    n1 = size(G1.V,1);
    n2 = size(G2.V,1);
    
    Rmin = 0; Rmax = 30;
    d = 2;
    nbins = (Rmax-Rmin)/d;
    binEdges = linspace(Rmin,Rmax,nbins+1);
    
    % adjacency matrix of the first dependency graph
    A1 = zeros(n1, n1);
    E1 = G1.E; E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(A1), E1(:,1), E1(:,2));
    A1(ind) = 1;

    % adjacency matrix of the second dependency graph
    A2 = zeros(n2, n2);
    E2 = G2.E; E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(A2), E2(:,1), E2(:,2));
    A2(ind) = 1;
    
    
    
    G1_hist = zeros(n1,nbins);
%     figure; 
    for i=1:n1
        v1 = G1.V(i,1:2);
        ind_V_subG1 = ( (G1.V(:,1)-v1(1)).^2 + (G1.V(:,2)-v1(2)).^2<=Rmax^2);
        subG1_V = G1.V(ind_V_subG1, 1:2);
        
        A1cut = A1(ind_V_subG1, ind_V_subG1');    
        dist1 = squareform(pdist(subG1_V, 'euclidean'));
        dist1(~A1cut) = NaN;
        
        hist_descr = histc(dist1(:), binEdges);
        G1_hist(i,:) = hist_descr(1:end-1)/sum(hist_descr(1:end-1)); 
        
        
%         [subG1_E(:,1), subG1_E(:,2)] = find(A1cut);
%         subG1 = struct('V', subG1_V, 'E', subG1_E);

%         subplot(2, n1/2, i); plot_graph([], subG1);
        
        clear subG1_E;
    end
    
    G2_hist = zeros(n2,nbins);
%     figure; 
    for j=1:n2
        v2 = G2.V(j,1:2);
        ind_V_subG2 = ( (G2.V(:,1)-v2(1)).^2 + (G2.V(:,2)-v2(2)).^2<=Rmax^2);
        subG2_V = G2.V(ind_V_subG2, 1:2);

        A2cut = A2(ind_V_subG2, ind_V_subG2');    
        dist2 = squareform(pdist(subG2_V, 'euclidean'));
        dist2(~A2cut) = NaN;
        
        hist_descr = histc(dist2(:), binEdges);
        G2_hist(j,:) = hist_descr(1:end-1)/sum(hist_descr(1:end-1));

%         [subG2_E(:,1), subG2_E(:,2)] = find(A2cut);
%         subG2 = struct('V', subG2_V, 'E', subG2_E);
       
%         subplot(2, n2/2, j); plot_graph([], subG2);
        
        clear subG2_E;
    end
    
    D1 = repmat(G1_hist, n2, 1);
    D2 = kron(G2_hist, ones(n1,1));
    
    C = ((D1-D2).^2)./(D1+D2) * 0.5;
    C(isnan(C)) =0;
    C = sum(C, 2);
   
    sim = exp(-sum(C(:))/n1/n2);
    

end