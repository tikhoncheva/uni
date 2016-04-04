function affinity = dissim2affinity( dissim )
% function to transform dissimilarity values to affinity values
scale_sig = sqrt(0.15);    % = 1.0;
% affinity = max( 50 - (dissim ./ scale_sig^2), 0 );

% other options
affinity = exp( -(dissim./scale_sig^2) );
% max( 500 - (dissim.^2 ./ scale_sig^2), 0 );
end