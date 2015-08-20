function [ LLG1, LLG2 ] = preprocessing(LLG1, LLG2, agparam)
% Run two preprocessing steps:
% - create a codebook of node descriptors to calculate later appearence
%   similarity of anchors
% - calculate vector of node similarities

% Step 1 : codebook of node descriptors
nV1 = size(LLG1.V,1); nV2 = size(LLG2.V,1);

nWords = round(agparam.nWordsPerc * (nV1+nV2)/2); % number of word in the codebook
codebook_ind = kmeans(double([LLG1.D, LLG2.D]'), nWords, 'MaxIter',1000);

LLG1.nWords = nWords;
LLG1.V = [LLG1.V, codebook_ind(1:nV1)];  % save codebook ID of each node

LLG2.nWords = nWords;
LLG2.V = [LLG2.V, codebook_ind(nV1+1:end)];  % save codebook ID of each node

end

