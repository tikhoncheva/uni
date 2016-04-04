%% -----------------  show the current GM result
warning off
img_offset = size(cdata.view(1).img, 2);
figure(hFig1); imshow(imgInput); hold on;

str_out = sprintf('== Prog GM iter%2d : %d matches - Score:%.2f', iterGM, nDetected, score_GM);
title(str_out);
disp(str_out);

% draw matches
vIdx = find(X_sol);
for iter_t = 1:length(vIdx)
    match_t = cand_matchlist(vIdx(iter_t),1:2);
    col1 = 'g'; %col2 = 'r';
    plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
        [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],'-s','LineWidth', 2, 'Color', 'w', ...
        'MarkerEdgeColor','k', 'MarkerFaceColor', 'r','MarkerSize',10 );
    plot([ all_feat1(match_t(1),1), all_feat2(match_t(2),1)+img_offset ],...
        [ all_feat1(match_t(1),2), all_feat2(match_t(2),2) ],'LineWidth', 2, 'Color', col1, ...
        'MarkerEdgeColor','k', 'MarkerFaceColor', 'r','MarkerSize',10 );
end 
% draw triangulation: head-magenta, tail-cyan
% TP_matchlist = cand_matchlist(find(X_sol),1:2);
% TP_xy1 = all_feat1(TP_matchlist(:,1),1:2);  TP_xy2 = all_feat2(TP_matchlist(:,2),1:2);
% if size(unique(TP_xy1, 'rows'),1) > 3 
%     delaunayTRI = delaunay(all_feat1(TP_matchlist(:,1),1),all_feat1(TP_matchlist(:,1),2));
%     triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'w-','LineWidth',3);
%     triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'w-','LineWidth',3);
%     triplot(delaunayTRI,TP_xy1(:,1),TP_xy1(:,2),'r-','LineWidth',2);
%     triplot(delaunayTRI,TP_xy2(:,1)+img_offset,TP_xy2(:,2),'r-','LineWidth',2);
% end

drawnow;

if iterGM == 1 && ~bStop
 in_str = input( ['one-shot GM is done. Proceed to ProgGM? [y/n]: '],'s');
 if strcmp(in_str,'n'),  bStop = 1;   end
end
warning on