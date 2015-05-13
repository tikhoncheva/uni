
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching
% HLGmatches    result of higher level graaph matching
% matches       result of matching this two graphs
%
% new_affmatrix_HLG   updated affinity matrix for matching problem on the Higher Level

function [new_affmatrix_HLG] = rebuild_HLGraph(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches_it, HLGmatches_it, gamma)
   % rebuild connections between LLG1 and HLG1
   
   nV1 = size(LLG1.V,1);
   nV2 = size(LLG2.V,1);
   
   m = size(HLG1.V, 1);
   
   T = zeros(m, 6);
   
   for j=1:m
      
        lmatche = reshape(LLGmatches_it.lweights(j,:), nV1, nV2);
        
        [pairs(:,1), pairs(:,2)]  =  find(lmatche);
        
        x1 = LLG1.V(pairs(:,1),:);
        x2 = LLG2.V(pairs(:,2),:);
        
        % estimate affine transformation
        [H, ~] = ransacfitaffine(x1', x2', 0.005);
        
        T(j,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
        
        clear pairs;
   end

   LLG1_U_new = connect2levels2(LLG1, HLG1, LLG2, T, 0.5);
   


end