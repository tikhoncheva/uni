%% find candidate matches 
function [cand_matches] = find_cand_anchor_matches(LLG1, LLG2, HLG1, HLG2)

setParameters;
ncand = agparam.ncand;

nA1 = size(HLG1.V,1); nA2 = size(HLG2.V,1);

f = @median;

cand_matches = [];
for ai = 1:nA1
   ind_Vai = HLG1.U(:,ai);
   D_Vai = LLG1.D(:, ind_Vai);
   
   ai_sim = zeros(1,nA2);
   
   for aj = 1:nA2
      ind_Vaj = HLG2.U(:,aj);
      
      siftdist = pdist2(D_Vai', LLG2.D(:, ind_Vaj)', 'euclidean');
      siftsim = 1./siftdist;
      
%       ai_sim(aj) = f(siftdist(:))/sum(ind_Vaj);
       minval = min(siftdist,[],2);
%        maxval = max(siftsim, [],2);
       ai_sim(aj) = mean(minval(:));
   end
   
   [~, minpos] = sort(ai_sim);
   
   cand_matches = [cand_matches; [repmat(ai,ncand,1), minpos(1:ncand)']];

end


end