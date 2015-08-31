% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

% Rule 1:
% if the aff.transformation between graphs is reliable, for all nodes in
% both subgraphs add their nearest neighbors (according to the transformattion)
% in the opposite subgraph

% Rule 2:
% If some subgraph consists of less than 3 nodes, assign the nodes of
% the subgraph to the anchor, to which the nearest neighbors of this nodes
% belong to

function [HLG1, HLG2] = update_subgraphs_2(LLG1, LLG2, HLG1, HLG2, ...
                                         LLGmatches, HLGmatches, affTrafo)
   fprintf('\n------ Rearrange subgraphs');

   nV1 = size(LLG1.V, 1);  nV2 = size(LLG2.V, 1);
   
   old_U1 = HLG1.U;
   old_U2 = HLG2.U;
   
   new_U1 = Inf*ones(size(old_U1));
   new_U2 = Inf*ones(size(old_U2));
   
   for k = 1:size(affTrafo,1)
      ai = affTrafo(k,1); 
      aj = affTrafo(k,2);

      Ti = affTrafo(k, 4:9);         % transformation from G_ai into G_aj
      Tj = affTrafo(k, 10:15);       % transformation from G_aj into G_ai (inverse Ti)      
      
      Ai = [[Ti(1) Ti(2)]; [Ti(3) Ti(4)]]; % transformation Tx = Ax+b
      bi = [ Ti(5); Ti(6)];

      Aj = [[Tj(1) Tj(2)]; [Tj(3) Tj(4)]];
      bj = [ Tj(5); Tj(6)];
      
      ind_Vai = HLG1.U(:,ai);
      ind_Vaj = HLG2.U(:,aj);
      
      Vai = LLG1.V(ind_Vai,1:2);      % coordinates of the nodes in the subgraph G_ai
      Vaj = LLG2.V(ind_Vaj,1:2);      % coordinates of the nodes in the subgraph G_aj      
      
      % Project Vai into LLG2.V
      PVai = Ai * Vai' + repmat(bi,1,size(Vai,1)); % proejction of Vai_nm nodes
      PVai = PVai';
      % find nearest neighbors of the projected nodes
      [nn_PVai, dist_aj] = knnsearch(LLG2.V(:,1:2), PVai);   %indices of nodes in LLG2.V
      new_U2(nn_PVai, aj) = dist_aj;
      
      % Project Vaj into LLG1.V
      PVaj = Aj * Vaj' + repmat(bj,1,size(Vaj,1)); % projection of Vaj_nm nodes
      PVaj = PVaj';
      % find nearest neighbors of the projected nodes      
      [nn_PVaj, dist_ai] = knnsearch(LLG1.V(:,1:2), PVaj);   %indices of nodes in LLG1.V     
      new_U1(nn_PVaj, ai) = dist_ai;         
   end
   
%    D1 = pdist2(LLG1.V, HLG1.V);
%    D2 = pdist2(LLG2.V, HLG2.V);
%    
%    new_U1 = 0.5*(new_U1+D1);
%    new_U2 = 0.5*(new_U2+D2);
   
   % new correspondence matrix between nodes and anchors
   [W1, minpos] = min(new_U1, [], 2);
   ind_U1_not_assigned = (W1==Inf);
   ind_V1 = (1:nV1)'; ind_V1(ind_U1_not_assigned) = [];  minpos(ind_U1_not_assigned) = [];
   ind = sub2ind(size(HLG1.U), ind_V1, minpos);
   
   new_U1(:) = 0;
   new_U1(ind) = 1;
   new_U1(ind_U1_not_assigned,:) = old_U1(ind_U1_not_assigned,:);
   
   HLG1.U = logical(new_U1);
  
   % new correspondence matrix between nodes and anchors
   [W2, minpos] = min(new_U2, [], 2);
   ind_U2_not_assigned = (W2==Inf);
   ind_V2 = (1:nV2)'; ind_V2(ind_U2_not_assigned) = [];  minpos(ind_U2_not_assigned) = [];
   ind = sub2ind(size(HLG2.U), ind_V2, minpos);
   
   new_U2(:) = 0;
   new_U2(ind) = 1;
   new_U2(ind_U2_not_assigned,:) = old_U2(ind_U2_not_assigned,:);
   
   HLG2.U = logical(new_U2);

   % mark anchors if corresponding subgraphs didn't changed
   F1 = HLG1.F;
   diff_U1 = abs(new_U1 - old_U1);
   F1(logical(sum(diff_U1))) = 0;

   F2 = HLG2.F;
   diff_U2 = abs(new_U2 - old_U2);
   F2(logical(sum(diff_U2))) = 0;   
   
   HLG1.F = F1;
   HLG2.F = F2;
   
end
