%% Weigh nodes of the initial graphs based on the node correspondences

% for each matched subgraph pair estimate an affine transformation based
% on the node correspondences; do it both directions; assign to each
% transformation an error: error = median(dist(projection, matche))
% the quality of the subgraph pair is set to be a minimum from to errors
% (error of the affine transformation in two directions)

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


function [affTrafo, U1, U2] = weighNodes_nonrigid(LLG1, LLG2, U1, U2, ...
                                         LLmatched_pairs, HLmatched_pairs, affTrafo)

   fprintf('\n------ Estimation of affine transformation between new subgraph pairs');
   M = Inf;
   
%     % Init full set of options %%%%%%%%%%
%     opt.method='nonrigid'; % use nonrigid registration
%     opt.beta=2;            % the width of Gaussian kernel (smoothness)
%     opt.lambda=3;          % regularization weight
% 
%     opt.viz=0;              % show every iteration
%     opt.outliers=0;         % don't account for outliers
%     opt.fgt=0;              % do not use FGT (default)
%     opt.normalize=1;        % normalize to unit variance and zero mean before registering (default)
%     opt.corresp=0;          % compute correspondence vector at the end of registration (not being estimated by default)
% 
%     opt.max_it=100;         % max number of iterations
%     opt.tol=1e-8;           % tolerance
%     opt.scale=0;            % fixed scale
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
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
   
   T = zeros(nPairs, 21);  
   
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
   %

   % estimate Transformation for new or changed subgraphs pairs
   for k = 1:nNewT
       
        ai = HLmatched_pairs(ind_new_subgraphPairs(k),1); % \in HLG1.V
        aj = HLmatched_pairs(ind_new_subgraphPairs(k),2); % \in HLG2.V
       
        ind_Vai = find(U1(:,ai));
        ind_Vaj = find(U2(:,aj));
        
        [~, ind_matched_nodes] = ismember(ind_Vai, LLmatched_pairs(:,1));
        ind_matched_nodes = ind_matched_nodes(ind_matched_nodes>0);
        matched_nodes = LLmatched_pairs(ind_matched_nodes,1:2);
      
        if (size(matched_nodes, 1)>4) % (size(matched_nodes, 1)>1)
            
            Vai_m = LLG1.V(matched_nodes(:,1),1:2);
            Vaj_m = LLG2.V(matched_nodes(:,2),1:2);
                   
            % estimate projective transformation  
            
            % using RANSAC by Peter Kovesi
            x1 = [Vai_m(:,1)'; Vai_m(:,2)'; ones(1,size(Vai_m,1))];
            x2 = [Vaj_m(:,1)'; Vaj_m(:,2)'; ones(1,size(Vaj_m,1))];    

            t = .001;  % Distance threshold for deciding outliers
            [H, inliers] = ransacfithomography(x1, x2, t);
            
            % using MATLAb built-in function
%             H1 = estimateGeometricTransform(Vai_m,Vaj_m, 'projective');    
%             H = H1.T';
            
            Z1     =  H(3,1)*Vai_m(:,1)+H(3,2)*Vai_m(:,2)+H(3,3);           
            PVai_m = [H(1,1)*Vai_m(:,1)+H(1,2)*Vai_m(:,2)+H(1,3), ...
                      H(2,1)*Vai_m(:,1)+H(2,2)*Vai_m(:,2)+H(2,3)];
            PVai_m = PVai_m./repmat(Z1,1,2);

%             [Transform, ~]=cpd_register(Vaj_m, Vai_m, opt); 
%             PVai_m = Transform.Y;        
%             G=cpd_G(Vai_m,Vai_m,opt.beta); % Construct affinity matrix G
%             PVai_m1 = Vai_m + G*Transform.W;
%             if opt.normalize
%                 PVai_m1 = PVai_m1*Transform.normal.xscale+repmat(Transform.normal.xd,size(Vai_m,1),1);
%             end
                       
            % from right to left 
            
            % using RANSAC by Peter Kovesi
            x1 = [Vaj_m(:,1)'; Vaj_m(:,2)'; ones(1,size(Vaj_m,1))];
            x2 = [Vai_m(:,1)'; Vai_m(:,2)'; ones(1,size(Vai_m,1))];    

            t = .001;  % Distance threshold for deciding outliers
            [inverseH, inliers] = ransacfithomography(x1, x2, t);
            
            % using MATLAb built-in function       
%             H2 = estimateGeometricTransform(Vaj_m, Vai_m, 'projective');
%             inverseH = H2.T';

            Z2     =  inverseH(3,1)*Vaj_m(:,1)+inverseH(3,2)*Vaj_m(:,2)+inverseH(3,3);
            PVaj_m = [inverseH(1,1)*Vaj_m(:,1)+inverseH(1,2)*Vaj_m(:,2)+inverseH(1,3), ...
                      inverseH(2,1)*Vaj_m(:,1)+inverseH(2,2)*Vaj_m(:,2)+inverseH(2,3)];
            PVaj_m = PVaj_m./repmat(Z2,1,2);
            
            
%             [Transform, ~]=cpd_register(Vai_m, Vaj_m, opt); 
%             PVaj_m = Transform.Y;                        
%             G=cpd_G(Vaj_m,Vaj_m,opt.beta); % Construct affinity matrix G
%             PVaj_m1 = Vaj_m + G*Transform.W;
          
            
            % calculate summary error of the estimated transformation
            err1 = median(sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2));    
            err2 = median(sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2));           
            
            [err, better_estimated_T] = min([err1, err2]);
%             switch better_estimated_T    
%                 case 1
%                     Aj = pinv(Ai);
%                     bj = - Aj*bi;    
%                     inverseH = [[Aj, bj]; [0 0 1]];             
%                 case 2
%                     Ai = pinv(Aj);
%                     bi = - Ai*bj;   
%                     H = [[Ai, bi]; [0 0 1]];                
%             end

            Z1     =  H(3,1)*Vai_m(:,1)+H(3,2)*Vai_m(:,2)+H(3,3);           
            PVai_m1 = [H(1,1)*Vai_m(:,1)+H(1,2)*Vai_m(:,2)+H(1,3), ...
                      H(2,1)*Vai_m(:,1)+H(2,2)*Vai_m(:,2)+H(2,3)];
            PVai_m1 = PVai_m1./repmat(Z1,1,2);

            Z2     =  inverseH(3,1)*Vaj_m(:,1)+inverseH(3,2)*Vaj_m(:,2)+inverseH(3,3);
            PVaj_m1 = [inverseH(1,1)*Vaj_m(:,1)+inverseH(1,2)*Vaj_m(:,2)+inverseH(1,3), ...
                      inverseH(2,1)*Vaj_m(:,1)+inverseH(2,2)*Vaj_m(:,2)+inverseH(2,3)];
            PVaj_m1 = PVaj_m1./repmat(Z2,1,2);    

%             PVai_m1 = PVai_m;
%             PVaj_m1 = PVaj_m;
            
            % Save new transformation matrix
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = err;
            T(ind_new_subgraphPairs(k), 4:12) = H(:)';
            T(ind_new_subgraphPairs(k), 13:21) = inverseH(:)';
            
      figure; subplot(1,2,1);
                    m = 450;
                    plot(LLG1.V(:,1), m-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;

                    V2 = LLG2.V; V2(:,1) = m + V2(:,1);
                    plot(V2(:,1), m-V2(:,2), 'ro', 'MarkerFaceColor','r');


                    plot(Vai_m(:,1), m-Vai_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                    Vaj_m(:,1) = m + Vaj_m(:,1);
                    plot(Vaj_m(:,1), m-Vaj_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                    
                    
                    Tx1 = PVai_m;
                    Tx1(:,1) = m + Tx1(:,1);
                    plot(Tx1(:,1), m-Tx1(:,2), 'm*')


                    nans = NaN * ones(size(Tx1,1),1) ;
                    x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
                    y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
                    line(x', m-y', 'Color','m', 'LineStyle', '-') ;
                    
                    Tx1 = PVai_m1; Tx1(:,1) = m + Tx1(:,1);
                    nans = NaN * ones(size(Tx1,1),1) ;
                    x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
                    y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
                    line(x', m-y', 'Color','c','LineStyle', '-') ;
                    
                    
                    matches = matched_nodes';
                    nans = NaN * ones(size(matches,2),1) ;
                    x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                    y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                    line(x', m-y', 'Color','m', 'LineStyle', '--') ;
                    
                    title(sprintf('Error=%0.3f', err1));                   
                    % ---------------------------------------------------- %
              subplot(1,2,2);

                    plot(LLG1.V(:,1), m-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
                    plot(V2(:,1), m-V2(:,2), 'ro', 'MarkerFaceColor','r');
                    
                    plot(Vai_m(:,1), m-Vai_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                    plot(Vaj_m(:,1), m-Vaj_m(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                    
                    Tx2 = PVaj_m;
                    plot(Tx2(:,1), m-Tx2(:,2), 'm*')
                    
                    nans = NaN * ones(size(Tx2,1),1) ;
                    x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
                    y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
                    line(x', m-y', 'Color','m', 'LineStyle', '-') ;

                    Tx2 = PVaj_m1;
                    nans = NaN * ones(size(Tx2,1),1) ;
                    x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
                    y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
                    line(x', m-y', 'Color','c', 'LineStyle', '-') ;                    
                    
                    nans = NaN * ones(size(matches,2),1) ;
                    x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                    y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                    line(x', m-y', 'Color','m', 'LineStyle', '--') ;    
                    
                    title(sprintf('Error=%0.3f', err2));
                    
            hold off;           
        else % if (size(matched_nodes, 1)<3) it is impossible to estimate affine transformation
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = M;
        end % if each of subgraphs have at least tree nodes matched
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end
   
   % for unchanged subgraphs copy transformation matrices from the previos
   % iteration
   for k = 1:numel(ind_old_subgraphPairs)
       aiaj = HLmatched_pairs(ind_old_subgraphPairs(k),1:2);
       [~, ind_aiaj_T_old] = ismember(aiaj, T_old(:,1:2), 'rows');
       assert(ind_aiaj_T_old~=0, 'cannot copy transformation matrix from previous iteration, because there is now such anchor match');
       T(ind_old_subgraphPairs(k),:) = T_old(ind_aiaj_T_old,:);
   end
   
   affTrafo{it+1,1} = T;

end
