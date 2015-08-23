% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%


function [HLG1, HLG2] = update_subgraphs(LLG1, LLG2, HLG1, HLG2, ...
                                         LLGmatches, HLGmatches, affTrafo)
   fprintf('\n------ Rearrange subgraphs');

   old_U1 = HLG1.U;
   old_U2 = HLG2.U;
   
   nV1 = size(LLG1.V,1); nV2 = size(LLG2.V,1);
   nA1 = size(HLG1.V,1); nA2 = size(HLG2.V,1);
   
   %% Class: initial labels of the nodes
   ind_initLab1 = find(HLG1.U');
   [initLab1, ~] = ind2sub(size(HLG1.U'), ind_initLab1);
   initLab1 = initLab1'; % 1xn1
   
   ind_initLab2 = find(HLG2.U');
   [initLab2, ~] = ind2sub(size(HLG2.U'), ind_initLab2);
   initLab2 = initLab2'; % 1xn2
   
   %% Unary: cost of the label lj for the node ui
   alpha = 0.2; 
   M = 1000;
   % distance of the nodes to the anchors
   D1_1 = pdist2(LLG1.V(:,1:2), HLG1.V(:,1:2));
   D2_1 = pdist2(LLG2.V(:,1:2), HLG2.V(:,1:2));
   
   % error between the node projections and matches
   D1_2 = M * ones(nV1, nA1);
   D2_2 = M * ones(nV2, nA2);
   
   ind_mV1 = LLGmatches.matched_pairs(:,1);
   ind_mV2 = LLGmatches.matched_pairs(:,2); 
   
   mV1 = LLG1.V(ind_mV1, 1:2);
   mV2 = LLG2.V(ind_mV2, 1:2);
   
   for k = 1:size(affTrafo,1)
       ai = affTrafo(k,1);
       aj = affTrafo(k,2);
       
       H = affTrafo(k, 4:9);
       invH = affTrafo(k, 10:15);
            
       Pr_mV1 = [H(1), H(2); H(3), H(4)] * mV1' + repmat([H(5);H(6)],1,size(mV1,1));
       Pr_mV1 = Pr_mV1';
       Pr_mV2 = [invH(1), invH(2); invH(3), invH(4)] * mV2' + repmat([invH(5);invH(6)],1,size(mV2,1));
       Pr_mV2 = Pr_mV2';
       
       D1_2(ind_mV1,ai) = sqrt((mV2(:,1)-Pr_mV1(:,1)).^2+(mV2(:,2)-Pr_mV1(:,2)).^2) ...
                        + sqrt((Pr_mV2(:,1)-mV1(:,1)).^2+(Pr_mV2(:,2)-mV1(:,2)).^2);
       D2_2(ind_mV2,aj) = D1_2(ind_mV1,ai);
   end
   
   unary1 = alpha*D1_1' + (1-alpha)*D1_2'; % nA1xnV1
   unary2 = alpha*D2_1' + (1-alpha)*D2_2'; % nA2xnV2
   
   
   %% Pairwise: Adjacency matrix of the graphs
   pairwise1 = sparse(LLG1.E(:,1), LLG1.E(:,2),ones(size(LLG1.E,1),1));
   pairwise2 = sparse(LLG2.E(:,1), LLG2.E(:,2),ones(size(LLG2.E,1),1));
   
   %% Labelcost:
   ind_HLG1_E = sub2ind([nA1,nA1], HLG1.E(:,1), HLG1.E(:,2));
   labelcost1 = zeros(nA1);
   labelcost1(ind_HLG1_E) = 1;
   
   ind_HLG2_E = sub2ind([nA2,nA2], HLG2.E(:,1), HLG2.E(:,2));
   labelcost2 = zeros(nA2);
   labelcost2(ind_HLG2_E) = 1;
   
   %% Apply Graph Cut   
   [Lab1, E1, E1_new] = GCMex(initLab1, single(unary1), pairwise1, single(labelcost1),0); % use swap
   [Lab2, E2, E2_new] = GCMex(initLab2, single(unary2), pairwise2, single(labelcost2),0); % use swap

   
   %% new correspondence matrix between nodes and anchors
   ind_Lab1 = sub2ind([nV1, nA1], [1:nV1]', Lab1);
   new_U1 = false(nV1, nA1);
   new_U1(ind_Lab1) = true;
   HLG1.U = new_U1;
  
   ind_Lab2 = sub2ind([nV2, nA2], [1:nV2]', Lab2);
   new_U2 = false(nV2, nA2);
   new_U2(ind_Lab2) = true;
   HLG2.U = new_U2;
   
   %% mark anchors if corresponding subgraphs didn't changed
   F1 = HLG1.F;
   diff_U1 = abs(new_U1 - old_U1);
   F1(logical(sum(diff_U1))) = 0;

   F2 = HLG2.F;
   diff_U2 = abs(new_U2 - old_U2);
   F2(logical(sum(diff_U2))) = 0;   
   
   HLG1.F = F1;
   HLG2.F = F2;
      

end
