 
function [S] = structural_node_similarity(HLG1, HLG2, LLG1, LLG2, corrmatrix)

vA1 = HLG1.V;  %2xnV1
vA2 = HLG2.V;  %2xnV2
            
nA1 = size(vA1,1);
nA2 = size(vA2,1);

nV1 = size(LLG1.V,1);
nV2 = size(LLG2.V,1);

% define size of the local neighborhood of a node
R = 30;                                         %  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% adjacency matrix of the first dependency graph
adjM1 = zeros(nV1, nV1);
E1 = LLG1.E;
E1 = [E1; [E1(:,2) E1(:,1)]];
ind = sub2ind(size(adjM1), E1(:,1), E1(:,2));
adjM1(ind) = 1;

% adjacency matrix of the second dependency graph
adjM2 = zeros(nV2, nV2);
E2 = LLG2.E;
E2 = [E2; [E2(:,2) E2(:,1)]];
ind = sub2ind(size(adjM2), E2(:,1), E2(:,2));
adjM2(ind) = 1; 
    

S = zeros(nA1*nA2,1); % similarity vector

for ai = 1:nA1 % consider anchor i
   % subgraph underlying the anchor i
   ai_x = HLG1.U(:,ai);
   if sum(ai_x)==0
       continue;
   end
   
   V1 = LLG1.V(ai_x,:);
   
   if (~isempty(LLG1.D))
        D1 = LLG1.D(:, ai_x);
   else 
        D1 = [];
   end
   adjM1cut = adjM1(ai_x, ai_x');
   if max(adjM1cut(:))==1
       [subE1(:,1), subE1(:,2)] = find(adjM1cut);
   else
       subE1 = [];
   end
   subG1 = struct('V', V1, 'D', D1, 'E', subE1);
          
   % list of possible matches of the anchor ai to the anchors of the second
   % graph
   seed_pairs = find(corrmatrix(ai,:)>0)';  
   
   for p = 1:numel(seed_pairs)
       aj = seed_pairs(p);
       % define subgraphs underlying the anchor aj of the second graph
       aj_x = HLG2.U(:,aj);
       if sum(aj_x)==0
           continue;
       end

       V2 = LLG2.V(aj_x,:);
       if (~isempty(LLG1.D))
            D2 = LLG2.D(:, aj_x);
       else 
            D2 = [];
       end
       adjM2cut = adjM2(aj_x, aj_x');
       if max(adjM2cut(:))==1
           [subE2(:,1), subE2(:,2)] = find(adjM2cut);
       else
           subE2 = [];
       end
       subG2 = struct('V', V2, 'D', D2, 'E', subE2);
   
       % compair two subgraphs
       simval = compair_subgraphs(subG1, subG2, R);
       
       S((aj-1)*nA1+ai) = simval;
      
       clear V2; clear D2; clear subE2; clear subG2;
   end
   
   clear V1; clear D1; clear subE1; clear subG1;
    
end



end