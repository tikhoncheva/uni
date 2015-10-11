%% Function to compute initial affinity matrix between two graphs
%
% HLG1 = (V,E,U)
% HLG2 = (V,E,U)
%
% LLG1 = (V,E,D)
% LLG2 = (V,E,D)

function [affmatrix, HLG1, HLG2] = initialAffinityMatrix(LLG1, LLG2, HLG1, HLG2, corrmatrix)



nA1 = size(HLG1.V,1);
nA2 = size(HLG2.V,1);

% diag of the affinity matrix = anchor similarity
[I,J] = find(corrmatrix);
cand_matches = [I,J];
ind_cand_matches = [(J-1)*nA1 + I];

nodesim = anchorsim_subg_matching(LLG1, LLG2, HLG1, HLG2, cand_matches);

% [nodesim1, HLG1, HLG2] = structural_node_similarity(LLG1, LLG2, HLG1, HLG2, corrmatrix); % using structur of the anchor subgraphs
 
% if ~isempty(LLG1.D) && ~isempty(LLG2.D)
%     [nodesim2, HLG1, HLG2] = BoF_node_similarity(LLG1, LLG2, HLG1, HLG2, corrmatrix); % using Back Of Features Representation
% else
%     nodesim2 = zeros(nA1*nA2,1); 
% end
% nodesim2 = zeros(nA1*nA2,1); 

% nodesim = nodesim1;
% nodesim = nodesim2;
% nodesim = nodesim1 + nodesim2;


% non-diagonal elements of the affinity matrix

D = zeros(nA1*nA2);

% edge weights
% % % % W1 = edgeWeights_HLG(HLG1, LLG1); ind1 = sub2ind([nA1, nA1], HLG1.E(:,1), HLG1.E(:,2));
% % % % W2 = edgeWeights_HLG(HLG2, LLG2); ind2 = sub2ind([nA2, nA2], HLG2.E(:,1), HLG2.E(:,2));

% distance matrix of the first anchor graph
G1 = zeros(nA1);
% G1(ind1) = W1; 

for i = 1:nA1
    ai = i;
    for j = 1:i-1
       aj = j;

       % nodes of the subgraph Ai
       ind_Vai = HLG1.U(:,ai);
       if sum(ind_Vai)==0
           continue;
       end 
       Vai = LLG1.V(ind_Vai,:);
       nVai = size(Vai, 1);

       % nodes of the subgraph Aj
       ind_Vaj = HLG1.U(:,aj);
       if sum(ind_Vaj)==0
           continue;
       end 
       Vaj = LLG1.V(ind_Vaj,:);   
       nVaj = size(Vaj, 1);

       % calculate pairwise distance between nodes in Vai and Vaj
       dist = repmat(Vai(:,1:2), nVaj,1) ...
            - kron  (Vaj(:,1:2), ones(nVai, 1));
       dist = sqrt(dist(:,1).^2 + dist(:,2).^2);

       % take median
       G1(i,j) = median(dist(:));
    end

 end
    
G1 = G1 + G1';
G1 = G1./max(G1(:));                          % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% distance matrix of the second anchor graph
G2 = zeros(nA2);
% G2(ind2) = W2;
for i = 1:nA2
    ai = i;
    for j = 1:i-1
       aj = j;

       % nodes of the subgraph Ai
       ind_Vai = HLG2.U(:,ai);
       if sum(ind_Vai)==0
           continue;
       end 
       Vai = LLG2.V(ind_Vai,:);
       nVai = size(Vai, 1);

       % nodes of the subgraph Aj
       ind_Vaj = HLG2.U(:,aj);
       if sum(ind_Vaj)==0
           continue;
       end 
       Vaj = LLG2.V(ind_Vaj,:);   
       nVaj = size(Vaj, 1);

       % calculate pairwise distance between nodes in Vai and Vaj
       dist = repmat(Vai(:,1:2), nVaj,1) ...
            - kron  (Vaj(:,1:2), ones(nVai, 1));
       dist = sqrt(dist(:,1).^2 + dist(:,2).^2);

       % take median
       G2(i,j) = median(dist(:));
    end

end
 
G2 = G2 + G2';
G2 = G2./max(G2(:));                    % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% edge similarity matrix of two anchor graphs
sigma = 10;                            % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
D = (repmat(G1, nA2, nA2)-kron(G2,ones(nA1))).^2;
D = exp(-D./sigma);                  
D(isnan(D)) = 0;
D(1:size(D,1)+1:end) = 0;



% resulting affinity matrix
affmatrix = diag(nodesim) + D;

affmatrix = affmatrix(ind_cand_matches ,ind_cand_matches);




end