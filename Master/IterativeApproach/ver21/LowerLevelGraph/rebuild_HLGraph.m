
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [LLG1, LLG2, HLG1, HLG2] = rebuild_HLGraph(LLG1, LLG2, HLG1, HLG2, ...
                                                    LLGmatches_it, ...
                                                    HLGmatches_it, GT, T, inverseT, gamma)           

   
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
    
%     % move anchors
%     
%      for j=1:size(HLG1.V,1)    
%          ind = find(LLG1.U(:,j)>0);
%          
%          x = sum(LLG1.V(ind,1))/ numel(ind);
%          y = sum(LLG1.V(ind,2))/ numel(ind);
%         
%          HLG1.V(j,:) = [x,y];
%      end
%      
%      for j=1:size(HLG2.V,1)    
%          ind = find(LLG2.U(:,j)>0);
%          
%          x = sum(LLG2.V(ind,1))/ numel(ind);
%          y = sum(LLG2.V(ind,2))/ numel(ind);
%         
%          HLG2.V(j,:) = [x,y];
%      end
%     
%     

end