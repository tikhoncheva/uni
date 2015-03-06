function CorrMatrix = roundMatrix(fracX)
    CorrMatrix = zeros(size(fracX,1),size(fracX,2));

    while nnz(fracX)~= 0 
        
        [maxElInCol, I ] = max(fracX,[], 1);        
        [~, j] = max(maxElInCol);
        i = I(j);
        
        CorrMatrix(i,j) = 1;
        fracX(i,:) = 0;
        fracX(:,j) = 0;

    end
end
