%% Prior Task

%%Author: Carina Sabourin
%%Contributing authors: Members of the Blohm Lab, Queen's Universty, Kingston, Ontario, Canada
                        %Psychtoolbox tutorials

%%This code runs a perisaccadic mislocalization task generated using
%%Psychtoolbox. Data collection is done through the Eyelink Psychtoolbox
%%package and thus requires that an eyelink PC and eye tracker be connected
%%to the host PC that is running this task. Current eyelink commands are compatible with Eyelink
%%1000. 

%%To run this experiement, simply press "Run" on Matlab and a dialogue box
%%will prompt user input. Ensure the EDF filename is named specified below
%%in order for the analysis to run later on.
%Ensure the EDF file name is 8 characters or less otherwise data will not be saved.


%%Note:

%%Task code requires the following dependcies:
    %%Psychtoolbox
    %%Psychtoolbox Eyelink
    %%generate_trial_leftwardprior.m in Matlab path
    %%generate_trial_rightwardprior.m in Matlab path


%% Environment Set-up Prior to First Recording

%Close any open psychtoolbox windows
sca

%Clear all workspace variables
clear all; 
clearvars; 

%turn off unnecessary warnings
warning off all 


%Set Psychtoolbox preferences
Screen('Preferences', 'SkipSyncTest', 1)

%minimize Psychtoolbox warnings
oldLevel = Screen('Preference', 'VisualDebugLevel', 1);
oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', 1);

%dialogue box
%Current experimental structure includes 2 sessions, with 10 blocks in each session and 50 trials in each block. 
%Half of the subjects should do the left prior condition first. The other half should do the right prior condition first.  

%set path
cd('C:\Users\blohmlab\Documents\Undergraduate\carina_sabourin\Code')
savePath ='C:\Users\blohmlab\Documents\Undergraduate\carina_sabourin\Data';
clear all; 
rand('state', sum(100*clock));
%screen preferences
Screen('Preference', 'SkipSyncTests', 1);
    screens = Screen('Screens'); %Obtain number of screens present
    screen_number = max(screens); %Use latest screen
%number of trials and number of blocks
ErrorDelay=1; interTrialInterval = .5; nTrialsPerBlock = 50; nBlocks=5; 


%EDF filename is concatenated using the file name, session # and block #.
%All together the name should consist of 8 characters or less. 
prompt = {'Tracker EDF file name:', 'Subject ID:', 'Session #', 'Block #', '# of trials', 'Condition'};
dlg_title = 'input';                              
num_lines = 1;                                                   
default_ans = {'xx', '3', '2', '0', '5','0'}; %Set for each session default answers. (Usually name, ID, Session, Condition)
input_cluster = inputdlg(prompt, dlg_title, num_lines, default_ans);
%Creates edfFile name 
edf_file=strcat(input_cluster{1}, input_cluster{5}, input_cluster{3});%name edf file as subject's initials (2 characters), 
%condition (3 characters;lef or rig for leftward and rightward prior,respectively), block number (2 char; i.e. 01-10)

%Convert all string inputs to numbers for use in functions.  
subject_id = str2num(input_cluster{2});
block_number = str2num(input_cluster{4}); 
num_trials = str2num(input_cluster{5});
session_number = str2num(input_cluster{3});
time=clock;

%Matlab file name includes EDF file and date/time of recording. 
filename = sprintf( '%s%s.mat', edf_file, 'SavedVariables');

% Set path to save the data and matlab files. 
path_name = 'C:\Users\blohmlab\Documents\Undergraduate\carina_sabourin\Data'; 

%variables
grey = [63.5 63.5 63.5 ]; white = [ 255 255 255]; black = [ 0 0 0]; red = [ 255 0 0];
bgcolor = grey; textcolor = black;
dotSize = 5; dotColor = black;
penWidth=7; %apprently  7 is the max pen width

 %Screen paramters (ViewPixx, 120Hz)
 %Distance from position of participant's eye to the middle of the screen
    screen_width = 58; %cm 
    dist_to_screen = 51;%cm 
    screen_height = 29.5; %cm

 %set background parameters
    Screen('Preference', 'SkipSyncTests', 2);
    [window, windowRect] = PsychImaging('OpenWindow', screen_number, black); %Background color is black
    flip_interval = Screen('GetFlipInterval', window); 
    frame_rate = round(FrameRate(window));
    [x_pixels, y_pixels] = Screen('WindowSize', window);
    [x_center, y_center] = RectCenter(windowRect);
    Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %smooth edges of stimulus display
    
    %The following is a calculation to obtain the pixels per degrees of viewing angle and
    %pixels per centimeters on the screen for each dimension. 
    window_x_degrees = atan2(screen_width/2, dist_to_screen)*2*180/pi; 
    ppdx = x_pixels/window_x_degrees; %calculate pixels per degrees on the X axis
    ppcmx = x_pixels/screen_width;
    window_y_degrees = atan2(screen_height/2, dist_to_screen)*2*180/pi; %degrees
    ppdy = y_pixels/window_y_degrees;
    ppcmy = y_pixels/screen_height;
  %% Generate target trajectory matrices and frame information for entire block of trials
 
  %exp_array is a cell since trials are of different lengths. This
    %variable holds the pixel positions for target trajectory, velocity information for each frame,
    %and an empty array for event timing capture for each trial. 
    exp_array = cell(num_trials,1); %holds pixel positions and timing for each trial
  
    %frameInfos holds the frame number in which events occured such as
    %fixation, steps, and ramps. This  will be used to send event markeres
    %to Eyelink.
    frame_infos = zeros(5,num_trials); %holds frame number correpsonding to events for each trial
    n_frames = zeros(1,num_trials);
    
        
%     %Loop to generate trial information for all trials in block
%     %Note:
%         %All trialMatrix pixel values are zero-centred. This means that
%         %when drawing to screen, we add the xCenter pixel value to make all
%         %pixel values relative to the center of the screen. 

     for aTrial = 1: num_trials
     [frame_info, x_location, condition, dur_F1, dur_F2, dur_probe, dur_F2afterprobe] = generate_trial(dist_to_screen, frame_rate, ppcmx)
%         
%         %Fill in empty variables with new information
        frame_infos(:,aTrial) = frame_info;
        n_frames(1,aTrial) = sum(frame_info);

     end

    
    
    %% Eyelink Code Block
    % Eyelink initialization and configuration
    
    if Eyelink('initialize','PsychEyelinkDispatchCallback'),
        fprintf('Eyelink failed init');
        Screen('CloseAll');
        return
    end
	
    HideCursor;
    el = EyelinkInitDefaults(window);
    % tell the Eyelink Host the coordinate space
    if Eyelink('IsConnected') ~= el.notconnected,
        Eyelink('Command', 'screen_pixel_coords = %d %d %d %d', 0, 0, windowRect(RectRight), windowRect(RectBottom));
    end
    Eyelink('Command','calibration_type = HV9');
    %EyeLink('Command','read_ioport %d',hex2dec('379'));
    Eyelink('Command','write_ioport %d %d',hex2dec('37A'), 0);
    Eyelink('Command','write_ioport %d %d',hex2dec('378'), 0);
    Eyelink('Command','file_event_filter = LEFT,RIGHT, FIXATION, BLINK, MESSAGE, BUTTON, SACCADE, INPUT');%sets which events will be written to the EDF file.
    Eyelink('Command','link_event_filter = LEFT,RIGHT, FIXATION, BLINK, MESSAGE, BUTTON, SACCADE, INPUT');%sets which types of events will be sent through link
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % configure eyelink to send raw data
    status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,BUTTON,HMARKER');
    if status~=0
        disp('link_sample_data error')
    end
    
    status=Eyelink('command','file_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT,BUTTON,HMARKER');
    if status~=0
        disp('file_sample_data error')
    end
    
        status=Eyelink('command','inputword_is_window = ON');
    if status~=0
        disp('inputword_is_window error')
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isempty(edf_file)
        edf_file = 'data';
    end
    Eyelink('openfile', edf_file);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Calibrate the eye tracker
    
    el.backgroundcolour = 204;
    el.foregroundcolour = 0;
    el.window = window;
    status = Eyelink('isconnected');
    if status == 0 %if not connected
        Eyelink('closefile');
        Eyelink('shutdown');
        
        Screen('CloseAll');
        ShowCursor;
        % restore Screen preferce settings.
        Screen('Preference', 'VisualDebugLevel', oldLevel);
        Screen('Preference', 'SuppressAllWarnings', oldEnableFlag);
        return;
    end
    
    el.callback = '';
    error = EyelinkDoTrackerSetup(el, el.ENTER_KEY); % This calls the calibration,error: Screen( 'FillRect',  el.window, el.backgroundcolour );	% clear_cal_display()
    
    
    if error ~= 0, fprintf('eye tracker setup error = %d\n',error);end
    %%%end calibration%%%%%
    
    
    %Set Background color
    Eyelink('command','draw_filled_box %d %d %d %d %d',windowRect(RectLeft),windowRect(RectTop),windowRect(RectRight),windowRect(RectBottom),0);
    
    Screen('FillRect',window,127,windowRect);%changed bg colour to grey
    Screen('Flip',window);
    Eyelink('StartRecording');
    %%%%%%%%%%%%%%%%
    eye_used = Eyelink('EyeAvailable');
    
    switch eye_used
        case el.BINOCULAR
            error('tracker indicates binocular');
        case el.LEFT_EYE
            error('tracker indicates left eye');
            case el.RIGHT_EYE
            disp('tracker indicates right eye')
        case -1
            error('eyeavailable returned -1');
        otherwise
            error('unexpected result from eyeavailable');
    end
    eyeIndex = el.RIGHT_EYE & eye_used;


%   Screen parameters for task
[screen_number, screenrect] = Screen(screen_number,'OpenWindow');
Screen('FillRect', screen_number, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2];
Screen(screen_number, 'Flip');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Experimental instructions, wait for a spacebar response to start
Screen('FillRect', screen_number ,bgcolor);
Screen('TextSize', screen_number, 24);
Screen('DrawText', screen_number,['Black fixation crosses will appear on the left or right side of the screen.'] ,center(1)-350,center(2)-20,textcolor);
Screen('DrawText', screen_number,['Fixate on each cross as they appear. Click where the red rectangle appears.'], center(1)-300, center(2)+30, textcolor);
Screen('Flip',screen_number );
WaitSecs(5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%eyelink for block
for a= 1:nBlocks         
   eye_used = Eyelink('EyeAvailable');
end

    
%eyelink
Eyelink('command','draw_text %d %d %d %d',windowRect(RectRight)-100, windowRect(RectBottom)-100, 10, a);
Eyelink('Command','write_ioport %d %d',hex2dec('378'), 3);

HideCursor(screen_number);   
Screen('Flip', window); 
     
    % task trial loop
    for aTrial = 1:nTrialsPerBlock
%function that returns all the necessary target parameters/locations. 
%comment out the generate trial function for whatever condtion is not being used
%generate  trial for leftward prior
[frame_info, x_location, condition, dur_F1, dur_F2, dur_probe, dur_F2afterprobe, F1_location, F2_location] = generate_trial_leftwardprior(dist_to_screen, frame_rate, ppcmx);
%generate trial for rightward prior
%[frame_info, x_location, condition, dur_F1, dur_F2, dur_probe, dur_F2afterprobe, F1_location, F2_location] = generate_trial_rightwardprior(dist_to_screen, frame_rate, ppcmx);
disp(aTrial); %For experimenter to track progress
        
currentTrialDigit = aTrial;
Screen('FillRect', window ,bgcolor);
expStart=GetSecs;
Eyelink('message','trialStart'); 
 %%%%%%%%%%%%         
 %F1=left fixaion cross
 if condition==0  
              
%segment 1
F1crossT(1,aTrial)=GetSecs-expStart;
Eyelink('message','Fix1On');
%left fixation cross    
        for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2+20, penWidth);
        end
 Screen('Flip', screen_number);
F1_locationx= screenrect(3)*1/4;
F1locx(1,aTrial) = F1_location;%fixation 1 location x in pixels
WaitSecs(dur_F1); 
Eyelink('message','Fix1Off');  
  
%segment 2
F2crossT(1,aTrial)=GetSecs-expStart; 
Eyelink('message','Fix2On');
%right fixation cross      
for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2+20, penWidth);
end 

Screen('Flip', screen_number);
F2_locationx= screenrect(3)*3/4;
F2locx(1,aTrial) = F2_locationx;%fixation 2 location x in pixels
WaitSecs(dur_F2); 
 
%segment 3
rectT(1,aTrial)=GetSecs-expStart;
Eyelink('message','ProbeOn');
    %right fixation cross      
for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2+20, penWidth);
end 

%rectangle

   for z = 1:100
   
      Screen('DrawLine', screen_number, red, x_location, screenrect(4)/2-z, x_location+20, screenrect(4)/2-z, penWidth);
      z = z+1;
   
   end
    for z = 1:100
   
      Screen('DrawLine', screen_number, red, x_location, screenrect(4)/2+z, x_location+20, screenrect(4)/2+  z, penWidth);
      z = z+1;
    end
Screen('Flip', screen_number);
probelocx(1,aTrial) = x_location;%probe location
WaitSecs(dur_probe);
Eyelink('message','ProbeOff');

%segment 4 
%right fixation cross      
for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2+20, penWidth);
end
Screen('Flip', screen_number);
WaitSecs(dur_F2afterprobe); 
Eyelink('message','Fix2Off');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %F1=Right fixation cross
 elseif condition==1

%segment 1
F1crossT(1,aTrial)=GetSecs-expStart;
Eyelink('message','Fix1On');
%right fixation cross      
for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)*3/4, screenrect(4)/2, screenrect(3)*3/4, screenrect(4)/2+20, penWidth);
end
Screen('Flip', screen_number);
F1_locationx= screenrect(3)*3/4;
F1locx(1,aTrial) = F1_locationx;%fixation 1 location x in pixels
WaitSecs(dur_F1);
Eyelink('message','Fix1Off');

 %segment 2
F2crossT(1,aTrial)=GetSecs-expStart;
Eyelink('message','Fix2On');
%left fixation cross    
for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2+20, penWidth);
end

Screen('Flip', screen_number);
F2_locationx= screenrect(3)*1/4;
F2locx(1,aTrial) = F2_locationx;%fixation 2 location x in pixels
WaitSecs(dur_F2); 
    
%segment 3
rectT(1,aTrial)=GetSecs-expStart;
Eyelink('message','ProbeOn');
%    left fixation cross    
for n = 1:currentTrialDigit
    Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2-20, penWidth);
    Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4-20, screenrect(4)/2, penWidth);
    Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4+20, screenrect(4)/2, penWidth);
    Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2+20, penWidth);
end


%rectangle
   for z = 1:100
   
      Screen('DrawLine', screen_number, red, x_location, screenrect(4)/2-z, x_location+20, screenrect(4)/2-z, penWidth);
      z = z+1;
   
   end
    for z = 1:100
   
      Screen('DrawLine', screen_number, red, x_location, screenrect(4)/2+z, x_location+20, screenrect(4)/2+  z, penWidth);
      z = z+1;
    end
Screen('Flip', screen_number);
probelocx(1,aTrial) = x_location;%probe location
WaitSecs(dur_probe); 
Eyelink('message','ProbeOff');

%segment 4 
%left fixation cross    
        for n = 1:currentTrialDigit
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2-20, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4-20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4+20, screenrect(4)/2, penWidth);
Screen('DrawLine', screen_number, black, screenrect(3)/4, screenrect(4)/2, screenrect(3)/4, screenrect(4)/2+20, penWidth);
        end
Screen('Flip', screen_number);
WaitSecs(dur_F2afterprobe);
Eyelink('message','Fix2Off');
HideCursor(window);
 end
saccdir(1,aTrial)=condition;%direction of saccade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%record subject's reponse    
Screen('FillRect', screen_number, bgcolor); %go to blank screen so that F2 or cursor arent there (might provide ref frame for subject)
Screen('Flip', screen_number);  
%cursor
ShowCursor('Arrow',screen_number);
SetMouse(screenrect(3)/2, screenrect(4)/2, screen_number); %makes cursor appear in center of screen
Screen('Flip', screen_number);
%General variable setup
clicks = 0;
black = [1,0,0];
nchunk = 1; % Chunk number
%main loop
while ~KbCheck %check keyboard has not been pressed
    [xclick, yclick, buttons] =GetMouse(screen_number); %alternate click loc
    if any(buttons)
        clicks = clicks+1;
        aoi_corners(nchunk, clicks, 1)= xclick;
        aoi_corners(nchunk, clicks, 2)= yclick;
        Screen('DrawDots', screen_number, [xclick, yclick], 10, black)
        Screen('Flip', screen_number, 0, 1)
%         wait until the mouse is released
        while(any(buttons))
            [~, ~, buttons] =GetMouse(window);
           WaitSecs(.001); % wait 1 ms 
        end  
    end  
end   
HideCursor(window);         
Eyelink('message','Click');
%error
error(1,aTrial)=x_location-xclick;
clicklocx(1,aTrial) = xclick;%click location

clicklocy(1,aTrial) = yclick;%click location
WaitSecs(1);         
Screen('Flip', screen_number);      
        
Screen('FillRect', window ,bgcolor); Screen('Flip', window);

           Eyelink('Command','write_ioport %d %d',hex2dec('378'), 3);
            

  %write out eyelink data
        Eyelink('message','trialEnd');
        Eyelink('command','draw_text %d %d %d %d',windowRect(RectRight)-100, windowRect(RectBottom)-100, 0, a);
        Eyelink('Command','write_ioport %d %d',hex2dec('378'), 0);
             

   end  % end of trial loop         

Screen('CloseAll');
%excel
%fclose(outfile); 
fprintf('Thanks for completing the experiment!!!'); 

   
    
    Eyelink('StopRecording');
    Eyelink('command', 'set_idle_mode');
    WaitSecs(0.5);
    Eyelink('CloseFile');
    
    
    %% Save block parameters to the matlab file
    save(strcat(path_name, '/', filename),'num_trials','edf_file', 'subject_id', 'block_number','condition', 'dist_to_screen', 'screen_width', 'screen_height', 'x_pixels', 'y_pixels', 'ppdy'...
    ,'x_center','x_pixels','y_pixels', 'frame_rate','ppdx','ppdy','ppcmx','ppcmy', 'y_center', 'flip_interval',... %name and specs
                                'frame_infos', 'n_frames', 'error', 'F1crossT', 'F2crossT', 'rectT', 'probelocx', 'clicklocx', 'clicklocy', 'F1locx', 'F2locx', 'saccdir');

    
                             

%% download eyelink data file
try
    fprintf('Receiving data file ''%s''\n',edf_file);
    %  status = Eyelink('ReceiveFile');
    status=Eyelink('ReceiveFile', edf_file ,path_name,1);
    if status > 0
        fprintf('ReceiveFile status %d\n ', status);
    end
    if 2 == exist(edf_file, 'file')
        fprintf('Data file ''%s'' can be found in '' %s\n',edf_file, pwd);
    end
catch Me
    fprintf('Problem receiving data file ''%s''\n',edf_file);
    Eyelink('ShutDown');
end
Eyelink('ShutDown');   