function sizeOfMajorCluster = display_result_matching( status, cdata, GT_indicator, bMasking, bCannonColor )
% display the result of feature matching

    nViewRank = 1200;
    bPause = 0;
    bShowConvexHulls = 0;
    bShowMatchLine = 1;
    bShowEllipse = 0;
    bShowPoint = 1;
    bLargerTop = 0;
    
    if nargin < 4, GT_indicator = ones(1,cdata.nInitialMatches);    end        
    if nargin < 5, bCannonColor = 1;    end
    if bCannonColor, colorOrder = 'rgbcymw';%'crgbymw';
    else colorOrder = ''; end

    
    %if cdata.bPair, imgInput = appendimages( cdata.view(1).img, cdata.view(2).img );
    if cdata.bPair, imgInput = appendimages( rgb2gray(cdata.view(1).img), rgb2gray(cdata.view(2).img) );
    else    imgInput = [ cdata.view(1).img ];    end
    imgInput = double(imgInput)./255;

    % sort for visualization
    nCluster = size(cdata.clusterInfo,2);
    [ temp traversalIdx ] = sort([ cdata.clusterInfo.size ],'descend');
    clear temp;

    if 1
        %hFigMain = figure(5002);
        imshow(imgInput);
        %set( gca,'Position',[0,0,1,1]);
        hold on;
        %pause;
    end
    
    sizeOfMajorCluster = [];
    cCol = 0;
    % traverse all the cluster, and assign color
    for k=1:nCluster
        % check validity of each cluster and assign a color to it
        if cdata.clusterInfo(traversalIdx(k)).valid
            if  cCol < size(colorOrder,2) 
                cCol = cCol + 1;
                cdata.clusterInfo(traversalIdx(k)).color = colorOrder(cCol);
            end
        else
            cdata.clusterInfo(traversalIdx(k)).color = 'k';
            continue;
        end
         fprintf( 'MCS %d (idx %d ) Col: %s   Size: %d   Area: %.2f\n',...
            k, traversalIdx(k), cdata.clusterInfo(traversalIdx(k)).color,...
            cdata.clusterInfo(traversalIdx(k)).size,...
            cdata.clusterInfo(traversalIdx(k)).areaHull1+cdata.clusterInfo(traversalIdx(k)).areaHull2);
        
    end
    
    if bLargerTop % visualize in the reverse order
        [ temp traversalIdx ] = sort([ cdata.clusterInfo.size ],'ascend');
    end
    
%% visualize
    hold on;
    for k = 1:min(nViewRank, nCluster)

        if  ~cdata.clusterInfo(traversalIdx(k)).valid
            continue;
        end
        
        % find matching features
        matchIdxInTheCluster = cdata.clusterInfo(traversalIdx(k)).matchIdx;
        flipInTheCluster = find(cdata.clusterInfo(traversalIdx(k)).flipOfMatch);
        curMatchList = cell2mat({ cdata.matchInfo(matchIdxInTheCluster).match }');
        idxFeat1 = curMatchList(:,1);    idxFeat2 = curMatchList(:,2);
        if cdata.bPair
            feat1= cdata.view(1).feat(idxFeat1,:);
            feat2= cdata.view(2).feat(idxFeat2,:); 
            feat2(:,1) = feat2(:,1) + size(cdata.view(1).img,2);
        else
            tmpFeat = idxFeat1(flipInTheCluster);
            idxFeat1(flipInTheCluster) = idxFeat2(flipInTheCluster);
            idxFeat2(flipInTheCluster) = tmpFeat;
            feat1= cdata.view(1).feat(idxFeat1,:);
            feat2= cdata.view(1).feat(idxFeat2,:); 
        end
        
        % draw convex hulls
        
               
        % matchIdxInTheCluster: indexes of matches contained in the cluster
        % feat1 :  features in view 1 - x y a b c ... ( ellipse features )
        % feat2 :  features in view 2 - x y a b c ... ( ellipse features )
        
        % access to all the extracted features
        % cdata.view(1).nFeat : the total num of features
        % cdata.view(1).nFeatOfExt : [ mser haraff hesaff ]
        % cdata.view(1).feat(:,1-7) - x y a b c ... ( ellipse features )
        %
        
        % draw false matches
        for i = 1:cdata.clusterInfo(traversalIdx(k)).size
            if GT_indicator(matchIdxInTheCluster(i)) == 1
                continue;
            else
                col1 = 'k'; col2 = 'k';
            end
            if bShowMatchLine
                %plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
                %        '-','LineWidth',3,'MarkerSize',10,'color', 'w');
                plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
                        '-','LineWidth',2,'MarkerSize',10,'color', col1);
            end
            if bShowEllipse
                drawEllipse3( feat1(i,1:5), 1, 'w',4);
                drawEllipse3( feat1(i,1:5), 1, col2,3);
                drawEllipse3( feat2(i,1:5) ,1, 'w',4);
                drawEllipse3( feat2(i,1:5) ,1, col2,3);
            end
            if bShowPoint
                plot([ feat1(i,1) ],[ feat1(i,2) ],...
                        'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',col2,'color', 'k');
                plot([ feat2(i,1) ],[ feat2(i,2) ],...
                        'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',col2,'color', 'k');
            end
                
        end
        % draw true matches
        for i = 1:cdata.clusterInfo(traversalIdx(k)).size
            if GT_indicator(matchIdxInTheCluster(i)) == 1                 
                col1 = cdata.clusterInfo(traversalIdx(k)).color;
                col2 = cdata.clusterInfo(traversalIdx(k)).color;
            else
                continue;
            end
            if bShowMatchLine
            plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
                    '-','LineWidth',3,'MarkerSize',10,'color', 'k');
            plot([ feat1(i,1), feat2(i,1) ],[ feat1(i,2), feat2(i,2) ],...
                    '-','LineWidth',2,'MarkerSize',10,'color', col1);
            end
            if bShowEllipse
                drawEllipse3( feat1(i,1:5), 1, 'w',4);
                drawEllipse3( feat1(i,1:5), 1, col2,3); %drawOrientation3( feat1(i,1:6) ,1, 'y', 3); 
                drawEllipse3( feat2(i,1:5) ,1, 'w',4);  
                drawEllipse3( feat2(i,1:5) ,1, col2,3); %drawOrientation3( feat2(i,1:6) ,1, 'y', 3);             
            end
            if bShowPoint
                plot([ feat1(i,1) ],[ feat1(i,2) ],...
                        'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',cdata.clusterInfo(traversalIdx(k)).color,'color', 'k');
                plot([ feat2(i,1) ],[ feat2(i,2) ],...
                        'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',cdata.clusterInfo(traversalIdx(k)).color,'color', 'k');
            end
        end 
        
        if bShowConvexHulls
            if size(unique(feat1(:,1:2),'rows'),1) > 2 && size(unique(feat2(:,1:2),'rows'),1) > 2
                hullFeat1 = cdata.clusterInfo(traversalIdx(k)).hullFeat1;
                hullFeat2 = cdata.clusterInfo(traversalIdx(k)).hullFeat2;
                plot(hullFeat1(:,1),hullFeat1(:,2),'Color','k','LineWidth',7);
                plot(hullFeat1(:,1),hullFeat1(:,2),':','Color',cdata.clusterInfo(traversalIdx(k)).color,'LineWidth',3);
                plot(hullFeat2(:,1),hullFeat2(:,2),'Color','k','LineWidth',7);
                plot(hullFeat2(:,1),hullFeat2(:,2),':','Color',cdata.clusterInfo(traversalIdx(k)).color,'LineWidth',3);
                
                plot([ feat1(:,1) ],[ feat1(:,2) ],...
                    'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',cdata.clusterInfo(traversalIdx(k)).color,'color', 'k');
                plot([ feat2(:,1) ],[ feat2(:,2) ],...
                    'o','LineWidth',2,'MarkerSize',10,'MarkerFaceColor',cdata.clusterInfo(traversalIdx(k)).color,'color', 'k');
            end
        end
        
        if bPause
            fprintf('cluster idx: %d\n',traversalIdx(k));
            pause;
        end
        
    end
    hold off;

    
