function [CorrMatrix] = roundMatrix(fracX)

    CorrMatrix = zeros(size(fracX));
    maxEl = 1;
    
    while (maxEl ~=0)
        
        [maxElInCol, I ] = max(fracX,[], 1);        
        [maxEl, j] = max(maxElInCol);
        i = I(j);
        
        CorrMatrix(i,j) = 1;
        fracX(i,:) = 0;
        fracX(:,j) = 0;
        
    end

end
