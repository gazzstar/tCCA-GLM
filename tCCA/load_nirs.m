function [fq, t, AUX, d_long, d_short, d0_long, d0_short, d, d0, SD, s, lstLongAct,lstShortAct,lstHrfAdd] = load_nirs(filename,flag_conc)


if contains(filename,'nirs')
    load([filename], '-mat');
else
    load([filename '.nirs'], '-mat');
end
% sampling frequency
fq = abs(1/(t(1)-t(2)));

% auxilliary channels
AUX = aux(:,2:7);
% acc1 = aux(:,2); % accelerometer
% acc2 = aux(:,3); % accelerometer
% acc3 = aux(:,4); % accelerometer
% PPG = aux(:,5); % pulse
% BP = aux(:,6); % blood pressure waveform
% RESP = aux(:,7); % respiration

if flag_conc
    dod = hmrIntensity2OD(d);
    dod = hmrBandpassFilt(dod, fq, 0, 0.5);
    dc = hmrOD2Conc(dod, SD, [6 6]);
    
    dod = hmrIntensity2OD(d0);
    dod = hmrBandpassFilt(dod, fq, 0, 0.5);
    dc0 = hmrOD2Conc(dod, SD, [6 6]);
    
    % resize conc to match the size of d, HbO first half, HbR second half
    foo = [ squeeze(dc(:,1,:)),squeeze(dc(:,2,:))];
    % get d_long and short(and active) now in conc
    d_long = [foo(:,lstLongAct), foo(:,lstLongAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    d_short = [foo(:,lstShortAct), foo(:,lstShortAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    
    foo = [ squeeze(dc0(:,1,:)),squeeze(dc0(:,2,:))];
    % get d_long and short(and active) now in conc
    d0_long = [foo(:,lstLongAct), foo(:,lstLongAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    d0_short = [foo(:,lstShortAct), foo(:,lstShortAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
else
    
    % get d_long and short(and active)
    d_long = [d(:,lstLongAct), d(:,lstLongAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    d_short = [d(:,lstShortAct), d(:,lstShortAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    d0_long = [d0(:,lstLongAct), d0(:,lstLongAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    d0_short = [d0(:,lstShortAct), d0(:,lstShortAct+size(d,2)/2)]; % first half 690 nm; second half 830 nm
    
end