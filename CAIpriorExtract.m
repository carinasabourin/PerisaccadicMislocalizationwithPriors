% CAIExtract.m
%% Extracts a list of relevant trial parameters from the loaded D data structure. Saves parameters in a param matrix

%%Author: Carina Sabourin
%% Queen's University, Kingston, Ontario, Canada

%%This function should be called from the drop down menu in the analysis 
%%interface after data has been loaded and manually inspected for bad
%%trials. This function will extract the relevant parameters for future
%%analysis in the saccade trigger study. Function re-saves the **_**D.mat
%%file with param, PE, and RS matrices. 

%% Extract Param

for i = 1:N
    
    % general info
    param1(i,1) = D{i}.trn; %trial number
    param1(i,2) = D{i}.good; %good or bad trial
    
    % timings
    param1(i,3) = D{i}.fix1on; %fixation 1 onset
    param1(i,4) = D{i}.fix1off; %fixation 1 offset
    param1(i,5) = D{i}.fix2on; %fixation 2 onset
    param1(i,6) = D{i}.fix2off; %fixation 2 offset
    param1(i,7) = D{i}.probeon; %probe onset
    param1(i,8) = D{i}.probeoff; %probe offset
    param1(i,9) = D{i}.click; %click occured
    
    % stimuli info
    param1(i,10) = D{i}.F1locx; %fixation1 480=left fix cross, 1440=right fix cross
    param1(i,11) = D{i}.F2locx; %fixation2 480=left fix cross, 1440=right fix cross
    param1(i,12) = D{i}.probelocx; %physical probe location on x axis % left=lower, right=lower
    param1(i,13) = D{i}.clicklocx; % perceived probe location (click) on x axis % left=lower, right=lower
    param1(i,14) = D{i}.clicklocy; % perceived probe location (click) on y axis top=lower,bottom=higher

    %first saccade parameters
    if isfield(D{i}, 'eyeON')
        if ~isnan(D{i}.eyeON)
            % saccade info
            param1(i,15) = D{i}.eyeON; %saccade onset
            param1(i,16) = D{i}.peakVt; %saccade peak time
            param1(i,17) = D{i}.eyeOFF; %saccade offset
            start = min(find(D{i}.t1>=D{i}.eyeON-50));
            sacend = max(find(D{i}.t1<=D{i}.eyeOFF+50));
            param1(i,18) = nanmean2(D{i}.eyeX(start-10:start)); %saccade X start
            param1(i,19) = nanmean2(D{i}.eyeY(start-10:start));%saccade Y start
            param1(i,20) = nanmean2(D{i}.eyeX(sacend:min(sacend+10,length(D{i}.eyeX)))); %saccade X end
            param1(i,21) = nanmean2(D{i}.eyeY(sacend:min(sacend+10,length(D{i}.eyeY)))); %saccade Y end
            param1(i,22) = D{i}.peakV; %saccade peak velocity
            param1(i,23) = D{i}.eyeOFF-D{i}.eyeON;  %saccade duration
            
        else
            param1(i,15) = NaN;
            param1(i,16) = NaN;
            param1(i,17) = NaN;
            param1(i,18) = NaN;
            param1(i,19) = NaN;
            param1(i,20) = NaN;
            param1(i,21) = NaN;
            param1(i,22) = NaN;
            param1(i,23) = NaN;
        end
    else
        param1(i,16) = NaN;
        param1(i,17) = NaN;
        param1(i,18) = NaN;
        param1(i,18) = NaN;
        param1(i,19) = NaN;
        param1(i,20) = NaN;
        param1(i,21) = NaN;
        param1(i,22) = NaN;
        param1(i,23) = NaN;
    end
    %second saccade parameters
    if isfield(D{i}, 'eyeON2')
        if ~isnan(D{i}.eyeON2)
            % saccade info
            param1(i,24) = D{i}.eyeON2; %saccade onset
            param1(i,25) = D{i}.peakVt2; %saccade peak time
            param1(i,26) = D{i}.eyeOFF2; %saccade offset
            start2 = min(find(D{i}.t1>=D{i}.eyeON2-50));
            sacend2 = max(find(D{i}.t1<=D{i}.eyeOFF2+50));
            param1(i,27) = nanmean2(D{i}.eyeX(start2-10:start2)); %saccade X start
            param1(i,28) = nanmean2(D{i}.eyeY(start2-10:start2));%saccade Y start
            param1(i,29) = nanmean2(D{i}.eyeX(sacend2:min(sacend2+10,length(D{i}.eyeX)))); %saccade X end
            param1(i,30) = nanmean2(D{i}.eyeY(sacend2:min(sacend2+10,length(D{i}.eyeY)))); %saccade Y end
            param1(i,31) = D{i}.peakV2; %saccade peak velocity
            param1(i,32) = D{i}.eyeOFF2-D{i}.eyeON2;  %saccade duration
            
        else
            param1(i,24) = NaN;
            param1(i,25) = NaN;
            param1(i,26) = NaN;
            param1(i,27) = NaN;
            param1(i,28) = NaN;
            param1(i,29) = NaN;
            param1(i,30) = NaN;
            param1(i,31) = NaN;
            param1(i,32) = NaN;
        end
    else
        param1(i,24) = NaN;
        param1(i,25) = NaN;
        param1(i,26) = NaN;
        param1(i,27) = NaN;
        param1(i,28) = NaN;
        param1(i,29) = NaN;
        param1(i,30) = NaN;
        param1(i,31) = NaN;
        param1(i,32) = NaN;
    end
end


%% Save Results

save([D{1}.filename(1:end-4), '.mat'], 'D', 'N', 'param1');
save([D{1}.filename(1:end-4) '.txt'], 'param1', '-ascii', '-tabs');
msgbox('Data has been successfully saved!','Good job');

close all; 
clear all;
CAIprior;
