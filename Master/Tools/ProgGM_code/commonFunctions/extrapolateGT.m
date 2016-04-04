function [ indicator_GT_ext ] = extrapolateGT( view, matchList, GTList, thresh_dist_GT )
% Make an extrapolated GT for evaluation
% output: 1 x nInitialMatches indicator vector

if length(view) == 1
    bSelf = 1;  view1 = 1;  view2 = 1;
else
    bSelf = 0;  view1 = 1;  view2 = 2;
end

if isempty(GTList)
    indicator_GT_ext = ones(1,size(matchList,1));
    fprintf('Ground truth not included -> all matches considered as True... \n');
else
    % find all matches close to GTs among the initial matches
    kdtreeNS1 = kdtree_build(view(view1).feat(matchList(:,1),1:2));%KDTreeSearcher( view(view1).feat(matchList(:,1),1:2) );
    kdtreeNS2 = kdtree_build(view(view2).feat(matchList(:,2),1:2));%KDTreeSearcher( view(view2).feat(matchList(:,2),1:2) ); 
    %matchList_GT = matchList(find(GT),:);
    nGTList = size(GTList,1);
    indicator_GT_ext = zeros(1,size(matchList,1));
    
    for i=1:nGTList
        query_view1 = view(view1).feat(GTList(i,1),1:2);
        query_view2 = view(view2).feat(GTList(i,2),1:2); 
        if ~bSelf
            %finds the points within the search radius
            ridx_view1 = kdtree_ball_query( kdtreeNS1, query_view1, thresh_dist_GT );
            %idx = rangesearch(kdtreeNS1,query_view1,thresh_dist_GT);
            %ridx_view1 = idx{1};
            ridx_view2 = kdtree_ball_query( kdtreeNS2, query_view2, thresh_dist_GT );
            %idx = rangesearch(kdtreeNS2,query_view2,thresh_dist_GT);
            %ridx_view2 = idx{1};
            %ridx_view1=BruteSearchMex(XY_view1',query_view1','r',thresh_dist_GT);
            %ridx_view2=BruteSearchMex(XY_view2',query_view2','r',thresh_dist_GT);
            trueIdx = intersect(ridx_view1, ridx_view2);
        else
            %finds the points within the search radius
%             ridx_view1a=BruteSearchMex(XY_view1',query_view1','r',thresh_dist_GT);
%             ridx_view2a=BruteSearchMex(XY_view2',query_view2','r',thresh_dist_GT);
%             ridx_view1b=BruteSearchMex(XY_view2',query_view1','r',thresh_dist_GT);
%             ridx_view2b=BruteSearchMex(XY_view1',query_view2','r',thresh_dist_GT);
%             trueIdx = union( intersect(ridx_view1a, ridx_view2a),intersect(ridx_view1b, ridx_view2b));
        end
        indicator_GT_ext(trueIdx) = 1;        
    end
    kdtree_delete(kdtreeNS1);
    kdtree_delete(kdtreeNS2);
end



