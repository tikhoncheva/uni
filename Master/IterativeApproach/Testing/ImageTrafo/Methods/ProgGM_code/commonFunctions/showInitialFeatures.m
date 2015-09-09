% Show initial cluster matches 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%figure;
%mparam.bFeatExtUse = [ 1 1 1 0 ];          % feature types used for *** matching! ***
mparam.bFeatExtUse
bPause = 0;
imshow(appendimages(rgb2gray(cdata.view(1).img),rgb2gray(cdata.view(2).img)));
hold on;
nFeat1 = size(cdata.view(1).feat,1);
nFeat2 = size(cdata.view(2).feat,1);

nDim = min( length(cdata.view(1).nFeatOfExt), length(cdata.view(1).nFeatOfExt));
nMaxG1 = sum( cdata.mparam.bFeatExtUse(1:nDim) .* cdata.view(1).nFeatOfExt(1:nDim));
nMaxG2 = sum( cdata.mparam.bFeatExtUse(1:nDim) .* cdata.view(2).nFeatOfExt(1:nDim));
fprintf('\n- maximal case: %d by %d \n',nMaxG1,nMaxG2);

for i=1:nFeat1
    if mparam.bFeatExtUse(cdata.view(1).typeFeat(i))
        feat1= cdata.view(1).feat(i,:);
        drawEllipse3( feat1(1:5), 1, 'k', 5);
        drawEllipse3( feat1(1:5), 1, 'm', 3);
    end
end
for i=1:nFeat2
    if mparam.bFeatExtUse(cdata.view(2).typeFeat(i))
        feat2 = cdata.view(2).feat(i,:);
        feat2(1) = feat2(1) + size(cdata.view(1).img,2);
        drawEllipse3( feat2(1:5), 1, 'k', 5);
        drawEllipse3( feat2(1:5), 1, 'm', 3);
    end
end    
    
pause;
for i=1:cdata.nInitialMatches
    idxFeat1 = cdata.matchInfo(i).match(1);
    idxFeat2 = cdata.matchInfo(i).match(2);
    feat1= cdata.view(1).feat(idxFeat1,:);
    feat2= cdata.view(2).feat(idxFeat2,:); 
    feat2(1) = feat2(1) + size(cdata.view(1).img,2);
    plot([ feat1(1), feat2(1) ]...
            ,[ feat1(2), feat2(2) ],...
            '-','LineWidth',3,'MarkerSize',10,...
            'color', 'k');
    plot([ feat1(1), feat2(1) ]...
            ,[ feat1(2), feat2(2) ],...
            '-','LineWidth',2,'MarkerSize',10,...
            'color', 'c');

    if bPause
        fprintf('match idx: %d/%d \n', i, cdata.nInitialMatches);
        pause;
    end
end
for i=1:cdata.nInitialMatches
    idxFeat1 = cdata.matchInfo(i).match(1);
    idxFeat2 = cdata.matchInfo(i).match(2);
    feat1= cdata.view(1).feat(idxFeat1,:);
    feat2= cdata.view(2).feat(idxFeat2,:); 
    feat2(1) = feat2(1) + size(cdata.view(1).img,2);
    drawEllipse3( feat1(1:5), 1, 'k', 4);
    drawEllipse3( feat2(1:5) ,1, 'k', 4);
    drawEllipse3( feat1(1:5), 1, 'm', 3);
    drawEllipse3( feat2(1:5) ,1, 'm', 3);
end

hold off;
clear feat1 feat2 idxFeat1 idxFeat2     


