% Simulated annealing for the graph matching based on the paper
% L.Herault, R.Horaud, "Symbolic Image Matching by Simulated Annealing"

function [LLmatches_new, HLG1, HLG2] = simulated_annealing_in_graphs(LLG1, LLG2, HLG1, HLG2, LLmatches, Mscore, T)
nIt = 1;

if size(LLmatches,1)<2
    nIt = 0;
end 

for k = 1:nIt
    
    f_accept = 1;
    
    % select randomly two matched nodes in LLG1
    v1v2 = datasample(LLmatches(:,1), 2,'Replace',false)';
    
    % find correspondences of this nodes in LLG2
    [~,ind_u1u2] = ismember(v1v2, LLmatches(:,1));
    u1 = LLmatches(ind_u1u2(:,1),2);   % v1 <-> u1
    u2 = LLmatches(ind_u1u2(:,2),2);   % v2 <-> u2
    
    % exchange correspondences between the nodes:  v1 <-> u2, v2 <-> u1
    LLmatches_new = LLmatches;
    LLmatches_new(ind_u1u2(1),2) = u2;
    LLmatches_new(ind_u1u2(2),2) = u1;

    % calculate energy change
    delta_E = Mscore - matching_score_LL(LLG1, LLG2, LLmatches_new);
                
    if delta_E>0 && 1/(1+exp(delta_E/T))<rand(1,1) %exp(-delta_E/T)>rand(1,1) 
        f_accept = 0;
        LLmatches_new = LLmatches;
    end
    
    if f_accept
        % excahnge anchors of the nodes u1, u2
        aj_u1 = find(HLG2.U(u1,:));
        aj_u2 = find(HLG2.U(u2,:));
        
        HLG2.U(u1, aj_u1) = 0; HLG2.U(u1, aj_u2) = 1;
        HLG2.U(u2, aj_u2) = 0; HLG2.U(u2, aj_u1) = 1;
        
    end        

end