
% LLG1, LLG2    two Lower Level Graphs, that should be matched
% matches       result of matching this two graphs
% AMatrix_HLG   affinity matrix of matching problem on the Higher Level

function new_AMatrix_HLG = reweight_HLGraph(LLG1, LLG2, HLGmatches)

new_AMatrix_HLG = HLGmatches.matches;

[L12(:,1), L12(:,2)] = find(HLGmatches.corrMatrix);




end