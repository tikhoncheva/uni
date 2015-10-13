function [ sub ] = getSubFromIdx( idx, nSize )

sub = zeros( length(idx), 2);
sub(:,1) =  ceil( nSize - 0.5 - sqrt( nSize^2 - nSize + 0.25 - 2*idx ) );
sub(:,2) =  sub(:,1) + idx - (sub(:,1) - 1).*( nSize - sub(:,1)./2 );

end

