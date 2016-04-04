% LLG1, LLG2    two Lower Level Graphs, that should be matched
% LLGmatches    result of lower level graph matching (pairs of correspondence nodes)
% HLGmatches    result of higher level graph matching (pairs of correspondence nodes)
%

% Project first graph into second and cocluster both aligned sets of nodes
% jointly

function [HLG1, HLG2] = grid_coclustering(LLG1, LLG2, HLG1, HLG2, ...
                                         LLGmatches, HLGmatches, affTrafo)
   fprintf('\n------ Co-Clustering (2)');

   nV1 = size(LLG1.V, 1);  nV2 = size(LLG2.V, 1);   
       
   %% Parameters of the grid
   setParameters;
   nr = agparam.grid_nr;       % number of rows in the grid
   nc = agparam.grid_nc;       % number of columns in the grid
   nA = nr*nc;                 % each grid cell is represented by the anchor
   
   %% define new anchor graphs
   new_HLG1.V = zeros(nA,2);
   new_HLG1.E = [];
   new_HLG1.U = false(nV1, nA);      % matrix of correspondences between nodes and anchors
   % similarity of the anchors
   new_HLG1.D_appear = [];
   new_HLG1.D_struct = cell(nA,1);   
   
   new_HLG2.V = zeros(nA,2);
   new_HLG2.E = [];
   new_HLG2.U = false(nV2, nA);      % matrix of correspondences between nodes and anchors   
   % similarity of the anchors
   new_HLG2.D_appear = [];
   new_HLG2.D_struct = cell(nA,1);      
   
   
   %% find reliable alignments
   reliable_alignments = [];
   nmax_matches = 40;
   
   for k = 1:size(affTrafo,1)
       
      ai = affTrafo(k,1); 
      aj = affTrafo(k,2);
      
      Ti = affTrafo(k, 4:9);         % transformation from G_ai into G_aj
      Tj = affTrafo(k, 10:15);       % transformation from G_aj into G_ai (inverse Ti)      
      
      Ai = [[Ti(1) Ti(2)]; [Ti(3) Ti(4)]]; % transformation Tx = Ax+b
      bi = [ Ti(5); Ti(6)];

      Aj = [[Tj(1) Tj(2)]; [Tj(3) Tj(4)]];
      bj = [ Tj(5); Tj(6)];
      
      ind_Vai = find(HLG1.U(:,ai));
      
      [~, ind_matched_nodes] = ismember(ind_Vai, LLGmatches.matched_pairs(:,1));
      ind_matched_nodes = ind_matched_nodes(ind_matched_nodes>0);
      matched_nodes = LLGmatches.matched_pairs(ind_matched_nodes,1:2);
      
      Vai_m = LLG1.V(matched_nodes(:,1),1:2); % coordinates of the matched nodes in the subgraph G_ai
      Vaj_m = LLG2.V(matched_nodes(:,2),1:2); % coordinates of the matched nodes in the subgraph G_aj    
      
      % Project Vai_m into LLG2.V
      PVai_m = Ai * Vai_m' + repmat(bi,1,size(Vai_m,1)); % proejction of Vai_nm nodes
      PVai_m = PVai_m';
      % Project Vaj_m into LLG1.V
      PVaj_m = Aj * Vaj_m' + repmat(bj,1,size(Vaj_m,1)); % projection of Vaj_m nodes
      PVaj_m = PVaj_m';
      
      
      err_ij = sqrt((Vaj_m(:,1)-PVai_m(:,1)).^2+(Vaj_m(:,2)-PVai_m(:,2)).^2);
      err_ji = sqrt((Vai_m(:,1)-PVaj_m(:,1)).^2+(Vai_m(:,2)-PVaj_m(:,2)).^2); 
      
      ind_r_alignments_1 = err_ij<0.1;
      ind_r_alignments_2 = err_ji<0.1;
      ind_r_alignments = ind_r_alignments_1 & ind_r_alignments_2;
      
      err = 0.5* (err_ij(ind_r_alignments)+err_ji(ind_r_alignments));
          
      reliable_alignments = [reliable_alignments; ...
                             [matched_nodes(ind_r_alignments, 1:2), err]];
      
      clear ai aj Ai Aj bi bj Ti Tj err ind_Vai ind_Vaj Vai_m Vaj_m;
      clear PVai_m PVaj_m err_ij err_ji;
   end
   
   if size(reliable_alignments,1)>5
       
       nmax_matches = min(nmax_matches , size(reliable_alignments,1));
       [~, ind_sort] = sort(reliable_alignments(:,3));
       reliable_alignments = reliable_alignments(ind_sort(1:nmax_matches),1:2);

       % Estimate transformation based on the reliable matches
       opt.method='rigid'; opt.viz=0; opt.scale=0; 
       [Transform, ~] = cpd_register(LLG1.V(reliable_alignments(:,1),1:2), ...
                                     LLG2.V(reliable_alignments(:,2),1:2), opt); 
       A = Transform.R;
       b = Transform.t;


       % Project first graph into second
       jointV = [LLG2.V(:,1:2), (1:nV2)', 2*ones(nV2,1)];

       V1 = LLG1.V(:,1:2);      % coordinates of the nodes in the subgraph G_ai     
       PV1 = A * V1' + repmat(b,1,size(V1,1)); % proejction of Vai_nm nodes
       PV1 = PV1';

       jointV = [jointV; [PV1, (1:nV1)', ones(nV1,1)] ];

       clear A b T V PV;


       % cocluster set of vertrices projected on the same plain
       hbound = linspace(min(jointV(:,1))-0.1, max(jointV(:,1))+0.1, nc+1);
       vbound = linspace(min(jointV(:,2))-0.1, max(jointV(:,2))+0.1, nr+1);

       for j = 1:nc
           ind_jointVj = jointV(:,1)>=hbound(j) & jointV(:,1)<hbound(j+1);

           for i = 1:nr
              % find nodes in the current grid cell
              ind_jointVi = jointV(:,2)>=vbound(i) & jointV(:,2)<vbound(i+1);
              ind_jointVij = find(ind_jointVi & ind_jointVj);

              aij = (j-1)*nr+i;
              new_HLG1.V(aij,:) = [ (hbound(j+1)+hbound(j))/2, (vbound(i+1)+vbound(i))/2];
              new_HLG2.V(aij,:) = [ (hbound(j+1)+hbound(j))/2, (vbound(i+1)+vbound(i))/2];

              aij_r = (min(j+1,nc)-1)*nr+i;
              aij_b = (j-1)*nr+min(i+1, nr);

              new_HLG1.E = [new_HLG1.E; [aij aij_r]; [aij aij_b]];
              new_HLG2.E = [new_HLG2.E; [aij aij_r]; [aij aij_b]];

              % nodes from the first graph
              ind_LLG1 = jointV(ind_jointVij, 4) == 1; 
              new_HLG1.U(jointV(ind_jointVij(ind_LLG1), 3), aij) = 1;          

              % nodes from the second graph
              ind_LLG2 = jointV(ind_jointVij, 4) == 2;
              new_HLG2.U(jointV(ind_jointVij(ind_LLG2), 3), aij) = 1;         
           end 
       end

       assert(sum(new_HLG1.U(:))==nV1, 'not all nodes in the first graph were assigned to the anchors');
       assert(sum(new_HLG2.U(:))==nV2, 'not all nodes in the second graph were assigned to the anchors');

       % find subgraphs, that were not changed (F(ai)==1 <-> subgraph wasn't changed)  
       new_HLG1.F = ones(nA,1);
       diff_U1 = abs(new_HLG1.U - HLG1.U);
       new_HLG1.F(logical(sum(diff_U1))) = 0;

       new_HLG2.F = ones(nA,1);
       diff_U2 = abs(new_HLG2.U - HLG2.U);
       new_HLG2.F(logical(sum(diff_U2))) = 0; 

       % copy assignment history from the previous HL graphs
       new_HLG1.H = HLG1.H;
       new_HLG2.H = HLG2.H;

       HLG1 = new_HLG1;
       HLG2 = new_HLG2;
   end % if we have enough reliable alignments
end
