 
function [LLG1, LLG2, LL_matches] = force1to1matching(LLG1, LLG2, LL_matches, HL_matches, T, GT)

    V1_unique = unique(LL_matches(:,1));
    
    for i=1:numel(V1_unique)
       ind_multimatches = find(LL_matches(:,1) == V1_unique(i));
       if (numel(ind_multimatches)>=2)
           
           n_multimatches = numel(ind_multimatches);
          
           % 2 matches in LL but three in HL
           v_ind = V1_unique(i);
           v = LLG1.V(v_ind, :)'; % 2 x 1
           
           u_ind = LL_matches(ind_multimatches,2);
           u = LLG2.V(u_ind,:); % ...x 2
           
           u = LLG2.V(GT(GT(:,1)==v_ind,2),:);
           u = repmat(u, n_multimatches,1);

          
%            v_anchors = find(LLG1.U(v_ind, :));
           

%                [~, u_anchors] = find(LLG2.U(u_ind,:));
%                u_anchors = unique(u_anchors);   
%                u_anchors = reshape(unique(u_anchors), 1, numel(u_anchors));               
%                all_pos_anchor_pairs = [repmat(v_anchors', numel(u_anchors),1), ...
%                                        kron(u_anchors', ones(numel(v_anchors),1))];
%                
%                ind_matched_anchors = ismember(HL_matches, all_pos_anchor_pairs, 'rows');

          
%             [~, ind_matched_anchors] = ismember(v_anchors, HL_matches(:,1));
%             ind_matched_anchors = ind_matched_anchors(ind_matched_anchors>0);
            
           ind_matched_anchors = LL_matches(ind_multimatches,3);                 
           
           T_candid = T(ind_matched_anchors, :);
          
           Tv = [];
          
           for j=1:size(T_candid,1)          
               % T(j) is a [6x1] row-vector
               A = reshape(T(j,1:4), 2, 2);
               b = T(j, 5:6)';
               % projection of points LLG.V
               fV = A * v + b;
               Tv = [Tv;  fV'];
            end
          
          diff = Tv-u;
          diff = sqrt(diff(:,1).^2+diff(:,2).^2);
          [~, min_pos] = min(diff);
          
          bestanchor_pair = HL_matches(ind_matched_anchors(min_pos), :);
%           bestanchor_pair = HL_matches( ind_matched_anchors(min_pos), 2);
          
          LLG1.U(v_ind,:) = 0;
          LLG1.U(v_ind, bestanchor_pair(1)) = 1;
          
          u_ind = LL_matches(ind_multimatches(min_pos),2);
          LLG2.U(u_ind, :) = 0;
          LLG2.U(u_ind, bestanchor_pair(2)) = 1;
          
          % matches to delete
          matches_to_del = [ v_ind*ones(numel(ind_multimatches),1), LL_matches(ind_multimatches,2)];
          tmp = (matches_to_del(:,1:2)==repmat([v_ind, u_ind], n_multimatches,1));
          matches_to_del(tmp(:,1)-tmp(:,2)==0,:) = [];
          ind_matches_to_del = ismember(LL_matches(:,1:2), matches_to_del, 'rows');
          LL_matches(ind_matches_to_del, :) = [];
          
       end % if
         
    end % for all matched edges of the first graph
    
end