function mouseclick_callback(gcbo,eventdata)
      % the arguments are not important here, they are simply required for
      % a callback function. we don't even use them in the function,
      % but Matlab will provide them to our function, we we have to
      % include them.
      %
      % first we get the point that was clicked on

      global img1
      global img2
      global frames;
      f = frames;
      global descr;
      d = descr;
      
      global initMatches;
      global newMatches;
           
      cP = get(gca,'Currentpoint');
      n = cP(1,1);
      m = cP(1,2);
      
      [m1,n1, ~] = size(img1) ;
      [m2,n2, ~] = size(img2) ;
      
      if (n>n1)
         n = n-n1;
         img = 2;
      else
         img = 1;
      end
      
      if img==1
        nn = knnsearch(f{1}(1:2,:)',[n,m]);
        feature_nn = f{1}(:,nn);
      
      else
        nn = knnsearch(f{2}(1:2,:)',[n,m]);
        feature_nn = f{2}(:,nn);
        feature_nn(1) = feature_nn(1) + n1;      
      
      end
      
      % show best match
      v1 = f{1}(1:2,:);
      v2 = f{2}(1:2,:);
      nV1 = size(f{1},2);
      nV2 = size(f{2},2);
      
      matchOld = zeros(nV1, nV2);
      matchNew = zeros(nV1, nV2);
      if (img==1)
        matchOld(nn, :) = initMatches(nn, :);
        matchNew(nn, :) = newMatches(nn, :);
      else
        matchOld(:, nn) = initMatches(:, nn);
        matchNew(:, nn) = newMatches(:,nn);          
      end
      
      plotMatches(img1,img2, v1', v2', matchNew, matchOld);
      
      
      % get corresponding descriptor of the best match      
      if img==1
        
        nn_2 = find(matchNew(nn, :));
        feature_nn_2 = f{2}(:,nn_2);
        feature_nn_2(1) = feature_nn_2(1) + n1;
      else
        nn_2 = nn;  
        feature_nn_2 = feature_nn;
        
        nn = find(matchNew(:,nn_2));
        feature_nn = f{1}(:,nn);

      end    
      
      vl_plotsiftdescriptor( d{1}(:,nn), feature_nn) ;
      vl_plotsiftdescriptor( d{2}(:,nn_2), feature_nn_2) ;
      
      set(gca,'ButtonDownFcn', @mouseclick_callback)
      set(get(gca,'Children'),'ButtonDownFcn', @mouseclick_callback)
      
      
      % cut patches
      R  = 15; % from vl_feat
      c1  = f{1}(1:2,nn);
      patch1 = imcrop(img1, [c1(1)-R, c1(2)-R, 2*R+1, 2*R+1]);
      figure
      imagesc(patch1),  colormap gray, hold off;

      c2  = f{2}(1:2,nn_2);
      patch2 = imcrop(img2, [c2(1)-R, c2(2)-R, 2*R+1, 2*R+1]);
      figure
      imagesc(patch2), colormap gray, hold off;

  end