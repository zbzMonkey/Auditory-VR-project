%% You need to check the second part to make sure all paramethers are right before use-Bingzhen
close all
clear
clc

disp('You need to check the [Get data from different time period] part to make sure all paramethers are right before using-Bingzhen')
%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file

%% Get data from different time period
n_first = 1; %the start of data order
n_last = 200; %the end of data order
fh = 19000; %hz
fl = 20000; %hz

fs = 200000; %sample frequency, hz
time_delay = 0.1; %each frequency will show 'time_delay', sec, we record 100ms/2000ms (the value should be 0.1/2) data for each frequency band
time_gate = 0.01; %sec, get rid of data between two recording or the spectral splatter
sound_data = [];
low_fre = 0; % the range of frequency
high_fre = 80000; % the range of frequency
time_reso = 0.001; %sec, the resolotion is higher, the frequency resolution is lower
nfft = 612; % nfft = fs/F, F is the fre resolution, when fs = 2ookhz, nfft=200, F = 1khz; most of time, nfft = 2^x (x is integer)
beta = 8; % 6-8 would be better for THD detection, the value of kaiser window
noverlap = (time_reso*fs)/2; % the overlap region in spectrum figure
confiden = 0.95;
leakage_value = 0.5; % [0 1]
thd_times = 7; % rang of harmonic distortion: from 1st to (thd_times)th
thd_percent = [];
Pow_of_harmonic_whole = [];

for i = n_first:n_last
    sound_data(i,:) = UntitledPXI1Slot4ai0.Data((time_gate*fs+fs*time_delay*(i-1)):(fs*time_delay*i-time_gate*fs)); % move the edge, get rid og gate part
    minus_mean_sound_data = [];
    minus_mean_sound_data = sound_data(i,:)-mean(sound_data(i,:));  % remove DC
    pxx0 = [];
    f0 = [];
    pxx0_pks = [];
    pxx0_reorder = [];
    pxx0_2max = [];

%     figure
%     pspectrum(minus_mean_sound_data,fs,'Leakage',leakage_value,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
    figure
    [pxx0,f0] = pspectrum(minus_mean_sound_data,fs, 'Leakage',leakage_value,'power','FrequencyLimits',[low_fre high_fre]);    
    plot(f0,pow2db(pxx0))
    
    pxx0_pks = findpeaks(pxx0,f0);
    pxx0_reorder = sort(pxx0_pks);
    pxx0_2max = pxx0_reorder((end-1):end);
    
    % get the data without input frequency band
    pxx1 = [];
    wh = fh/(fs/2);
    bh = wh/10; % the bandwidth
    [b1,a1] = iirnotch(wh,bh);
%     [H,wh] = freqz(b1,a1);
    minus_mean_sound_data_filter = [];
    minus_mean_sound_data_filter = filter(b1,a1, minus_mean_sound_data');

    wl = fl/(fs/2);
    bl = wl/10; % the bandwidth
    [b2,a2] = iirnotch(wl,bl);
    minus_mean_sound_data_filter_whole = [];
    minus_mean_sound_data_filter_whole = filter(b2,a2, minus_mean_sound_data_filter);

    figure
    [pxx1,f11] = pspectrum(minus_mean_sound_data_filter_whole,fs, 'Leakage',leakage_value,'power','FrequencyLimits',[low_fre high_fre]);    
    plot(f11,pow2db(pxx1))  


end

% plot imd
figure
x_imd = [0.1:0.1:20];
plot(x_imd, imd_19_20)
ylabel('IMD (%)')
xlabel('Segment (0.1s each)')
title('IMD of different segments')
    





