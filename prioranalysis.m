%% Analysis Code For Perisaccadic Mislocalization Task
%%Author: Carina Sabourin
%%Queen's University, Kingston, Ontario, Canada

%This function operates on the filtered data files and discards all trials marked as bad during visual inspection during data marking,
%trials for which the first and second fixation were not within 5º of the fixation targets and for which saccade onset occurred more than 300 ms after F2 presentation.
%Trials for which the localization error was more than 2 standard deviations away from the participant?s average or the saccade amplitude was not between 15º and 30º were discarded from analysis. 
%Moving averages were calculated individually for each participant for both conditions by binning target presentation (relative to saccade onset) in 25 ms and 50 ms nonoverlapping bins and subsequentlyaveraging the perceived target location. 
%Bayesian inference was used to analyze the temporal evolution the subjects? prior based on their perceptual judgment and by making minimal assumptions regarding their sensory input.


%create all matrix with all gathered data, each row holds all the gathered
%data for each individual trial
% columns are:

%1 = subject ID
%2 = prior direction (1 = left, 2 = right)
%3 = block number
%4 = trial number
%5 = good(0) or bad(1)
%6 = fixation 1 onset
%7 = fixation 1 offset
%8 = fixation 2 onset
%9 = fixation 2 offset
%10 = probe onset
%11 = probe offset
%12 = click occured
%13 = %fixation1 480=left fix cross, 1440=right fix cross
%14 = fixation2 480=left fix cross, 1440=right fix cross
%15 = physical probe location on x axis % left=neg, right=pos
%16 = perceived probe location (click) on x axis % left=neg, right=pos
%17 = perceived probe location (click) on y axis top=lower,bottom=higher
%18 = saccade1 onset
%19 = saccade1 peak time
%20 = saccade1 offset
%21 = saccade1 X start
%22 = saccade1 Y start
%23 = saccade1 X end
%24 = saccade1 Y end
%25 = saccade1 peak velocity
%26 = saccade1 duration
%27 = saccade2 onset
%28 = saccade2 peak time
%29 = saccade2 offset
%30 = saccade2 X start
%31 = saccade2 Y start
%32 = saccade2 X end
%33 = saccade2 Y end
%34 = saccade2 peak velocity
%35 = saccade2 duration
%36 = saccade onset relative to fixation 2 onset
%37 = saccade onset relative to probe onset
%38 = probe onset relative to fixation 2 onset
%39 = good probe trials are 1
%40 = errors in perceived location, + = mislocalized to the right,- = left
%41 = good fixation 1 trials
%42 = saccade amplitude
%43 = good saccade amplitude trials are 1
%44 = hemifield physical probe was in, 0=left, 1=right
%45 = trials w/o very big errors

%params are:

%param1 = removed bad trials
%param2 = removed trials with bad percevied probe location (clicked at top of screen)
%param3 = removed trials with bad first fixation
%param4 = all good trials, removed trials with bad amplitudes
%param5 = removed trials with very big errors in perceived probe locations

clear all;
close all;

%% list and compile all data files

%subjects 
sub = ['cs';'ec';'hp';'jc';'jt';'sb';'sd'];

%prior direction
direction = ['lef'; 'rig'];

%control files 
filename1 = {
    'cslef01';
    'cslef02';
    'cslef03';
    'cslef04';
    'cslef05';
    'cslef06';
    'cslef07';
    'cslef08';
    'cslef09';
    'cslef10';
    'csrig01';
    'csrig02';
    'csrig03';
    'csrig04';
    'csrig05';
    'csrig06';
    'csrig07';
    'csrig08';
    'csrig09';
    'csrig10';
    'eclef01';
    'eclef02';
    'eclef03';
    'eclef04';
    'eclef05';
    'eclef06';
    'eclef07';
    'eclef08';
    'eclef09';
    'eclef10';
    'ecrig01';
    'ecrig02';
    'ecrig03';
    'ecrig04';
    'ecrig05';
    'ecrig06';
    'ecrig07';
    'ecrig08';
    'ecrig09';
    'ecrig10';
    'hplef01';
    'hplef02';
    'hplef03';
    'hplef04';
    'hplef05';
    'hplef06';
    'hplef07';
    'hplef08';
    'hplef09';
    'hplef10';
    'hprig01';
    'hprig02';
    'hprig03';
    'hprig04';
    'hprig05';
    'hprig06';
    'hprig07';
    'hprig08';
    'hprig09';
    'hprig10';
    'jclef01';
    'jclef02';
    'jclef03';
    'jclef04';
    'jclef05';
    'jclef06';
    'jclef07';
    'jclef08';
    'jclef09';
    'jclef10';
    'jcrig01';
    'jcrig02';
    'jcrig03';
    'jcrig04';
    'jcrig05';
    'jcrig06';
    'jcrig07';
    'jcrig08';
    'jcrig09';
    'jcrig10';
    'jtlef01';
    'jtlef02';
    'jtlef03';
    'jtlef04';
    'jtlef05';
    'jtlef06';
    'jtlef07';
    'jtlef08';
    'jtlef09';
    'jtlef10';
    'jtrig01';
    'jtrig02';
    'jtrig03';
    'jtrig04';
    'jtrig05';
    'jtrig06';
    'jtrig07';
    'jtrig08';
    'jtrig09';
    'jtrig10';
    'gtlef01';
    'gtlef02';
    'gtlef03';
    'gtlef04';
    'gtlef05';
    'gtlef06';
    'gtlef07';
    'gtlef08';
    'gtlef09';
    'gtlef10';
    'gtrig01';
    'gtrig02';
    'gtrig03';
    'gtrig04';
    'gtrig05';
    'gtrig06';
    'gtrig07';
    'gtrig08';
    'gtrig09';
    'gtrig10';
    'sblef01';
    'sblef02';
    'sblef03';
    'sblef04';
    'sblef05';
    'sblef06';
    'sblef07';
    'sblef08';
    'sblef09';
    'sblef10';
    'sbrig01';
    'sbrig02';
    'sbrig03';
    'sbrig04';
    'sbrig05';
    'sbrig06';
    'sbrig07';
    'sbrig08';
    'sbrig09';
    'sbrig10';
    'sdlef01';
    'sdlef02';
    'sdlef03';
    'sdlef04';
    'sdlef05';
    'sdlef06';
    'sdlef07';
    'sdlef08';
    'sdlef09';
    'sdlef10';
    'sdrig01';
    'sdrig02';
    'sdrig03';
    'sdrig04';
    'sdrig05';
    'sdrig06';
    'sdrig07';
    'sdrig08';
    'sdrig09';
    'sdrig10';
    
 
    }; %% name of txt file for experiment
param = [];
for f = 1:length(filename1),
    eval(sprintf('load %s.txt',filename1{f}));
    eval(sprintf('filename =  %s;',filename1{f}));
    for i=1:length(sub), %reiterates thru length of sub(vector)
        if strncmp(filename1(f), sub(i,1:2), 2),
            x=char(filename1{f});
            aa=str2double([x(6:7)]);
            for l=1:2,
                if x(3)==direction(l), %direction
                    
                    param = [param; i*ones(length(filename(:,1)),1) l*ones(length(filename(:,1)),1) aa*ones(length(filename(:,1)),1) filename];
                end
            end
        end
    end
end
     
clearvars -except param sub 
% savefile = 'paramvs.txt';
% save (savefile, 'param', '-ascii', '-tabs');
% load paramvs.txt;
% param = paramvs;

%% data filtering

% remove bad trials
ind = find(param(:,5)==0);
param1=param(ind,:);
 
% look at array onset
% figure();
% hold on;
% plot(param1(:,26), 'ro');
% % plot(param1(:,14), 'go');

ind = find(param1(:,15)>0);
length(ind)
 
%look at start positions
% figure();
% hold on;
% plot(param1(:,21), param1(:,22), 'bo');
% plot(param1(:,23), param1(:,24), 'k+');
% axis equal;
% legend('start positions');
% axis([-10 10 -10 10]);


% calculate saccade onset relative to fixation 2 onset
param1(:,36) = param1(:,18)-param1(:,8);
 

% calculate saccade onset relative to probe onset
param1(:,37) = param1(:,18)-param1(:,10);

% calculate probe onset relative to fixation 2 onset
param1(:,38) = param1(:,10)-param1(:,8);



%check stimuli position and timing to ensure task is coded correctly
figure();
hold on;
plot(param5(:,38), 'r.');
title('saccade rel. probe');


figure();
hold on;
plot(param1(:,16), param1(:,17), 'r.');
title('perceived probe location');
axis([-100 100 -50 50]);

% sort good and bad probe trials
for i=1:length(param1),
   if param1(i,16)>-40 & param1(i,16)<40 & param1(i,17)>-10 & param1(i,17)<10, param1(i,39)=1; % good probe trial
   else param1(i,39)=0; % 0 is a bad trial
   end
end
%remove trials with bad percevied probe location (clicked at top of screen)
ind = find(param1(:,39)==1);
param2 = param1(ind,:);

% figure();
% hold on;
% plot(param2(:,16), param2(:,17), 'r.');
% title('perceived probe location');
% axis equal;

% calculate error in perceived location
param2(:,40)= param2(:,15)-param2(:,16);%pos=mislocalized to the right,

figure();
hold on;
plot(param2(:,40), 'r.');
title('error in perceived probe location');
% axis equal;

% figure();
% hold on;
% ind = find(param2(:,1)==7 & param2(:,13)<0);
% plot(param2(ind,21), param2(ind,22), 'r.');
% ind = find(param2(:,1)==7 & param2(:,13)>0);
% plot(param2(ind,21), param2(ind,22), 'g.');
% axis([-30 30 -30 30]);
% 
% remove trials with bad first fixation
%& param2(i,22)>-5 & param2(i,22)<5
for i=1:length(param2),
    if param2(i,13)<0, % left fixation
        if param2(i,21)>-17 & param2(i,21)<-7 & param2(i,22)>-5 & param2(i,22)<5, param2(i,41)=1; % good probe trial
        else param2(i,41)=0; % 0 is a bad trial
        end
    elseif param2(i,13)>0, % right fixation
        if param2(i,21)>7 & param2(i,21)<17 & param2(i,22)>-5 & param2(i,22)<5, param2(i,41)=1; % good probe trial
        else param2(i,41)=0; % 0 is a bad trial
        end
    end
end

ind = find(param2(:,41)==1);
param3 = param2(ind,:);

%% calculate saccade amplitude
param3(:,42)= abs(param3(:,21)-param3(:,23));

figure();
hold on;
plot(param3(:,42), 'r.');
title ('saccade amplitude');
axis([0 6000 0 40]);

%remove trials with bad amplitudes
   if param3(i,42)>15 & param3(i,42)<30, param3(i,43)=1; % good probe trial
   else param3(i,43)=0; % 0 is a bad trial
   end
end

ind = find(param3(:,43)==1);
param4 = param3(ind,:);


% figure();
% hold on;
% plot(param4(:,42), 'r.');
% title ('saccade amplitude');

%check to see if probe appears in hemifiled 75% of the time for each
%condition

%hemifield physical probe was in, 0=left, 1=right
for i=1:length(param4)
   if param4(i,15)<0
      param4(i,44)=0; % 0 is a left trial
   elseif param4(i,15)>0
     param4(i,44)=1; % 1 is a right trial
    else
           param4(i,44)=2; %probe is at 0,0
   end
end
%find all leftward prior where probe on left side
indLL = find(param4(:,2)==1 & param4(:,44)==0);
indL = find(param4(:,2)==1);
percentLeft=(length(indLL)/length(indL))*100;


%find all rightward prior where probe on right side
indRR = find(param4(:,2)==2 & param4(:,44)==1);
indR = find(param4(:,2)==2);
percentRight=(length(indRR)/length(indR))*100;


%remove trials with very big errors in perceived probe locations (more than
%2 standard devation away from the mean)
for s=1:length(sub),
    for b=1:max(param4(:,3)),
        ind = find (param4(:,1)==s & param4(:,3)==b);
        if ~isempty(ind), 
             meanerr = nanmean(param4(ind,40));
             sderr = nanstd(param4(ind,40));
             for n=1:length(ind),
                 if param4(ind(n),40)>meanerr-sderr*2 & param4(ind(n),40)<meanerr+sderr*2,
                     param4(ind(n),45)=1;else param4(ind(n),45)=0;
                 end
             end
         end
     end
 end
        
ind = find(param4(:,45)==1);
param5 = param4(ind,:);


%compute standard deviation of error
param5(:,46) = nanmean(param5(:,40));
param5(:,47) = nanstd(param5(:,40));

%number of good trials per subject
indsub=find(param3(:,1)==5);
noftrialsforsub=length(indsub);

%remove trials where 'saccade onset relative to probe onset' is bad
for i=1:length(param5),
   if param5(i,37)>-200 & param5(i,37)<200, param5(i,48)=1; % good probe trial
   else param5(i,48)=0; % 0 is a bad trial
   end
end

ind = find(param5(:,48)==1);
param6 = param5(ind,:);


%% binning trials 
 
%50 ms bins
figure();
hold on;
plot(param5(:,37), param5(:,40),'r.');

bins = -300:50:300;

meanbins = [];
for c=1:2, %condition (left prior or right prior)
    for b=1:length(bins)-1, % saccade onset bins
        ind = find(param5(:,2)==c & param5(:,37)>=bins(b) & param5(:,37)<bins(b+1));
        meanbins = [meanbins; c (bins(b)+bins(b+1))/2 nanmean(param5(ind,40)) nansem(param5(ind,40)) length(ind)];
    end
end

length(meanbins(:,1)==1)

figure();
hold on;
ind = find(meanbins(:,1)==1); % leftward priors
errorbar(meanbins(ind,2), meanbins(ind,3), meanbins(ind,4), 'r');
ind = find(meanbins(:,1)==2); % rightward priors
errorbar(meanbins(ind,2), meanbins(ind,3), meanbins(ind,4), 'b');
legend('leftward', 'rightward');
title('error as a function of saccade onset/probe onset-50ms bins');
xlabel('saccade onset relative to probe onset in bins');
ylabel('perceived error'); 

%10 ms bins
% figure();
% hold on;
% plot(param5(:,37), param5(:,40),'r.');

bins = -300:25:300;

meanbins = [];
for c=1:2, %condition (left prior or right prior)
    for b=1:length(bins)-1, % saccade onset bins
        ind = find(param5(:,2)==c & param5(:,37)>=bins(b) & param5(:,37)<bins(b+1));
        meanbins = [meanbins; c (bins(b)+bins(b+1))/2 nanmean(param5(ind,40)) nansem(param5(ind,40)) length(ind)];
    end
end

%find avg size of bins, want >20
length(meanbins(:,1)==1)


figure();
hold on;
ind = find(meanbins(:,1)==1); % leftward priors
errorbar(meanbins(ind,2), meanbins(ind,3), meanbins(ind,4), 'r');
ind = find(meanbins(:,1)==2); % rightward priors
errorbar(meanbins(ind,2), meanbins(ind,3), meanbins(ind,4), 'b');
legend('leftward', 'rightward');
title('error as a function of saccade onset/probe onset-10ms bins');
xlabel('saccade onset relative to probe onset in bins');
ylabel('perceived error'); 


%% separated by participant



bins = -300:25:300;
meanbinsub = [];
for c=1:2, %condition (left prior or right prior)
    for s=1:length(sub)
    for b=1:length(bins)-1, % saccade onset bins
        ind = find(param5(:,2)==c & param5(:,1)==s & param5(:,37)>=bins(b) & param5(:,37)<bins(b+1));
        meanbinsub = [meanbinsub; c s (bins(b)+bins(b+1))/2 nanmean(param5(ind,40)) nansem(param5(ind,40)) length(ind)];
    end
    end
end

%remove all bins where there aren't enough trials for each subject
%(this way you don't bias stuff towards the results of some subjects)

ind = find(meanbinsub(:,6)>8);
meanbinsub2 = meanbinsub(ind,:);

%next mean across participants with standard error bars too (but only if
%there is enough data in each bin from all 7 participants
bins2 = -237.5:25:237.5;
meanbinsub3 = [];
for c=1:2, %condition (left prior or right prior)
    for b=1:length(bins2), % saccade onset bins
        ind = find(meanbinsub2(:,1)==c & meanbinsub2(:,3)==bins2(b) );
        if length(ind)>6
            meanbinsub3 = [meanbinsub3; c bins2(b) nanmean(meanbinsub2(ind,4)) nansem(meanbinsub2(ind,4)) length(ind)];
        else
            meanbinsub3 = [meanbinsub3; c bins2(b) NaN NaN length(ind)];
            
        end
    end
end
%bins matrix
%1 = prior direction (1 = left, 2 = right)
%2 = saccade onset relative to probe onset in bins
%3 = periceived error
%4 = distance above and below each error bar
%5 = number trials in bin


figure();
hold on;
ind = find(meanbinsub3(:,1)==1); % leftward priors
errorbar(meanbinsub3(ind,2), meanbinsub3(ind,3), meanbinsub3(ind,4), 'r');
ind = find(meanbinsub3(:,1)==2); % rightward priors
errorbar(meanbinsub3(ind,2), meanbinsub3(ind,3), meanbinsub3(ind,4), 'b');
% title('Rightward prior:localization error as a function of saccade onset');
legend('Leftward', 'Rightward');
xlabel('Time to saccade onset (ms)');
ylabel('Error in perceptual localization (°)');


%% bayes analysis


bins=1:10;
blockbins=[];
for c=1:2%for left and right conditions (1 = left, 2 = right)
    for block=1:max(param5(:,3))
        for trial=1:10:50
    ind = find(param5(:,2)==c & param5(:,3)==block);
    like=param5(ind,40); pdlike = fitdist(like,'Normal');%likelihood pdf
    post=param5(ind,16); pdpost = fitdist(post,'Normal');%post pdf
    prior=post./like; pdprior=fitdist(prior,'Normal');%prior pdf
    [q,r] = deconv(post,like); deconpost = conv(like,q) + r;%decon post
    pddeconpost = fitdist(deconpost,'Normal');
    pdexp = fitdist(param5(:,16),'Normal');%exp prior
    r=(pdprior.sigma)^2/((pdprior.sigma)^2+(pdlike.sigma)^2);%gain
    blockbins=[blockbins; c  block trial pdlike.mu pdlike.sigma pdpost.mu pdpost.sigma pdprior.mu pdprior.sigma pddeconpost.mu pddeconpost.sigma pdexp.mu pdexp.sigma r];
        end
    end
end
% 1=condition (1 = left, 2 = right)
% 2=block
% 3=trial bins
% 4=like mu
% 5=like sigma
% 6=post mu
% 7=post sigma
% 8=prior mu
% 9=prior sigma
% 10=deconpost mu
% 11=deconpost sigma

%average subject prior for last 50 trials-takeout
d=[]
d=[blockbins(45,8) blockbins(46,8) blockbins(47,8) blockbins(48,8) blockbins(49,8) blockbins(50,8)];
lefavgmu=mean(d)
g=[]
g=[blockbins(95,8) blockbins(96,8) blockbins(97,8) blockbins(98,8) blockbins(99,8) blockbins(100,8)];
rigavgmu=mean(blockbins(g,8))


%mean of exp prior
ind=param(:,2)==1;
explefmu=mean(param(ind,16))
ind=param(:,2)==2;
exprigmu=mean(param(ind,16))

%create likelihood disribution (normal distribution of localization error)
ind=param5(:,1)==1; d=param5(ind,40);%left prior 
histfit(d);
pdLeftLike = fitdist(d,'Normal');
ind=param5(:,1)==2; h=param5(ind,40);%right prior
histfit(param5(ind,16));
pdRigLike = fitdist(h,'Normal');

%create posterior disribution (normal distribution of percived location)
ind=param5(:,1)==1; f=param5(ind,16);%left prior 
histfit(f);
pdLeftPost = fitdist(f,'Normal');
ind=param5(:,1)==2; e=param5(ind,16);%right prior
histfit(param5(ind,16));
pdRigPost = fitdist(e,'Normal');
likeLeft=d; likeRig=h; postLeft=f; postRig=e;% rename var

%calculate prior disribution (normal distribution of percived location)
priorLeft=postLeft./likeLeft; %left prior
pdLeftPrior = fitdist(priorLeft,'Normal');
priorRig=postRig./likeRig; %right prior
pdRigPrior = fitdist(priorRig,'Normal');

%plot PDFs
LefL=histcounts(likeLeft);%like
LefL = smoothdata(LefL,'gaussian');
RigL=histcounts(likeRig);
RigL = smoothdata(RigL,'gaussian');
LefPo=histcounts(postLeft);%post
LefPo = smoothdata(LefPo,'gaussian');
RigPo=histcounts(postRig);
RigPo = smoothdata(RigPo,'gaussian');
LefPr=histcounts(priorLeft);%prior
LefPr = smoothdata(LefPr,'gaussian');
RigPr=histcounts(priorRig);
RigPr = smoothdata(RigPr,'gaussian');

%great figure with PDF for every condition
figure();
subplot(2,3,1)
axes;
area(LefL,'FaceColor',[0 0 1])
% title('Leftward Likelihood');
set(gca,'XTick',[], 'YTick', []);
axes;
subplot(2,3,4)
area(RigL,'FaceColor',[0 0 1]);
% title('Rightward Likelihood');
set(gca,'XTick',[], 'YTick', []);
subplot(2,3,2)
area(LefPr,'FaceColor',[0 1 0])
% title('Leftward Prior');
set(gca,'XTick',[], 'YTick', []);
subplot(2,3,5)
area(RigPr,'FaceColor',[0 1 0])
% title('Rightward Prior');
set(gca,'XTick',[], 'YTick', []);
subplot(2,3,3)
area(LefPo,'FaceColor',[1 0 0])
% title('Leftward Posterior');
set(gca,'XTick',[], 'YTick', []);
subplot(2,3,6)
area(LefL,'FaceColor',[1 0 0])
%title('Rightward Posterior');
set(gca,'XTick',[], 'YTick', []);

%plot histfits
figure();
subplot(3,2,1)
histfit(likeLeft);
title('Leftward Likelihood');
subplot(3,2,2)
histfit(likeRig);
title('Rightward Likelihood');
subplot(3,2,3)
histfit(priorLeft);
title('Leftward Prior');
subplot(3,2,4)
histfit(priorRig);
title('Rightward Prior');
subplot(3,2,5)
histfit(postLeft);
title('Leftward Posterior');
subplot(3,2,6)
histfit(postRig);
title('Rightward Posterior');

%deconvolve post with like
[q,r] = deconv(postLeft,likeLeft);%left
postLeft2 = conv(likeLeft,q) + r;
pdpostLeft2 = fitdist(postLeft2,'Normal');
[q,r] = deconv(postRig,likeRig);%Rig
postRig2 = conv(likeRig,q) + r;
pdpostRig2 = fitdist(postRig2,'Normal');
figure();%plot histfit left
subplot(1,2,2);
histfit(postLeft2);
title('Left Prior: Deconvoluted Posterior');
subplot(1,2,1);
histfit(postLeft);
title('Left Prior: Initial Posterior');
figure();%plot histfit right
subplot(1,2,2);
histfit(postRig2);
title('Right Prior: Deconvoluted Posterior');
subplot(1,2,1);
histfit(postRig);
title('Right Prior: Initial Posterior');
LefDeconPost=histcounts(postLeft2);%smooth left
LefDeconPost = smoothdata(LefDeconPost,'gaussian');
RigDeconPost=histcounts(postRig2);%smooth right
RigDeconPost = smoothdata(RigDeconPost,'gaussian');
figure();%plot smooth with subplots left
subplot(2,1,1)
plot(LefPr)
title('Left Prior: Initial Posterior');
subplot(2,1,2)
plot(LefDeconPost)
title('Left Prior: Deconvoluted Posterior');
figure();%plot smooth with subplots right
subplot(2,1,1)
plot(RigPr)
title('Right Prior: Initial Posterior');
subplot(2,1,2)
plot(RigDeconPost)
title('Right Prior: Deconvoluted Posterior');
figure();%plot smooth overlaying left
hold on;
plot(RigPr,'b')
plot(RigDeconPost,'g');
legend('Left Prior: Initial Posterior','Left Prior: Deconvoluted Posterior');



