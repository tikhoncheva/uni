%% return list of the initial correspondences between two graphs

function InitialCorrespondences = initial_correspondences(LLG1, LLG2)

nV1 = size(LLG1.V, 1);
nV2 = size(LLG2.V, 1);

%% full correspondences list
InitialCorrespondences = [repmat((1:nV1)', nV2,1), kron((1:nV2)', ones(nV1,1))];

end
