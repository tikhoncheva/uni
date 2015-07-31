% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

% Rule 1:
% if the aff.transformation between graphs is reliable, for all unmatched nodes in
% both subgraphs add their nearest neighbors (according to the transformattion)
% in the opposite subgraph

function [new_HLG1, new_HLG2] = rearrange_subgraphs(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, T, inverseT)
       
   display(sprintf('\n================================================'));
   display(sprintf('Rearrange subgraphs'));
   display(sprintf('=================================================='));
   
   tic
   
   new_HLG1 = HLG1;
   new_HLG2 = HLG2;
   
   % for each pairs of anchor matches ai<->aj estimate the best local
   % affine transformation
   n_pairs_HL = size(HLGmatches.matched_pairs,1); 
   
   error_eps = 1.0;
   
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
                        
            if (err<error_eps)
                % nodes of the first graph, that wasn't matched
                ind_Vai_m = ismember(ind_Vai, pairs(:,1));
                Vai_nm = LLG1.V(ind_Vai(~ind_Vai_m), 1:2);            

                % nodes of the second graph, that wasn't matched
                ind_Vaj_m = ismember(ind_Vaj, pairs(:,2));            
                Vaj_nm = LLG2.V(ind_Vaj(~ind_Vaj_m), 1:2);            

                PVai_nm = Ai * Vai_nm' + repmat(bi,1,size(Vai_nm,1)); % proejction of Vai_nm nodes
                PVai_nm = PVai_nm';
                PVaj_nm = Aj * Vaj_nm' + repmat(bj,1,size(Vaj_nm,1)); % projection of Vaj_nm nodes
                PVaj_nm = PVaj_nm';

                % calculate the nearest neighbours of the projections and
                % include them into corresponding graphs
                nn_PVai_nm = knnsearch(LLG2.V, PVai_nm);   %indices of nodes in LLG2.V
                nn_PVaj_nm = knnsearch(LLG1.V, PVaj_nm);   %indices of nodes in LLG1.V

                Z2 = LLG2.V(nn_PVai_nm, 1:2);
                Z1 = LLG1.V(nn_PVaj_nm, 1:2);

                new_HLG1.U(nn_PVaj_nm, :) = 0;
                new_HLG1.U(nn_PVaj_nm, ai) = 1;

                new_HLG2.U(nn_PVai_nm, :) = 0;
                new_HLG2.U(nn_PVai_nm, aj) = 1;                        


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


                        plot(Vai_nm(:,1), 256-Vai_nm(:,2), 'ko', 'MarkerFaceColor','k'), hold on;
                        PVaj_nm(:,1) = 300 + PVaj_nm(:,1);
                        plot(PVaj_nm(:,1), 256-PVaj_nm(:,2), 'ko', 'MarkerFaceColor','k'), hold on;

                        plot(Z1(:,1), 256-Z1(:,2), 'ko', 'MarkerFaceColor','k'), hold on;
                        Z2(:,1) = 300 + Z2(:,1);
                        plot(Z2(:,1), 256-Z2(:,2), 'ko', 'MarkerFaceColor','k'), hold on;

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
        end
        
        clear pairs;
        clear ind_V1;
        clear ind_matched_pairs;
   end

   display(sprintf('Summary %.03f sec', toc));
   display(sprintf('==================================================\n'));

end
