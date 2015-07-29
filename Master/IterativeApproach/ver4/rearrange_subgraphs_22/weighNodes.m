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
%
% Output
%   affTrafo    structure with the transformation matrices for each pair of
%               matched subgraphs (is given in HLMatches)
%     W1        weights of the nodes in LLG1
%     W2        weights of the nodes in LLG2


function [affTrafo, W1, W2] = weighNodes(LLG1, LLG2, U1, U2, ...
                                         LLMatches, HLMatches)

   fprintf('\n------ Estimation of affine transformation between subgraphs');
   
   nPairs = size(HLMatches.matched_pairs,1);    
   
   T = zeros(nPairs, 6);  
   Tinverse = zeros(nPairs, 6);  
   
   M = Inf;
   W1 = ones(size(LLG1.V,1),1)*M; % assume first that all nodes are unmatched
   W2 = ones(size(LLG2.V,1),1)*M;
   
   for k=1:nPairs
       
        ai = HLMatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLMatches.matched_pairs(k,2); % \in HLG2.V
       
        ind_Vai = find(U1(:,ai));
        ind_Vaj = find(U2(:,aj));
        
        [~, ind_matched_nodes] = ismember(ind_Vai, LLMatches.matched_pairs(:,1));
        ind_matched_nodes = ind_matched_nodes(ind_matched_nodes>0);
        matched_nodes = LLMatches.matched_pairs(ind_matched_nodes,1:2);
      
        if (size(matched_nodes, 1)>=3)
            
            Vai_m = LLG1.V(matched_nodes(:,1),:);
            Vaj_m = LLG2.V(matched_nodes(:,2),:);
                   
            % estimate affine transformation  
            
            % from left to right
            [H, ~] = ransacfitaffine(Vai_m', Vaj_m', 0.01);        
            T(k,:) = [H(1,1) H(1,2) H(2,1) H(2,2) H(1,3) H(2,3)];
            Ai = [[H(1,1) H(1,2)];[H(2,1) H(2,2)]];
            bi = [H(1,3); H(2,3)];
                       
            % from right to left
            [inverseH, ~] = ransacfitaffine(Vaj_m', Vai_m', 0.01);

            Tinverse(k,:) = [inverseH(1,1) inverseH(1,2) inverseH(2,1) inverseH(2,2) inverseH(1,3) inverseH(2,3)];
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
                    Tinverse(k,:) = [Aj(1,1) Aj(1,2) Aj(2,1) Aj(2,2) bj(1) bj(2)];                    
                case 2
                    Ai = pinv(Aj);
                    bi = - Ai*bj;                    
                    T(k,:) = [Ai(1,1) Ai(1,2) Ai(2,1) Ai(2,2) bi(1) bi(2)];                    
            end
            
            % calculate summary error of the estimated transformation
            W1(matched_nodes(:,1)) = err;
            W2(matched_nodes(:,2)) = err;
        
        end % if each of subgraphs have at least tree nodes matched
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end


    affTrafo = struct('T', T, 'Tinverse', Tinverse);

end
