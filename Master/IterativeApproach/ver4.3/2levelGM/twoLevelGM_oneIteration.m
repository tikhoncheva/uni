%% One iteration of the two-level Graph Matching Algorithm

function [HLG1, HLG2, LLGmatches, HLGmatches, affTrafo] = ...
                   twoLevelGM_oneIteration(it, LLG1, LLG2, HLG1, HLG2, LLGmatches, HLGmatches, affTrafo)
    
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    fprintf('ITERATION %d\n', it);
    fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n');
    
    if it>1
        % ----------------------------------------------------------------------- 
        fprintf('\n== Update graph partitioning for the next iteration');
        % -----------------------------------------------------------------------     
        [HLG1, HLG2, affTrafo] = MetropolisAlg(it-1, LLG1, LLG2, HLG1, HLG2,...
                                             LLGmatches(it-1), HLGmatches(it-1), affTrafo);
    end
    % -----------------------------------------------------------------------    
    fprintf('\n== Matching on the Higher Level');
    % -----------------------------------------------------------------------  

    [corrmatrix, affmatrix, HLG1, HLG2] = initialization_HLGM(LLG1, LLG2, HLG1, HLG2);

    if (it==1)
        HLMatches = matchHLGraphs(corrmatrix, affmatrix);
    else
        HLMatches = matchHLGraphs(corrmatrix, affmatrix, HLG1, HLG2, HLGmatches(it-1));
    end
    HLGmatches(it) = HLMatches;
    
    % -----------------------------------------------------------------------    
    fprintf('\n== Matching on the Lower Level');
    % -----------------------------------------------------------------------   
    [subgraphNodes, corrmatrices, affmatrices, ind_origin] = initialization_LLGM(LLG1, LLG2, ...
                                                                     HLG1.U, HLG2.U,...
                                                                     HLGmatches(it).matched_pairs);    
%     nV1 = size(LLG1.V,1);   nV2 = size(LLG2.V,1);                                                                 
    if (it==1)
        LLMatches = matchLLGraphs(LLG1, LLG2, subgraphNodes, corrmatrices, affmatrices, ind_origin, HLGmatches(it).matched_pairs);
    else
        LLMatches = matchLLGraphs(LLG1, LLG2, subgraphNodes, corrmatrices, affmatrices, ind_origin, ...
                                  HLGmatches(it).matched_pairs, ...
                                  LLGmatches(it-1));
    end
    LLGmatches(it) = LLMatches; 

    fprintf('\n');                                     
end