%% Weigh nodes of the initial graphs based on the node correspondences

% for each matched subgraph pair estimate an affine transformation based
% on the node correspondences; do it both directions; assign to each
% transformation an error: error = median(dist(projection, matche))
% the quality of the subgraph pair is set to be a minimum from to errors
% (error of the affine transformation in two directions)

% + build a hierarchy of each subgraph pair for better esimation of an 
% affine transformation

% Input
%   LLG1        first graph
%   LLG2        second graph
%    U1         matrix of correspondences between nodes and anchors
%    U2         in the subgraphs
% LLMatches     correspondences between nodes of the initial graphs
% HLMatches     correspondences between anchors
% affTrafo      estimated affine transformations on the previous iterations
%
% Output
%   affTrafo    structure with the transformation matrices for each pair of
%               matched subgraphs (is given in HLMatches)


function [affTrafo, U1, U2] = weighNodes_3(LLG1, LLG2, U1, U2, ...
                                         LLmatched_pairs, HLmatched_pairs, affTrafo)

   fprintf('\n------ Estimation of affine transformation between new subgraph pairs');
   M = Inf;
   
   nPairs = size(HLmatched_pairs,1);    
   
   it = size(affTrafo,1);
   if (it == 0)
       ind_new_subgraphPairs  = [1:nPairs]';
       ind_old_subgraphPairs = [];
       nNewT = nPairs;
   else
       ind_new_subgraphPairs  = find(HLmatched_pairs(:,3) == 0);
       ind_old_subgraphPairs  = [1:nPairs];
       ind_old_subgraphPairs(ind_new_subgraphPairs) = [];
       nNewT = numel(ind_new_subgraphPairs);   
       T_old = affTrafo{it};
   end
   
   T = zeros(nPairs, 15);  

   % eliminate subgraphs with less than 1 node
   ind_feas_anchors = ~(sum(U1,1)==1);
   ind_subg_to_del = find(sum(U1,1) == 1);
   for i = 1:numel(ind_subg_to_del)   
       ai = ind_subg_to_del(i);

       ind_Vai = find(U1(:,ai));
       Vai = LLG1.V(ind_Vai,1:2);      % coordinates of the nodes in the subgraph G_ai

       if ~isempty(Vai)   % it can happen, that nodes were already adjust to the new anchors
           new_U1_cut = U1(:,ind_feas_anchors);
           [ind_feas_neighb, ~]= find(new_U1_cut);
           ind_feas_neighb = unique(ind_feas_neighb);

           nn_Vai = knnsearch(LLG1.V(ind_feas_neighb,1:2), Vai, 'K', 1);   %indices of nodes in LLG2.V
           nn_Vai = ind_feas_neighb(nn_Vai);
           U1(ind_Vai, :) = U1(nn_Vai, :);
       end
   end   
   clear i ai ind_feas_anchors ind_feas_neighb ind_subg_to_del ind_Vai Vai nn_Vai;
   
   ind_feas_anchors = ~(sum(U2,1)==1);
   ind_subg_to_del = find(sum(U2,1) == 1);
   for j = 1:numel(ind_subg_to_del)   
       aj = ind_subg_to_del(j);

       ind_Vaj = find(U2(:,aj));
       Vaj = LLG2.V(ind_Vaj,1:2);      % coordinates of the nodes in the subgraph G_ai

       if ~isempty(Vaj)   % it can happen, that nodes were already adjust to the new anchors
           new_U2_cut = U2(:,ind_feas_anchors);
           [ind_feas_neighb, ~]= find(new_U2_cut);
           ind_feas_neighb = unique(ind_feas_neighb);

           nn_Vaj = knnsearch(LLG2.V(ind_feas_neighb,1:2), Vaj, 'K', 1);   %indices of nodes in LLG2.V
           nn_Vaj = ind_feas_neighb(nn_Vaj);
           U2(ind_Vaj, :) = U2(nn_Vaj, :);
       end
   end
   clear j aj ind_feas_anchors ind_feas_neighb ind_subg_to_del ind_Vai Vai nn_Vai;
   
   %% estimate Transformation for new or changed subgraphs pairs
   for k = 1:nNewT
       
        ai = HLmatched_pairs(ind_new_subgraphPairs(k),1); % \in HLG1.V
        aj = HLmatched_pairs(ind_new_subgraphPairs(k),2); % \in HLG2.V
        
        ind_Vai = find(U1(:,ai));
        
        [~, ind_matched_nodes] = ismember(ind_Vai, LLmatched_pairs(:,1));
        ind_matched_nodes = ind_matched_nodes(ind_matched_nodes>0);
        matched_nodes = LLmatched_pairs(ind_matched_nodes,1:2);
      
        if (size(matched_nodes, 1)>1) % (size(matched_nodes, 1)>3)
            
            Vai_m = LLG1.V(matched_nodes(:,1),1:2);
            Vaj_m = LLG2.V(matched_nodes(:,2),1:2);
              
            % from left to rigth
            [~, Ai, bi] = ransac_cdf(Vai_m, Vaj_m, 0.8, 0.5);
%             [~, Ai, bi] = ransac_afftrafo(Vai_m, Vaj_m, 0.8, 0.5);
            
            PVai_m = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1)); % proejction of Vai_m nodes
            PVai_m = PVai_m';
            err_vect1 = sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2);
                
            H = [[Ai, bi];[0 0 1]]; 
%             err1 = quantile(err_vect1, 0.25); 
            err1 = median(err_vect1);
            
            
            % from right to left
            [~, Aj, bj] = ransac_cdf(Vaj_m, Vai_m, 0.6, 0.5);
%             [~, Aj, bj] = ransac_afftrafo(Vaj_m, Vai_m, 0.8, 0.5);
            
            PVaj_m = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of Vaj_m nodes
            PVaj_m = PVaj_m'; 
            err_vect2 = sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2);  
            
            inverseH = [[Aj, bj];[0 0 1]];    
%             err2 = quantile(err_vect2, 0.25); %median(err_vect2);
            err2 = median(err_vect2);
            
            %% calculate summary error of the estimated transformation
            [err, better_estimated_T] = min([err1, err2]);
            switch better_estimated_T    
                case 1
                    Aj = pinv(Ai);
                    bj = - Aj*bi;    
                    inverseH = [[Aj, bj]; [0 0 1]];             
                case 2
                    Ai = pinv(Aj);
                    bi = - Ai*bj;   
                    H = [[Ai, bi]; [0 0 1]];                
            end   
                
            PVai_m1 = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1)); % proejction of Vai_m nodes
            PVai_m1 = PVai_m1';
            PVaj_m1 = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of Vaj_m nodes
            PVaj_m1 = PVaj_m1';            
            
            %% Save new transformation matrix
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = err;
            T(ind_new_subgraphPairs(k), 4:9) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            T(ind_new_subgraphPairs(k), 10:15) = [inverseH(1,1) inverseH(1,2) inverseH(2,1) inverseH(2,2) inverseH(1,3) inverseH(2,3)];
            
%       figure; subplot(1,2,1);
%                     m = 450;
%                     plot(LLG1.V(:,1), m-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
% 
%                     V2 = LLG2.V; V2(:,1) = m + V2(:,1);
%                     plot(V2(:,1), m-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
% 
%                     plot(Vai_m(:,1), m-Vai_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     Vaj_m(:,1) = m + Vaj_m(:,1);
%                     plot(Vaj_m(:,1), m-Vaj_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     
%                     
%                     Tx1 = PVai_m;
%                     Tx1(:,1) = m + Tx1(:,1);
%                     plot(Tx1(:,1), m-Tx1(:,2), 'm*')
% 
% 
%                     nans = NaN * ones(size(Tx1,1),1) ;
%                     x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
%                     y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
%                     line(x', m-y', 'Color','m', 'LineStyle', '-') ;
%                     
%                     Tx1 = PVai_m1; Tx1(:,1) = m + Tx1(:,1);
%                     nans = NaN * ones(size(Tx1,1),1) ;
%                     x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
%                     y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
%                     line(x', m-y', 'Color','c','LineStyle', '-') ;
%                     
%                     
%                     matches = matched_nodes';
%                     nans = NaN * ones(size(matches,2),1) ;
%                     x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                     y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                     line(x', m-y', 'Color','m', 'LineStyle', '--') ;
%                     
%                     title(sprintf('Error=%0.3f', err1));                   
%                     % ---------------------------------------------------- %
%               subplot(1,2,2);
% 
%                     plot(LLG1.V(:,1), m-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
%                     plot(V2(:,1), m-V2(:,2), 'ro', 'MarkerFaceColor','r');
%                     
%                     plot(Vai_m(:,1), m-Vai_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     plot(Vaj_m(:,1), m-Vaj_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                     
%                     Tx2 = PVaj_m;
%                     plot(Tx2(:,1), m-Tx2(:,2), 'm*')
%                     
%                     nans = NaN * ones(size(Tx2,1),1) ;
%                     x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
%                     y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
%                     line(x', m-y', 'Color','m', 'LineStyle', '-') ;
% 
%                     Tx2 = PVaj_m1;
%                     nans = NaN * ones(size(Tx2,1),1) ;
%                     x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
%                     y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
%                     line(x', m-y', 'Color','c', 'LineStyle', '-') ;                    
%                     
%                     nans = NaN * ones(size(matches,2),1) ;
%                     x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                     y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                     line(x', m-y', 'Color','m', 'LineStyle', '--') ;    
%                     
%                     title(sprintf('Error=%0.3f', err2));
%                     
%             hold off;           
        else % if (size(matched_nodes, 1)<3) it is impossible to estimate affine transformation
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = M;
        end % if each of subgraphs have at least tree nodes matched
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end
   
   %% for unchanged subgraphs copy transformation matrices from the previos
   % iteration
   for k = 1:numel(ind_old_subgraphPairs)
       aiaj = HLmatched_pairs(ind_old_subgraphPairs(k),1:2);
       [~, ind_aiaj_T_old] = ismember(aiaj, T_old(:,1:2), 'rows');
       assert(ind_aiaj_T_old~=0, 'cannot copy transformation matrix from previous iteration, because there is now such anchor match');
       T(ind_old_subgraphPairs(k),:) = T_old(ind_aiaj_T_old,:);
   end
   
   affTrafo{it+1,1} = T;

end
