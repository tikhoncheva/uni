handleCount = handleCount+1; h(handleCount) = figure(handleCount);
hold on;

x = (1:size(yData,1));
x = x*10-10;
x(1)= 1;

for k = 1:length(methods)
    plot(x, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
end
Xmin = min(x)-1; Xmax = max(x)+1;
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
    plot(x, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
end
hold off;

% save plots

set(h(handleCount), 'color', 'w');

F = getframe(h(handleCount));
img = F.cdata;
imwrite(img, [savepath,'performance/',names{handleCount}, '.png']);

clear Xmin Xmax Ymin Ymax yData yLabelText hLegend k