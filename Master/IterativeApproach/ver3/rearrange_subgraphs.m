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

function [HLG1, HLG2] = rearrange_subgraphs(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, T, inverseT)
       
   display(sprintf('\n================================================'));
   display(sprintf('Rearrange subgraphs'));
   display(sprintf('=================================================='));
   
   tic
   
   nV1 = size(LLG1.V, 1);
   nV2 = size(LLG2.V, 1);
   
   new_HLG1_U = 0.5*double(HLG1.U); 
   new_HLG2_U = 0.5*double(HLG2.U); 
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1); 
   
   error_eps = 1.0;
   nswap = 3;
   
   for k=1:n_pairs_HL
       
        ai = HLGmatches.matched_pairs(k,1); % \in HLG1.V
        aj = HLGmatches.matched_pairs(k,2); % \in HLG2.V
       
        
        ind_Vai = find(HLG1.U(:,ai));
        ind_Vaj = find(HLG2.U(:,aj));
        
        [~, ind_matched_pairs] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
        ind_matched_pairs = ind_matched_pairs(ind_matched_pairs>0);
        pairs = LLGmatches.matched_pairs(ind_matched_pairs,1:2);

        Vai = LLG1.V(ind_Vai,:);      % indices of nodes in the subgraph G_ai
        Vaj = LLG2.V(ind_Vaj,:);      % indices of nodes in the subgraph G_aj
        
        
        if (size(pairs, 1)>=3)
            
            Vai_m = LLG1.V(pairs(:,1),:);  % matched nodes in the subgraph G_ai
            Vaj_m = LLG2.V(pairs(:,2),:);  % matched nodes in the subgraph G_aj
                          
            Ti = T(k, :);             % transformation from G_ai into G_aj
            Tj = inverseT(k,:);       % transformation from G_aj into G_ai (inverse Ti)
            
            Ai = [[Ti(1) Ti(2)]; [Ti(3) Ti(4)]]; % transformation Tx = Ax+b
            bi = [ Ti(5); Ti(6)];
            
            Aj = [[Tj(1) Tj(2)]; [Tj(3) Tj(4)]];
            bj = [ Tj(5); Tj(6)];
            

            
            PVai_m = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1));             % proejction of Vai_m nodes
            PVai_m = PVai_m';
            PVaj_m = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of x2 nodes
            PVaj_m = PVaj_m';
            
            % calculate summary error of the estimated transformation
            err1 = median(sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2));    
            err2 = median(sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2));
            err = 0.5*(err1 + err2);
                        
            if (err<error_eps)  % Rule 1

                PVai = Ai * Vai' + repmat(bi,1,size(Vai,1)); % proejction of Vai_nm nodes
                PVai = PVai';
                PVaj = Aj * Vaj' + repmat(bj,1,size(Vaj,1)); % projection of Vaj_nm nodes
                PVaj = PVaj';

                % calculate the nearest neighbours of the projections and
                % include them into corresponding graphs
                [nn_PVai, nn_PVai_dist] = knnsearch(LLG2.V, PVai);   %indices of nodes in LLG2.V
                [nn_PVaj, nn_PVaj_dist] = knnsearch(LLG1.V, PVaj);   %indices of nodes in LLG1.V

                Z2 = LLG2.V(nn_PVai, 1:2);
                Z1 = LLG1.V(nn_PVaj, 1:2);

%                 new_HLG1.U(nn_PVaj, :) = 0;
                new_HLG1_U(nn_PVaj, ai) = exp(-err); %1;

%                 new_HLG2.U(nn_PVai, :) = 0;
                new_HLG2_U(nn_PVai, aj) = exp(-err); %1;                        


%                 figure; subplot(1,2,1);
%                 
%                         V2 = LLG2.V; V2(:,1) = 300 + V2(:,1);
%                         
%                         edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
%                         points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
%                         line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
% 
%                         edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
%                         points = V2(edges,:); points(3:3:end,:) = NaN;
%                         line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
%                         
% 
%                         plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
%                         plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
% 
%                         plot(Vai(:,1), 256-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                         Vaj(:,1) = 300 + Vaj(:,1);
%                         plot(Vaj(:,1), 256-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
% 
%                         plot(Z1(:,1), 256-Z1(:,2), 'ko', 'MarkerFaceColor','k'), hold on;
%                         Z2(:,1) = 300 + Z2(:,1);
%                         plot(Z2(:,1), 256-Z2(:,2), 'ko', 'MarkerFaceColor','k'), hold on;
% 
%                         Tx1 = PVai_m;
%                         Tx1(:,1) = 300 + Tx1(:,1);
%                         plot(Tx1(:,1), 256-Tx1(:,2), 'm*')
% 
%                         nans = NaN * ones(size(Tx1,1),1) ;
%                         x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
%                         y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
%                         line(x', 256-y', 'Color','m') ;
% 
%                         matches = pairs';
% 
%                         nans = NaN * ones(size(matches,2),1) ;
%                         x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                         y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                         line(x', 256-y', 'Color','m', 'LineStyle', '--') ;
%                         title(sprintf('Transformation error %.03f', err1));
% 
%                         % ---------------------------------------------------- %
%                         subplot(1,2,2);
%                         
%                         edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
%                         points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
%                         line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
% 
%                         edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
%                         points = V2(edges,:); points(3:3:end,:) = NaN;
%                         line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
%                         
% 
%                         plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
%                         plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');
% 
% 
%                         plot(Vai(:,1), 256-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
%                         plot(Vaj(:,1), 256-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
% 
% 
%                         Tx2 = PVaj_m;
%                         plot(Tx2(:,1), 256-Tx2(:,2), 'm*')
% 
%                         Vaj_m(:,1) = 300 + Vaj_m(:,1);
%                         nans = NaN * ones(size(Tx2,1),1) ;
%                         x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
%                         y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
%                         line(x', 256-y', 'Color','m') ;
% 
%                         matches = pairs';
%                         nans = NaN * ones(size(matches,2),1) ;
%                         x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
%                         y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
%                         line(x', 256-y', 'Color','m', 'LineStyle', '--') ;                   
% 
%                         title(sprintf('Transformation error %.03f', err2));
%                 hold off;           
            else % if the estimated transformation law is not reliable
%                 ind_Vai = HLG1.U(:,ai);      
%                 nVai = size(Vai,1);
%                 
%                 ind = randi([1 nVai], nswap, 1);
%                 
%                 nn_ind = knnsearch(LLG1.V(~ind_Vai), LLG1.V(ind_Vai(ind)), 'K', 2);   %indices of nodes in LLG2.V
%                 nn_ind(:,1) = [];                
%                 new_HLG1_U(ind_Vai(ind), :) = new_HLG1_U(nn_ind, :);
%                 
% 
%                 ind_Vaj = HLG2.U(:,aj);      
%                 nVaj = size(Vaj,1);
%                 
%                 ind = randi([1 nVaj], nswap, 1);
%                 
%                 nn_ind = knnsearch(LLG2.V(~ind_Vaj), LLG2.V(ind_Vaj(ind)), 'K', 2);   %indices of nodes in LLG2.V
%                 nn_ind(:,1) = [];                
%                 new_HLG2_U(ind_Vaj(ind), :) = new_HLG2_U(nn_ind, :);                
                
                figure; subplot(1,2,1);
                
                        V2 = LLG2.V; V2(:,1) = 300 + V2(:,1);
                        
                        edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
                        points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
                        line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;

                        edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
                        points = V2(edges,:); points(3:3:end,:) = NaN;
                        line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
                        

                        plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
                        plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');


                        plot(Vai(:,1), 256-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                        Vaj(:,1) = 300 + Vaj(:,1);
                        plot(Vaj(:,1), 256-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;


                        Tx1 = PVai_m;
                        Tx1(:,1) = 300 + Tx1(:,1);
                        plot(Tx1(:,1), 256-Tx1(:,2), 'm*')

                        nans = NaN * ones(size(Tx1,1),1) ;
                        x = [ Vai_m(:,1) , Tx1(:,1) , nans ] ;
                        y = [ Vai_m(:,2) , Tx1(:,2) , nans ] ; 
                        line(x', 256-y', 'Color','m') ;

                        matches = pairs';

                        nans = NaN * ones(size(matches,2),1) ;
                        x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                        y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                        line(x', 256-y', 'Color','m', 'LineStyle', '--') ;
                        title(sprintf('Transformation error %.03f', err1));

                        % ---------------------------------------------------- %
                        subplot(1,2,2);
                        
                        edges = LLG1.E'; edges(end+1,:) = 1; edges = edges(:); 
                        points = LLG1.V(edges,:); points(3:3:end,:) = NaN;
                        line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;

                        edges = LLG2.E'; edges(end+1,:) = 1; edges = edges(:);
                        points = V2(edges,:); points(3:3:end,:) = NaN;
                        line(points(:,1), 256-points(:,2), 'Color', 'g'), hold on;
                        

                        plot(LLG1.V(:,1), 256-LLG1.V(:,2), 'ro', 'MarkerFaceColor','r'), hold on;
                        plot(V2(:,1), 256-V2(:,2), 'ro', 'MarkerFaceColor','r');


                        plot(Vai(:,1), 256-Vai(:,2), 'bo', 'MarkerFaceColor','b'), hold on;
                        plot(Vaj(:,1), 256-Vaj(:,2), 'bo', 'MarkerFaceColor','b'), hold on;


                        Tx2 = PVaj_m;
                        plot(Tx2(:,1), 256-Tx2(:,2), 'm*')

                        Vaj_m(:,1) = 300 + Vaj_m(:,1);
                        nans = NaN * ones(size(Tx2,1),1) ;
                        x = [ Vaj_m(:,1) , Tx2(:,1) , nans ] ;
                        y = [ Vaj_m(:,2) , Tx2(:,2) , nans ] ; 
                        line(x', 256-y', 'Color','m') ;

                        matches = pairs';
                        nans = NaN * ones(size(matches,2),1) ;
                        x = [ LLG1.V(matches(1,:),1) , V2(matches(2,:),1) , nans ] ;
                        y = [ LLG1.V(matches(1,:),2) , V2(matches(2,:),2) , nans ] ; 
                        line(x', 256-y', 'Color','m', 'LineStyle', '--') ;                   

                        title(sprintf('Transformation error %.03f', err2));
                hold off;           
                
            end % err<err_eps
        else % Rule 2
            if size(Vai,1)<3
                nn_Vai = knnsearch(LLG1.V, Vai, 'K', 2);   %indices of nodes in LLG2.V
                nn_Vai(:,1) = [];                
                new_HLG1_U(ind_Vai, :) = new_HLG1_U(nn_Vai, :);

            end
            if size(Vaj,1)<3
                nn_Vaj = knnsearch(LLG2.V, Vaj, 'K', 2);   %indices of nodes in LLG2.V
                nn_Vaj(:,1) = [];             
                new_HLG2_U(ind_Vaj, :) = new_HLG2_U(nn_Vaj, :);
          
            end
        end
       
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end
   
   [~, max_pos] = max(new_HLG1_U, [], 2);
   ind = sub2ind(size(HLG1.U), [1:nV1]', max_pos);
   new_HLG1_U(:) = 0;
   new_HLG1_U(ind) = 1;
   
   [~, max_pos] = max(new_HLG2_U, [], 2);
   ind = sub2ind(size(HLG2.U), [1:nV2]', max_pos);
   new_HLG2_U(:) = 0;
   new_HLG2_U(ind) = 1;
   
   HLG1.U = logical(new_HLG1_U);
   HLG2.U = logical(new_HLG2_U);
   

   display(sprintf('Summary %.03f sec', toc));
   display(sprintf('==================================================\n'));

end
