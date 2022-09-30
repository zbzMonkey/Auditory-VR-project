%% You need to check the second part to make sure all paramethers are right before use-Bingzhen
close all
clear
clc

disp('You need to check the [Get data from different time period] part to make sure all paramethers are right before using-Bingzhen')
%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file
loudness = UntitledPXI1Slot4ai0.Data;

%% Get the frequency recorded
url = 'C:\Speaker THD Measurement\Data\ToneLen_100ms\FFT Output_2022_08_25_16_59_40.csv';
num = xlsread(url);
sound_fre = num(:,1);

%% calculate the loudness
fs = 200000; %hz
time_delay = 2; %sec, the time delay for each frequency band
time_gate = 0.01; % sec, the estimated gate period
mean_sound_whole = [];
error_whole = [];
n_first = 1;
n_last = 200;

for i = n_first:n_last
    sound_data = [];
    locs = [];
    pks = [];
    sound_peak = [];
    sound_data = UntitledPXI1Slot4ai0.Data(((fs*time_delay*(i-1))+1):(fs*time_delay*i));
    [pks,locs] = findpeaks(sound_data);
    sound_peak = sound_data(locs);
    mean_sound = mean(abs(sound_peak));
    error = std(abs(sound_peak));
    mean_sound_whole = cat(2, mean_sound_whole, mean_sound);
    error_whole = cat(2, error_whole, error);
end

errorbar(sound_fre(n_first:n_last), mean_sound_whole,error_whole);
ylabel('Normalized voltage');
xlabel('Frequency (Hz)');
    