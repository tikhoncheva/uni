function [aff_sim_HL, aff_sim_LL] = affine_transformation_similarity(...
                                            LLG1, LLG2, HLG1, HLG2, ...
                                            matches_LL, matches_HL, T, GT)
                                        
   nV1 = size(LLG1.V,1);
   nV2 = size(LLG2.V,1);
   
   nA1 = size(HLG1.V,1);
   nA2 = size(HLG2.V,1);
   
   aff_sim_LL = Inf(1, nV1*nV2);
   aff_sim_HL = Inf(1, nA1*nA2);
   
   anchors_nodes_corrmatrix1 = zeros(nV1, nA1);
   anchors_nodes_corrmatrix1(matches_LL(:,1),:) = LLG1.U(matches_LL(:,1),:);
   
   mA = size(T, 1);  % number of matches anchors = number of estimated affine transformations  
   assert( mA == size(matches_HL,1), ...
       'number of matches anchors != number of estimated affine transformations');
     
   for j=1:mA
       
        % anchor node, match  ai <-> aj
        ai = matches_HL(j,1);
        aj = matches_HL(j,2);
       
        if (sum(T(j,:))>0)

            % T(j) is a [6x1] row-vector
            A = reshape(T(j, 1:4), 2, 2);
            b = T(j, 5:6)';
            
            % indices of nodes corresponding to anchor ai
            ind_nodes_ai = find(anchors_nodes_corrmatrix1(:,ai));
            [~, ind_nodes_ai_m] = ismember(ind_nodes_ai, matches_LL(:,1));
            ind_nodes_aj = matches_LL(ind_nodes_ai_m,2);
            
            % projection of points corresponding to anchor ai
            n = size(ind_nodes_ai, 1);
            T_Vai = A * LLG1.V(ind_nodes_ai,:)' + repmat(b,1,n);
            T_Vai = T_Vai';
            
            % matches of those points
            M_Vai = LLG2.V(ind_nodes_aj,:);
            
            % ground truth of those points
            [~, ind_in_GT] = ismember(ind_nodes_ai, GT.LLpairs(:,1));
            GT_Vai = LLG2.V( GT.LLpairs(ind_in_GT, 1), :);
            
            % distance between projections and found matches            
%             diff = single(sqrt( (M_Vai(:,1) - T_Vai(:,1)).^2 + ...
%                                 (M_Vai(:,2) - T_Vai(:,2)).^2) );
%          
            diff1 = single(sqrt( (M_Vai(:,1) - GT_Vai(:,1)).^2 + ...
                                 (M_Vai(:,2) - GT_Vai(:,2)).^2) );    
            diff2 = single(sqrt( (T_Vai(:,1) - GT_Vai(:,1)).^2 + ...
                                 (T_Vai(:,2) - GT_Vai(:,2)).^2) );     
            diff =  diff1 + diff2;

            diff_sum = sum(diff(:));
            
            aff_sim_HL((aj-1)*nA1 + ai) = diff_sum / n;
            
            ind = (ind_nodes_aj-1)*nV1 + ind_nodes_ai;  
            aff_sim_LL(ind) = diff;
            
        end
   end 
    
   
   aff_sim_HL = exp(-aff_sim_HL);
%    aff_sim_HL = aff_sim_HL/sum(aff_sim_HL(:));
   
   aff_sim_LL = exp(-aff_sim_LL);
%    aff_sim_LL = aff_sim_LL/sum(aff_sim_LL(:));

end