% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%

function [T, inverseT] = affine_transformation_estimation(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches)
       
   nV1 = size(LLG1.V,1);
   nV2 = size(LLG2.V,1);
   
%    m = size(HLG1.V, 1);
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1);
   
   T = zeros(n_pairs_HL, 6);  
   
   inverseT = zeros(n_pairs_HL, 6);  
   
   for k=1:n_pairs_HL
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        ind_Vi = find(LLG1.U(:,ai));
        
        [~, ind_matched_pairs] = ismember(ind_Vi, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);
        
%         lmatche = reshape(LLGmatches_it.lweights(j,:), nV1, nV2);
%         [pairs(:,1), pairs(:,2)]  =  find(lmatche);
        
        if (size(pairs, 1)>=3)
            
            x1 = LLG1.V(pairs(:,1),:);
            x2 = LLG2.V(pairs(:,2),:);
        
            % estimate affine transformation
            [H, ~] = ransacfitaffine(x1', x2', 0.005);
        

            T(k,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            
            A = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            b = [H(1,3); H(2,3)];
            
            A_prime = pinv(A);
            b_prime = - A_prime*b;
            
            inverseT(k,:) = [A_prime(1,1) A_prime(1,2) A_prime(2,1) A_prime(2,2) b_prime(1) b_prime(2)];  
            
            
            figure,
            
                    plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'r*'), hold on;

                    V2 = LLG2.V;
                    V2(:,1) = 300 + V2(:,1);
                    plot(V2(:,1), 256-V2(:,2), 'r*');


                    plot(x1(:,1), 256-x1(:,2), 'b*'), hold on;

                    x2(:,1) = 300 + x2(:,1);
                    plot(x2(:,1), 256-x2(:,2), 'b*'), hold on;

                    edges = LLG1.E';
                    edges(end+1,:) = 1;
                    edges = edges(:);

                    points = LLG1.V(edges,:);
                    points(3:3:end,:) = NaN;

                    line(points(:,1), 256-points(:,2), 'Color', 'g');

                    edges = LLG2.E';
                    edges(end+1,:) = 1;
                    edges = edges(:);

                    points = V2(edges,:);
                    points(3:3:end,:) = NaN;

                    line(points(:,1), 256-points(:,2), 'Color', 'g');

                    fx1 = A * x1' + repmat(b,1,size(x1,1));
                    fx1 = fx1';

                    fx1_prime = fx1;
                    fx1_prime(:,1) = 300 + fx1(:,1);


                    plot(fx1_prime(:,1), 256-fx1_prime(:,2), 'm*')


                    nans = NaN * ones(size(fx1_prime,1),1) ;
                    x = [ x1(:,1) , fx1_prime(:,1) , nans ] ;
                    y = [ x1(:,2) , fx1_prime(:,2) , nans ] ; 
                    line(x', 256-y', 'Color','m') ;
                    
                    matches = pairs';

                   nans = NaN * ones(size(matches,2),1) ;
                   x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                   y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                   line(x', 256-y', 'Color','m', 'LineStyle', '--') ;


            hold off;
                
                
        end
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end


end
