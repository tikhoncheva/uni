plotSet.lineWidth = 3; % Line width
plotSet.markerSize = 6; % Marker Size
plotSet.fontSize = 14; % Font Size
plotSet.font = '\fontname{Arial}'; % Font default
% [ nCandMatch, nTrue, nDetected, nTP, score_GM];

plotData(1).name = '  progGM';
plotData(2).name = '2levelGM';
plotData(3).name = 'featureM';



indToShow = [ 5 4 4 ];
perform_data_tmp = perform_data;

% set min, max for the score plot
Xmin = -1;  Xmax = -1;
Ymin = Inf; Ymax = -Inf; 
for j=1:length(methods)
    p_data = perform_data_tmp{cImg,j};
%     p_data(:,5) = p_data(:,5) * (2*max(p_data(:,2))/max(p_data(:,5)));
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


% --------------------------------------------------------------------
% Score
% --------------------------------------------------------------------
figure;
for j=1:length(methods)
    p_data = perform_data_tmp{cImg,j};

    hold on;
    plot(0:(size(p_data,1)-1),p_data(1:end,5), ...
            'LineWidth', plotSet.lineWidth, ...
            'Color', methods(j).color, ...
            'LineStyle', methods(j).lineStyle, ...
            'Marker', methods(j).marker, ...
            'MarkerSize', plotSet.markerSize); 
end
set(gca,'XTick',0:Xmax-1);    
axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
xlabel([plotSet.font 'Iteration'], 'FontSize', plotSet.fontSize);
ylabel([plotSet.font 'Score' ], 'FontSize', plotSet.fontSize);
hLegend = legend(plotData(1:length(methods)).name);
set(hLegend, 'Location', 'best', 'FontSize', 13)
% title(sprintf('%s vs %s', methods(1).strName, methods(2).strName));
hold off;
drawnow;  

% --------------------------------------------------------------------
% Precision
% --------------------------------------------------------------------
figure; Ymin = 0; Ymax = 1;
for j=1:length(methods)
    p_data = perform_data_tmp{cImg,j};

    hold on;
    plot(0:(size(p_data,1)-1),p_data(1:end,4)./p_data(1:end,3), ...
            'LineWidth', plotSet.lineWidth, ...
            'Color', methods(j).color, ...
            'LineStyle', methods(j).lineStyle, ...
            'Marker', methods(j).marker, ...
            'MarkerSize', plotSet.markerSize);   
end
set(gca,'XTick',0:Xmax-1);    
axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
xlabel([plotSet.font 'Iteration'], 'FontSize', plotSet.fontSize);
ylabel([plotSet.font 'Precision' ], 'FontSize', plotSet.fontSize);
hLegend = legend(plotData(1:length(methods)).name);
set(hLegend, 'Location', 'best', 'FontSize', 13)
% title(sprintf('%s vs %s', methods(1).strName, methods(2).strName));
hold off;
drawnow;  
% --------------------------------------------------------------------
% Recall
% --------------------------------------------------------------------
figure; Ymin = 0; Ymax = 1;
for j=1:length(methods)
    p_data = perform_data_tmp{cImg,j};

    hold on;
    plot(0:(size(p_data,1)-1),p_data(1:end,4)./p_data(1:end,2), ...
            'LineWidth', plotSet.lineWidth, ...
            'Color', methods(j).color, ...
            'LineStyle', methods(j).lineStyle, ...
            'Marker', methods(j).marker, ...
            'MarkerSize', plotSet.markerSize); 
end
set(gca,'XTick',0:Xmax-1);    
axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
xlabel([plotSet.font 'Iteration'], 'FontSize', plotSet.fontSize);
ylabel([plotSet.font 'Recall' ], 'FontSize', plotSet.fontSize);
hLegend = legend(plotData(1:length(methods)).name);
set(hLegend, 'Location', 'best', 'FontSize', 13)
% title(sprintf('%s vs %s', methods(1).strName, methods(2).strName));
hold off;
drawnow;