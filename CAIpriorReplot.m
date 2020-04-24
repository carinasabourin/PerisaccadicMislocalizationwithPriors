% CAIpriorReplot.m

%%Author: Carina Sabourin
%%Contributing authors: Members of the Blohm Lab, Queen's University
%%Kingston, Ontario, Canada

%This function replots the time-dependant data as well as the spatial data.

global trn N D h f ax;

if trn < 1, trn = 1; end
if trn > N, trn = N; end

CAIGoodBadToggle;
set(f,'name',['CAI prior saccade' ' trial # ' num2str(trn)]);




%% Plot time-dependent data

axes(ax(1));
cla; hold on;
plot(D{trn}.t1(1:end), D{trn}.eyeX(1:end), 'r'); % horizontal eye
plot(D{trn}.t1(1:end), D{trn}.eyeY(1:end), 'g'); % vertical eye
plot([D{trn}.fix2on D{trn}.fix2on], [-20 20], 'm-'); %fix 2 on
plot([D{trn}.fix2off D{trn}.fix2off], [-20 20], 'm-'); %fix 2 off
plot([D{trn}.probeon D{trn}.probeon], [-20 20], 'c-'); %probe on
plot([D{trn}.probeoff D{trn}.probeoff], [-20 20], 'c-'); %probe off
plot([D{trn}.click D{trn}.click], [-20 20], 'k-'); %click
set(ax(1),'xlim',[D{trn}.t1(1) D{trn}.t1(end)],'ylim',[-20 20])
D{trn}.trn = trn;

axes(ax(2));
cla; hold on;
plot(D{trn}.t1(1:end), D{trn}.eyeXv(1:end), 'r'); % X eye velo
plot(D{trn}.t1(1:end), D{trn}.eyeYv(1:end), 'g'); % Z eye velo
plot(D{trn}.t1(1:end), D{trn}.eyeVv(1:end), 'b'); % vectorial eye velo
plot([D{trn}.fix2on D{trn}.fix2on], [-300 300], 'm-'); %fix 2 on
plot([D{trn}.fix2off D{trn}.fix2off], [-300 300], 'm-'); %fix 2 off
plot([D{trn}.probeon D{trn}.probeon], [-300 300], 'c-'); %probe on
plot([D{trn}.probeoff D{trn}.probeoff], [-300 300], 'c-'); %probe off
plot([D{trn}.click D{trn}.click], [-300 300], 'k-'); %probe off
set(ax(2),'xlim',[D{trn}.t1(1) D{trn}.t1(end)],'ylim',[-300 300])
CAIdetectSaccades;


%% Compute eye on-/off-set

if ~isfield(D{trn},'eyeON')
%     acc = sqrt(D{trn}.eyeXa.^2 + D{trn}.eyeYa.^2);
%     acc0 = acc(D{trn}.fix2on:end);
%     ind = find(acc0>2000);
%     [pos,n] = GRAIgroup(ind,30,30);
    vel = sqrt(D{trn}.eyeXv.^2 + D{trn}.eyeYv.^2);
    vel0 = vel(D{trn}.fix2on:end);
    ind = find(vel0>30);
    [pos,n]=GRAIgroup(ind,30,30);
    if ~isempty(pos)
        D{trn}.eyeON = D{trn}.t1(ind(pos(1))+D{trn}.fix2on);
        D{trn}.eyeOFF =D{trn}.t1(ind(pos(2))+D{trn}.fix2on);
        
        start = find(D{trn}.t1==D{trn}.eyeON);
        sacend = find(D{trn}.t1==D{trn}.eyeOFF);
        vel1 = D{trn}.eyeVv(start:sacend);
        D{trn}.peakVt = D{trn}.t1(find(D{trn}.eyeVv==max(vel1)));
    else
        D{trn}.eyeON=NaN;
        D{trn}.eyeOFF=NaN;
        D{trn}.peakVt=NaN;
    end
else
    Rarr = min(find(D{trn}.t1 >= D{trn}.eyeON)):max(find(D{trn}.t1 <= D{trn}.eyeOFF));
end

%% Compute eye on-/off-set

if ~isfield(D{trn},'eyeON2')
    vel = sqrt(D{trn}.eyeXv.^2 + D{trn}.eyeYv.^2);
    vel0 = vel(D{trn}.fix2on:end);
    ind = find(vel0>30);
    [pos,n]=GRAIgroup(ind,30,30);
    if ~isempty(pos)
        if length(pos)>2
            D{trn}.eyeON2 = D{trn}.t1(ind(pos(3))+D{trn}.fix2on);
            D{trn}.eyeOFF2 =D{trn}.t1(ind(pos(4))+D{trn}.fix2on);
            start = find(D{trn}.t1==D{trn}.eyeON2);
            sacend = find(D{trn}.t1==D{trn}.eyeOFF2);
            vel1 = D{trn}.eyeVv(start:sacend);
            D{trn}.peakVt2 = D{trn}.t1(find(D{trn}.eyeVv==max(vel1)));
        else
            D{trn}.eyeON2=NaN;
            D{trn}.eyeOFF2=NaN;
            D{trn}.peakVt2=NaN;
        end
    else
        D{trn}.eyeON2=NaN;
        D{trn}.eyeOFF2=NaN;
        D{trn}.peakVt2=NaN;
    end
else
    Rarr = min(find(D{trn}.t1 >= D{trn}.eyeON2)):max(find(D{trn}.t1 <= D{trn}.eyeOFF2));
end

% figure out peak velocity
if D{trn}.eyeON<D{trn}.eyeOFF
    start = min(find(D{trn}.t1>=D{trn}.eyeON));
    sacend = max(find(D{trn}.t1<=D{trn}.eyeOFF));
    vel1 = D{trn}.eyeVv(start:sacend);
    D{trn}.peakV = max(vel1);
    D{trn}.peakVt = D{trn}.t1(find(D{trn}.eyeVv==max(vel1)));
end

if D{trn}.eyeON2<D{trn}.eyeOFF2
    start = min(find(D{trn}.t1>=D{trn}.eyeON2));
    sacend = max(find(D{trn}.t1<=D{trn}.eyeOFF2));
    vel1 = D{trn}.eyeVv(start:sacend);
    D{trn}.peakV2 = max(vel1);
    D{trn}.peakVt2 = D{trn}.t1(find(D{trn}.eyeVv==max(vel1)));
end


for i = 1:2
    axes(ax(i));
    mov(i,1) = plot([D{trn}.eyeON D{trn}.eyeON],[-300 300],'k');
    mov(i,2) = plot([D{trn}.eyeOFF D{trn}.eyeOFF],[-300 300],'k--');
    mov(i,3) = plot([D{trn}.peakVt D{trn}.peakVt],[-300 300],'k:');
    mov(i,1) = plot([D{trn}.eyeON2 D{trn}.eyeON2],[-300 300],'r');
    mov(i,2) = plot([D{trn}.eyeOFF2 D{trn}.eyeOFF2],[-300 300],'r--');
    mov(i,3) = plot([D{trn}.peakVt2 D{trn}.peakVt2],[-300 300],'k:');
end

%% Plot spatial data
% try
axes(ax(6));
cla;hold on;
plot(D{trn}.F1locx,0, 'ko');
plot(D{trn}.F2locx,0, 'k+');
h.xyplot = plot(D{trn}.eyeX(D{trn}.fix2on:D{trn}.fix2on+1000),D{trn}.eyeY(D{trn}.fix2on:D{trn}.fix2on+1000),'g');
% end
set(ax(6),'xlim',[-20 20],'ylim',[-20 20])
 
%% Finalize

sstr = fieldnames(h);
for i = 1:length(sstr)
    set(eval(['h.' sstr{i}]),'visible','on');
end