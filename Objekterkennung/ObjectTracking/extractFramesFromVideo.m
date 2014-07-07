function extractFramesFromVideo(videoName)

clc;   
close all;  
clear; 


video_path = ['.'];
videoName = 'redcup2.avi';
[~, videoNameWithoutExt, ~] = fileparts(videoName);
output_path = ['.' filesep 'Frames' filesep videoNameWithoutExt];


% % Converte video to readable format !
% mov = mmread([video_path filesep videoName]);
% 
% writerObj = VideoWriter([video_path filesep 'readcup2.avi']);
%     open(writerObj);
% writeVideo(writerObj,mov.frames);
% close(writerObj);


mov = VideoReader('readcup2.avi');
% movFrames=read(mov);
nFrames=mov.NumberOfFrames;

for i = 1:nFrames
    img = read(mov,i);
    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
    imwrite(img,fullfile(output_path,sprintf('img%d.jpg',i)));
end

end