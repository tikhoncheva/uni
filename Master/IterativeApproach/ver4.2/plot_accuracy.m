% Accuracy plot
function plot_accuracy(Gmatches, GT)
nIt = size(Gmatches,2);
it = 1:1:nIt;

accuracy = zeros(1, nIt);
for i=1:1:nIt
    TP = ismember(Gmatches(i).matched_pairs(:,1:2), GT, 'rows');
    TP = sum(TP(:));
%     accuracy(i) = TP/ size(Gmatches(i).matched_pairs,1) * 100;
    accuracy(i) = TP/ size(GT,1) * 100;
    if i>1
        ind = ismember(Gmatches(i).matched_pairs(:,1:2), ...
                       Gmatches(i-1).matched_pairs(:,1:2));
    end
end
    
    
plot(it, accuracy), hold on; plot(it,accuracy, 'bo'), hold off;
xlabel('Iteration'); ylabel('Accurasy'); set(gca,'FontSize',6)
set(legend('Accurasy'), 'Location', 'best', 'FontSize', 6);
end