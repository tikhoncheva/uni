%%%%%%%DISPLAY ELLIPSE
function drawellipse3( xyabc ,scaling, col, width)

% input: xyabco  - nFeat x 5 matrix
%        scaling - scale for visualization
%        col     - color for visualization
%        width   - line width for visualization

x = xyabc(:,1); y = xyabc(:,2); a = xyabc(:,3); b = xyabc(:,4); c = xyabc(:,5);

if( ~exist('width') )
    width = 2;
end

for iter_i = 1:size( xyabc, 1)
    [v e]=eig([a(iter_i) b(iter_i);b(iter_i) c(iter_i)]);

    l1=1/sqrt(e(1));
    l2=1/sqrt(e(4));

    alpha=atan2(v(4),v(3));
    t = 0:pi/50:2*pi;
    yt=scaling*(l2*sin(t));
    xt=scaling*(l1*cos(t));

    p=[xt;yt];
    R=[cos(alpha) sin(alpha);-sin(alpha) cos(alpha)];
    pt=R*p;
    %plot(pt(2,:)+x(iter_i),pt(1,:)+y(iter_i),'Color','w','LineWidth',width+1);
    plot(pt(2,:)+x(iter_i),pt(1,:)+y(iter_i),'Color',col,'LineWidth',width);
    %set(gca,'Position',[0 0 1 1]);
end