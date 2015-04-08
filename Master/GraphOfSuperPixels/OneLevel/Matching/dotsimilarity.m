%% dot similarity function
% v1 (n1xd) set of n1 vectors
% v2 (n2xd) set of n2 vectors

% sim similarity value between each two vectors from each set

function sim = dotsimilarity(v1, v2)

n1 = size(v1,1);
n2 = size(v2,1);

sim = zeros(n1, n2);

norm2 = sqrt(sum(v2.^2,2));

for i=1:n1
    % (1x128)(128xn2)
   sim(i,:) = v1(i,1:end)*v2'; 
   sim(i,:) = sim(i,:)/norm(v1(i,:));
   sim(i,:) = sim(i,:)./norm2';

end

end