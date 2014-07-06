function ObjectTracking

clc;   
close all;  
clear; 

%% Preparations

%% 1: read frames
input_path = ['.' filesep 'FramesIn' filesep 'redcup2'];
output_path = ['.' filesep 'FramesIn' filesep 'redcup2'];
% Get list of all jpg files in ornder 
imagefiles = dir([input_path filesep '*.jpg']) ;    
Nframes = length(imagefiles);   

% then read all images from the order
Nframes = 2;
frames = cell(1,Nframes); % cell of the images
for i=1:Nframes
    currentfilename = imagefiles(i).name;
    currentimage = imread([data_path filesep currentfilename]);
    % Convert the image to gray scale
    frames{i} = currentimage;%rgb2gray(currentimage); 
end

%% 2: mark object to track 
% show first image and wait till tracking object will be marked
figure
    imagesc(frames{1}),
    title(sprintf('First frame from %i', Nframes));

uiwait(msgbox('Locate the object! First center'));
[x0,y0] = ginput(1);
x0 = round(x0);
y0 = round(y0);
hold on; % Prevent image from being blown away.
plot(x0,y0,'r+', 'MarkerSize', 30);

% uiwait(msgbox('Now vertical radius'));
% [x2,y2] = ginput(1);
% hold on; % Prevent image from being blown away.
% plot(x2,y2,'r+', 'MarkerSize', 30);
% hold on;
% 
% uiwait(msgbox('and horizontal radius'));
% [x3,y3] = ginput(1);
% hold on; % Prevent image from being blown away.
% plot(x3,y3,'r+', 'MarkerSize', 30);
% hold on;

% a=abs(y1-y2); % horizontal radius
% b=abs(x1-x3); % vertical radius

a = 35; % horizontal radius
b = 46; % vertical radius

% plot an ellipse
t=-pi:0.01:pi;
    xt=x0+a*cos(t);
    yt=y0+b*sin(t);
plot(xt,yt)

%% 3: Normalize target to a unit circle
% find pixel inside selected region
x_target = findPixels(frames{1}, x0, y0, a, b);

% figure
%     imagesc(frames{1}),hold on,
%     plot (x_target(:,1),x_target(:,2),'-o');
%     title(sprintf('First frame from %i', N));

% Normalizationa

% fprintf (' Normalization constans h_x = %d , h_y = %d', hx, hy );



%% TRACKING

%% Step 1: Initialization

% center of the tracking object in each frame
cObj = zeros(Nframes,2);
% initial location of the target
cObj(1,:) = [x0, y0];
%
% Parameters
% Feature Space : RGB color space quantized in 16x16x16 bins
m = 16^3; % m-bins  histogramm
h = 5;  % kernel bandwidth
eps = 0.001; % precision
%
% k_x_star = zeros(1,size(x_star,1));
% 
% for i=1:size(x_star,1)
%    k_x_star(i) = K((x_star(i,:)-cObj(1,:))*(x_star(i,:)-cObj(1,:))');
% end
% 
% C = 1/sum(k_x_star);  % normalized constant

% Target Model - the probability of the feature u=1..m in the target
x_star = x_target;
dbu = delta_b_u(frames{1}, x_star, m); %matrix number of pixel in
                                                % region times m
q = pdf(x_star, dbu, cObj(1,:), m, 1);

% for u=1:m
%    q(u) =C*sum (k_x_star(:)*krDel(Fbins(frames{1},x_star(:,:))-u));
% %     for i=1:size(x_star,1)
% %         q(u) = q(u) +  k_x_star(i)*krDel(Fbins(frames{1},x_star(i,:))-u);
% %     end
% %     q(u) = q(u)*C;
% end    

%% Algorithmus

% for each frame
for frameId=2:Nframes
    cy0 = cObj(frameId-1,:);
    % find center of the target :
    cy1 = [0,0];
    
    while ( sqrt((cy0-cy1)*(cy0-cy1)') > eps)
        % fint pixels of interest around center of the previous frame
        x= findPixels(frames{frameId-1}, cy0(1),cy0(2) , a, b);
        %b_x = FeatureRepresentation(frames{frameId}, z, m);
        dbu = delta_b_u(frames{frameId}, x, m); %matrix number of pixel in
                                                % region times m
        
        % calculate p_y0
        p_y0 = pdf(x, dbu , cy0, m , h);
        
        % calculate Bhattacharyya coefficient target and target candidate
        % ro = sum (sqrt(p_y0.*q));
        
        % calculate wights
        w = zeros(1,size(x,1));
        for i=1:size(x,1)
           w(i) = sum(sqrt(q./p_y0).*dbu(i,:)) 
           x(i,:) = x(i,:)*w(i);
        end  
        % calculate new center candidat
        cy1 = sum(x)/sum(w)
          
    end
    %
    cObj(frameId,:) = cy1;
end

for i=2:Nframes
    f = figure
        imagesc(frames{i});
        title(sprintf('Frame %i from %i', i, Nframes)), hold on;
    % plot an ellipse
    t=-pi:0.01:pi;
        xt= cObj(i,1)+a*cos(t);
        yt= cObj(i,2)+b*sin(t);
    plot(xt,yt)
    hol off;
    
    print(f, '-r80', '-dtiff', fullfile(output_path,...
                                    sprintf('Frame%d.jpg',i)));
end

end

%% Function findPixels
function pixels = findPixels(img, x0, y0, a, b)
% find pixels inside selected ellipse (x/a)^2+(y/b)^2=1

pixels = [];
for y = 1:size(img,1)
    for x = 1:size(img,2)
        dist =  ((x-x0)/a)^2 + ((y-y0)/b)^2 ;
        dist = dist^(1/2);
        if(dist<=1) %euclidean distance
            %frames{1}(y,x) = 255;
            pixels = [x y ; pixels];
        end
    end
end
end

%% Function b
function bxy = Fbins(img, pixel)
% function calculates to the pixel (x,y) index b(x,y) of its bin in the
% quzntized feature space
if (size(img,3)~=3)
     error('function b: Input image must be RGB.')
end

r = img(pixel(1,1),pixel(1,2),1);
g = img(pixel(1,1),pixel(1,2),2);
b = img(pixel(1,1),pixel(1,2),3);

r_bin = floor(r/16);
g_bin = floor(g/16);
b_bin = floor(b/16);

bxy = (r_bin-1)*16 + g_bin + (b_bin-1)*32;

end

%% Probability density function (pdf)
function p = pdf(x, dbu, cy, m, h)
% Input x Vektor of pixels
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
       p(u) =C*sum (k_x(:).*dbu(:,u));
    %     for i=1:size(x_star,1)
    %         q(u) = q(u) +  k_x_star(i)*krDel(Fbins(frames{1},x_star(i,:))-u);
    %     end
    %     q(u) = q(u)*C;
    end  
end

%% Kernel with Epanechnikov profile
function kx = K(x)
% in our case d = 1, x \in [0, \infty)
d=1;
cd = 2*pi ;
    if x<=1
        kx = cd*(d+2)*(1-x)/2;
    else
        kx = 0;
    end
end

%% KroneckerDelta 
function b_u = delta_b_u(img, x, m)

    b_u = zeros (size(x,1), m);
    for i=1:size(x,1)
        b_x = Fbins(img,x(i,:));
        for u=1:m 
            if (b_x-u)==0
                b_u(i,u) = 1;
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