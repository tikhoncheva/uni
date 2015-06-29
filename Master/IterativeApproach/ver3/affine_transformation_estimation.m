% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

function [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches)
       
   nV1 = size(LLG1.V,1);
   nV2 = size(LLG2.V,1);
   
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1);
   
   T = zeros(n_pairs_HL, 6);  
   
   inverseT = zeros(n_pairs_HL, 6);  
   
   % list of problematic nodes (nodes, that were not matched oder were matched wrong)
   listV1 = []; listV2 = [];
   
   for k=1:n_pairs_HL
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        ind_Vai = find(HLG1.U(:,ai));
        ind_Vaj = find(HLG2.U(:,aj));
        
        [~, ind_matched_pairs] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);
        
%         list1 = [list1, ind_matched_pairs(ind_matched_pairs==0)];

        X1 = LLG1.V(ind_Vai,:);
        X2 = LLG2.V(ind_Vaj,:);
        
        
        
        if (size(pairs, 1)>=3)
            
            x1 = LLG1.V(pairs(:,1),:);
            x2 = LLG2.V(pairs(:,2),:);
            
            X1 = LLG1.V(pairs(:,1),:);
            X2 = LLG2.V(pairs(:,1),:);
            
            matched_nodes_Gai = ismember(ind_Vai, pairs(:,1));
            matched_nodes_Gaj = ismember(ind_Vaj, pairs(:,2));
            
            X1 = [X1; LLG1.V(~matched_nodes_Gai, 1:2)];
            X2 = [X2; zeros(sum(~matched_nodes_Gai),2)];

            X1 = [X1; zeros(sum(~matched_nodes_Gaj),2)];
            X2 = [X2; LLG2.V(~matched_nodes_Gaj, 1:2)];            
        
            % estimate affine transformation
            [H, inliers] = ransacfitaffine(x1', x2', 0.01);
        

            T(k,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            
            A = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            b = [H(1,3); H(2,3)];
            
            A_prime = pinv(A);
            b_prime = - A_prime*b;
            
            inverseT(k,:) = [A_prime(1,1) A_prime(1,2) A_prime(2,1) A_prime(2,2) b_prime(1) b_prime(2)];  

            
            Prx1 = A * x1' + repmat(b,1,size(x1,1));             % proejction of x1 nodes
            Prx1 = Prx1';
            Prx2 = A_prime * x2' + repmat(b_prime,1,size(x2,1)); % projection of x2 nodes
            Prx2 = Prx2';
            
            % calculate summary error of the estimated transformation
            err1 = sum(sqrt((x1(:,1)-Prx2(:,1)).^2+(x1(:,2)-Prx2(:,2)).^2))/size(pairs, 1);            
            err2 = sum(sqrt((x1(:,1)-Prx2(:,1)).^2+(x1(:,2)-Prx2(:,2)).^2))/size(pairs, 1);            
            err = err1 + err2;

            
            
            PrX1 = A * X1' + repmat(b,1,size(X1,1));             % proejction of x1 nodes
            PrX1 = PrX1';
            PrX2 = A_prime * X2' + repmat(b_prime,1,size(X2,1)); % projection of x2 nodes
            PrX2 = PrX2';
            
            
            figure; subplot(1,2,1);
            
                    plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;

                    V2 = LLG2.V;
                    V2(:,1) = 300 + V2(:,1);
                    plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');


                    plot(X1(:,1), 256-X1(:,2), 'bo', 'MarkerFaceColor','b'), hold on;

                    X2(:,1) = 300 + X2(:,1);
                    plot(X2(:,1), 256-X2(:,2), 'bo', 'MarkerFaceColor','b'), hold on;

                    edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
                    points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
                    line(points(:,1), 256-points(:,2), 'Color', 'g');

                    edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
                    points = V2(edges,:); points(3:3:end,:) = NaN;
                    line(points(:,1), 256-points(:,2), 'Color', 'g');

                    Tx1 = PrX1;
                    Tx1(:,1) = 300 + Tx1(:,1);
                    plot(Tx1(:,1), 256-Tx1(:,2), 'm*')


                    nans = NaN * ones(size(Tx1,1),1) ;
                    x = [ X1(:,1) , Tx1(:,1) , nans ] ;
                    y = [ X1(:,2) , Tx1(:,2) , nans ] ; 
                    line(x', 256-y', 'Color','m') ;
                    
                    matches = pairs';

                   nans = NaN * ones(size(matches,2),1) ;
                   x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                   y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                   line(x', 256-y', 'Color','m', 'LineStyle', '--') ;
                   title(sprintf('Transformation error %.03f', err1));
                   
                   % ---------------------------------------------------- %
                   subplot(1,2,2);

                   plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
                   plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');

                   edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
                   points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
                   line(points(:,1), 256-points(:,2), 'Color', 'g');

                   edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
                   points = V2(edges,:); points(3:3:end,:) = NaN;
                   line(points(:,1), 256-points(:,2), 'Color', 'g');


                   plot(X1(:,1), 256-X1(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                   plot(X2(:,1), 256-X2(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                   

                   Tx2 = PrX2;
                   plot(Tx2(:,1), 256-Tx2(:,2), 'm*')

                   nans = NaN * ones(size(Tx2,1),1) ;
                   x = [ X2(:,1) , Tx2(:,1) , nans ] ;
                   y = [ X2(:,2) , Tx2(:,2) , nans ] ; 
                   line(x', 256-y', 'Color','m') ;
                    
                   matches = pairs';
                   nans = NaN * ones(size(matches,2),1) ;
                   x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                   y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                   line(x', 256-y', 'Color','m', 'LineStyle', '--') ;                   
                    
                   title(sprintf('Transformation error %.03f', err2));
            hold off;
                
              
        end
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end


end
