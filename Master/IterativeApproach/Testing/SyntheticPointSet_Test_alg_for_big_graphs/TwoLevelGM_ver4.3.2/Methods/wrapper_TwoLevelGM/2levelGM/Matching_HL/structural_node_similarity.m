 
function [S, HLG1, HLG2] = structural_node_similarity(LLG1, LLG2, HLG1, HLG2, corrmatrix)

vA1 = HLG1.V;  %2xnV1
vA2 = HLG2.V;  %2xnV2
            
nA1 = size(vA1,1);
nA2 = size(vA2,1);

nV1 = size(LLG1.V,1);
nV2 = size(LLG2.V,1);

setParameters;

% define size of the local neighborhood of a node
R = agparam.R;

% update structural descriptors of the anchors
HLG1 = struct_anchor_descr(LLG1, HLG1);
HLG2 = struct_anchor_descr(LLG2, HLG2);  

S = zeros(nA1*nA2,1); % similarity vector

for ai = 1:nA1 % consider anchor i
   
   descr_ai = HLG1.D_struct{ai};      % descriptor of the anchor ai
   if isempty(descr_ai)
       continue;
   end
   n1 = size(descr_ai,1);
          
   % list of possible matches of the anchor ai to the anchors of the second graph
   ai_pairs = find(corrmatrix(ai,:)>0)';  
   
   for p = 1:numel(ai_pairs)
       aj = ai_pairs(p);
       descr_aj = HLG2.D_struct{aj};  % descriptor of the anchor aj
       if isempty(descr_aj)
           continue;
       end
       n2 = size(descr_aj,1);
       
       % similarity value between descriptors
       D1 = repmat(descr_ai, n2, 1);
       D2 = kron(descr_aj, ones(n1,1));
    
       C = ((D1-D2).^2)./(D1+D2) * 0.5;
       C(isnan(C)) =0;
       C = sum(C, 2);
   
       simval = exp(-sum(C(:))/n1/n2);
             
       S((aj-1)*nA1+ai) = simval; 
   end
    
end



end