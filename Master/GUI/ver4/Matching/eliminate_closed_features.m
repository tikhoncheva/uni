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

    %find unique points
    coord2 = unique(coord', 'rows');
    coord2 = coord2';
    for ii=1:size(coord2,2)
        % for all multiple points
        equalP  = find(coord(1,:)==coord2(1,ii) & coord(2,:)==coord2(2,ii));
%!!!!!!!!!!!!!!!!!!!!        
%         [~, min_ind]= min(val(equalP));
        [~,ind]= max(val(equalP));  % for cosine similarity we are looking for max
        % left only the most similar one
        saveInd = equalP(ind);
        remaining_features(equalP(equalP~=saveInd)) = 0;
    end    
% 
%     % delete points that are too close to each other
%     % 
%     % distance matrix    
%     distM = triu(squareform(pdist(coord', 'euclidean')),1); % (n) x (n)
%       
%     % set the threshold
%     minEl = min(distM(distM(:)>0));
%     thr = minEl * 2.;
%     
%     [i,j] = find(distM>0 & distM<thr);
%     
%     for ii=1:size(i)
%         pair = [i(ii), j(ii)];
%         [~,minValInd] = min(val(pair));
%         remaining_features(pair(minValInd)) = 0;
%     end

    remaining_features = remaining_features(remaining_features>0);

end