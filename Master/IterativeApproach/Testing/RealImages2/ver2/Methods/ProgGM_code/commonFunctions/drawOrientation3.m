%%%%%%%DISPLAY ORIENTATION LINE
function drawOrientation3(xyabco,scaling,col,width)

% input: xyabco  - nFeat x 6 matrix
%        scaling - scale for visualization
%        col     - color for visualization
%        width   - line width for visualization

x = xyabco(:,1); y = xyabco(:,2); a = xyabco(:,3); b = xyabco(:,4); c = xyabco(:,5);
angle = xyabco(:,6);

if( ~exist('width') )
    width = 2;
end

for iter_i = 1:size( xyabco, 1)
    % make transform matrix
    trM = [a(iter_i), b(iter_i); b(iter_i), c(iter_i)]^(-0.5);
    trM = trM * (2*scaling/41);

    % angles are measured from (-1,0) clockwise
    % determine orinetation line in warped patch
    radius = 41/2;
    xo = radius * -cos(-angle);
    yo = radius * sin(-angle);


    xyi = trM * [xo;yo];

    xi = xyi(1);
    yi = xyi(2);

    % draw orientation line in original image
    plot([x,x+xi],[y,y+yi], 'color', 'k', 'linewidth', width+1);
    plot([x,x+xi],[y,y+yi], 'color', col, 'linewidth', width);
end


