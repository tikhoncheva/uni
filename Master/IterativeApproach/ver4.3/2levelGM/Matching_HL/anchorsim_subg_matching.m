%% Similarity between the anchor of two anchor graphs
%  based on the matching score of the underlying subgraphs
%
% Input
%
% Outout
%
%
function [sim] = anchorsim_subg_matching (LLG1, LLG2, HLG1, HLG2, cand_matches)

    nV1 = size(LLG1.V,1); nV2 = size(LLG2.V,1);
    nA1 = size(HLG1.V,1); nA2 = size(HLG2.V,1);
    
%     [I,J] = find(corrmatrix);
%     cand_matches = [I,J];

    % adjacency matrix of the first dependency graph
    adjM1 = zeros(nV1, nV1);
    E1 = LLG1.E;
    E1 = [E1; [E1(:,2) E1(:,1)]];
    ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
    adjM1(ind) = 1;

    % adjacency matrix of the second dependency graph
    adjM2 = zeros(nV2, nV2);
    E2 = LLG2.E;
    E2 = [E2; [E2(:,2) E2(:,1)]];
    ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
    adjM2(ind) = 1;  

    sim = zeros(nA1*nA2, 1);

    for k = 1:size(cand_matches,1)

       ai = cand_matches(k,1);
       aj = cand_matches(k,2);
       ind_Vai = HLG1.U(:,ai);
       
       Vai = LLG1.V(ind_Vai,1:2)'; nVai = size(Vai,2); % 2 x nVai
       if (~isempty(LLG1.D))
           Dai = LLG1.D(:, ind_Vai);
       else 
           Dai = [];
       end
       adjM1cut = adjM1(ind_Vai, ind_Vai');


       ind_Vaj = HLG2.U(:, aj);
       Vaj = LLG2.V(ind_Vaj,1:2)'; nVaj = size(Vaj,2);  % 2 x  nVaj
       if (~isempty(LLG2.D))
           Daj = LLG2.D(:, ind_Vaj);
       else 
           Daj = [];
       end
       adjM2cut = adjM2(ind_Vaj, ind_Vaj');

       % correspondence matrix 
       corrmatrix = ones(nVai,nVaj);                                   % !!!!!!!!!!!!!!!!!!!!!! now: all-to-all

       % compute initial affinity matrix
       if (size(Vai,2)<=1 || size(Vaj,2)<=1)
           continue;
       else
           affmatrix = initialAffinityMatrix2(Vai, Vaj, Dai, Daj, adjM1cut, adjM2cut, corrmatrix);
       end    

       [score, X] = GraphMatching(corrmatrix, affmatrix);
       % subgraph weights
       Ai = 1/sum(X(:)); %/nV1;
       Aj = 1; %/nV2;
       sim((aj-1)*nA1 + ai) = Ai*Aj*score;
       
%        Vai = Vai';
%        Vaj = Vaj';
%        
%        if size(Vai,1)<=1 || size(Vaj,1)<=1
%            continue;
%        end
%            
%           
%        
%        opt.method='rigid'; opt.viz=0; opt.scale=0;
%        
%        [Transform, ~]=cpd_register(Vaj, Vai, opt); 
%        Ai = Transform.R;
%        bi = Transform.t;
%  
%        [Transform, ~]=cpd_register(Vai, Vaj, opt); 
%        Aj = Transform.R;
%        bj = Transform.t;              
%             
%        PVai = Ai * Vai' + repmat(bi,1,size(Vai,1)); % proejction of Vai nodes
%        PVai = PVai';
%        
%        [nn_PVai, dist_aj] = knnsearch(LLG2.V(:,1:2), PVai);   %indices of nodes in LLG2.V
%        
%        PVaj = Aj * Vaj' + repmat(bj,1,size(Vaj,1)); % projection of Vaj nodes
%        PVaj = PVaj';       
%        
%        [nn_PVaj, dist_ai] = knnsearch(LLG1.V(:,1:2), PVaj);   %indices of nodes in LLG1.V  
%        
%        err1 = median(dist_aj);  
%        err2 = median(dist_ai);
%        err = min([err1, err2]);
%        
%        sim((aj-1)*nA1 + ai) = exp(-err);

    end 
    
    sim;
    
end