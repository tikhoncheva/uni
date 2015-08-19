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

plot(it, score), hold on; plot(it,score, 'bo'), hold off;
xlabel('Iteration'); ylabel('Score');set(gca,'FontSize',6);
set(legend('Score'), 'Location', 'best', 'FontSize', 6);

end
