 
function [LLG1, LLG2, LL_matches] = force1to1matching(LLG1, LLG2, LL_matches, HL_matches, T)

    V1_unique = unique(LL_matches(:,1));
    
    for i=1:numel(V1_unique)
       ind_multimatches = find(LL_matches(:,1) == V1_unique(i));
       if (numel(ind_multimatches)>=2)
          
           % 2 matches in LL but three in HL
           v_ind = V1_unique(i);
           u_ind = LL_matches(ind_multimatches,2);
           
           v = LLG1.V(v_ind, :)'; % 2 x 1
          
           v_anchors = find(LLG1.U(v_ind, :));
          
           [~, ind_anchors] = ismember(v_anchors, HL_matches(:,1));
           ind_anchors = ind_anchors(ind_anchors>0);
          
           T_candid = T(ind_anchors, :);
          
           Tv = [];
          
           for j=1:size(T_candid,1)          
               % T(j) is a [6x1] row-vector
               A = reshape(T(j,1:4), 2, 2);
               b = T(j, 5:6)';
               % projection of points LLG.V
               fV = A * v + b;
               Tv = [Tv;  fV'];
            end
          
          diff = Tv-LLG2.V(LL_matches(ind_multimatches,2),:);
          diff = sqrt(diff(:,1).^+diff(:,2).^2);
          [~, min_pos] = min(diff);
          
          bestanchor = HL_mathces(ind_anchor(min_pos), 1);
          bestanchor_pair = HL_mathces( ind_anchors(min_pos), 2);
          
          LLG1.U(v_ind,:) = 0;
          LLG1.U(v_ind, bestanchor) = 1;
          
          u_ind = LL_matches(ind_multimathces(min_pos),2);
          LLG2.U(u_ind, :) = 0;
          LLG2.U(u_ind, bestanchor_pair) = 1;
          
          % matches to delete
          matches_to_del = [ v_ind*ones(numel(ind_multimatches),1), LL_matches(ind_multimathces,2)];
          matches_to_del(matches_to_del==[v_ind, min_pos]) = [];
          LL_matches(LL_matches==matches_to_del) = [];
          
       end % if
         
    end % for all matched edges of the first graph
    

end