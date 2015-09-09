function plotMatches(method, problem, accuracy, score, X)

    figure;
    
    img1 = problem.cdata.view(1).img;
    img2 = problem.cdata.view(2).img;

    LLG1 = problem.LLG1;
    LLG2 = problem.LLG2;
    [matches(:,1), matches(:,2)] = find(reshape(X, size(LLG1.V,1), size(LLG2.V,1)));
    GT = problem.cdata.GT;
    ind_TP = ismember(matches, GT, 'rows');

    n1 = size(img1,2);                      % width of the first image
    img3 = combine2images(img1,img2);       % plot two concatenated images
    imagesc(img3) ; hold on ; axis off;
    title(sprintf('%s score:%.3f accuracy:%.3f', method(9:end), score, accuracy));
    
    LLG2.V(:,1) = n1 + LLG2.V(:,1);	% shift x-coordinates of the second graphs

    plot(LLG1.V(:,1), LLG1.V(:,2), 'ko', 'MarkerFaceColor', 'k'); 
    plot(LLG2.V(:,1), LLG2.V(:,2), 'ko', 'MarkerFaceColor', 'k'); 

    nans = NaN * ones(size(matches,1),1) ;
    x = [ LLG1.V(matches(:,1),1) , LLG2.V(matches(:,2),1) , nans ] ;
    y = [ LLG1.V(matches(:,1),2) , LLG2.V(matches(:,2),2) , nans ] ; 
    line(x', y', 'Color', 'r', 'LineWidth', 2) ;


    nans = NaN * ones(size(matches(ind_TP,1:2),1),1) ;
    x = [ LLG1.V(matches(ind_TP,1),1) , LLG2.V(matches(ind_TP,2),1) , nans ] ;
    y = [ LLG1.V(matches(ind_TP,1),2) , LLG2.V(matches(ind_TP,2),2) , nans ] ; 
    line(x', y', 'Color', 'b', 'LineWidth', 2) ;

hold off;
end
