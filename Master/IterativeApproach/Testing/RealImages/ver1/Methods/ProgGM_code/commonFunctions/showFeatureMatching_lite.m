function showFeatureMatching_lite(cdata, matchlist, matchscore )

imgInput = appendimages( cdata.view(1).img, cdata.view(2).img );
imgInput = double(imgInput)./255;
imshow(rgb2gray(imgInput)); hold on;
iptsetpref('ImshowBorder','tight');

% sort from high score to low score
[ matchscore, ind_s ] = sort(matchscore,'descend');
matchlist = matchlist(ind_s,:);

% positive weight edges
maxW = matchscore(1);
minW = matchscore(end);

cmap = colormap('jet');
colormap('gray');    

idxFeat1 = matchlist(:,1);
idxFeat2 = matchlist(:,2);
feat1 = cdata.view(1).feat(idxFeat1,:);
feat2 = cdata.view(2).feat(idxFeat2,:);
feat2(:,1) = feat2(:,1) + size(cdata.view(1).img,2);

% show in reverse order (to show high score matches better)
for i = size(matchlist,1):-1:1
    col1 = cmap( ceil( (matchscore(i)-minW) * length(cmap) / (maxW-minW+eps) + eps), :);
    
    plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
            '-','LineWidth',3,'MarkerSize',10,'color', 'k');
    plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
            '-','LineWidth',2,'MarkerSize',10,'color', col1);

    drawEllipse3( feat1(i,1:5), 1, 'k',3);
    drawEllipse3( feat1(i,1:5), 1, col1,2);
    drawEllipse3( feat2(i,1:5) ,1, 'k',3);
    drawEllipse3( feat2(i,1:5) ,1, col1,2);                    
end                     

hold off

drawnow;