%% convert TDMS file to .mat file
close all
clear
clc

%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file

%% Get the frequency recorded
url = 'C:\Speaker THD Measurement\Data\ToneLen_100ms\FFT Output_2022_08_25_16_59_40.csv';
num = xlsread(url);
sound_fre = num(:,1);

%% Get data from different time period
n_first = 1; %the start of data order
n_last = 200; %the end of data order
fs = 200000; %sample frequency, hz
time_delay = 0.1; %each frequency will show 'time_delay', sec
low_fre = 0;
high_fre = 80000;
time_reso = 0.001; %sec
nfft = 256; % nfft = fs/F, F is the fre resolution, when fs = 2ookhz, nfft=200, F = 1khz; most of time, nfft = 2^x (x is integer)
beta = 8;
noverlap = (time_reso*fs)/2;
confiden = 0.95;
sound_data_whole = [];

for i = n_first:n_last
    sound_data = [];
    sound_data = UntitledPXI1Slot4ai0.Data((1+fs*time_delay*(i-1)):(fs*time_delay*i));
    sound_data_whole = cat(1,sound_data_whole,sound_data);
end

figure
pspectrum(sound_data_whole,fs,'Leakage',0.5,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
