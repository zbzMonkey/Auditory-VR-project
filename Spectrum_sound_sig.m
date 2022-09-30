%% convert TDMS file to .mat file
close all
clear
clc

%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file

%% Get the frequency recorded
url = Get_CSV_file;
num = xlsread(url);
sound_fre = num(:,1);

%% Get data from different time period
n_first = 120; %the start of data order
n_last = 120; %the end of data order
fs = 200000; %sample frequency, hz
time_delay = 0.1; %each frequency will show 'time_delay', sec
sound_data = [];
low_fre = 0;
high_fre = 80000;
time_reso = 0.01; %sec
nfft = 256; % nfft = fs/F, F is the fre resolution, when fs = 2ookhz, nfft=200, F = 1khz; most of time, nfft = 2^x (x is integer)
beta = 8; % 6-8 would be better for THD detection
noverlap = (time_reso*fs)/2;
confiden = 0.95;
thd_percent = [];

for i = n_first:n_last
    sound_data(i,:) = UntitledPXI1Slot4ai0.Data((1+fs*time_delay*(i-1)):(fs*time_delay*i));
    figure
    pspectrum(sound_data(i,:),fs,'Leakage',0.5,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
    figure
    [pxx0,f0] = pspectrum(sound_data(i,:),fs, 'Leakage',0.5,'FrequencyLimits',[low_fre high_fre])    
    plot(f0,pow2db(pxx0))
    figure
    [pxx1,f1,pxxc1] = pwelch(sound_data(i,:),hamming(time_reso*fs),noverlap,nfft,fs,'ConfidenceLevel',confiden);
    plot(f1,pow2db(pxx1))
    figure
    [pxx2,f2,pxxc2] = pwelch(sound_data(i,:),kaiser(time_reso*fs, beta),noverlap,nfft,fs,'ConfidenceLevel',confiden);
    plot(f2,pow2db(pxx2))

    thd_db = [];
    [thd_db, harmpow, harmfreq] = thd(sound_data(i,:), fs, 7);
    thd_percent(i) = (10^(thd_db/20))*100; 
    T = table(harmfreq, harmpow, 'VariableNames', {'Frequency', 'Power'});
    figure
    thd(sound_data(i,:),fs,7);
    display (thd_percent);
end 

figure
plot(sound_fre(n_first:n_last), thd_percent)
ylabel('THD (%)')
xlabel('Frequency (Hz)')
title('THD of different frequency range')






    