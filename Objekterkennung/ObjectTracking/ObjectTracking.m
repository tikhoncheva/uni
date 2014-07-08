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
%Nframes = 50;
frames = cell(1,Nframes); % cell of the images
for i=1:Nframes
    currentfilename = imagefiles(i).name;
    frames{i} = imread([input_path filesep currentfilename]);
    frames{i} = im2double(frames{i});
end

%
%% 2: mark object to track 

a = 30; % horizontal radius of Ellipse
b = 40; % vertical radius of Ellipse

% show first image and wait till tracking object will be marked
f = figure;
    imagesc(frames{1}),
    title(sprintf('Frame 1 from %i', Nframes));
    
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
    plot(xt,yt,'r')
print(f, '-r80', '-dtiff', fullfile(output_path, sprintf('Frame1.jpg')));
hold off;    
    
    

%% TRACKING

%% Step 1: Initialization

% center of the target (CT) in each frame
CT = zeros(Nframes,2);
% normalized coordinates of target center in each frame
normCT = zeros(Nframes,2);

% initial location of the target (got from user)
CT(1,:) = [x0, y0];
%
% Parameters
% Feature Space : RGB color space quantized in 16x16x16 bins
m = 16^3; % m-bins  histogram
h = 2.0;  % kernel bandwidth
eps = 0.0001; % precision

%% Target Model

% find pixel inside selected Ellipse
x= findPixels(frames{1}, CT(1,:), a, b);

% because we don't need to save feature representations of x_star separately
% calculate delta(b(x_star_i) - u)
dbu = delta_b_u(frames{1}, x, m); %size: size(x_star,1) times m
% normalized coordinates of pixels inside selected region and target center
[normX, normCT(1,:)]= normalizeX(x,CT(1,:),a,b);

% Target model: 
q = pdf(normX, dbu, normCT(1,:) , m, 1.);


%% Targen Lokalization!

% for each frame
for frameId=2:Nframes
    % get center of the previous frame
    y0 = CT(frameId-1,:);
    % find pixels of interest (POI) around y0
    x= findPixels(frames{frameId}, y0, a, b);
    % calculate delta(b(x_star_i) - u)
    dbu = delta_b_u(frames{frameId}, x, m); 
    % normalized coordinates of pixels inside selected region and target center
    [normX, normy0] = normalizeX(x, y0, a, b);
       
    % Target candidates
    p_y0 = pdf(normX, dbu , normy0, m , h);
 
    % Bhattacharyya Coefficient
    rho0 = sum(sqrt(q.*p_y0));
    
    f=figure;
      imagesc(frames{frameId}), 
      title(sprintf('Frame %i from %i', frameId, Nframes)), hold on;

    % find center of the target :
    while 1
      
        % plot around current target center
        t=-pi:0.01:pi;
            xt= y0(1)+a*cos(t);
            yt= y0(2)+b*sin(t);
        plot(xt,yt,'b')
        
        % calculate wights
        q_p = sqrt(q./p_y0);
        w = zeros(1,size(x,1));
        normXw = zeros(size(x,1),2);
        for i=1:size(x,1)
           w(i) = sum(q_p.*dbu(i,:));
           normXw(i,:) = normX(i,:).*w(i);
        end  
        
        % calculate new center 
        normy1 = sum(normXw)/sum(w);
        y1 = [round(normy1(1)*a), round(normy1(2)*b)] ;
        
%         By numerical problems        
%         % Target candidates
%         p_y1 = pdf(normX, dbu , normy1, m , h);
%         
%         % Bhattacharyya Coefficient
%         rho1 = sum(sqrt(q.*p_y1));
%         
%         while rho1 <rho0
%             sprintf(' %f < % f',rho1, rho0 )
%             y1 = (y0+y1)/2.;
%             normy1 = [y1(1)/a, y1(2)/b] ;
%             p_y1 = pdf(normX, dbu , normy1, m , h);
%             rho1 = sum(sqrt(q.*p_y1));
%             
%             t=-pi:0.01:pi;
%                 xt= y1(1)+a*cos(t);
%                 yt= y1(2)+b*sin(t);
%             plot(xt,yt)    
%         end        
        
        if ( sqrt((normy0-normy1)*(normy0-normy1)') < eps)
            break;
        else
            y0 = y1;
            normy0 = normy1;
            % Target candidates
            p_y0 = pdf(normX, dbu , normy0, m , h);
        end         
    end
    t=-pi:0.01:pi;
        xt= y1(1)+a*cos(t);
        yt= y1(2)+b*sin(t);
    plot(xt,yt,'g')
    hold off;
    print(f, '-r80', '-dtiff', fullfile(output_path,...
                                     sprintf('Frame%d.jpg',frameId)));
    %
    normCT(frameId,:) = normy1;
    CT(frameId,:) = y1;
end
% 
% for i=2:Nframes
%     f = figure('visible','off');
%         imagesc(frames{i});
%         title(sprintf('Frame %i from %i', i, Nframes)), hold on;
%     % plot an ellipse
%     t=-pi:0.01:pi;
%         xt= CT(i,1)+a*cos(t);
%         yt= CT(i,2)+b*sin(t);
%     plot(xt,yt)
%     hold off;
%     
%     print(f, '-r80', '-dtiff', fullfile(output_path,...
%                                     sprintf('Frame%d.jpg',i)));
% end

close all;  
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

% figure
%     imagesc(img),hold on,
%     plot (pixels(:,1),pixels(:,2),'.b');

end

%% Function b
function bxy = Fbins(img, pixel)
% function calculates to the pixel (x,y) index b(x,y) of its bin in the
% quantized feature space
if (size(img,3)~=3)
     error('function b: Input image must be RGB.')
end


r = img(pixel(1),pixel(2),1);
g = img(pixel(1),pixel(2),2);
b = img(pixel(1),pixel(2),3);

r_bin = floor(r*16)+1;
g_bin = floor(g*16)+1;
b_bin = floor(b*16)+1;

bin = sprintf('%f  %f  %f ', (r_bin-1)*256, (g_bin-1)*16 , b_bin);

bxy = (r_bin-1)*256 + (g_bin-1)*16 + b_bin;

end

%% Probability density function (pdf)
function p = pdf(x, dbu, cy, m, h)
% Input x vector of pixels
%       y is coordinates of the center
%       m dimensional of the feature space
    
    % calculate kernel function of pixels
    k_x = double(zeros(1,size(x,1)));
    for i=1:size(x,1)
       k_x(i) = K((x(i,:)-cy)*(x(i,:)-cy)'/h^2);
    end
    
    % constant C
    C = double(1/sum(k_x));  % normalized constant

    % probability of the feature u=1..m in the target
    p = double(zeros(1,m));
    for u=1:m
       %p(u) =C*sum (k_x(:).*dbu(:,u));
        for i=1:size(x,1)
            p(u) = p(u) +  k_x(i)*dbu(i,u);
        end
        p(u) = p(u)*C;
        
        % 
        if p(u)==0
           p(u)=0.00001; 
        end
    end  
    
end

%% Kernel with Epanechnikov profile
function kx = K(x)
% in our case d = 1, x \in [0, \infty)
d=1.;
cd = 2*pi;

    if x<=1
       kx = double((d+2)*(1-x))/2./cd;
    else
        kx = double(0);
    end
end

%% delta(b(x_i)-u)
function dbu = delta_b_u(img, x, m)

    dbu = zeros (size(x,1), m);
    % dbu = uint16(dbu);
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

%% Normolization of the coordinates
function [normX, normCenter] = normalizeX(x,y,a,b)

normX(:,1) = x(:,1)./a;
normX(:,2) = x(:,2)./b;

normCenter = [y(1)/a, y(2)/b];
end