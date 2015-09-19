%% find candidate matches 
function [cand_matches] = find_cand_anchor_matches(LLG1, LLG2, HLG1, HLG2)

setParameters;
ncand = agparam.ncand;
thr = 1.1;
nA1 = size(HLG1.V,1); nA2 = size(HLG2.V,1);

%% Bag of features
corrmatrix = ones(nA1, nA2);
[nodesim1, ~, ~] = structural_node_similarity(LLG1, LLG2, HLG1, HLG2, corrmatrix); % using structur of the anchor subgraphs
nodesim1 = reshape(nodesim1, nA1, nA2);

%------------------------------------------------------------------
% Feature matching
%------------------------------------------------------------------
nodesim2 = zeros(nA1, nA2);
cand_matches = [];
for ai = 1:nA1
   ind_Vai = HLG1.U(:,ai);
   Dai = LLG1.D(:, ind_Vai);
   
   ai_sim = zeros(1,nA2);
   
   for aj = 1:nA2
      ind_Vaj = HLG2.U(:,aj);
      Daj = LLG2.D(:, ind_Vaj);
      
      [~, dist] = vl_ubcmatch(Dai, Daj, thr);
      ai_sim(aj) = sum(dist)/min(size(Dai,2), size(Daj,2));
   end
   nodesim2(ai,:) = ai_sim;
   [~, minpos] = sort(ai_sim);
   cand_matches = [cand_matches; [repmat(ai,ncand,1), minpos(1:ncand)']];
end  

% f = @median;
% cand_matches = [];
% for ai = 1:nA1
%    ind_Vai = HLG1.U(:,ai);
%    D_Vai = LLG1.D(:, ind_Vai);
%    
%    ai_sim = zeros(1,nA2);
%    
%    for aj = 1:nA2
%       ind_Vaj = HLG2.U(:,aj);
%       
%       siftdist = pdist2(D_Vai', LLG2.D(:, ind_Vaj)', 'euclidean');
%       siftsim = 1./siftdist;
%       
% %       ai_sim(aj) = f(siftdist(:))/sum(ind_Vaj);
%        minval = min(siftdist,[],2);
% %        maxval = max(siftsim, [],2);
%        ai_sim(aj) = mean(minval(:));
%    end
%    
%    [~, minpos] = sort(ai_sim);
%    
%    cand_matches = [cand_matches; [repmat(ai,ncand,1), minpos(1:ncand)']];
% 
% end  


end