function makeVideoFromFrames(videoName)

clc;   
close all;  
clear; 

frame_path = ['.' filesep 'FramesOut' filesep 'redcup2'];
video_path = ['.'];
videoName = 'result_redcup2.avi';

framefiles = dir([frame_path filesep '*.jpg']) ;    


% read all frames from the order
Nframes = length(framefiles);   
frames = cell(1,Nframes); % cell of the images


writerObj = VideoWriter([video_path filesep videoName]);
open(writerObj);

for i=1:Nframes
    currentframename = framefiles(i).name;
    frames{i} = imread([frame_path filesep currentframename]);
    writeVideo(writerObj,frames{i});
end

close(writerObj);

end