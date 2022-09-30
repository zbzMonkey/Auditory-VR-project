%% You need to check the second part to make sure all paramethers are right before use-Bingzhen
close all
clear
clc

disp('You need to check the [Get data from different time period] part to make sure all paramethers are right before using-Bingzhen')
%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file

%% Get the frequency recorded
url = Get_CSV_file;
num = xlsread(url);
sound_fre = num(:,1);

%% Get data from different time period
n_first = 1; %the start of data order
n_last = 179; %the end of data order
fs = 200000; %sample frequency, hz
time_delay = 0.1; %each frequency will show 'time_delay', sec, we record 100ms/2000ms (the value should be 0.1/2) data for each frequency band
time_gate = 0.005; %sec, get rid of data between two recording or the spectral splatter
sound_data = [];
low_fre = 0; % the range of frequency
high_fre = 80000; % the range of frequency
time_reso = 0.5; %sec, the resolotion is higher, the frequency resolution is lower
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

%     figure
%     pspectrum(minus_mean_sound_data,fs,'Leakage',leakage_value,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
    figure
    [pxx0,f0] = pspectrum(minus_mean_sound_data,fs, 'Leakage',leakage_value,'power','FrequencyLimits',[low_fre high_fre]);    
    plot(f0,pow2db(pxx0))

    [pxx0_pks, pxx0_locs] = findpeaks(pxx0,f0);
    p1 = [];
    p1 = max(pxx0_pks);
   
% get the data without input frequency band
    pxx1 = [];
    w0 = sound_fre(i)/(fs/2);
    bw = w0/10; % the bandwidth
    [b,a] = iirnotch(w0,bw);
    [H,w] = freqz(b,a);
    minus_mean_sound_data_filter = [];
    minus_mean_sound_data_filter = filter(b,a, minus_mean_sound_data');
%     figure
%     pspectrum(minus_mean_sound_data_filter,fs,'Leakage',leakage_value,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
    figure
    [pxx1,f1] = pspectrum(minus_mean_sound_data_filter,fs, 'Leakage',leakage_value,'power','FrequencyLimits',[low_fre high_fre]);    
    plot(f1,pow2db(pxx1))  

    [pxx1_pks, pxx1_locs] = findpeaks(pxx1,f1);
    thd_n (i) = sqrt(sum(pxx1_pks(:))/p1)*100; % the thd plus noise, %

%     % Another way to draw spectrum figure
%     figure
%     [pxx2,f2,pxxc2] = pwelch(minus_mean_sound_data,hamming(time_reso*fs),noverlap,nfft,fs,'ConfidenceLevel',confiden);
%     plot(f2,pow2db(pxx2))
%     figure
%     [pxx3,f3,pxxc3] = pwelch(minus_mean_sound_data,kaiser(time_reso*fs, beta),noverlap,nfft,fs,'ConfidenceLevel',confiden);
%     plot(f3,pow2db(pxx3))

 % Show the different frequency band used to calculate thd
    thd_db = [];
    Pow_of_harmonic = [];
    frequency_of_harmonic = [];
    [thd_db, harmpow, harmfreq] = thd(minus_mean_sound_data, fs, thd_times, 'aliased');
    thd_percent(i) = (10^(thd_db/20))*100; 
    T = table(harmfreq, harmpow, 'VariableNames', {'Frequency', 'Power'});
    Pow_of_harmonic = table2array(T(1:thd_times,2));
    frequency_of_harmonic = table2array(T(1:thd_times,1));
    Pow_of_harmonic_whole = cat(2, Pow_of_harmonic_whole, Pow_of_harmonic);
    figure
    thd(minus_mean_sound_data,fs,thd_times, 'aliased');
%     display (thd_percent);

end 

% plot the figure of all harmonic
figure
for i = 1:length(frequency_of_harmonic)
power_each_harminic(i) = mean(Pow_of_harmonic_whole(i,:));
% error_power_each_harminic(i) = std(Pow_of_harmonic_whole(i,:));
end
boxchart(Pow_of_harmonic_whole');
hold on
plot(power_each_harminic, '-*');
ylabel('Power');
xlabel('Order of harmonic');
hold off
% [tbl] = annova_multiple(Pow_of_harmonic_whole);

% plot thd
figure
plot(sound_fre(n_first:n_last), thd_percent)
ylabel('THD (%)')
xlabel('Frequency (Hz)')
title('THD of different frequency range')

%plot thd+n
figure
plot(sound_fre(n_first:n_last), thd_n(n_first:n_last))
ylabel('THD+n (%)')
xlabel('Frequency (Hz)')
title('THD+n of different frequency range')