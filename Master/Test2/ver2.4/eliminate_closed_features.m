%% Eliminate Picks that are to close to each other
% Calculate the distance between each pair of features.
% Find features which are close to one other and leave
%
% cf coordinates of the features
% picks of features
function indx_remaining_features = eliminate_closed_features(cf, p)
    % number of features
    nF = size(cf,2);
    indx_remaining_features = ones(1,nF);
    % 
    
    eps = 1.1;
    
    % distance matrix    
    distM = squareform(pdist(cf', 'euclidean')); % (nF) x (nf)
    
    % diag(distM) = 0 so we add a biggest distance in matrix to all diag
    % elements
    maxEl = max (distM(:));
    distM = distM + eye(nF,nF)* maxEl;
    
    % calculate the smallest distance in matrix
    minEl = 0.001 + min (distM(:));
    
    % calculate the mean distance in matrix
    meanEl = mean(distM(:))
    
    threshold = meanEl * 0.0002;
    
    %
    for i=1:nF
       %minDist_i = min(distM(i,:));   % for each feature find min distance to other features
       
       indx = distM(i,:) < threshold; %minEl * 0.8;
       
       distM(i,indx) = 0;
       
       indx_remaining_features(indx) = 0;
        
    end
    
    indx_remaining_features = logical(indx_remaining_features);


end