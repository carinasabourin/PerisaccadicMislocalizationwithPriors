% CAIpriorLoad.m
%% Loads a block of trials to the analysis interface

%Author: Carina Sabourin
%Contributing authors: Members of the Blohm Lab, Queen's University,
%Kingston, Ontario, Canada.

%This function loads a block of trials produced by the perisaccadic
%mislocalization with priors task and then sorts them into a data cell (D). Eye tracking data is
%extracted from an edf file and trial parameters are extracted from the
%.mat file. Function creates a **_**D.mat file. 

%Called functions can be found in the accomanying files folder
%Dependencies:
    %el2matInputEvent

function [D,N] = CAIpriorLoad

    %% Select File
    
   [edf_filename, edf_pathname] = uigetfile({'*.edf'},'Choose the file you want to load....');
    cd(edf_pathname);
    
    % Skip extracting if extracted data already exists
    if exist([edf_filename(1:end-4) '.mat'],'file') == 2
        load([edf_filename(1:end-4) '.mat']);
    else
        
        % Load .edf in matlab
        XX=el2mat(edf_filename);
        
        %% Parse .edf events messages - Edit here the EyeLink messages to match the Psychophysics experiment
        
        %trial start times
        s = {'trialStart'};
        [trialstart trialstartmes]=getELmes(XX, s);
        
        %fixation 1 on times
        s = {'Fix1On'};
        [fix1times fix1mes]=getELmes(XX, s);
        
        %fixation 1 off times
        s = {'Fix1Off'};
        [fix1offtimes fix1offmes]=getELmes(XX, s);
        
        %fixation 2 times response time (bar1 off time)
        s = {'Fix2On'};
        [fix2times fix2mes]=getELmes(XX, s);
        
        %probe on times
        s = {'ProbeOn'};
        [probeontimes probeonmes]=getELmes(XX, s);
                                                
        %probe off times
        s = {'ProbeOff'};
        [probeofftimes probeoffmes]=getELmes(XX, s);
        
        %fixation 2 off times
        s = {'Fix2Off'};
        [fix2offtimes fix2offmes]=getELmes(XX, s);
        
        %click times
        s = {'Click'};
        [clicktimes clickmes]=getELmes(XX, s);
        
        %trial start times
        s = {'trialEnd'};
        [trialend trialendmes]=getELmes(XX, s);
                
        %% Load corresponding .mat file
        load(sprintf('%s%s.mat', edf_filename(1:end-4), 'SavedVariables'));
        %% Plot time-dependent data
%correct incorrect distance_to_screen, recalc ppdx, ppdy, x_center, y_center
dist_to_screen=56.5; %cm

    window_x_degrees = atan2(screen_width/2, dist_to_screen)*2*180/pi; 
    ppdx = x_pixels/window_x_degrees; %calculate pixels per degrees on the X axis
    ppcmx = x_pixels/screen_width;
    window_y_degrees = atan2(screen_height/2, dist_to_screen)*2*180/pi; %degrees
    ppdy = y_pixels/window_y_degrees;
    ppcmy = y_pixels/screen_height;



  
        %% Compute basic variables
        
        N=length(trialstart(:,1)); % figure out how many trials total
        for k = 1:N
            % Constant values for every k :
            D{k}.sfr1 = 1000; %eyetracker sample rate
            D{k}.ppd=ppdx ; % pixels per degree
            D{k}.centreX = x_center; % px
            D{k}.centreY = y_center; % px
            D{k}.filename = edf_filename;
            cd(edf_pathname); cd('..')
            D{k}.file = [cd '\' edf_filename(1:end) '.mat'];
            
            % Constant values for every k, specific to the experiment :
            D{k}.trn = k; % trial number
            D{k}.good = 0;
            
            % Screens display times
            D{k}.fix1on=fix1times(k)-fix1times(k); % fixation 1 onset
            D{k}.fix1off=fix1offtimes(k)-fix1times(k); % fixation 1 offset
            D{k}.fix2on=fix2times(k)-fix1times(k); % fixation 2 onset
            D{k}.fix2off=fix2offtimes(k)-fix1times(k); % fixation 2 offset
            D{k}.probeon=probeontimes(k)-fix1times(k); % probe onset
            D{k}.probeoff=probeofftimes(k)-fix1times(k); % probe offset
            D{k}.click=clicktimes(k)-fix1times(k); % click occured
            
            %fixation positions on x axis
            D{k}.F1locx = (F1locx(1,k)-x_center)/ppdx; %fixation1 %480=left fix cross, 1440=right fix cross
            D{k}.F2locx = (F2locx(1,k)-x_center)/ppdx; %fixation2 %480=left fix cross, 1440=right fix cross
            
            %physical probe location on x axis
            D{k}.probelocx = (probelocx(1,k)-x_center)/ppdx; % left=lower, right=lower
            
            %perceived probe location (click) on x axis
            D{k}.clicklocx = (clicklocx(1,k)-x_center)/ppdx; % left=lower, right=lower
            D{k}.clicklocy = (clicklocy(1,k)-y_center)/ppdy;% top=lower,bottom=higher

                        
            % EyeLink data
            stime = find(XX.sampledata(:,1)>=trialstart(k)); % start time
            etime = find(XX.sampledata(:,1)<=clicktimes(k)); % end time %changed from waitanswertimes to click
            arrT = stime(1):etime(end); % timestamps array
            D{k}.t1 = (0:length(arrT)-1)+XX.sampledata(stime(1),1)-trialstart(k); % gives the time in ms of the sample data from trial start
            D{k}.eyeX=(XX.sampledata(arrT,2)-D{1}.centreX)/D{1}.ppd; % eyeHorizontal array
            D{k}.eyeY=(D{1}.centreY - XX.sampledata(arrT,3))/D{1}.ppd; % eyeVertical array
        end
        %% Filter signals & differentiate
        
        for k = 1:N
            D{k}.cutoff = 110; % cut-off frequency for filter, syds is 50
            D{k}.sfr = 1000; % sampling frequency
            D{k}.win = 0.005; % time window (1/2 width) for differentiation
            
            D{k}.eyeX = autoregfiltinpart_ok(D{k}.sfr1,D{k}.cutoff,D{k}.eyeX); % Filtered X
            D{k}.eyeY = autoregfiltinpart_ok(D{k}.sfr1,D{k}.cutoff,D{k}.eyeY); % Filtered Y
            D{k}.eyeXv = GRAIdiff(1/D{k}.sfr1,D{k}.win,D{k}.eyeX); % X velocity
            D{k}.eyeYv = GRAIdiff(1/D{k}.sfr1,D{k}.win,D{k}.eyeY); % Y velocity
            D{k}.eyeVv = sqrt(D{k}.eyeXv.^2 + D{k}.eyeYv.^2); % Net velocity
            D{k}.eyeXa = GRAIdiff(1/D{k}.sfr1,D{k}.win,D{k}.eyeXv);% X acceleration
            D{k}.eyeYa = GRAIdiff(1/D{k}.sfr1,D{k}.win,D{k}.eyeYv); % Y acceleration
            D{k}.eyeVa = sqrt(D{k}.eyeXa.^2 + D{k}.eyeYa.^2); % Net acceleration
        end       
    end
end
