%% Similarity between the anchor of two anchor graphs
%  based on the matching score of the underlying subgraphs
%
% Input
%
% Outout
%
%
function [sim] = anchorsim_subg_matching (LLG1, LLG2, HLG1, HLG2, cand_matches)

% fprintf('--- anchor similarity');

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
       if (nVai==0 || nVaj==0 || nVai==1 || nVaj==1)
           continue;
       else
           affmatrix = initialAffinityMatrix2(Vai, Vaj, Dai, Daj, adjM1cut, adjM2cut, corrmatrix);
       end
       
%        opt.method='affine';
%        opt.corresp=1;
%        opt.viz=0;
%        
%        Vai = Vai';
%        Vaj = Vaj';
%        
%        if nVai<nVaj
%            Vai = [Vai; zeros(nVaj-nVai,2)];
%        end
%        if nVaj<nVai
%            Vaj = [Vaj; zeros(nVai-nVaj,2)];
%        end
%        [Transform, C]=cpd_register(Vaj, Vai, opt); 
%        
%        ind = [1:nVai]';
%        if nVaj<nVai
%            ind = ismember(C, [1:nVaj]);
%        end
%        
%        err = sum((Vaj(C(ind),1:2) - Vai(ind,1:2)).^2,2);
%        err= sum(err(:))/numel(C);
%        sim((aj-1)*nA1 + ai) = 1/err;
       [score, X] = GraphMatching(corrmatrix, affmatrix);
       
       if score>0
           % subgraph weights
           Ai = 1/sum(X(:)); %/nV1;
           Aj = 1; %/nV2;
           sim((aj-1)*nA1 + ai) = Ai*Aj*score;
       end
    end 
    
    sim;
    
end