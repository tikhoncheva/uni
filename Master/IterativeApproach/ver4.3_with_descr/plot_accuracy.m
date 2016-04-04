% Accuracy plot
function plot_accuracy(LLG1, LLG2, Gmatches, GT)
nIt = size(Gmatches,2);
it = 1:1:nIt;
Accuracy = calculateAccuracy(LLG1, LLG2, Gmatches, GT);    
    
plot(it, Accuracy), hold on; plot(it,Accuracy, 'bo'), hold off;
xlabel('Iteration'); ylabel('Accurasy'); set(gca,'FontSize',6)
set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end