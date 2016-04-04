% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

function [Ti, Tj, W1, W2] = affine_transformation_estimation(LLG1, LLG2, U1, U2, ...
                                               LLGmatches, HLGmatches) 

   fprintf('\n---- Estimation of affine transformation between subgraphs');

%    tic 
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1);
   
   Ti = zeros(n_pairs_HL, 6);  
   Tj = zeros(n_pairs_HL, 6);  
   
   for k=1:n_pairs_HL
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        ind_Vai = find(U1(:,ai));
        ind_Vaj = find(U2(:,aj));
        
        [~, ind_matched_pairs] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);

        X1 = LLG1.V(ind_Vai,:);
        X2 = LLG2.V(ind_Vaj,:);
        
        
        
        if (size(pairs, 1)>=3)
            
            Vai_m = LLG1.V(pairs(:,1),:);
            Vaj_m = LLG2.V(pairs(:,2),:);
                   
            % estimate affine transformation  
            
            % from left to right
%             H1 = fitgeotrans(Vai_m, Vaj_m, 'affine');
%             H1 = estimateGeometricTransform(Vai_m,Vaj_m,'affine');
%             H = H1.T';            
            [H, ~] = ransacfitaffine(Vai_m', Vaj_m', 0.01);        
            Ti(k,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            Ai = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            bi = [H(1,3); H(2,3)];
            
%             A_prime = pinv(A);
%             b_prime = - A_prime*b;
            
            % from right to left
%             H2 = fitgeotrans(Vaj_m, Vai_m, 'affine');
%             H2 = estimateGeometricTransform(Vaj_m,Vai_m,'affine');
%             inverseH = H2.T';
            [inverseH, ~] = ransacfitaffine(Vaj_m', Vai_m', 0.01);
% %             inverseT(k,:) = [A_prime(1,1) A_prime(1,2) A_prime(2,1) A_prime(2,2) b_prime(1) b_prime(2)];  
            Tj(k,:) = [inverseH(1,1) inverseH(1,2) inverseH(2,1) inverseH(2,2) inverseH(1,3) inverseH(2,3)];
            Aj = [[inverseH(1,1)  inverseH(1,2)];[inverseH(2,1) inverseH(2,2)]];
            bj = [ inverseH(1,3); inverseH(2,3)];     
            
            PVai_m = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1)); % proejction of Vai_m nodes
            PVai_m = PVai_m';
            PVaj_m = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of Vaj_m nodes
            PVaj_m = PVaj_m';
            
            % calculate summary error of the estimated transformation
            err1 = median(sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2));    
            err2 = median(sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2));
            
            [~, better_estimated_T] = min([err1, err2]);
            switch better_estimated_T    
                case 1
                    Aj = pinv(Ai);
                    bj = - Aj*bi;                    
                    Tj(k,:) = [Aj(1,1) Aj(1,2) Aj(2,1) Aj(2,2) bj(1) bj(2)];                    
                case 2
                    Ai = pinv(Aj);
                    bi = - Ai*bj;                    
                    Ti(k,:) = [Ai(1,1) Ai(1,2) Ai(2,1) Ai(2,2) bi(1) bi(2)];                    
            end
            
            
            
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
%                     Tx1 = PVai_m;
%                     Tx1(:,1) = 300 + Tx1(:,1);
%                     plot(Tx1(:,1), 256-Tx1(:,2), 'm*')
% 
% 
%                     nans = NaN * ones(size(Tx1,1),1) ;
%                     x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
%                     y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
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
%                     Tx2 = PVaj_m;
%                     plot(Tx2(:,1), 256-Tx2(:,2), 'm*')
%                     
%                     Vaj_m(:,1) = 300 + Vaj_m(:,1);
%                     nans = NaN * ones(size(Tx2,1),1) ;
%                     x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
%                     y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
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

%    display(sprintf('Summary %.03f sec', toc));
%    display(sprintf('==================================================\n'));
end
