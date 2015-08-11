 
function [S, HLG1, HLG2] = BoF_node_similarity(LLG1, LLG2, HLG1, HLG2, corrmatrix)
            
nA1 = size(HLG1.V,1);
nA2 = size(HLG2.V,1);

% load IDs of nodes in the common codebook
nWords = LLG1.nWords; % == LLG2.nWords;
codebook1_ind = LLG1.V(:,3);
codebook2_ind = LLG2.V(:,3);

HLG1 = BoF_anchor_descr(HLG1, nWords, codebook1_ind);
HLG2= BoF_anchor_descr(HLG2, nWords, codebook2_ind);

S = zeros(nA1*nA2,1);
for i = 1:nA1
    hist_ai = HLG1.D_appear(i, :);
        
    ai_pairs = find(corrmatrix(i,:)>0)';  
    
    for k = 1:numel(ai_pairs)
        j = ai_pairs(k);
        hist_aj = HLG2.D_appear(j, :);

        C = ((hist_ai-hist_aj).^2)./(hist_ai+hist_aj); %* 0.5;
        C(isnan(C)) =0;
        C = sum(C(:));
                
        S((j-1)*nA1+i) = 1-C/size(hist_aj,2);      
    end
    
end

% S = S / norm
% S = exp(-S );

end