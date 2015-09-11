function [ matchInfo ] = make_initialmatches_mcho( viewInfo, mparam, bShow )
% Find NN matches between feature sets
% matchInfo(:).match = [ featA featB ]
% matchInfo(:).dist  = descriptor distance between featA & featB;
%
% Minsu Cho, Seoul National University
% Updated: 16th November March 2011

initialMatch = [];
distInitialMatch = [];
nInitialMatches = 0;

if length(viewInfo) == 1
    bSelf = 1;
    view1 = 1;  view2 = 1;
else
    bSelf = 0;
    view1 = 1;  view2 = 2;
end

% set feature types to match 
if any(strcmp(fieldnames(mparam), 'bFeatExtUse')) 
    typeToMatch =  mparam.bFeatExtUse;
else
    typeToMatch = [ viewInfo(view1).nFeatOfExt > 0 ] & [ viewInfo(view2).nFeatOfExt > 0];
end

maxFeatType = max(viewInfo(view1).typeFeat);
nMatchOfFeatType = zeros(maxFeatType,1);
nFeatTypeToMatch = nnz(typeToMatch);%length(unique(viewInfo(1).typeFeat));

for i=1:maxFeatType
    
    if ~typeToMatch(i),  continue;   end
    if ~bSelf % in case of a image pair
        range1 = find( viewInfo(view1).typeFeat == i );
        range2 = find( viewInfo(view2).typeFeat == i );    
    else % in case of a single image
        range1 = find( viewInfo(view1).typeFeat == i );
        range2 = range1;
    end
    if isempty(range1) || isempty(range2),  continue;   end
    
    tic;
    if mparam.bReflective
        [ tmpInitialMatch, sqdist ] = descmatch_mcho_mex( viewInfo(view1).desc(range1,:)',...
            viewInfo(view2).desc_ref(range2,:)',bSelf , mparam.distRatio, mparam.distThres, mparam.kNN ) ;
    else
        [ tmpInitialMatch, sqdist ] = descmatch_mcho_mex( viewInfo(view1).desc(range1,:)',...
            viewInfo(view2).desc(range2,:)',bSelf , mparam.distRatio, mparam.distThres, mparam.kNN ) ;
    end
    fprintf('   %f secs elapsed for matching %d-%d of type %d features\n', toc, length(range1), length(range2), i );
        
    if bSelf && size(tmpInitialMatch,2) > 0
        % eliminate too close matches ( self-matching )
        pointDistThres = ceil(mparam.selfmatching_dist_thres * max(size(viewInfo(1).img,1),size(viewInfo(1).img,2)));
        ptDist = sum( (viewInfo(1).feat(range1( tmpInitialMatch(1,:) ),1:2) - viewInfo(1).feat( range1( tmpInitialMatch(2,:) ),1:2)).^2, 2);
        del_idx = find( ptDist < pointDistThres^2 );
        tmpInitialMatch(:, del_idx ) = [];
        sqdist( del_idx ) = [];
        fprintf('   delete %d candidates by self dist threshold (%.2f: %d pixels) \n', length(del_idx), mparam.selfmatching_dist_thres, pointDistThres);
    end
    
    if mparam.thresholdScaleDiff > 0 && size(tmpInitialMatch,2) > 0
        % eliminate matches with too large scale diff
        det1 = viewInfo(view1).feat(range1(tmpInitialMatch(1,:)),7);
        det2 = viewInfo(view2).feat(range2(tmpInitialMatch(2,:)),7);
        logscale_diff = abs(log(det1) - log(det2));
        del_idx = find( logscale_diff > log(mparam.thresholdScaleDiff) );
        tmpInitialMatch(:, del_idx ) = [];
        sqdist( del_idx ) = [];
        fprintf('   delete %d candidates by scale diff threshold (%d).\n', length(del_idx), mparam.thresholdScaleDiff);
    end
    
    if mparam.bMatchDistribution == 2 % equal distribution for each feat type
        nMaxMatchForThis = ceil( mparam.nMaxMatch / nFeatTypeToMatch );    
        [ temp tmpMatchIdx ] = sort(sqdist,'ascend');
    
        if mparam.bFilterMatch && size(tmpInitialMatch,2) > 0
            % eliminate redundant matches based on the position
            % accumulate features accoring to the rank of sqdist (ascending)
            sel_idx = tmpMatchIdx(1);
            XY_sel_view1 = viewInfo(view1).feat(range1(tmpInitialMatch(1,tmpMatchIdx(1))),1:2);
            XY_sel_view2 = viewInfo(view2).feat(range2(tmpInitialMatch(2,tmpMatchIdx(1))),1:2);
            nSelMatch = 1;
            for  iter_cand = 1:size(tmpInitialMatch,2)
                if nSelMatch >= nMaxMatchForThis, break; end
                XY_view1 = viewInfo(view1).feat(range1(tmpInitialMatch(1,tmpMatchIdx(iter_cand))),1:2);
                XY_view2 = viewInfo(view2).feat(range2(tmpInitialMatch(2,tmpMatchIdx(iter_cand))),1:2);
                if ~bSelf
                    %finds the points within the search radius
                    ridx_view1=BruteSearchMex(XY_sel_view1',XY_view1','r',mparam.redundancy_thres);
                    ridx_view2=BruteSearchMex(XY_sel_view2',XY_view2','r',mparam.redundancy_thres);
                else
                    %finds the points within the search radius
                    ridx_view1=BruteSearchMex([XY_sel_view1; XY_sel_view2]',XY_view1','r',mparam.redundancy_thres);
                    ridx_view2=BruteSearchMex([XY_sel_view2; XY_sel_view1]',XY_view2','r',mparam.redundancy_thres);
                end
                equi_ridx = intersect(ridx_view1, ridx_view2);
                if isempty(equi_ridx) % if there's no equi matches
                    nSelMatch = nSelMatch + 1;
                    % insert it into the selected xy list
                    sel_idx(nSelMatch) = tmpMatchIdx(iter_cand);
                    XY_sel_view1(nSelMatch,:) = XY_view1;
                    XY_sel_view2(nSelMatch,:) = XY_view2;
                end            
            end
            fprintf('   %d candidates selected avoiding equivalent matches (%d pixels)\n', length(sel_idx), mparam.redundancy_thres);
            sel_idx = sort(sel_idx); % re-aline ascending order
            tmpInitialMatch = tmpInitialMatch(:, sel_idx );
            sqdist = sqdist( sel_idx );
            
        elseif size(tmpInitialMatch,2) > nMaxMatchForThis
            % select the best nMaxMatch
            fprintf('   delete %d candidates due to max num of match (%d), max dist:%.2f \n', size(tmpInitialMatch,2)-nMaxMatchForThis, nMaxMatchForThis, temp(nMaxMatchForThis));
            del_idx = tmpMatchIdx((nMaxMatchForThis+1):end);
            tmpInitialMatch(:, del_idx ) = [];
            sqdist( del_idx ) = [];            
        end            
    end % loop end of equal max distribution
    
    nMatchOfFeatType(i) = size(tmpInitialMatch,2);
    fprintf('->> %d valid matches for type %d features\n', nMatchOfFeatType(i), i );
    % stack the new matches
    if nMatchOfFeatType(i) > 0
        % initialMatch = [ feat1 feat2 feattype ; ... ]
        initialMatch = [ initialMatch; range1( tmpInitialMatch(1,:) ), range2( tmpInitialMatch(2,:) ), ones(nMatchOfFeatType(i),1)*i ];
        distInitialMatch = [ distInitialMatch sqdist ]; 
    end
        
end

nInitialMatches = sum(nMatchOfFeatType);

% When MatchDistribution type == 1, a post-proposs goes on...
% caution! from now on, the match matrix is represented by initialMatch( nInitialMatch, 2 ) 
if mparam.bMatchDistribution == 1 
    [ temp tmpMatchIdx ] = sort(distInitialMatch,'ascend');
    if mparam.bFilterMatch && nInitialMatches > 0
        % eliminate euivalent matches based on the position
        % accumulate features accoring to the rank of sqdist (ascending)
        sel_idx(1) = tmpMatchIdx(1);
        XY_sel_view1(1,:) = viewInfo(view1).feat(initialMatch(tmpMatchIdx(1),1),1:2);
        XY_sel_view2(1,:) = viewInfo(view2).feat(initialMatch(tmpMatchIdx(1),2),1:2);
        nSelMatch = 1;
        for  iter_cand = 2:nInitialMatches
            if nSelMatch >= mparam.nMaxMatch, break; end
            XY_view1 = viewInfo(view1).feat(initialMatch(tmpMatchIdx(iter_cand),1),1:2);
            XY_view2 = viewInfo(view2).feat(initialMatch(tmpMatchIdx(iter_cand),2),1:2);
            if ~bSelf
                %finds the points within the search radius
                ridx_view1=BruteSearchMex(XY_sel_view1',XY_view1','r',mparam.redundancy_thres);
                ridx_view2=BruteSearchMex(XY_sel_view2',XY_view2','r',mparam.redundancy_thres);
            else
                %finds the points within the search radius
                ridx_view1=BruteSearchMex([XY_sel_view1; XY_sel_view2]',XY_view1','r',mparam.redundancy_thres);
                ridx_view2=BruteSearchMex([XY_sel_view2; XY_sel_view1]',XY_view2','r',mparam.redundancy_thres);
            end
            equi_ridx = intersect(ridx_view1, ridx_view2);
            if isempty(equi_ridx) % if there's no equi matches
                nSelMatch = nSelMatch + 1;
                % insert it into the selected xy list
                sel_idx(nSelMatch) = tmpMatchIdx(iter_cand);
                XY_sel_view1(nSelMatch,:) = XY_view1;
                XY_sel_view2(nSelMatch,:) = XY_view2;
            end            
        end
        fprintf('   %d candidates selected avoiding equivalent matches (%d pixels)\n', length(sel_idx), mparam.redundancy_thres);
        sel_idx = sort(sel_idx); % re-aline ascending order
        initialMatch = initialMatch(sel_idx,:);
        distInitialMatch = distInitialMatch( sel_idx );
        nInitialMatches = nSelMatch;
    else 
        if nInitialMatches > mparam.nMaxMatch
            % select the best nMaxMatch 
            fprintf('   %d matches are eliminated due to max num of match (%d), max dist:%f \n',...
                nInitialMatches-mparam.nMaxMatch, mparam.nMaxMatch, temp(mparam.nMaxMatch));
            initialMatch(tmpMatchIdx((mparam.nMaxMatch+1):end),:) = [];
            distInitialMatch(tmpMatchIdx((mparam.nMaxMatch+1):end)) = [];
            nInitialMatches = mparam.nMaxMatch;
        end
    end
    
    
end
fprintf('>>>> %d total valid matches\n', nInitialMatches );

for k=1:maxFeatType
    nMatch = sum( initialMatch(:,3) == k );
    if nMatch > 0,  fprintf('     %4d matches from feat type %d\n', nMatch, k ); end
end

%% construct match data
disp('-- Constructing the initial match data');
for i=1:nInitialMatches    
    matchInfo(i).match = initialMatch(i,1:2);
    matchInfo(i).dist = distInitialMatch(i);
end

if bShow
    showInitialMatches3;
end