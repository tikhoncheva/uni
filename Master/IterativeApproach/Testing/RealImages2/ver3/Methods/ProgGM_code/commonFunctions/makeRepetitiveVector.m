function [ repVector ] = makeRepetitiveVector( value, rep )

repVector = [];
for i = 1:length(value)
    repVector = [ repVector, value(i) * ones(1,rep(i))];
end
