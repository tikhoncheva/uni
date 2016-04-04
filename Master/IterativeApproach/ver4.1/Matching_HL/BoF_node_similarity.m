 
function [S] = BoF_node_similarity(HLG1, HLG2, LLG1, LLG2, corrmatrix)
            
nA1 = size(HLG1.V,1);
nA2 = size(HLG2.V,1);

nV1 = size(LLG1.V,1);    % number of nodes in LLG1
nV2 = size(LLG2.V,1);    % number of nodes in LLG2

k = round(0.4* (nV1+nV2)/2);

% create a codebook
D = [LLG1.D, LLG2.D]'; % (nV1+nV2)x128
codebook_ind = kmeans(double(D), k, 'MaxIter',1000);

vA1_hist = BoF_anchor_descr(HLG1, LLG1, k, codebook_ind(1:nV1));
vA2_hist = BoF_anchor_descr(HLG2, LLG2, k, codebook_ind(nV1+1:end));


S = zeros(nA1*nA2,1);

for i = 1:nA1
    hist_ai = vA1_hist(i, :);
        
    ai_pairs = find(corrmatrix(i,:)>0)';  
    
    for k = 1:numel(ai_pairs)
        j = ai_pairs(k);
        hist_aj = vA2_hist(j, :);

        C = ((hist_ai-hist_aj).^2)./(hist_ai+hist_aj); %* 0.5;
        C(isnan(C)) =0;
        C = sum(C(:));
                
        S((j-1)*nA1+i) = 1-C/size(hist_aj,2);      
    end
    
end

% S = S / norm
% S = exp(-S );

    


end