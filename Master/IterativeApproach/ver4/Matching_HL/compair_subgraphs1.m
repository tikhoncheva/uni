%% Function for compairing two graphs according to their structure
%
%  Input
%     G1 = (V,D,E)    first subgraph
%     G2 = (V,D,E)   second subgraph
%
% Output
%    sim    similarity value between two graphs

% Using Eigenvector Centrality
function [sim] = compair_subgraphs1(G1, G2)
    
    n1 = size(G1.V,1);
    n2 = size(G2.V,1);
    
    R = 30;
    
    ang =0:0.1:2*pi;
    cx = R*cos(ang);
    cy = R*sin(ang);
    
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

    G1_EVcentrality = zeros(n1,1);
    for i=1:n1
        v1 = G1.V(i,1:2);
        ind_V_subG1 = ( (G1.V(:,1)-v1(1)).^2 + (G1.V(:,2)-v1(2)).^2<=R^2);
        ind_v1 = ((G1.V(ind_V_subG1,1)-v1(1)).^2 + (G1.V(ind_V_subG1,2)-v1(2)).^2==0);
        A1cut = A1(ind_V_subG1, ind_V_subG1');    
        [V,D] = eig(A1cut);     % A1cut*V = V*D.
        [~,gr_eval] = max(D(1:size(D,1)+1:end));
        G1_EVcentrality(i) = V(ind_v1,gr_eval);
        
        clear subG1_E;
    end
    
    G2_EVcentrality = zeros(n2,1);
    for j=1:n2
        v2 = G2.V(j,1:2);
        ind_V_subG2 = ( (G2.V(:,1)-v2(1)).^2 + (G2.V(:,2)-v2(2)).^2<=R^2);
        ind_v2 = ((G2.V(ind_V_subG2,1)-v2(1)).^2 + (G2.V(ind_V_subG2,2)-v2(2)).^2==0);
        A2cut = A2(ind_V_subG2, ind_V_subG2');
        [V,D] = eig(A2cut);
        [~,gr_eval] = max(D(1:size(D,1)+1:end));
        G2_EVcentrality(j) = V(ind_v2,gr_eval);
      
        clear subG2_E;
    end
    
    pairwise_comp = abs(repmat(G1_EVcentrality,1, n2) - repmat(G2_EVcentrality',n1,1));
    pairwise_comp = exp(-pairwise_comp);
    
    sim = max( pairwise_comp, [], 2);
    
    sim = sum(sim)/n1;

end