%% Generate Rightward Prior Trial for Perisaccadic Mislocalization Task 

%Author: Carina Sabourin
%Affiliation: Blohm Lab, Queen's Universty, Kingston, Ontario, Canada

% This function generates  the saccade direction (leftward or rightward), length of stimuli
% presentation, and target (red rectangle) position for each trial.

%Arguments:
    %dist_to_screen: Required for accurate degree of visual field estimation
    %frame_rate: to calculate trajectory durations and necessary frames
    %ppcmx: conversion ratio from cm to pixels.
    

%Output:
    %x_location-position of target along horizontal axis
    %condition-direction of saccade
    %dur_F1-length of time F1 appears for
    %dur_F2-length of time F2 appears for before probe
    %dur_probe-length of time probe appears for
    %dur_F2afterprobee-length of time probe appears for
    %F1_location-position of the first fixation cross
    %F2_location-position of the second fixation cross

function [frame_info, x_location, condition, dur_F1, dur_F2, dur_probe, dur_F2afterprobe, F1_location, F2_location] = generate_trial_rightwardprior(dist_to_screen, frame_rate, ppcmx)

%% set initial target motion parameters

%Screen parameters
 screens = Screen('Screens'); %Obtain number of screens present
 screen_number = max(screens); %Use latest screen
[screen_number, screenrect] = Screen('OpenWindow');
frame_rate = round(FrameRate(0));


%randomize location of the probe along the x-axis, so that its appears in
%the right hemifield 75% of the time 

%for case 75% on the right~rightward prior
   if randn()+0.5>=0
    offset=(screenrect(3)/2);
else offset=0;
    end

x_location = (screenrect(3)/2)*rand+offset; 


%randomize saccade direction  condition=0->F1=L (rightward saccade),
%condition=1->F1=R (leftward saccade)
r=randn;

if r<=0                          
    condition=1;

else
    condition=0;      
     
end

if condition==0
    F1_location= screenrect(3)/4;
    F2_location=screenrect(3)*3/4;
else 
    F2_location= screenrect(3)/4;
    F1_location=screenrect(3)*3/4;
end
    
    
%% Set duration of each target motion 

%Duration of each part of the trajectory is randomized within a certain
%range.
dur_F1 = 1+0.5*rand; %s~randomize F1 timing so that it randomly appears between 1000-1500 ms
%probe appears randomly btwn -150 ms to +200 ms saccade onset
a = 0.050;
b = 0.400;
r = (b-a).*rand(1000,1) + a;
dur_F2=r(randi(numel(r)));%s
dur_probe = 0.016; %s, 2 frames
dur_F2afterprobe=1-dur_probe-dur_F2;%s
%matrix with all stimuli time
stimuli_time_matrix= [dur_F1 dur_F2 dur_probe dur_F2afterprobe];
%matrix with

%Convert duration in ms to number of frames according to the frame rate/1000 to convert from s to ms,
n_F1_frames = floor((dur_F1)*frame_rate/1000);
n_F2_frames = floor((dur_F2)*frame_rate/1000);
n_probe_frames = floor((dur_probe)*frame_rate/1000);
n_F2afterprobe_frames = floor((dur_F2afterprobe)*frame_rate/1000);


%create postion matrix in pixels
pixels_position_matrix = [x_location F1_location F2_location]; %pixels, on x-axis
%convert to cm on the plane of the trig using ppcmx
cm_position_matrix = pixels_position_matrix./ppcmx; %need to add input arguemnt ofr ppcmx to be able to run it
%convert to degree relaltive to subject eye position 
degree_position_matrix=(atan(cm_position_matrix./dist_to_screen).*180)./pi;
%create time matrix that is the lengthof trial in frames
time_matrix = zeros(length(pixels_position_matrix),1);

end









