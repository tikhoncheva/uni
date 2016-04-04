%% 
function  [HLG1, HLG2] = buildHLGraphs_homography(LLG1, LLG2, agparam)

nV1 = size(LLG1.V,1);                 % number of nodes in the LLG
nV2 = size(LLG2.V,1);                 % number of nodes in the LLG

% lay a grid upon the graphs
r  = max( max(LLG1.V(:,1)), max(LLG2.V(:,1))); 
l  = min( min(LLG1.V(:,1)), min(LLG2.V(:,1)));

t = max( max(LLG1.V(:,2)), max(LLG2.V(:,2)));
b = min( min(LLG1.V(:,2)), min(LLG2.V(:,2)));

nr = 4;
nc = 4;

hbound = linspace(l-0.1, r+0.1, nc+1);
vbound = linspace(b-0.1, t+0.1, nr+1);

nCells = nr*nc;           % number of Cells in the grid
% Candidate matches

% CPD options
opt.method='rigid'; opt.viz=0; opt.scale=0; 

U1 = false(nV1, nCells);      % matrix of correspondences between nodes and anchors
U2 = false(nV2, nCells);      % matrix of correspondences between nodes and anchors

initialMatches = LLG1.candM;
E = [];

for j = 1:nc
    
    ind_V1j = LLG1.V(:,1)>hbound(j) & LLG1.V(:,1)<hbound(j+1);
    ind_V2j = LLG2.V(:,1)>hbound(j) & LLG2.V(:,1)<hbound(j+1);
    
    for i = 1:nr
       % find nodes in the current grid cell
       ind_V1i = LLG1.V(:,2)>=vbound(i) & LLG1.V(:,2)<vbound(i+1);
       ind_V2i = LLG2.V(:,2)>=vbound(i) & LLG2.V(:,2)<vbound(i+1);
       
       ind_V1ij = ind_V1i & ind_V1j;
       ind_V2ij = ind_V2i & ind_V2j;
       
       aij = (j-1)*nr+i;
       
       U1(ind_V1ij, aij) = 1;
       U2(ind_V2ij, aij) = 1;
       
       aij_r = (min(j+1,nc)-1)*nr+i;
       aij_b = (j-1)*nr+min(i+1, nr);
       
       E = [E; [aij aij_r]; [aij aij_b]];
    end 
end
ind_empty_cells1 = sum(U1,1)==0;
ind_empty_cells2 = sum(U2,1)==0;

U1(:, ind_empty_cells1) = [];
U2(:, ind_empty_cells2) = [];

nCells1 = size(U1,2);
nCells2 = size(U2,2);

assert(sum(U1(:))==nV1, 'not all nodes were assigned to the anchors');
assert(sum(U2(:))==nV2, 'not all nodes were assigned to the anchors');

cellCorr = [repmat((1:nCells1)', nCells2,1), kron((1:nCells2)',ones(nCells1,1))];
nCellCorr = nCells1*nCells2;

T = zeros(nCells1*nCells2, 1+9);    % matrix of projective transformations between the cells
for k = 1:nCellCorr
    c1 = cellCorr(k,1); 
    c2 = cellCorr(k,2);
   
    ind_Vc1 = U1(:, c1);
    ind_Vc2 = find(U2(:, c2));
   
    Vc1 = LLG1.V(ind_Vc1,1:2);
    Vc2 = LLG2.V(ind_Vc2,1:2);
   
    %% estimate transformation
    if size(Vc1,1)<=1 || size(Vc2,1)<=1
       H = [[1,0,0];[0,1,0]; [0,0,1]];
       err = Inf;
    else   
        [Transform, ~]=cpd_register(Vc2, Vc1, opt); 
        Ai = Transform.R;
        bi = Transform.t;
        H = [[Ai, bi];[0 0 1]];

        %% Quality of the transformation
        Pr_Vc1 = H*[Vc1';ones(1, size(Vc1,1))];
        Pr_Vc1 = Pr_Vc1(1:2,:)';

        err_arr = zeros(size(Vc1,1),1);
        initM_Vc1 = initialMatches(ind_Vc1);
        for i = 1:size(Vc1,1)
            nn_Vc1_i = initM_Vc1{i};
            nn_Vc1_i = ismember(ind_Vc2, nn_Vc1_i);

            if nnz(nn_Vc1_i)>0
                dist = pdist2(Pr_Vc1(i,1:2), Vc2(nn_Vc1_i,1:2));
                err_arr(i) = min(dist(:));
            end
        end
        err = median(err_arr);
    end
    
    T(k,1) = err;           % save trafo with corresponding error
    T(k,2:10) = H(:)';
    
end

% find transformations with the small error
thr_trafErr = 3;
T_selected = T(T(:,1)<thr_trafErr, :);

% find close transformations

dist_trafo = squareform(pdist(T_selected));
sim_trafo = exp(-dist_trafo);
[NcutDiscrete,~,~] = ncutW(sim_trafo ,nA);


end