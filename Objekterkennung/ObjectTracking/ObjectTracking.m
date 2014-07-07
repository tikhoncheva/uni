function ObjectTracking

clc;   
close all;  
clear; 

%% Preparations

%% 1: read frames
input_path = ['.' filesep 'FramesIn' filesep 'redcup2'];
output_path = ['.' filesep 'FramesOut' filesep 'redcup2'];
% Get list of all jpg files in ornder 
imagefiles = dir([input_path filesep '*.jpg']) ;    
Nframes = length(imagefiles);   

% then read all images from the order
Nframes = 2;
frames = cell(1,Nframes); % cell of the images
for i=1:Nframes
    currentfilename = imagefiles(i).name;
    frames{i} = imread([input_path filesep currentfilename]);
end

%
%% 2: mark object to track 

a = 25; % horizontal radius of Ellipse
b = 30; % vertical radius of Ellipse

% show first image and wait till tracking object will be marked
f = figure;
    imagesc(frames{1}),
    title(sprintf('First frame from %i', Nframes));
    
    % wait
    uiwait(msgbox('Locate the object! First center'));
    [x0,y0] = ginput(1);
    x0 = round(x0);
    y0 = round(y0);
    hold on; % Prevent image from being blown away.
    plot(x0,y0,'r+', 'MarkerSize', 30);
    
    % plot an ellipse
    t=-pi:0.01:pi;
        xt=x0+a*cos(t);
        yt=y0+b*sin(t);
    plot(xt,yt)
print(f, '-r80', '-dtiff', fullfile(output_path, sprintf('Frame1.jpg')));
hold off;    
    
    
    
% frames{1} = imresize(frames{1}, [size(frames{1},1)*a ...
%                                  size(frames{1},2)*b]);
% x0 = x0*b;
% y0 = y0*a;


% f = figure;
%     imagesc(frames{1}),
%     title(sprintf('First frame from %i', Nframes));
%     hold on;
%     
%     % plot an ellipse
%     t=-pi:0.01:pi;
%         xt=x0+a*cos(t);
%         yt=y0+b*sin(t);
%     plot(xt,yt)

% print(f, '-r80', '-dtiff', fullfile(output_path, sprintf('Frame1.jpg')));
% hold off;


%% TRACKING

%% Step 1: Initialization

% center of the tracking object in each frame
cObj = zeros(Nframes,2);
% initial location of the target (got from user)
cObj(1,:) = [x0, y0];
%
% Parameters
% Feature Space : RGB color space quantized in 16x16x16 bins
m = 16^3; % m-bins  histogram
h = 100;  % kernel bandwidth
eps = 0.001; % precision

%% Target Model

% find pixel inside selected Ellipse
x_star = findPixels(frames{1}, cObj(1,:), a, b);
% % calculate delta(b(x_star_i) - u)
% % because we don't need to save feature representations of x_star separately
dbu = delta_b_u(frames{1}, x_star, m); %size: size(x_star,1) times m


% Target model: 
%q = pdf(x_star, dbu, cObj(1,:), m, 1);
q = pdf(x_star, dbu, [0 0], m, 1);
q_pos = find(q>0)
%% Algorithm

% for each frame
for frameId=2:Nframes
    cy0 = cObj(frameId-1,:);
    % find center of the target :
    cy1 = [0,0];
    
%     frames{frameId} = imresize(frames{frameId}, [size(frames{frameId},1)*a ...
%                                  size(frames{frameId},2)*b]);
    count = 1;
    while count~=2 %( sqrt((cy0-cy1)*(cy0-cy1)') > eps)
        % find pixels of interest (POI) around center of the previous frame
        x= findPixels(frames{frameId}, cy0, a, b);
        dbu = delta_b_u(frames{frameId}, x, m); %matrix number of pixel in
                                                % region times m
        
        % Target candidates
        p_y0 = pdf(x, dbu , cy0, m , h);
        p_y0_pos = find(p_y0>0)
        
%         sprintf('sum(p_y0)=%d', sum(p_y0))
        % calculate Bhattacharyya coefficient target and target candidate
        % ro = sum (sqrt(p_y0.*q));
        
        q_p = sqrt(q./p_y0);
        size(q_p);
        % calculate wights
        w = zeros(1,size(x,1));
        for i=1:size(x,1)
           w(i) = sum(q_p.*dbu(i,:));
           x(i,:) = x(i,:)*w(i);
        end  
        
        % calculate new center candidate
        cy1 = sum(x)/sum(w);
          
        count = 2;
    end
    %
    cObj(frameId,:) = cy1;
end

for i=2:Nframes
    f = figure;
        imagesc(frames{i});
        title(sprintf('Frame %i from %i', i, Nframes)), hold on;
    % plot an ellipse
    t=-pi:0.01:pi;
        xt= cObj(i,1)+a*cos(t);
        yt= cObj(i,2)+b*sin(t);
    plot(xt,yt)
    hold off;
    
    print(f, '-r80', '-dtiff', fullfile(output_path,...
                                    sprintf('Frame%d.jpg',i)));
end

end

%% Function findPixels
function pixels = findPixels(img, cy, a, b)
% find pixels inside selected ellipse (x/a)^2+(y/b)^2=1

pixels = [];

for y = cy(2)-b:cy(2)+b % size(img,1)
    for x = cy(1)-a:cy(1)+a %size(img,2)
        dist =  ((x-cy(1))/a)^2 + ((y-cy(2))/b)^2 ;
        dist = dist^(1/2);
        if(dist<=1) %euclidean distance
            pixels = [x y ; pixels];
        end
    end
end

figure
    imagesc(img),hold on,
    plot (pixels(:,1),pixels(:,2),'.b');

end

%% Function b
function bxy = Fbins(img, pixel)
% function calculates to the pixel (x,y) index b(x,y) of its bin in the
% quantized feature space
if (size(img,3)~=3)
     error('function b: Input image must be RGB.')
end

r = img(pixel(1),pixel(2),1)+1;
g = img(pixel(1),pixel(2),2)+1;
b = img(pixel(1),pixel(2),3)+1;

r_bin = floor(r/16)+1;
g_bin = floor(g/16)+1;
b_bin = floor(b/16)+1;

bxy = (r_bin-1)*256 + (g_bin-1)*16 + b_bin;

end

%% Probability density function (pdf)
function p = pdf(x, dbu, cy, m, h)
% Input x vector of pixels
%       y is coordinates of the center
%       m dimensional of the feature space
    
    % calculate kernel function of pixels

    k_x = zeros(1,size(x,1));

    for i=1:size(x,1)
       k_x(i) = K((x(i,:)-cy)*(x(i,:)-cy)'/h^2);
    end

    C = 1/sum(k_x);  % normalized constant

    % probability of the feature u=1..m in the target
    p = zeros(1,m);
    for u=1:m
       %p(u) =C*sum (k_x(:).*dbu(:,u));
        for i=1:size(x,1)
            p(u) = p(u) +  k_x(i)*dbu(i,u);
        end
        p(u) = p(u)*C;
    end  
    
end

%% Kernel with Epanechnikov profile
function kx = K(x)
% in our case d = 1, x \in [0, \infty)
d=1;
cd = 2*pi ;
    if x<=1
        kx = (d+2)*(1-x)/2/cd;
    else
        kx = 0;
    end
end

%% delta(b(x_i)-u)
function dbu = delta_b_u(img, x, m)

    dbu = zeros (size(x,1), m);
    for i=1:size(x,1)
        b_x = Fbins(img,x(i,:));
        for u=1:m 
            if b_x==u
                dbu(i,u) = 1;
            end;
        end
    end
%     
%     if x==0
%         d = 1;
%     else
%         d = 0;
%     end
end