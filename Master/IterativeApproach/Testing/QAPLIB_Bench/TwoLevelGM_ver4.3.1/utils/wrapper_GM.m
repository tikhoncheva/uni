%% Makes current problem into Graph Matching form
function [accuracy, score, time, X] = wrapper_GM(method, cdata)
% Make function evaluation script
str = ['feval(@' func2str(method.fhandle)];
for j = 1:length(method.variable), str = [str ',cdata.' method.variable{j} ]; end
if ~isempty(method.param), for i = 1:length(method.param), str = [str, ',method.param{' num2str(i) '}']; end; end
str = [str, ')']; 

if ~strcmp(func2str(method.fhandle), 'wrapper_TwoLevelGM')
    % Function evaluation & Excution time Check
    tic; Xraw = eval(str); %time = toc;
    % Discretization by one-to-one mapping constraints
    if 0
        % Hungarian assignment
        X = zeros(size(cdata.E12)); X(find(cdata.E12)) = Xraw;
        X = discretisationMatching_hungarian(X,cdata.E12); X = X(find(cdata.E12));
    else % Greedy assignment
        X = greedyMapping(Xraw, cdata.group1, cdata.group2);
    end
    % Matching Score
    P = reshape(X, cdata.nP1, cdata.nP2);
    score = trace(cdata.G1*P*transpose(cdata.G2)*transpose(P));
%     score = X'*cdata.affinityMatrix*X; % objective score function
    time = toc; % @ETikhonc: move toc to the end, because TwoLevelGM does also discretization
else
    tic; [Xraw, score] = eval(str); time = toc;
    X = Xraw;
end

% [ tmpS tmpSel tmp_norm ] = RMP_mult_mm(cdata.affinityMatrix, Xraw, cdata.group1);
% if 0
%     tmpX = Xraw;
%     tmpX(~tmpSel) = 0;
%     t_norm = sqrt(sum(tmpX.^2));
% else
%     t_norm = sqrt(tmp_norm);
% end
% if t_norm ~= 0
%     %tmpX = tmpX / t_norm;
%     Xraw = Xraw / t_norm;
% end
% score_MP = (Xraw')*RMP_mult_mm(cdata.affinityMatrix, (Xraw), cdata.group1);
%score_MP
%pause;
%score_MP = 0;
%score_MP = (Xraw'*tmpS) / sum(Xraw(find(tmpS>0)).^2);
%pause;
%score_MP = sum(score_MP .* score_MP);
if length(cdata.GTbool) ~= length(cdata.affinityMatrix)
    accuracy = NaN; % Exception for no GT information
else
    accuracy = (X(:)'*cdata.GTbool(:))/sum(cdata.GTbool);
end