function [ matchInfo ] =  make_initialmatches(descrImg1, descrImg2, mparam)
% Find NN matches between feature sets
% matchInfo(:).match = [ featA featB ]
% matchInfo(:).dist  = descriptor distance between featA & featB;


initialMatch = [];
simInitialMatch = [];


tic
[ tmpInitialMatch, simdot ] = descmatch_dot( descrImg1, descrImg2, ...
                                                              mparam.kNN);

fprintf(' %f secs elapsed for matching %d-%d features\n', toc, size(descrImg1,2), size(descrImg2,2));


nMatches = size(tmpInitialMatch,2);

if nMatches > 0
    initialMatch = [ initialMatch; tmpInitialMatch(1,:); tmpInitialMatch(2,:)];
    simInitialMatch = [ simInitialMatch simdot ];
end

if nMatches > mparam.nMaxMatch
    [ temp tmpMatchIdx ] = sort(simInitialMatch,'descend');
    % select the best nMaxMatch 
    fprintf(' %d matches are eliminated due to max num of match (%d), max dist:%f \n',...
         nMatches-mparam.nMaxMatch, mparam.nMaxMatch, temp(mparam.nMaxMatch));

    initialMatch(tmpMatchIdx((mparam.nMaxMatch+1):end),:) = [];
    simInitialMatch(tmpMatchIdx((mparam.nMaxMatch+1):end)) = [];
    nMatches = mparam.nMaxMatch;
    
end


matchInfo.match = initialMatch;
matchInfo.dist = max(simInitialMatch) - simInitialMatch;
matchInfo.sim = simInitialMatch';

end