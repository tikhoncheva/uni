 
function [LLG1, LLG2, HLG1, HLG2, ...
          LLGmatches, HLGmatches] = twoLevelGM(LLG1, LLG2, HLG1, HLG2, ...
                                               LLGmatches, HLGmatches, it, N)

for i = 1:N
    display(sprintf('ITERATION %d', it+1));
    
    tic;
    % -----------------------------------------------------------------------    
    fprintf('\n== Match anchor graphs');
    % -----------------------------------------------------------------------    
    [corrmatrix, affmatrix] = initialization_HLGM(HLG1, HLG2, LLG1, LLG2);

    if (it==1)
        HLM = matchHLGraphs(corrmatrix, affmatrix);
    else
        HLM = matchHLGraphs(corrmatrix, affmatrix, HLG1, HLG2, ...
                                  HLGmatches(it-1));
    end
    HLGmatches(it) = HLM;
    
    % -----------------------------------------------------------------------    
    fprintf('\n== Match initial graphs');
    % -----------------------------------------------------------------------   
    [subgraphNodes, corrmatrices, affmatrices] = initialization_LLGM(LLG1, LLG2, ...
                                                                     HLG1.U, HLG2.U,...
                                                                     HLGmatches(it).matched_pairs);    
    if (it==1)
        LLM = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, HLGmatches(it).matched_pairs);
    else
        LLM = matchLLGraphs(nV1, nV2, subgraphNodes, corrmatrices, affmatrices, ...
                                HLGmatches(it).matched_pairs, ...
                                LLGmatches(it-1));
    end
    LLGmatches(it) = LLM;

    % ----------------------------------------------------------------------- 
    fprintf('\n== Update subgraphs for the next iteration');
    % ----------------------------------------------------------------------- 
    
    [LLG1, LLG2, HLG1, HLG2] = MetropolisAlg(it, LLG1, LLG2, HLG1, HLG2,...
                                         LLGmatches(it), HLGmatches(it));
    % -----------------------------------------------------------------------       
    it = it + 1;
    T_it = toc;
    time = time + T_it;

    fprintf('\n');
    
end


end