function [ score time X Xraw] = wrapper_GM(method, cdata)

variables = method.variable;
for i = 1:length(variables), eval([variables{i} '=cdata.' variables{i} ';']); end

str = ['feval(@' func2str(method.fhandle)];
for j = 1:length(method.variable)
    str = [str ',' method.variable{j} ];
end
str = [str ')'];

tic;
Xraw = eval(str);
time = toc;
X = greedyMapping(Xraw, cdata.group1, cdata.group2);
%score = eigenVector;
score = X'*cdata.affinityMatrix*X;
