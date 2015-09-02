% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

% Assume, that we have anchor correspondence (ak; ap); ak\in HLG1.V; ap\in HLG2.V
% According to the estimated transformation between the subgraphs G_ak,
% G_ap we can place G_ak over G_ap in the second graph. The nodes in LLG2.V,
% that are not included in G_ap, but covered by the projection of G_ap can be 
% included in G_ap
% The decision to include a node into subgraph is based on the distance 
% between the node and the closest node of the projections

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

      err = affTrafo(k, 3);
      
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
      ind = dist_aj>0.1;
      dist_aj(ind) = [];
      nn_PVai(ind) = [];  
      
      % for the multiple entries of one node select the one with smallest
      % distance
      tmp = [nn_PVai, dist_aj];
      [~,ind] = sort(tmp(:,2));
      [~,ia] = unique(tmp(ind,1));
      tmp = tmp(ind(ia),:);

      new_U2(uint8(tmp(:,1)), aj) = tmp(:,2);   
      
      % Project Vaj into LLG1.V
      PVaj = Aj * Vaj' + repmat(bj,1,size(Vaj,1)); % projection of Vaj_nm nodes
      PVaj = PVaj';
      % find nearest neighbors of the projected nodes      
      [nn_PVaj, dist_ai] = knnsearch(LLG1.V(:,1:2), PVaj);   %indices of nodes in LLG1.V   
      ind = dist_ai>0.1;
      dist_ai(ind) = [];
      nn_PVaj(ind) = [];      
      
      % for the multiple entries of one node select the one with smallest
      % distance
      tmp = [nn_PVaj, dist_ai];
      [~,ind] = sort(tmp(:,2));
      [~,ia] = unique(tmp(ind,1));
      tmp = tmp(ind(ia),:);

      new_U1(uint8(tmp(:,1)), ai) = tmp(:,2);
      
%       figure; subplot(1,2,1);
%             
%                     plot(LLG1.V(:,1), 8-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
% 
%                     V2 = LLG2.V; V2(:,1) = 8 + V2(:,1);
%                     plot(V2(:,1), 8-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
% 
%                     plot(Vai(:,1), 8-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     Vaj(:,1) = 8 + Vaj(:,1);
%                     plot(Vaj(:,1), 8-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     
%                     
%                     plot(V2(nn_PVai,1), 8-V2(nn_PVai,2), 'ko', 'MarkerFaceColor','k');
%                     
%                     Tx1 = PVai;
%                     Tx1(:,1) = 8 + Tx1(:,1);
%                     plot(Tx1(:,1), 8-Tx1(:,2), 'm*')
% 
% 
%                     nans = NaN * ones(size(Tx1,1),1) ;
%                     x = [ Vai(:,1) , Tx1(:,1) , nans ] ;
%                     y = [ Vai(:,2) , Tx1(:,2) , nans ] ; 
%                     line(x', 8-y', 'Color','m') ;
%                     
%                     title(sprintf('Error=%0.3f', err));
% 
%               subplot(1,2,2);
% 
%                     plot(LLG1.V(:,1), 8-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
%                     plot(V2(:,1), 8-V2(:,2), 'ro', 'MarkerFaceColor','r');
%                     
%                     plot(Vai(:,1), 8-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     plot(Vaj(:,1), 8-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                    
%                     plot(LLG1.V(nn_PVaj,1), 8-LLG1.V(nn_PVaj,2), 'ko', 'MarkerFaceColor','k');
%                     
%                     Tx2 = PVaj;
%                     plot(Tx2(:,1), 8-Tx2(:,2), 'm*')
%                     
%                     nans = NaN * ones(size(Tx2,1),1) ;
%                     x = [ Vaj(:,1) , Tx2(:,1) , nans ] ;
%                     y = [ Vaj(:,2) , Tx2(:,2) , nans ] ; 
%                     line(x', 8-y', 'Color','m') ;
%                     
%             hold off;
        clear ai aj Ai Aj bi bj Ti Tj err ind_Vai ind_Vaj Vai Vaj;
        clear PVai PVaj dist_ai dist_aj nn_PVai nn_PVaj;
        clear ia ind tmp;
   end
   
%    D1 = pdist2(LLG1.V, HLG1.V);
%    D2 = pdist2(LLG2.V, HLG2.V);
%    
%    new_U1 = 0.5*(new_U1+D1);
%    new_U2 = 0.5*(new_U2+D2);
   
   % new correspondence matrix between nodes and anchors
   [W1, minpos] = min(new_U1, [], 2); 
   ind_U1_not_assigned = (W1==Inf);
   [~, minpos(ind_U1_not_assigned)] = max(old_U1(ind_U1_not_assigned,:), [], 2);
   ind_V1 = (1:nV1)'; %ind_V1(ind_U1_not_assigned) = [];  minpos(ind_U1_not_assigned) = [];
   ind = sub2ind(size(HLG1.U), ind_V1, minpos);
   
   new_U1(:) = 0;
   new_U1(ind) = 1;
   new_U1(ind_U1_not_assigned,:) = old_U1(ind_U1_not_assigned,:);
   
   HLG1.U = logical(new_U1);
 
   H1 = [minpos, W1];
   if ~isempty(HLG1.H) && sum(ind_U1_not_assigned)>0
      H1(ind_U1_not_assigned, 2) = HLG1.H(ind_U1_not_assigned,end);
      H1(ind_U1_not_assigned, 1) = HLG1.H(ind_U1_not_assigned,end-1);
   end
   HLG1.H = [HLG1.H, H1];
   
   
   [W1, minpos] = min(HLG1.H(:, 2:2:end), [], 2);
   minpos = 2*minpos-1;
   minpos = HLG1.H(sub2ind(size(HLG1.H), (1:nV1)', minpos));
   
   ind_V1 = (1:nV1)'; 
   ind = sub2ind(size(HLG1.U), ind_V1, minpos);
   
   new_U1(:) = 0;
   new_U1(ind) = 1;   
   
   HLG1.U = logical(new_U1);
  
   % new correspondence matrix between nodes and anchors
   [W2, minpos] = min(new_U2, [], 2); 
   ind_U2_not_assigned = (W2==Inf);
   [~, minpos(ind_U2_not_assigned)] = max(old_U2(ind_U2_not_assigned,:), [], 2);
   ind_V2 = (1:nV2)'; %ind_V2(ind_U2_not_assigned) = [];  minpos(ind_U2_not_assigned) = [];
   ind = sub2ind(size(HLG2.U), ind_V2, minpos);
   
   new_U2(:) = 0;
   new_U2(ind) = 1;
   new_U2(ind_U2_not_assigned,:) = old_U2(ind_U2_not_assigned,:);
   
   HLG2.U = logical(new_U2);
   
   H2 = [minpos, W2]; 
   if ~isempty(HLG2.H) && sum(ind_U2_not_assigned)>0
      H2(ind_U2_not_assigned, 2) = HLG2.H(ind_U2_not_assigned,end);
      H2(ind_U2_not_assigned, 1) = HLG2.H(ind_U2_not_assigned,end-1);
   end
   HLG2.H = [HLG2.H, H2];   
   
   [W2, minpos] = min(HLG2.H(:, 2:2:end), [], 2);
   minpos = 2*minpos-1;
   minpos = HLG2.H(sub2ind(size(HLG2.H), (1:nV2)', minpos));
   
   ind_V2 = (1:nV2)'; 
   ind = sub2ind(size(HLG2.U), ind_V2, minpos);
   
   new_U2(:) = 0;
   new_U2(ind) = 1;
   
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
