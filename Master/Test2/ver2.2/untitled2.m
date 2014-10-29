nV1 = 3;
nv2 = 3;
matchInfo.match = [[1,1,2,2,3,3];[1,2,2,3,2,3]]



% conflict groups
[ group1, group2 ] = make_group12(matchInfo.match(1:2,:));
conflictMatrix = getConflictMatrix(group1, group2);

% affinity matrix

nAffMatrix = size(matchInfo.match, 2);
AffMatrix = zeros(nAffMatrix);

%     edge similarity (non-diagonal elements of the affinity matrix)

Adj1 = DG{img1};
Adj2 = DG{img2};

[IJ(:,1), IJ(:,2)] = find(Adj1);
[AB(:,1), AB(:,2)] = find(Adj2);
    
D = zeros(nAffMatrix);

for ia = 1:nAffMatrix
    i = cand_matchlist_uniq(1, ia);
    a = cand_matchlist_uniq(2, ia);
        
    for jb = 1:nAffMatrix
        j = cand_matchlist_uniq(1, jb);
        b = cand_matchlist_uniq(2, jb);
            
        if (ismember([i, j], IJ, 'rows') && ismember([a, b], AB, 'rows'))
                
            var1 = sum( (v1(1:2, i) - v1(1:2, j)).^2,1);
            e_ij = sqrt(var1);

            var2 = sum( (v2(1:2, a) - v2(1:2, b)).^2,1);
            e_ab = sqrt(var2);

            D(ia, jb) =  (e_ij-e_ab)^2; 
                
        end
            
    end
end

