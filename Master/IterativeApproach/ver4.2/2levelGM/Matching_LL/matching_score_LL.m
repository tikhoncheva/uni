function [score] = matching_score_LL(LLG1, LLG2, corresp)
% returns global matching score given node correspondences
% Do not calculate global affinity matrix, because it can be too big
%
%  Input
%   LLG1 = (V1,E1,D1)   first graph 
%   LLG2 = (V2,E2,D2)   second graph
%   corresp             correspondences between nodes of the LLG1, LLG2 (size [N,2])
%
%  Output
%   score               matching score

N = size(corresp,1);    % number of correspondences

% similarity between matched nodes
sim_V = 0;
% if (~isempty(LLG1.D) && ~isempty(LLG2.D))
%     sim_V = zeros(N,1);
%     for i = 1:N
% %         sim_V(i) = nodeSimilarity(LLG1.D(:,corresp(i,1)), LLG2.D(:,corresp(i,2)), 'euclidean');
%         sim_V(i) = nodeSimilarity(LLG1.D(:,corresp(i,1)), LLG2.D(:,corresp(i,2)), 'cosine');
%     end
%     sim_V = sum(sim_V(:));
% end

% similarity between matched edges
ind = [1:N];
[p,q] = meshgrid(ind, ind);
m_edges = [p(:) q(:)];      % all possible matched edges based on node matches

% find edges that really exist in LLG1, LLG2
v1 = corresp(m_edges(:,1),1); v2 = corresp(m_edges(:,2),1); % v1,v2\in LLG1.V
u1 = corresp(m_edges(:,1),2); u2 = corresp(m_edges(:,2),2); % u1,u2\in LLG2.V

ind_v1 = ismember([v1,v2], LLG1.E, 'rows');
ind_v2 = ismember([v2,v1], LLG1.E, 'rows');
ind_v1v2 = ind_v1|ind_v2;

ind_u1 = ismember([u1,u2], LLG2.E, 'rows');
ind_u2 = ismember([u2,u1], LLG2.E, 'rows');
ind_u1u2 = ind_u1 | ind_u2;

ind = ind_v1v2 & ind_u1u2;
m_edges = m_edges(ind,:);

% similarity between remaind edges
le_v1v2 = sqrt(sum ((LLG1.V(corresp(m_edges(:,1),1),1:2) - LLG1.V(corresp(m_edges(:,2),1),1:2)).^2,2) );
le_u1u2 = sqrt(sum ((LLG2.V(corresp(m_edges(:,1),2),1:2) - LLG2.V(corresp(m_edges(:,2),2),1:2)).^2,2) );

sim_E = edgeSimilarity(le_v1v2, le_u1u2);

% sim_E = zeros(size(m_edges,1),1);
% the same in vector form
% for i = 1:size(m_edges,1)
%     v1 = corresp(m_edges(i,1),1); v2 = corresp(m_edges(i,2),1); % v1,v2\in LLG1.V
%     u1 = corresp(m_edges(i,1),2); u2 = corresp(m_edges(i,2),2); % u1,u2\in LLG2.V
%     
% %     if (v1~=v2 && u1~=u2)
%     if (ismember([v1,v2], LLG1.E, 'rows') || ismember([v2,v1], LLG1.E, 'rows'))  && ...
%        (ismember([u1,u2], LLG2.E, 'rows') || ismember([u2,u1], LLG2.E, 'rows'))
%         le_v1v2 = sqrt(sum((LLG1.V(v1,1:2) - LLG1.V(v2,1:2)).^2));
%         le_u1u2 = sqrt(sum((LLG2.V(u1,1:2) - LLG2.V(u2,1:2)).^2));
%     
%         sim_E(i) = edgeSimilarity(le_v1v2, le_u1u2);
%     end
% end
    
sim_E = sum(sim_E(:));

score = sim_V + sim_E;
end

