plotSet.lineWidth = 3; % Line width
plotSet.markerSize = 6; % Marker Size
plotSet.fontSize = 15; % Font Size
plotSet.font = '\fontname{Arial}'; % Font default
% [ nCandMatch, nTrue, nDetected, nTP, score_GM];
plotData(1).name = 'cand. matches';
plotData(1).color = 'k'; plotData(1).lineStyle = '-'; plotData(1).marker = 'd';
plotData(2).name = 'True Candidate';
plotData(2).color = 'r'; plotData(2).lineStyle = '--'; plotData(2).marker = 's';
plotData(3).name = 'Detected';
plotData(3).color = 'g'; plotData(3).lineStyle = '-'; plotData(3).marker = 'd';
plotData(4).name = 'True Positive';
plotData(4).color = 'g'; plotData(4).lineStyle = '-'; plotData(4).marker = 'o';
plotData(5).name = 'Score';
plotData(5).color = 'b'; plotData(5).lineStyle = '-'; plotData(5).marker = '^';

indToShow = [ 5 2 4 ];
perform_data_tmp = perform_data;

% set min, max
Xmin = -1;  Xmax = -1;
Ymin = Inf; Ymax = -Inf; 
for j=1:length(methods)
    p_data = perform_data_tmp{cImg,j};
    p_data(:,5) = p_data(:,5) * (2*max(p_data(:,2))/max(p_data(:,5)));
    perform_data_tmp{cImg,j} = p_data;
    
    Xmax_tmp = size(p_data,1);
    if Xmax_tmp > Xmax, Xmax = Xmax_tmp; end;
    Ymin_tmp = min(min(p_data(:,indToShow)));
    if Ymin_tmp < Ymin, Ymin = Ymin_tmp; end;
    Ymax_tmp = max(max(p_data(:,indToShow)));
    if Ymax_tmp > Ymax, Ymax = Ymax_tmp; end;
end
Ymax = Ymax + 30;
Ymin = 0;

% show the plots
for j=1:length(methods)
    figure;
    p_data = perform_data_tmp{cImg,j};
    % scaling of score for visualization
    tmpMax = max(p_data(:,5));%+20;
    scoreGrowth(cImg,i) = p_data(end,5) / p_data(1,5);
    inlierGrowth(cImg,i) = p_data(end,4) / p_data(1,4);
    %set(0,'CurrentFigure',hFig2); clf;
    hold on;
    
    for k = indToShow
        plot(0:(size(p_data,1)-1),p_data(1:end,k), ...
            'LineWidth', plotSet.lineWidth, ...
            'Color', plotData(k).color, ...
            'LineStyle', plotData(k).lineStyle, ...
            'Marker', plotData(k).marker, ...
            'MarkerSize', plotSet.markerSize);
    end
    
    set(gca,'XTick',0:Xmax-1);    
    axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
    xlabel([plotSet.font 'Progressive Step'], 'FontSize', plotSet.fontSize);
    ylabel([plotSet.font '' ], 'FontSize', plotSet.fontSize);
    % for k = 1:length(Fix)
    %     text(Xmin+0.1*(Xmax-Xmin), Ymin+0.1*(length(Fix)-k+1)*(Ymax-Ymin), ...
    %         [plotSet.font settings{Fix(k)}{2} ' = ' num2str(settings{Fix(k)}{4})], ...
    %         'FontSize', plotSet.fontSize);
    % end

    hLegend = legend(plotData(indToShow).name);
    set(hLegend, 'Location', 'best', 'FontSize', 14)
    title(methods(j).strName);
    
    drawnow;
    if 0
        title('');
        t = clock; time_tag = sprintf('%02d%02d%02d%02d%02d', t(2), t(3), t(4), t(5), round(t(6)));
        saveStr = sprintf('%s_%s_%s','ProGM',time_tag,methods(j).strName);
        %scrsz = get(0,'ScreenSize');    set(hFig1, 'Position',[1 scrsz(4)/6 scrsz(3)/1.7 scrsz(4)/1.8]);
        saveas(gcf,['./save_ProGM/' saveStr '.jpg']);
    end
    
end