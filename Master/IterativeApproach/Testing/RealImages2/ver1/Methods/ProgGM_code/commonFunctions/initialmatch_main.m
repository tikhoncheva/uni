function cdata = initialmatch_main( iparam, fparam, mparam, bBB )
if nargin < 4
    bBB = false;
end
% Load model image
disp('== Obtaining features from images...');

bShow = iparam.bShow;
nView = iparam.nView;

for j=1:nView
    viewInfo = extract_localfeatures_mcho( iparam.view(j).filePathName, fparam, bShow );
    viewInfo.fileName = iparam.view(j).fileName;  
    view(j) = viewInfo;
end
    
% eliminate patches for memory efficiency
view(1).patch = cell(0); 
view(1).desc_ref = [];
if iparam.bPair
    view(2).patch = cell(0);
    view(2).desc_ref = [];
end

if bBB % select a bounding box in ref
    % eliminate features out of a given bounding box
    imgInput = appendimages( view(1).img, view(2).img );
    fig1 = figure('Name','Select ROI on the left image...'); imshow(double(imgInput)./255); hold on;
    plot(view(1).feat(:,1),view(1).feat(:,2),'s','MarkerEdgeColor','k',...
                'MarkerFaceColor', 'r','MarkerSize', 5);
    plot(view(2).feat(:,1)+size(view(1).img,2),view(2).feat(:,2),'s','MarkerEdgeColor','k',...
                'MarkerFaceColor', 'b','MarkerSize', 5);            
    disp('Select ROI on the left image...');
    bbox_rect = getrect;
    if ~isempty(bbox_rect)
        valid_idx = find( (view(1).feat(:,1) >= bbox_rect(1)) & (view(1).feat(:,1) <= bbox_rect(1)+bbox_rect(3))...
            & (view(1).feat(:,2) >= bbox_rect(2)) & (view(1).feat(:,2) <= bbox_rect(2)+bbox_rect(4)) );
        view(1).typeFeat = view(1).typeFeat( valid_idx );
        view(1).feat = view(1).feat( valid_idx, :);
        view(1).desc = view(1).desc( valid_idx, :);
        view(1).shscMatrix = view(1).shscMatrix( valid_idx, :);
        view(1).affMatrix = view(1).affMatrix( valid_idx, :);
        %viewInfo.patch = viewInfo.patch( :, valid_idx);
    end
    close(fig1);
end

% Find initial matches 
disp('== Performing initial matching of the feature regions');
[ matchInfo ]= make_initialmatches_mcho( view, mparam, bShow );
drawnow;
nInitialMatches = length(matchInfo);
disp( [ 'num of initial matches: ' num2str(nInitialMatches) ] );
% Find overlapping matches
disp('== Finding overlapping relations of the initial matches');
[ overlapMatrix ]= make_overlapMatrix2( view, cell2mat({ matchInfo.match }'), mparam );
nOverlap = sum(sum(overlapMatrix));
fprintf('- %d (%4.2f%%) overlapping pairs detected\n', nOverlap, nOverlap/nInitialMatches^2);
    
cdata.bPair = iparam.bPair;
cdata.nView = iparam.nView;
cdata.bReflective = mparam.bReflective;
%cdata.baseOfInitialMatch = baseOfInitialMatch;
cdata.nInitialMatches = nInitialMatches;
cdata.view = view;
cdata.matchInfo = matchInfo;
cdata.overlapMatrix = overlapMatrix;

cdata.mparam = mparam;
cdata.iparam = iparam;
cdata.fparam = fparam;