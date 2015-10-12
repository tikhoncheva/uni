% Show initial match 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
figure;

bPair = length(viewInfo) > 1;
if bPair
    imshow(appendimages(rgb2gray(viewInfo(1).img),rgb2gray(viewInfo(2).img)));
    offset = size(viewInfo(1).img,2);
    view1 = 1;  view2 = 2;
else
    imshow(rgb2gray(viewInfo(1).img));
    offset = 0;
    view1 = 1;  view2 = 1;
end
hold on;

nInitialMatches = length(matchInfo);
for i=1:nInitialMatches
    feat1=viewInfo(view1).feat(matchInfo(i).match(1),:);
    feat2=viewInfo(view2).feat(matchInfo(i).match(2),:);
    plot([feat1(1), feat2(1)+offset],[feat1(2), feat2(2)],'LineWidth',3,'Color','k' );
    plot([feat1(1), feat2(1)+offset],[feat1(2), feat2(2)],'LineWidth',2,'Color','y' );
end

% for i=1:nInitialMatches
%     feat1=viewInfo(view1).feat(matchInfo(i).match(1),:);
%     feat2=viewInfo(view2).feat(matchInfo(i).match(2),:);
% 
%     %if matchInfo(i).head == 1
%     if feat1(7) >= feat2(7)
%         colFeat1 = 'red';
%         colFeat2 = 'red';
%         %colFeat2 = 'blue';
%     else
%         colFeat2 = 'red';
%         colFeat1 = 'red';
%         %colFeat1 = 'blue';
%     end
%     %colFeat2 = 'red';
%     %colFeat1 = 'red';
%     drawellipse3(feat1(1:5), 1, colFeat1);
%     drawOrientation3(feat1(1:6), 1, colFeat1)
%     drawellipse3( [ feat2(1)+offset, feat2(2:5) ], 1, colFeat2);
%     drawOrientation3( [ feat2(1)+offset, feat2(2:6) ], 1, colFeat2);
% end
title( [ viewInfo(view1).fileName ' + ' viewInfo(view2).fileName ] );
hold off;
clear feat1 feat2 offset;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%disp( [ '- num of initial matches: ' num2str(nInitialMatches) ] );
