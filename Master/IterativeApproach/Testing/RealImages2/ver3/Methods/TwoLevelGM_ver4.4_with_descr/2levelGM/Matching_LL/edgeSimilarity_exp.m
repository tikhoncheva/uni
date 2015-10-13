%% Calculate pairwise similarity between edges
% use euclidian distance  between two descriptors, but note, that it meassures dissimilarity
%
% Input
%       E1: d x n1 set of n1 vectors
%       E2: d x n2 set of n2 vectors
%
% Output
%      sim: vector of pairwise similarity between two sets of vectors
%

function [sim] = edgeSimilarity_exp(E1, E2)

    assert( size(E1, 1) == size(E2, 1), ... 
        'Error in nodeSimilarity-function: two sets of descriptors have different size' );
    
    sigma = 0.15; % 100     % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    sim = exp(-(E1-E2).^2./sigma);                  
    sim(isnan(sim)) = 0;
   
end
