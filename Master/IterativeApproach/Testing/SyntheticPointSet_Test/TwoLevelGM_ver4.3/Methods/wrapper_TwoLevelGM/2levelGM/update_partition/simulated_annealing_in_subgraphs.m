% Simulated annealing for the graph matching based on the paper
% L.Herault, R.Horaud, "Symbolic Image Matching by Simulated Annealing"
function [LLmatches_new] = simulated_annealing_in_subgraphs(LLG1, LLG2, HLG1, HLG2, HLmatches, LLmatches, Mscore, T)

nIt = 1;

if size(HLmatches,1)<1
    nIt = 0;
end

% display(sprintf('Temperature T=%f', T));

for k = 1:nIt
    
    % select randomly an matched anchor in the HLG1
    ai = datasample(HLmatches(:,1), 1,'Replace',false)';
    
    ind_Vai = find(HLG1.U(:,ai));
    is_matched = ismember(ind_Vai, LLmatches(:,1));   
    ind_mVai = ind_Vai(is_matched); % indices of the matched nodes in the subgraph ai
    
    if numel(ind_mVai)<2
        LLmatches_new = LLmatches;
        continue;
    end
    % select two random matched nodes in the subgraph ai
    v1v2 = datasample(ind_mVai, 2,'Replace',false)';
    
    % find correspondences of this nodes (subgraph aj in LLG2)
    [~,ind_u1u2] = ismember(v1v2, LLmatches(:,1));
    
    u1 = LLmatches(ind_u1u2(:,1),2);   % v1 <-> u1
    u2 = LLmatches(ind_u1u2(:,2),2);   % v2 <-> u2
    
    % exchange correspondences between the nodes:  v1 <-> u2, v2 <-> u1
    LLmatches_new = LLmatches;
    LLmatches_new(ind_u1u2(1),2) = u2;
    LLmatches_new(ind_u1u2(2),2) = u1;
    
    % calculate energy change
    delta_E = Mscore - matching_score_LL(LLG1, LLG2, LLmatches_new);
        
            
    if delta_E>0 && exp(-delta_E/T)<rand(1,1) 
        LLmatches_new = LLmatches;
        display('not accepted!');
    end


end