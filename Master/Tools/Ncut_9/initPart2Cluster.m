function Bc = initPart2Cluster(parts, numCluster, lambda, neglectAntiCorr)
%   Find good part to cluster assignments based on spectral clustering of 
%   part correlations.
%   Inputs:
%   parts - the columns of this matrix correspond to different images; 
%           the first half of rows correspond to champfer scores 
%           and the second half to part locations
%   numClusters - number of clusters
%   lambda - expresses the significance of chamfer score for clustering; 
%            between 0 and 1   
%   neglectAntiCorr - binary variable whose value is true if the
%   anti-correlation between parts is to be neglected
%   Output:
%   Bc - a prototype matrix which defines a many-to-one assignment of parts
%   to clusters; columns correspond to different clusters
    
    [Npart, Nimg] = size(parts);
    Npart = Npart / 2;

    % normalize parts values
    mu = mean(parts, 2);
    sigma = std(parts, 1, 2);
    parts = (parts - repmat(mu, 1, Nimg)) ./ (repmat(sigma, 1, Nimg) + eps);
    
    % compute correlation between chamfer scores of parts
    C_chm = parts(1:Npart,:) * parts(1:Npart,:)' / Nimg;
    if (neglectAntiCorr)
        C_chm = (C_chm > 0) .* C_chm;
    else
        C_chm = abs(C_chm);
    end
    
    % compute correlation between locations of parts
    C_loc = parts(Npart+1:end,:) * parts(Npart+1:end,:)' / Nimg;
    if (neglectAntiCorr)
        C_loc = (C_loc > 0) .* C_loc;
    else
        C_loc = abs(C_loc);
    end
    
    % compute similarity matrix
    W = lambda * C_chm + (1 - lambda) * C_loc;
    
    % compute spectral clustering 
    Bc = ncutW(W, numCluster);
    
end