
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [LLG1, LLG2, HLG1, HLG2, T] = rebuild_HLGraph(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches_it, HLGmatches_it, GT, gamma)
   
   nV1 = size(LLG1.V,1);
   nV2 = size(LLG2.V,1);
   
   m = size(HLG1.V, 1);
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   m = size(HLGmatches_it.matched_pairs,1);
   
   T = zeros(m, 6);  
   inverseT = zeros(m, 6);  
   for j=1:m
        lmatche = reshape(LLGmatches_it.lweights(j,:), nV1, nV2);
        
        [pairs(:,1), pairs(:,2)]  =  find(lmatche);
%         pairs2 = [];
%         for i=1:size(pairs,1)
%             p = find(GT.LLpairs(:,1)==pairs(i,1));       
%             pairs2 = [pairs2; GT.LLpairs(p,:)];
%         end
%         pairs = pairs2;
        
        if (size(pairs, 1)>=3)
            x1 = LLG1.V(pairs(:,1),:);
            x2 = LLG2.V(pairs(:,2),:);
        
            % estimate affine transformation
            [H, ~] = ransacfitaffine(x1', x2', 0.005);
        

            T(j,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            
            A = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            b = [H(1,3); H(2,3)];
            
            A_prime = pinv(A);
            b_prime = - A_prime*b;
            
            inverseT(j,:) = [A_prime(1,1) A_prime(1,2) A_prime(2,1) A_prime(2,2) b_prime(1) b_prime(2)];  
            
            
%             figure,
%             
%                     plot(LLG1.V(:,1), 6-LLG1.V(:,2), 'r*'), hold on;
% 
%                     V2 = LLG2.V;
%                     V2(:,1) = 8 + V2(:,1);
%                     plot(V2(:,1), 6-V2(:,2), 'r*');
% 
% 
%                     plot(x1(:,1), 6-x1(:,2), 'b*'), hold on;
% 
%                     x2(:,1) = 8 + x2(:,1);
%                     plot(x2(:,1), 6-x2(:,2), 'b*'), hold on;
% 
%                     edges = LLG1.E';
%                     edges(end+1,:) = 1;
%                     edges = edges(:);
% 
%                     points = LLG1.V(edges,:);
%                     points(3:3:end,:) = NaN;
% 
%                     line(points(:,1), 6-points(:,2), 'Color', 'g');
% 
%                     edges = LLG2.E';
%                     edges(end+1,:) = 1;
%                     edges = edges(:);
% 
%                     points = V2(edges,:);
%                     points(3:3:end,:) = NaN;
% 
%                     line(points(:,1), 6-points(:,2), 'Color', 'g');
% 
%                     fx1 = A * x1' + repmat(b,1,size(x1,1));
%                     fx1 = fx1';
% 
%                     fx1_prime = fx1;
%                     fx1_prime(:,1) = 8 + fx1(:,1);
% 
% 
%                     plot(fx1_prime(:,1), 6-fx1_prime(:,2), 'm*')
% 
% 
%                     nans = NaN * ones(size(fx1_prime,1),1) ;
%                     x = [ x1(:,1) , fx1_prime(:,1) , nans ] ;
%                     y = [ x1(:,2) , fx1_prime(:,2) , nans ] ; 
%                     line(x', 6-y', 'Color','m') ;
%                     
%                     matches = pairs';
% 
%                    nans = NaN * ones(size(matches,2),1) ;
%                    x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                    y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                    line(x', 6-y', 'Color','m', 'LineStyle', '--') ;
% 
% 
%             hold off;
                
                
        end
        clear pairs;
   end
   
   gamma = 0.5;
   % rebuild connections between LLG and HLG
%    LLG1_U_new = connect2levels2(LLG1, HLG1, LLG2.V, HLGmatches_it.matched_pairs, ...
%                                                     LLGmatches_it.matched_pairs, T, gamma);
%                                                 
%    LLG2_U_new = connect2levels2(LLG2, HLG2, LLG1.V, [HLGmatches_it.matched_pairs(:,2), HLGmatches_it.matched_pairs(:,1)], ...
%                                                     [LLGmatches_it.matched_pairs(:,2), LLGmatches_it.matched_pairs(:,1)], ...
%                                                     inverseT, gamma);
   
   % using Ground truth to decide, how correct is estimated transformations
   
   LLG1_U_new = connect2levels2(LLG1, HLG1, LLG2.V, HLGmatches_it.matched_pairs, ...
                                                    GT.LLpairs, T, gamma);
                                                
   LLG2_U_new = connect2levels2(LLG2, HLG2, LLG1.V, [HLGmatches_it.matched_pairs(:,2), HLGmatches_it.matched_pairs(:,1)], ...
                                                    [GT.LLpairs(:,2), GT.LLpairs(:,1)], ...
                                                    inverseT, gamma);
                                                
    LLG1.U = LLG1_U_new;
    LLG2.U = LLG2_U_new;
    
    % move anchors
    
     for j=1:size(HLG1.V,1)    
         ind = find(LLG1.U(:,j)>0);
         
         x = sum(LLG1.V(ind,1))/ numel(ind);
         y = sum(LLG1.V(ind,2))/ numel(ind);
        
         HLG1.V(j,:) = [x,y];
     end
     
     for j=1:size(HLG2.V,1)    
         ind = find(LLG2.U(:,j)>0);
         
         x = sum(LLG2.V(ind,1))/ numel(ind);
         y = sum(LLG2.V(ind,2))/ numel(ind);
        
         HLG2.V(j,:) = [x,y];
     end
    
    

end