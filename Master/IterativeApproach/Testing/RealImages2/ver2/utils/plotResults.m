handleCount = handleCount+1; h(handleCount) = figure(handleCount);
hold on;

for k = 1:length(methods)
    plot(xData, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
end
Xmin = min(xData)-1; Xmax = max(xData)+1;
Ymin = min(yData(:)); Ymax = max(yData(:));
axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
xlabel([plotSet.font 'Sequence gap '], 'FontSize', plotSet.fontSize);
ylabel([plotSet.font yLabelText], 'FontSize', plotSet.fontSize);
% for k = 1:length(methods)
%     text(Xmin+0.1*(Xmax-Xmin), Ymin+0.1*(length(Fix)-k+1)*(Ymax-Ymin), ...
%         [plotSet.font settings{Fix(k)}{2} ' = ' settings{methods(k).strName)], ...
%         'FontSize', plotSet.fontSize);
% end

hLegend = legend(methods(:).strName);
set(hLegend, 'Location', 'best')

for k = length(methods):-1:1
    plot(xData, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
    errorbar(xData, yData(:,k), E(:,k), 'Color', methods(k).color);
end
hold off;

% save plots

set(h(handleCount), 'color', 'w');

F = getframe(h(handleCount));
img = F.cdata;
imwrite(img, [savepath,'performance/',names{handleCount}, '.png']);

clear Xmin Xmax Ymin Ymax yData yLabelText hLegend k