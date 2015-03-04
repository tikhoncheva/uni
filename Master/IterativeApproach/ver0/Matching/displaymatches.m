%% display matching results
% img1  first image
% img2  second image
% G1 = {V,E}    first graph to match
% G2 = {V,E}    second graph to match
% M             correspondence matrix
function displaymatches(img1, G1, img2, G2, M)

  % Append images
  img3 = combine2images(img1, img2);

  % Visualize all interest points
  figure;
  imshow(img1img2)
  hold on
  plot(px1,py1,'+g','MarkerSize',5, 'LineWidth', 1.8);
  hold on
  plot(px2+size(img1,2),py2,'+g','MarkerSize',5, 'LineWidth', 1.8);

  % Visualize the N best matches
  for i=1:N
    disp(['Match',num2str(i),': dist=',num2str(SDist(i))]);
    plot( px1(SIdx(i)), py1(SIdx(i)), 'ro', 'MarkerSize',10, 'LineWidth', 2.0);
    hold on
    ht = text( px1(SIdx(i))+4, py1(SIdx(i))+12, num2str(i) );
    set(ht,'FontWeight','bold','FontSize', 2, 'Color', 'red');
    hold on
    plot( px2(Idx(SIdx(i)))+size(img1,2), py2(Idx(SIdx(i))), 'ro', 'MarkerSize', 10, 'LineWidth', 2.0);
    hold on
    ht = text( px2(Idx(SIdx(i)))+4+size(img1,2), py2(Idx(SIdx(i)))+12, num2str(i) );
    set(ht,'FontWeight','bold', 'Color', 'red');
    line([px1(SIdx(i)), px2(Idx(SIdx(i)))+size(img1,2)], [py1(SIdx(i)), py2(Idx(SIdx(i)))], 'LineWidth', 1.9,'Color','red');
  end
  
end
