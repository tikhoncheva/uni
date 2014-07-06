function extractFramesFromVideo(videoName)

clc;   
close all;  
clear; 

video_path = ['.']
videoName = 'redcup.avi';
[~, videoNameWithoutExt, ~] = fileparts(videoName);

output_path = ['.' filesep strcat('Frames_',videoNameWithoutExt)]


% Read in the movie.
mov = VideoReader([video_path filesep videoName]);

numberOfFrames = mov.NumberOfFrames% size(mov, 2);

for frame = 1 : numberOfFrames
    % Extract the frame from the movie structure.
    thisFrame = mov(frame).cdata;
    % Create a filename.
    outputFileNameFrame = sprintf('Frame %4.4d.png', frame);
    outputFileName = fullfile(output_path, outputFileNameFrame);

    % Write it out to disk.
    imwrite(thisFrame, outputFileName, 'png');
end

end