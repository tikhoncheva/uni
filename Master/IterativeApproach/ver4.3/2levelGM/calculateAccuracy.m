%% Calculate accuracy of the Algorithm on each iteration

function Accuracy = calculateAccuracy(LLG1, LLG2, Gmatches, GT)
Accuracy = [];
extrapolation_dist = 15; 
if ~isempty(GT)
    nIt = size(Gmatches,2);

    Accuracy = zeros(1, nIt);
    Accuracy1 = zeros(1, nIt);
    for i=1:1:nIt
        TP = ismember(Gmatches(i).matched_pairs(:,1:2), GT, 'rows');
        TP = sum(TP(:));
%         Accuracy(i) = TP/ size(Gmatches(i).matched_pairs,1) * 100; % precision?
        Accuracy(i) = TP/ size(GT,1) * 100;                        % recall ???

        Initialmatches = initial_correspondences(LLG1, LLG2);
        X_GT = extrapolateGT(LLG1.V, LLG2.V, Initialmatches, GT, extrapolation_dist); % extrapolate the groundtruths
        
        X = zeros(size(LLG1.V,1), size(LLG2.V,1));
        X(sub2ind(size(X), Gmatches(i).matched_pairs(:,1), Gmatches(i).matched_pairs(:,2))) = 1;
        X = X(:);
        X_EXT = extrapolateMatchIndicator( LLG1.V, LLG2.V, Initialmatches, X, extrapolation_dist ); % extrapolate the solutions                            
        Accuracy1(i)  = (X_EXT*X_GT')/nnz(X_GT) * 100;    
    end
    

        
    
end

end