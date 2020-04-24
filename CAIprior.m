% CAIpriors.m
%
% Based on Chanel's Analysis Interface (CAI)
%% Analysis interface for Perisaccadic Mislocalization with Priors task. 

% Author: Carina Sabourin
%Contributing authors: Members of Blohm Lab, Queen's University, Kington,
%Ontario, Canada. 

%This program opens the UI interface that handles the data produced by the
%saccade trigger task. The user can load a block of trials, view each
%individual trial and extract a data matrix with desired parameters. Trials
%are visually inspected for calibration and tracking errors. Trials can be
%marked as good or bad whithin the interface. Saccade detection is
%automatic. 

%Called functions can be found in the accompanying files folder.
%Dependencies:
% LoadData.m
% Plotter.m
% ExtractData.m
% SaccSet
%GoodBadToggle

clear
warning off

global h f ax ylab;

%% create figure
f = figure('Name', 'Marking',...
    'Units', 'normalized', 'Position', [.01 .01 .98 .94], 'toolbar',...
    'none', 'NumberTitle', 'off', 'WindowKeyPressFcn', @figure_WindowKeyPressFcn);

% create axes
ylab = {'Eye pos (deg)', 'Eye Velo (mm/s)', 'Torsion (deg)', 'Torsion R', ' Head pos (deg)'};
for i = 1:5
    ax(i) = axes('Units', 'normalized', 'Position', [.05 1.02-i*.19 .5 .15]);
    ylabel(ylab{i});
end
xlabel('Time (s)')
ax(6) = axes('Units', 'normalized', 'Position', [.48 .35 .6 .6],...
    'PlotBoxAspectRatio', [1 1 1]);
xlabel('Horizontal eye position (deg)')
ylabel('Vertical eye position (deg)')


%% initialize basic variables
% trn = 1;

%% add menu items
gm(1) = uimenu('label', '        CAIprior        ');
gm(2) = uimenu(gm(1), 'label', 'Load block of data...', 'callback', '[D,N]=CAIpriorLoad; trn=1; CAIpriorReplot');
gm(3) = uimenu(gm(1), 'label', 'Extract parameters', 'callback', 'CAIpriorExtract');

%% add buttons & controls
h.goToTrial = uicontrol('Style', 'text', 'String', 'Go to trial #', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.825 0.25 0.05 0.025]);

h.edit = uicontrol('Style', 'edit', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.875 0.25 0.025 0.025]);

h.go = uicontrol('Style', 'pushbutton', 'String', 'Go', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.9 0.25 0.025 0.025], 'Callback',...
    'trn=str2num(get(h.edit, ''String'')); CAIpriorReplot');

h.nextTrial = uicontrol('Style', 'pushbutton', 'String', 'Next trial', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.75 0.25 0.05 0.025], 'Callback', @Next_Callback);

h.previousTrial = uicontrol('Style', 'pushbutton', 'String', 'Previous trial', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.7 0.25 0.05 0.025], 'Callback', @Previous_Callback);

h.trialGood = uicontrol('Style', 'pushbutton', 'String', 'Trial GOOD', 'foregroundcolor', 'g',...
    'units', 'normalized', 'Position', [0.6 0.25 0.05 0.025], 'Visible', 'off',...
    'Callback', @GoodBad_Callback);

h.spOn = uicontrol('Style', 'pushbutton', 'String', 'Smooth pursuit onset', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.6 0.15 0.1 0.025], 'Callback', 'CAIspon');

h.on = uicontrol('Style', 'pushbutton', 'String', 'Eye mvt ONset', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.6 0.15 0.1 0.025], 'Callback', 'mode0=1; CAIeyeon');

h.off = uicontrol('Style', 'pushbutton', 'String', 'Eye mvt OFFset', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.7 0.15 0.1 0.025], 'Callback', 'mode0=2; CAIeyeon');

h.on2 = uicontrol('Style', 'pushbutton', 'String', 'Eye mvt ONset2', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.8 0.15 0.1 0.025], 'Callback', 'mode0=1; CAIeyeon2');

h.off2 = uicontrol('Style', 'pushbutton', 'String', 'Eye mvt OFFset2', 'Visible', 'off',...
    'units', 'normalized', 'Position', [0.9 0.15 0.1 0.025], 'Callback', 'mode0=2; CAIeyeon2');



