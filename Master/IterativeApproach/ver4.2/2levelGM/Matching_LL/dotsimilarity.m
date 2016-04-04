%% dot similarity function
% Input
%       X1: d x n1 set of n1 vectors
%       X2: d x n2 set of n2 vectors
%
% Output
%      sim: vector of pairwise similarity between two sets of vectors

function sim = dotsimilarity(x1, x2)

    n1 = size(x1,2);
    n2 = size(x2,2);

    sim = zeros(n1, n2);

    norm2 = sqrt(sum(x2.^2, 1) );

    for i=1:n1
       sim(i,:) = x1(:, i)' * x2; % (n1x128)(128xn2)
       sim(i,:) = sim(i,:)/norm(x1(:,i)');
       sim(i,:) = sim(i,:)./norm2;
    end
    
    % vectorize result matrix columnwise
    sim = reshape(sim, 1, numel(sim)); 

end
