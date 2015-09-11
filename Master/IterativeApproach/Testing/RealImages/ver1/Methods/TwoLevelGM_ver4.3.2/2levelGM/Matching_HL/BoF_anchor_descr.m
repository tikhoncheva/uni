%% Describe each anchor of the HLG using codebook of node descriptors
%
% Input
%  HLG              higher level graph
%    k              number of words in the codebook
%  codebook_ind     mapping between nodes of LLG and codewords
%
% Output
%   HLG             HLG with the updated D_appear matrix

function [HLG] = BoF_anchor_descr(HLG, k, codebook_ind)
            
nA = size(HLG.V,1);    % number of anchors
% I = [1:nA];
I = find(HLG.F==0);

codebook_ind = repmat(codebook_ind, 1, nA);
codebook_ind = codebook_ind.*HLG.U;


anchor_hist = zeros(nA, k);

for q = 1:numel(I)
    i = I(q);
    if sum(codebook_ind(:,i)>0)
        
        [lwords,~,l_ind] = unique(codebook_ind(:,i));
        lwords = lwords(2:end);
        l_ind = l_ind - 1; l_ind( l_ind==0) = [];
        
        lhist = zeros(numel(l_ind),k);
        ind = sub2ind(size(lhist), [1:numel(l_ind)]', lwords(l_ind) );
        lhist(ind) = 1;
        lhist = sum(lhist);
        
        lhist = lhist/max(lhist(:));    % normalization
        
        anchor_hist(i,:) = lhist;
    end
end


HLG.D_appear(I,:) = anchor_hist(I,:);


end