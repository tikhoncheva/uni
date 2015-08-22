% calculate energy gap between optimal solution and used  
function energy_gap(LLG1, LLG2, solution, GT)

nIt = size(solution,2);
f = zeros(1, nIt);

opt_score = matching_score_LL(LLG1,LLG2, GT);
for i = 1:nIt
   score = solution(i).objval;
   
   f(i) = abs(score-opt_score)/(abs(score) + 1^(-10));
    
end

figure;hold on;
plot([1:nIt], f, ...
    'LineWidth', 2, ...
    'Color', 'b', ...
    'LineStyle', '-', ...
    'Marker', 'x', ...
    'MarkerSize',10);

Xmin = 1; Xmax = nIt;
Ymin = 0; Ymax = max(f(:));

axis([Xmin Xmax Ymin-0.02*(Ymax-Ymin) Ymax+0.02*(Ymax-Ymin)]);

xlabel('Iteration', 'FontSize', 13);
ylabel('Gap', 'FontSize', 13);

hold off;

clear Xmin Xmax Ymin Ymax 

end