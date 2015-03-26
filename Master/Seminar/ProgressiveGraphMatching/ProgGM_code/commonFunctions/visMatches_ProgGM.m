%% -----------------  show the current GM result
warning off
if cdata.bPair, img_offset = size(cdata.view(1).img, 2);
else    img_offset = 0;    end
figure(hFig1); imshow(imgInput); hold on;
str_out = sprintf('== Prog GM iter%2d : %d matches - Precision: %.3f (%d/%d), Recall: %.3f (%d/%d)  Score:%.2f'...
         , iterGM, nDetected, nTP/nDetected, nTP, nDetected, nTP/nTrue, nTP, nTrue, score_GM);
title(str_out);
disp(str_out);
% draw all the candidate matches at GM
if 0
    for iter_t = 1:nCandMatch
        match_t = cand_matchlist(iter_t,1:2);
        col1 = 'y'; col2 = 'k';    
        plot([ cdata.view(1).feat(match_t(1),1), cdata.view(2).feat(match_t(2),1)+img_offset ],...
            [ cdata.view(1).feat(match_t(1),2), cdata.view(2).feat(match_t(2),2) ],...
                '-','LineWidth',3,'MarkerSize',10,'color', 'k');
        plot([ cdata.view(1).feat(match_t(1),1), cdata.view(2).feat(match_t(2),1)+img_offset ],...
            [ cdata.view(1).feat(match_t(1),2), cdata.view(2).feat(match_t(2),2) ],...
                '-','LineWidth',2,'MarkerSize',10,'color', col1);
    end
    vIdx = find(X_GT);
    for iter_t = 1:length(vIdx)
        match_t = cand_matchlist(vIdx(iter_t),1:2);
        if X_GT(vIdx(iter_t)) && X_sol_EXT(vIdx(iter_t))  % true positive               
            col1 = 'r'; %col2 = 'r';
            plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
            [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
                '-','LineWidth',3,'MarkerSize',10,'color', 'w');
            plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
            [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
                '-','LineWidth',2,'MarkerSize',10,'color', col1);
            %drawEllipse3( all_feat1(match_t(1),1:5), 1, col1, 2);
            %drawOrientation3( all_feat1(match_i(1),1:6) ,1, 'y', 3); 
            %drawEllipse3( all_feat2(match_t(2),1:5)+[ img_offset 0 0 0 0] ,1, col1, 2);    
            %drawOrientation3( all_feat2(match_i(2),1:6)+[img_offset 0 0 0
            %0 0] ,1, col1, 2);
        end
    end 
    % draw triangulation: head-magenta, tail-cyan
    TP_matchlist = cand_matchlist(:,1:2);
    TP_xy1 = all_feat1(TP_matchlist(:,1),1:2);  TP_xy2 = all_feat2(TP_matchlist(:,2),1:2);
    if size(unique(TP_xy1, 'rows'),1) > 3 
        delaunayTRI = delaunay(all_feat1(TP_matchlist(:,1),1),all_feat1(TP_matchlist(:,1),2));
        %triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'w-','LineWidth',3);
        triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'b-','LineWidth',2);
        delaunayTRI = delaunay(all_feat2(TP_matchlist(:,2),1),all_feat2(TP_matchlist(:,2),2));
        %triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'w-','LineWidth',3);
        triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'b-','LineWidth',2);
    end
    drawnow;
    if 1
        title('');
        t = clock; time_tag = sprintf('%02d%02d%02d%02d%02d', t(2), t(3), t(4), t(5), round(t(6)));
        saveStr = sprintf('%s_%s_%s_%03d_%02d_%02d','ProGM',time_tag,method.strName,iterGM,nTP,nTrue);
        %scrsz = get(0,'ScreenSize');    set(hFig1, 'Position',[1 scrsz(4)/6 scrsz(3)/1.7 scrsz(4)/1.8]);
        saveas(gcf,['./save_ProGM/' saveStr '.jpg']);
    end
    %pause;
    imshow(imgInput); hold on;
end


% draw false matches
if 1
    vIdx = find(X_GT | X_sol_EXT);
    for iter_t = 1:length(vIdx)
        match_t = cand_matchlist(vIdx(iter_t),1:2);
        if X_GT(vIdx(iter_t)) && X_sol_EXT(vIdx(iter_t))  % true positive               
        elseif X_GT(vIdx(iter_t))  % true negative
%                     col1 = 'b'; 
%                     plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
%                     [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
%                         ':','LineWidth',2,'MarkerSize',10,'color', col1);
        else % false positive
            col1 = 'k'; 
%                     plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
%                     [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
%                         '-','LineWidth',1,'MarkerSize',10,'color', col1);
        end
    end 
end
vIdx = find(X_GT | X_sol_EXT);
for iter_t = 1:length(vIdx)
    match_t = cand_matchlist(vIdx(iter_t),1:2);
    if X_GT(vIdx(iter_t)) && X_sol_EXT(vIdx(iter_t))  % true positive               
        col1 = 'g'; %col2 = 'r';
        plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
        [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
            '-','LineWidth',2,'MarkerSize',10,'color', 'w');
        plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
        [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],...
            '-','LineWidth',1,'MarkerSize',10,'color', col1);
        %drawEllipse3( all_feat1(match_t(1),1:5), 1, col1, 2);
        %drawOrientation3( all_feat1(match_i(1),1:6) ,1, 'y', 3); 
        %drawEllipse3( all_feat2(match_t(2),1:5)+[ img_offset 0 0 0 0] ,1, col1, 2);    
        %drawOrientation3( all_feat2(match_i(2),1:6)+[img_offset 0 0 0
        %0 0] ,1, col1, 2);
    end
end 
% draw triangulation: head-magenta, tail-cyan
TP_matchlist = cand_matchlist(find(X_GT & X_sol_EXT),1:2);
TP_xy1 = all_feat1(TP_matchlist(:,1),1:2);  TP_xy2 = all_feat2(TP_matchlist(:,2),1:2);
if size(unique(TP_xy1, 'rows'),1) > 3 
    delaunayTRI = delaunay(all_feat1(TP_matchlist(:,1),1),all_feat1(TP_matchlist(:,1),2));
    triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'w-','LineWidth',3);
    triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'w-','LineWidth',3);
    triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'r-','LineWidth',2);
    triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'r-','LineWidth',2);
end

%draw the scores of the matches
%         vIdx = find(X_sol);
%         for iter_t = 1:length(vIdx)
%             match_t = cand_matchlist(vIdx(iter_t),1:2);
%             plot(all_feat1(match_t(1),1),all_feat1(match_t(1),2),'o','LineWidth',1,...
%                         'MarkerSize',floor(inlierness_GM(iter_t)/100)+1,'MarkerFaceColor','m','color','w');
%         end  
drawnow;
if 0
    title('');
    t = clock; time_tag = sprintf('%02d%02d%02d%02d%02d', t(2), t(3), t(4), t(5), round(t(6)));
    saveStr = sprintf('%s_%s_%s_%03d_%02d_%02d','ProGM',time_tag,method.strName,iterGM,nTP,nTrue);
    %scrsz = get(0,'ScreenSize');    set(hFig1, 'Position',[1 scrsz(4)/6 scrsz(3)/1.7 scrsz(4)/1.8]);
    saveas(gcf,['./save_ProGM/' saveStr '.jpg']);
end

if iterGM == 1 && ~bStop
 in_str = input( ['one-shot GM is done. Proceed to ProgGM? [y/n]: '],'s');
 if strcmp(in_str,'n'),  bStop = 1;   end
end
warning on