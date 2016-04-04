% Score plot
% Input
% Gmatches HLGmatches or LLGmatches

function plot_score(Gmatches)

nIt = size(Gmatches,2);
it = 1:1:nIt;

score = zeros(1, nIt);
for i=1:1:nIt
    score(i) = Gmatches(i).objval;
end

plot(it, score, 'lineWidth', 3),
hold on;
plot(it,score, 'bo', 'MarkerSize', 10), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',15);
set(legend('Score'), 'Location', 'best', 'FontSize', 15);

end
