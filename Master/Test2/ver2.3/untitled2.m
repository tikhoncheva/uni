
% MPM code
addpath(genpath(['..' filesep '..' filesep 'MPM_release_v1_2']));

nV1 = 3;
nV2 = 3;

match = [[1,1,2,2,3,3];[1,2,2,3,2,3]];
sim = [0.7, 0.6, 0.8, 0.5, 0.5, 0.9];

v1 = [[0,1,0];[0,0,1]];
v2 = [[0,1,1];[0,0,1]];
[ uniq_feat2, tmp, new_feat2 ] = unique(match(2,:));
cand_matchlist_uniq = [ match(1,:); new_feat2' ];

E12 = ones(nV1,nV2);
[L12(:,1), L12(:,2)] = find(E12);
L12
[group1, group2] = make_group12(L12);
conflictMatrix = getConflictMatrix(group1, group2)

% conflict groups
% L12_2(:,1) = match(2,:).';
% L12_2(:,2) = match(1,:).';
% L12_2
% [ group1, group2 ] = make_group12(L12_2)
% conflictMatrix = getConflictMatrix(group1, group2)

nAffMatrix = nnz(E12);
% nAffMatrix = size(match, 2);
AffMatrix = zeros(nAffMatrix);

%     edge similarity (non-diagonal elements of the affinity matrix)

Adj1 = [[0,1,1];[1,0,1];[1,1,0]];
Adj2 = [[0,0,1];[0,0,1];[1,1,0]];

[IJ(:,1), IJ(:,2)] = find(Adj1);
[AB(:,1), AB(:,2)] = find(Adj2);

D = zeros(nAffMatrix);



for ia = 1:size(cand_matchlist_uniq,2)
    i = cand_matchlist_uniq(1, ia);
    a = cand_matchlist_uniq(2, ia);
    
    for jb = 1:size(cand_matchlist_uniq,2)
        j = cand_matchlist_uniq(1, jb);
        b = cand_matchlist_uniq(2, jb);
          
        if (ismember([i, j], IJ, 'rows') && ismember([a, b], AB, 'rows'))
                
            var1 = sum( (v1(1:2, i) - v1(1:2, j)).^2,1);
            e_ij = sqrt(var1);

            var2 = sum( (v2(1:2, a) - v2(1:2, b)).^2,1);
            e_ab = sqrt(var2);
            [~, ind_i] = ismember([i, a], L12, 'rows');
            [~, ind_j] = ismember([j, b], L12, 'rows');
            D(ind_i, ind_j) =  (e_ij-e_ab)^2; 
        end
            
    end
end

D
D.*~full(getConflictMatrix(group1, group2))

x = MPM(D, group1, group2);
Objective = x'*AffMatrix * x;
  
x = reshape(x, [nV1, nAffMatrix/nV1]);

newCorrMatrix = roundMatrix(x)
