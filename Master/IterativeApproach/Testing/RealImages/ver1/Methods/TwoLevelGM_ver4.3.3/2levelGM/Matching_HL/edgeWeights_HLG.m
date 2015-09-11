%% compute the edge weight matrix for a given HLG with corresponding LLG

function  [W] = edgeWeights_HLG(HLG, LLG)
            
    nA = size(HLG.V,1);     % number of anchors in HLG
    nV = size(LLG.V,1);     % number of nodes in corresponding LLG

    W = zeros(size(HLG.E));        % list of weight of HLG edges
    W(:,2) = [];


    for k = 1:size(HLG.E,1)

       ai = HLG.E(k,1);
       aj = HLG.E(k,2);

       % nodes of the subgraph Ai
       ind_Vai = HLG.U(:,ai);
       if sum(ind_Vai)==0
           continue;
       end 
       Vai = LLG.V(ind_Vai,:);
       nVai = size(Vai, 1);

       % nodes of the subgraph Aj
       ind_Vaj = HLG.U(:,aj);
       if sum(ind_Vaj)==0
           continue;
       end 
       Vaj = LLG.V(ind_Vaj,:);   
       nVaj = size(Vaj, 1);

       % calculate pairwise distance between nodes in Vai and Vaj
       dist = repmat(Vai(:,1:2), nVaj,1) ...
            - kron  (Vaj(:,1:2), ones(nVai, 1));
       dist = sqrt(dist(:,1).^2 + dist(:,2).^2);

       % take median
       W(k) = median(dist(:));

    end

end