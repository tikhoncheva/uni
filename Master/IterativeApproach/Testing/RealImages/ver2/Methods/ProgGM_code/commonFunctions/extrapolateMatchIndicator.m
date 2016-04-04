function [ indicator_ext ] = extrapolateMatchIndicator( view, matchList, indicator, search_radius )
% Make an extrapolated GT for evaluation
% output: 1 x nInitialMatches indicator vector

if length(view) == 1
    bSelf = 1;  view1 = 1;  view2 = 1;
else
    bSelf = 0;  view1 = 1;  view2 = 2;
end

if isempty(indicator)
    indicator_ext = ones(1,size(matchList,1));
    fprintf('the given match indicator vector is empty -> all selected...\n');
else
    % find all matches very close to the given matches
    %XY_view1= view(view1).feat(matchList(:,1),1:2);
    %XY_view2= view(view2).feat(matchList(:,2),1:2); 
    kdtreeNS1 = kdtree_build(view(view1).feat(matchList(:,1),1:2));%KDTreeSearcher( view(view1).feat(matchList(:,1),1:2) );
    kdtreeNS2 = kdtree_build(view(view2).feat(matchList(:,2),1:2));%KDTreeSearcher( view(view2).feat(matchList(:,2),1:2) ); 
    curMatchIdx = find(indicator);
    nCurMatch = length(curMatchIdx);
    indicator_ext = zeros(1,size(matchList,1));
    
    for i=1:nCurMatch
        query_view1 = view(view1).feat(matchList(curMatchIdx(i),1),1:2);
        query_view2 = view(view2).feat(matchList(curMatchIdx(i),2),1:2);
        if ~bSelf
            %finds the points within the search radius
            %idx = rangesearch(kdtreeNS1,query_view1,search_radius);
            %ridx_view1 = idx{1};
            ridx_view1 = kdtree_ball_query( kdtreeNS1, query_view1, search_radius );
            %idx = rangesearch(kdtreeNS2,query_view2,search_radius);
            %ridx_view2 = idx{1};
            ridx_view2 = kdtree_ball_query( kdtreeNS2, query_view2, search_radius );
            %ridx_view1=BruteSearchMex(XY_view1',query_view1','r',search_radius);
            %ridx_view2=BruteSearchMex(XY_view2',query_view2','r',search_radius);
            closeMatchIdx = intersect(ridx_view1, ridx_view2);
        else
            %finds the points within the search radius
%             ridx_view1a=BruteSearchMex(XY_view1',query_view1','r',search_radius);
%             ridx_view2a=BruteSearchMex(XY_view2',query_view2','r',search_radius);
%             ridx_view1b=BruteSearchMex(XY_view2',query_view1','r',search_radius);
%             ridx_view2b=BruteSearchMex(XY_view1',query_view2','r',search_radius);
%             closeMatchIdx = union( intersect(ridx_view1a, ridx_view2a),intersect(ridx_view1b, ridx_view2b));
        end
        indicator_ext(closeMatchIdx) = 1;        
    end
    kdtree_delete(kdtreeNS1);
    kdtree_delete(kdtreeNS2);
end

%fprintf('input %d matches -> %d extrapolated matches\n', nCurMatch, nnz(indicator_ext) );


