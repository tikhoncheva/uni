function cdata = initialmatch_main_re( iparam, cdata, mparam )
% make new initial matches maintaining the features
    
% Find initial matches 
disp('== Performing initial matching of the feature regions');
[ matchInfo ]= make_initialmatches_mcho( cdata.view, mparam, iparam.bShow );
drawnow;
nInitialMatches = length(matchInfo);
disp( [ 'num of initial matches: ' num2str(nInitialMatches) ] );
% Find overlapping matches
disp('== Finding overlapping relations of the initial matches');
[ overlapMatrix ]= make_overlapMatrix2( cdata.view, cell2mat({ matchInfo.match }'), mparam );
nOverlap = sum(sum(overlapMatrix));
fprintf('- %d (%4.2f%%) overlapping pairs detected\n', nOverlap, nOverlap/nInitialMatches^2);
    
%cdata.baseOfInitialMatch = baseOfInitialMatch;
cdata.nInitialMatches = nInitialMatches;
cdata.matchInfo = matchInfo;
cdata.overlapMatrix = overlapMatrix;

% save the current parameter
cdata.mparam = mparam;