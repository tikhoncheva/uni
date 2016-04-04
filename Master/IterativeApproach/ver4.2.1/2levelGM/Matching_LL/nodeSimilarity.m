%% Calculate pairwise similarity between node descriptors
% use euclidian distance  between two descriptors, but note, that it meassures dissimilarity
%
% Input
%       D1: d x n1 set of n1 vectors
%       D2: d x n2 set of n2 vectors
%       method: 'euclidean'     use euclidian distance, but note,
%                               that it meassures dissimilarity
%               'cosine'        use cosine similarity
%
% Output
%      sim: vector of pairwise similarity between two sets of vectors
%

function [sim] = nodeSimilarity(x1, x2, method)

    assert( size(x1, 1) == size(x2, 1), ... 
        'Error in nodeSimilarity-function: two sets of descriptors have different size' );
    
    n1 = size(x1,2);
    n2 = size(x2,2);
     
    switch (method)
        
        case 'euclidean'    % Euclidian distance between descriptors
            
            descr = [x1'; x2'];  % (nV1+nV2) x d

            dist = squareform(pdist(double(descr), 'euclidean')); % (n1+n2) x (n1+n2) distance matrix
            dist = dist(1:n1, n1+1:end);

            % normalize distances
            norm_max_rows = max(dist,[],2);
            
%             norm_min_rows = min(dist,[],2);
%             dist = (dist - repmat(norm_min_rows,1, n2))./ repmat(norm_max_rows - norm_min_rows, 1, n2);
%             dist = 1- dist;

            norm_max_rows(norm_max_rows==0) = 1;
            dist = 1- dist./repmat(norm_max_rows, 1, n2);
            
            % vectorize result matrix columnwise
            sim = reshape(dist, 1, numel(dist));  
        
        case 'cosine'   % Cosine similarity function
            x1 = double(x1); x2 = double(x2);
            
            sim = zeros(n1, n2);
            norm2 = sqrt(sum(x2.^2, 1) );

            for i=1:n1
               sim(i,:) = x1(:, i)' * x2; % (n1x128)(128xn2)
               sim(i,:) = sim(i,:)/norm(x1(:,i)');
                sim(i,:) = sim(i,:)./norm2;
            end
            
            % vectorize result matrix columnwise
            sim = reshape(sim, 1, numel(sim)); 
            
        otherwise
            sim = zeros(1, n1*n2);
    end
    
end
