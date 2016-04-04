function [feat num dim]=loadfeatures_v2(file, detector, param)
% Load local features

outname = [ 'tmp_' detector '_features.out' ]; %% temporary output file buffer name
fpath = fileparts(which(mfilename)); %% current directory path
inname = file;


switch detector
    
    case 'mser'
        fprintf('-- Detecting MSER features from %s\n',file);
        if (nargin<3)
           fprintf('No settings specified, so using defaults...\n');
           param.MSER_Ellipse_Scale = 1.0;
           param.MSER_Maximum_Relative_Area = 0.010;
           param.MSER_Minimum_Size_Of_Output_Region = 30;
           param.MSER_Minimum_Margin = 10;
           param.MSER_Use_Relative_Margins = 0;
           param.MSER_Vervose_Output = 0;
        end
%        opt = sprintf('-t 2 -es %f -per %f -ms %d -mm %d -rel %d -v %d -i %s -o %s',...
%            param.MSER_Use_Relative_Margins, param.MSER_Vervose_Output,...
        opt = sprintf('-t 2 -es %f -per %f -ms %d -mm %d -i "%s" -o "%s"',...
            param.MSER_Ellipse_Scale, param.MSER_Maximum_Relative_Area,...
            param.MSER_Minimum_Size_Of_Output_Region, param.MSER_Minimum_Margin,...
            inname, outname );
        if strncmp(computer,'PC',2) % MS Windows
          exec_str = ['"' fpath '/detectors/mser.exe"'];
        elseif strcmp(computer,'GLNX86') % Linux
          exec_str = [fpath '/detectors/mser.ln'];
        else error('This function can run only with MS Windows or Linux');
        end
    
    case 'hesaff'
        fprintf('-- Detecting Hessian-Affine features from %s\n',file);
        if (nargin<3)
           fprintf('No settings specified, so using defaults...\n');
           param.HARAFF_harThres = 10;
        end
        
        opt = sprintf('-hesaff -hesThres %d -i "%s" -o1 "%s"',...
            param.HESAFF_hesThres, ...
            inname, outname );

        if strncmp(computer,'PC',2) % MS Windows
          exec_str = ['"' fpath '/detectors/extract_features_32bit.exe"'];
        elseif strcmp(computer,'GLNX86') % Linux
          exec_str = [fpath '/detectors/extract_features_32bit.ln'];
        else error('This function can run only with MS Windows or Linux');
        end
        
    case 'haraff'
        fprintf('-- Detecting Harris-Affine features from %s\n',file);
        if (nargin<3)
           fprintf('No settings specified, so using defaults...\n');
           param.HARAFF_harThres = 10;
        end
        
        opt = sprintf('-haraff -harThres %d -i "%s" -o1 "%s"',...
            param.HARAFF_harThres, ...
            inname, outname );

        if strncmp(computer,'PC',2) % MS Windows
          exec_str = ['"' fpath '/detectors/extract_features_32bit.exe"'];
        elseif strcmp(computer,'GLNX86') % Linux
          exec_str = [fpath '/detectors/extract_features_32bit.ln'];
        else error('This function can run only with MS Windows or Linux');
        end
        
    case 'sift' % LOG features
        
        % Load image
        image = imread(inname);
        if size(image,3) > 1
           image = rgb2gray(image);
        end
        [rows, cols] = size(image); 
        % Convert into PGM imagefile, readable by "keypoints" executable
        f = fopen('tmp.pgm', 'w');
        if f == -1
            error('Could not create file tmp.pgm.');
        end
        fprintf(f, 'P5\n%d\n%d\n255\n', cols, rows);
        fwrite(f, image', 'uint8');
        fclose(f);
        fprintf('-- Detecting SIFT LOG features from %s\n',file);
        
        opt = sprintf('<tmp.pgm >"%s"', outname);
        if strncmp(computer,'PC',2) % MS Windows
          exec_str = ['"' fpath '/detectors/siftWin32"'];
        elseif strcmp(computer,'GLNX86') % Linux
          exec_str = [fpath '/detectors/sift'];
        else error('This function can run only with MS Windows or Linux');
        end
        
        %if f ~= -1, delete('tmp.pgm');  end
end
        
% Call the binary executable
%[exec_str  ' ' opt ]
result = unix([exec_str  ' ' opt ]);

if result ~= 0
  error('Calling the [ %s ] feature detector failed processing %s.',detector, inname);
end

% Load the output file
fid = fopen(outname, 'r');
if fid==-1
  error('Cannot load results from [ %s ] feature detector processing %s.', detector,inname);
end

if strcmp(detector,'sift')
    [header, count] = fscanf(fid, '%d %d', [1 2]);
    if count ~= 2
        error('Invalid keypoint file beginning.');
    end
    num = header(1);
    len = header(2);
    if len ~= 128
        error('Keypoint descriptor length invalid (should be 128).');
    end

    % Creates the two output matrices (use known size for efficiency)
    %locs = double(zeros(num, 4));
    %descriptors = double(zeros(num, 128));
    feat = zeros(num, 5);
    % Parse tmp.key
    for i = 1:num
        [vector, count] = fscanf(fid, '%f %f %f %f', [1 4]); %row col scale ori
        if count ~= 4
            error('Invalid keypoint file format');
        end
        % convert the params into elliptical representation
        feat(i, 1) = vector(1, 2);
        feat(i, 2) = vector(1, 1);
        feat(i, 3) = 0.05/vector(1, 3)^2; % adequate param: 0.05 & x2 or 0.03 & x1.5
        feat(i, 4) = 0;
        feat(i, 5) = 0.05/vector(1, 3)^2;

        [descrip, count] = fscanf(fid, '%d', [1 len]);
        if (count ~= 128)
            error('Invalid keypoint file value.');
        end
        % Normalize each input vector to unit length
        %descrip = descrip / sqrt(sum(descrip.^2));
        %descriptors(i, :) = descrip(1, :);
    end
    
else
    try
        header=fscanf(fid, '%f',1);
        num=fscanf(fid, '%d',1);
        feat = fscanf(fid, '%f', [5, inf]);
        feat=feat';        
        %s = reshape( fdata(c+[1:5*fdata(2)]), [5 fdata(2)] );
    catch
        error('Wrong length of the output file processing %s.',inname);
    end
    
end

fclose(fid);

% if fid ~= -1
%     delete(outname); 
% end
fprintf('%s interest points: %d\n',detector, num);


