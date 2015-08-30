handleCount = handleCount+1; h(handleCount) = figure(handleCount);
hold on;
for k = 1:length(methods)
    plot(settings{Con}{4}, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
    
end
% errorbar(settings{Con}{4}, yData(:,end), L(:,end), U(:,end));

Xmin = min(settings{Con}{4}); Xmax = max(settings{Con}{4});
Ymin = min(yData(:)); Ymax = max(yData(:));
axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);
xlabel([plotSet.font settings{Con}{2}], 'FontSize', plotSet.fontSize);
ylabel([plotSet.font yLabelText], 'FontSize', plotSet.fontSize);
for k = 1:length(Fix)
    text(Xmin+0.1*(Xmax-Xmin), Ymin+0.1*(length(Fix)-k+1)*(Ymax-Ymin), ...
        [plotSet.font settings{Fix(k)}{2} ' = ' num2str(settings{Fix(k)}{4})], ...
        'FontSize', plotSet.fontSize);
end

hLegend = legend(methods(:).strName);
set(hLegend, 'Location', 'best')

for k = length(methods):-1:1
    plot(settings{Con}{4}, yData(:,k), ...
        'LineWidth', plotSet.lineWidth, ...
        'Color', methods(k).color, ...
        'LineStyle', methods(k).lineStyle, ...
        'Marker', methods(k).marker, ...
        'MarkerSize', plotSet.markerSize);
end
hold off;

clear Xmin Xmax Ymin Ymax yData L U yLabelText hLegend k