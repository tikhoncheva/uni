% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

function [T, inverseT, W1, W2] = affine_transformation_estimation(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches) 

   display(sprintf('\n================================================'));
   display(sprintf('Estimation of affine transformation between subgraphs'));
   display(sprintf('=================================================='));

   tic 
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1);
   
   T = zeros(n_pairs_HL, 6);  
   inverseT = zeros(n_pairs_HL, 6);  
   
   W1 = zeros(size(LLG1.V,1),1);
   W2 = zeros(size(LLG2.V,1),1);
   
   for k=1:n_pairs_HL
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        ind_Vai = find(HLG1.U(:,ai));
        ind_Vaj = find(HLG2.U(:,aj));
        
        [~, ind_matched_pairs] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);

        X1 = LLG1.V(ind_Vai,:);
        X2 = LLG2.V(ind_Vaj,:);
        
        
        
        if (size(pairs, 1)>=3)
            
            x1 = LLG1.V(pairs(:,1),:);
            x2 = LLG2.V(pairs(:,2),:);
                   
            % estimate affine transformation
            [H, ~] = ransacfitaffine(x1', x2', 0.01);
        
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
            
            
%             figure; subplot(1,2,1);
%             
%                     plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
% 
%                     V2 = LLG2.V;
%                     V2(:,1) = 300 + V2(:,1);
%                     plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
% 
%                     plot(X1(:,1), 256-X1(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
% 
%                     X2(:,1) = 300 + X2(:,1);
%                     plot(X2(:,1), 256-X2(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
% 
%                    
%                     edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
%                     points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
%                     line(points(:,1), 256-points(:,2), 'Color', 'g');
% 
%                     edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
%                     points = V2(edges,:); points(3:3:end,:) = NaN;
%                     line(points(:,1), 256-points(:,2), 'Color', 'g');
% 
%                     Tx1 = Prx1;
%                     Tx1(:,1) = 300 + Tx1(:,1);
%                     plot(Tx1(:,1), 256-Tx1(:,2), 'm*')
% 
% 
%                     nans = NaN * ones(size(Tx1,1),1) ;
%                     x = [ x1(:,1) , Tx1(:,1) , nans ] ;
%                     y = [ x1(:,2) , Tx1(:,2) , nans ] ; 
%                     line(x', 256-y', 'Color','m') ;
%                     
%                     matches = pairs';
% 
%                     nans = NaN * ones(size(matches,2),1) ;
%                     x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                     y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                     line(x', 256-y', 'Color','m', 'LineStyle', '--') ;
%                    
%                     % ---------------------------------------------------- %
%                     subplot(1,2,2);
% 
%                     plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
%                     plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
%                     edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
%                     points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
%                     line(points(:,1), 256-points(:,2), 'Color', 'g');
% 
%                     edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
%                     points = V2(edges,:); points(3:3:end,:) = NaN;
%                     line(points(:,1), 256-points(:,2), 'Color', 'g');
% 
% 
%                     plot(X1(:,1), 256-X1(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     plot(X2(:,1), 256-X2(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                    
% 
%                     Tx2 = Prx2;
%                     plot(Tx2(:,1), 256-Tx2(:,2), 'm*')
%                     
%                     x2(:,1) = 300 + x2(:,1);
%                     nans = NaN * ones(size(Tx2,1),1) ;
%                     x = [ x2(:,1) , Tx2(:,1) , nans ] ;
%                     y = [ x2(:,2) , Tx2(:,2) , nans ] ; 
%                     line(x', 256-y', 'Color','m') ;
%                     
%                     matches = pairs';
%                     nans = NaN * ones(size(matches,2),1) ;
%                     x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                     y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                     line(x', 256-y', 'Color','m', 'LineStyle', '--') ;                   
%                     
%             hold off;
        
        end % if each of subgraphs have at least tree nodes matched
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end

   display(sprintf('Summary %.03f sec', toc));
   display(sprintf('==================================================\n'));
end
