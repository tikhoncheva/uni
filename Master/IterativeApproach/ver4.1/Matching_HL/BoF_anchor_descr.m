%% Describe each anchor of the HLG using codebook of node descriptors
%
% Input
%  HLG              higher level graph
%  LLG              lower level graph
%    k              number of words in the codebook
%  codebook_ind     mapping between nodes of LLG and codewords
%
% Output
% anchor_hist       appearence descriptors of the anchors

function [anchor_hist] = BoF_anchor_descr(HLG, LLG, k, codebook_ind)
            
nA = size(HLG.V,1);    % number of anchors
% nV = size(LLG.V,1);    % number of nodes in the corresponding subgraph

% k = round(0.5*nV);     % number of word in the codebook

% LLG.D has the size 128xnV
% codebook_ind = kmeans(double(LLG.D'), k, 'MaxIter',1000);

codebook_ind = repmat(codebook_ind, 1, nA);
codebook_ind = codebook_ind.*HLG.U;

anchor_hist = zeros(nA, k);

for i = 1:nA
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





end