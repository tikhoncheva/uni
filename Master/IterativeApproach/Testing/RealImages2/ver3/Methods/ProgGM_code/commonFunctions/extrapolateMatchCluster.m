function [ cdata ] = extrapolateMatchCluster(cdata, extrapolation_dist)
% check clusters and eliminate trivial clusters
% The output is added to cdata.clusterInfo(:).valid = 0 or 1

if length(cdata.view) == 1
    bSelf = 1;  view1 = 1;  view2 = 1;
else
    bSelf = 0;  view1 = 1;  view2 = 2;
end

matchList = cell2mat({ cdata.matchInfo(:).match }');
nCluster = length(cdata.clusterInfo);

XY_view1= cdata.view(view1).feat(matchList(:,1),1:2);
XY_view2= cdata.view(view2).feat(matchList(:,2),1:2); 

% traverse all the cluster, and extrapolate matches 
for k=1:nCluster    
    % find matching features
    matchIdxInTheCluster = cdata.clusterInfo(k).matchIdx;
    curMatchList = cell2mat({ cdata.matchInfo(matchIdxInTheCluster).match }');
    nCurMatch = length(matchIdxInTheCluster);
        
    % find all matches close to the members among the initial matches
    ext_match = [];
    for i=1:nCurMatch
        query_view1 = cdata.view(view1).feat( curMatchList(i,1),1:2);
        query_view2 = cdata.view(view2).feat( curMatchList(i,2),1:2); 
        if ~bSelf
            %finds the points within the search radius
            ridx_view1=BruteSearchMex(XY_view1',query_view1','r',extrapolation_dist);
            ridx_view2=BruteSearchMex(XY_view2',query_view2','r',extrapolation_dist);
            trueIdx = intersect(ridx_view1, ridx_view2);
        else
            %finds the points within the search radius
            ridx_view1a=BruteSearchMex(XY_view1',query_view1','r',extrapolation_dist);
            ridx_view2a=BruteSearchMex(XY_view2',query_view2','r',extrapolation_dist);
            ridx_view1b=BruteSearchMex(XY_view2',query_view1','r',extrapolation_dist);
            ridx_view2b=BruteSearchMex(XY_view1',query_view2','r',extrapolation_dist);
            trueIdx = union( intersect(ridx_view1a, ridx_view2a),intersect(ridx_view1b, ridx_view2b));
            
        end
        %trueIdx = setdiff(trueIdx, matchIdxInTheCluster(i));
        ext_match = [ ext_match trueIdx ];
    end
    nOri = length(cdata.clusterInfo(k).matchIdx);
    % save them in clusterInfo
    cdata.clusterInfo(k).matchIdx = unique([ cdata.clusterInfo(k).matchIdx; ext_match' ]);
    cdata.clusterInfo(k).size = length(cdata.clusterInfo(k).matchIdx);
    fprintf('- Extrapolating cluster#%2d: %d + additional %d -> %d unique\n',k, nOri, length(ext_match), cdata.clusterInfo(k).size);
    
end

