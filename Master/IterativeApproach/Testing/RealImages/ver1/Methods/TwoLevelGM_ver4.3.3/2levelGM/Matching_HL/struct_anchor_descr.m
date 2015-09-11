function [HLG] = struct_anchor_descr(LLG, HLG)
% Describe each anchor of the HLG based on the structure of the underlying subgraph
%
% HLG.D_struct is a cell of histograms. The number of histograms for each
% anchor is equal to number of nodes in the underlying subgraph
% each histogram has a fix number of bins and describes the distribution
% of the lenghth of the edges inside of circle region around a node
%
% Input
%  LLG              lower level graph
%  HLG              higher level graph
%
% Output
%   HLG             HLG with the updated matrix D_struct

% update only changed subgraphs
I = find(HLG.F==0);


% set parameters of the descriptor
setParameters;
Rmin = 0; Rmax = agparam.R; % radius of the local neighborhood around a node
nbins = agparam.nbins;      % number of bins in the structural histogram
binEdges = linspace(Rmin,Rmax,nbins+1);
    

nV = size(LLG.V,1); % number of nodes
nA = size(HLG.V,1); % number of anchors

% adjacency matrix of the lower level graph
adjM = zeros(nV, nV);
E = LLG.E;
E = [E; [E(:,2) E(:,1)]];
ind = sub2ind(size(adjM), E(:,1), E(:,2));
adjM(ind) = 1;

anchor_descr = cell(nA,1);

for q = 1:numel(I)
   ai = I(q); % consider anchor i 
    
   % subgraph underlying the anchor i
   ai_x = HLG.U(:,ai);
   if sum(ai_x)==0
       continue;
   end
   
   V = LLG.V(ai_x,:);
   adjMcut = adjM(ai_x, ai_x');

   
   % descriptor of the subgraph
   n = size(V,1);
   subG_hist = zeros(n,nbins);
   for i=1:n
        u = V(i,1:2);
        ind_V = ((V(:,1)-u(1)).^2 + (V(:,2)-u(2)).^2<=Rmax^2);
        subG_V = V(ind_V, 1:2);
        
        A = adjMcut(ind_V, ind_V');    
        dist = squareform(pdist(subG_V, 'euclidean'));
        dist(~A) = NaN;
        
        hist_descr = histc(dist(:), binEdges);
        if (sum(hist_descr(1:end-1))>0)
            subG_hist(i,:) = hist_descr(1:end-1)/sum(hist_descr(1:end-1)); 
        else
            subG_hist(i,:) = hist_descr(1:end-1);
        end
   end
   
   anchor_descr{ai} = subG_hist;
   
   clear V; clear subG;
end

HLG.D_struct(I,:) = anchor_descr(I,:);

end