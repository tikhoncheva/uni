%% Eliminate Picks that are to close to each other
% Calculate the distance between each pair of features.
% Find features which are close to one other and leave
%
% coord coordinates of the features
% val 
function remaining_features = eliminate_closed_features(coord, val)
    % number of features
    n = size(coord,2);
    remaining_features = [1:n];
    % 
    % distance matrix    
    distM = triu(squareform(pdist(coord', 'euclidean')),1); % (n) x (n)
      
    % set the threshold
    minEl = min(distM(distM(:)>0));
    thr = minEl * 1.2;
    
    [i,j] = find(distM>0 & distM<thr);
    
    for ii=1:size(i)
        pair = [i(ii), j(ii)];
        [~,maxValInd] = max(val(pair));
        remaining_features(pair(maxValInd)) = 0;
    end
    remaining_features = remaining_features(remaining_features>0);
end