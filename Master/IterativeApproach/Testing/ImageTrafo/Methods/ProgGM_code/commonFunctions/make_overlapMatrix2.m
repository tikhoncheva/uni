function [ overlap ] = make_overlapMatrix2( viewInfo, matchList, mparam )
% Find overlapping matches between matches
%
% Minsu Cho, Seoul National University
% Final revision: 13th March 2011

if length(viewInfo) == 1
    bSelf = 1;  view1 = 1;  view2 = 1;
else
    bSelf = 0;  view1 = 1;  view2 = 2;
end

nMatch = size(matchList,1);

% construct match overlap matrix
% overlap : binary matrix whether two matches overlap or not
overlap =  uint8(zeros(nMatch));
if 0 %mparam.bFilterMatch
    % we already filtered out the equivalent matches,
    % so, just check indexes of features
    for i=1:nMatch
        if ~bSelf
            ovl_ridx = find( (matchList(:,1) == matchList(i,1)) | (matchList(:,2) == matchList(i,2)) );
        else
            ovl_ridx = find( ((matchList(:,1) == matchList(i,1)) | (matchList(:,2) == matchList(i,1)))...
                | ((matchList(:,1) == matchList(i,2)) | (matchList(:,2) == matchList(i,2))) );
        end
        overlap(i,ovl_ridx) = 1;
    end
else
    % check overlapping matches
    XY_sel_view1 = viewInfo(view1).feat(matchList(:,1),1:2);
    XY_sel_view2 = viewInfo(view2).feat(matchList(:,2),1:2);
    for i=1:nMatch
        XY_view1 = viewInfo(view1).feat(matchList(i,1),1:2);
        XY_view2 = viewInfo(view2).feat(matchList(i,2),1:2);
        if ~bSelf
            %finds the points within the search radius
            ridx_view1=BruteSearchMex(XY_sel_view1',XY_view1','r',mparam.redundancy_thres);
            ridx_view2=BruteSearchMex(XY_sel_view2',XY_view2','r',mparam.redundancy_thres);
%            idx = rangesearch(XY_view1,XY_sel_view1,mparam.redundancy_thres);
%            ridx_view1 = idx{1};
%            idx = rangesearch(XY_view2,XY_sel_view2,mparam.redundancy_thres);
%            ridx_view2 = idx{1};
            ovl_ridx = setdiff(union(ridx_view1, ridx_view2),intersect(ridx_view1, ridx_view2));
        else
            %finds the points within the search radius
            ridx_view1a=BruteSearchMex([XY_sel_view1]',XY_view1','r',mparam.redundancy_thres);
            ridx_view2a=BruteSearchMex([XY_sel_view2]',XY_view2','r',mparam.redundancy_thres);
            ridx_view1b=BruteSearchMex([XY_sel_view2]',XY_view1','r',mparam.redundancy_thres);
            ridx_view2b=BruteSearchMex([XY_sel_view1]',XY_view2','r',mparam.redundancy_thres);
            ovl_ridx = union( setdiff(union(ridx_view1a, ridx_view2a),intersect(ridx_view1a, ridx_view2a)),...
                setdiff(union(ridx_view1b, ridx_view2b),intersect(ridx_view1b, ridx_view2b)) );
        end

        overlap(i,ovl_ridx) = 1;
    end
end
overlap(1:size(overlap,1)+1:end) = 1;
overlap = overlap | overlap';
%figure; spy(overlap);