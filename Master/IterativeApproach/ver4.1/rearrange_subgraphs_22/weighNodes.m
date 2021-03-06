%% Weigh nodes of the initial graphs based on the node correspondences

% - for each matched subgraph pair estimate an affine transformation based
% on the node correspondences
% - for each node v in the first subgraph calculate the weight w as
%   an error between projected Point Tv and the correspondence Mv of v
%   do the same for the nodes in the second subgraphs, but use the inverse
%   transformation
%   the weight of an unmatched node is set to be M=const

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


function [affTrafo] = weighNodes(LLG1, LLG2, U1, U2, ...
                                         LLmatched_pairs, HLmatched_pairs, affTrafo)

   fprintf('\n------ Estimation of affine transformation between new subgraph pairs');
   
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

   % estimate Transformation for new or changed subgraphs pairs
   for k = 1:nNewT
       
        ai = HLmatched_pairs(ind_new_subgraphPairs(k),1); % \in HLG1.V
        aj = HLmatched_pairs(ind_new_subgraphPairs(k),2); % \in HLG2.V
       
        ind_Vai = find(U1(:,ai));
        ind_Vaj = find(U2(:,aj));
        
        [~, ind_matched_nodes] = ismember(ind_Vai, LLmatched_pairs(:,1));
        ind_matched_nodes = ind_matched_nodes(ind_matched_nodes>0);
        matched_nodes = LLmatched_pairs(ind_matched_nodes,1:2);
      
        if (size(matched_nodes, 1)>=3)
            
            Vai_m = LLG1.V(matched_nodes(:,1),:);
            Vaj_m = LLG2.V(matched_nodes(:,2),:);
                   
            % estimate affine transformation  
            
            % from left to right
%             H1 = fitgeotrans(Vai_m, Vaj_m, 'affine');
            H1 = estimateGeometricTransform(Vai_m,Vaj_m,'affine');
            H = H1.T'; 
%             [H, ~] = ransacfitaffine(Vai_m', Vaj_m', 0.01);        

            Ai = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            bi = [H(1,3); H(2,3)];
                       
            % from right to left
%             H2 = fitgeotrans(Vaj_m, Vai_m, 'affine');
            H2 = estimateGeometricTransform(Vaj_m,Vai_m,'affine');
            inverseH = H2.T';
%             [inverseH, ~] = ransacfitaffine(Vaj_m', Vai_m', 0.01);

            Aj = [[inverseH(1,1)  inverseH(1,2)];[inverseH(2,1) inverseH(2,2)]];
            bj = [ inverseH(1,3); inverseH(2,3)];     
                        
            PVai_m = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1)); % proejction of Vai_m nodes
            PVai_m = PVai_m';
            PVaj_m = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of Vaj_m nodes
            PVaj_m = PVaj_m';
            
            % calculate summary error of the estimated transformation
            err1 = median(sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2));    
            err2 = median(sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2));           
            
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
            
            % Save new transformation matrix
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = err;
            T(ind_new_subgraphPairs(k), 4:9) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            T(ind_new_subgraphPairs(k), 10:15) = [inverseH(1,1) inverseH(1,2) inverseH(2,1) inverseH(2,2) inverseH(1,3) inverseH(2,3)];
        else % if (size(matched_nodes, 1)<3) it is impossible to estimate affine transformation
            T(ind_new_subgraphPairs(k), 1:2) = [ai, aj];
            T(ind_new_subgraphPairs(k), 3) = Inf;
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
       T(ind_aiaj_T_old,:) = T_old(ind_aiaj_T_old,:);
   end
   
   affTrafo{it+1,1} = T;

end
