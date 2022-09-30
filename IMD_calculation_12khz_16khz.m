%% You need to check the second part to make sure all paramethers are right before use-Bingzhen
%% Nan
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
fh = 16000; % high frequency input
fl = 12000; % low frequency input
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
    P_fh_fl = [];
    P_fl2_fh = [];
    P_fh2_fl = [];

%     figure
%     pspectrum(minus_mean_sound_data,fs,'Leakage',leakage_value,'spectrogram','FrequencyLimits',[low_fre high_fre],'TimeResolution',time_reso)
    figure
    [pxx0,f0] = pspectrum(minus_mean_sound_data,fs, 'Leakage',leakage_value,'power','FrequencyLimits',[low_fre high_fre]);    
    plot(f0,pow2db(pxx0))
    
    pxx0_pks = findpeaks(pxx0,f0);
    pxx0_reorder = sort(pxx0_pks);
    pxx0_2max = pxx0_reorder((end-1):end);
    fh_fl = fh-fl;
    fl2_fh = (2*fl)-fh;
    fh2_fl = (2*fh)-fl;
    fl__fh = fl+fh;
    fl2 = 2*fl;
    fh2 = 2*fh;
    fl3 = 3*fl;
    fh3 = 3*fh;
    fl2__fh = 2*fl+fh;
    fh2__fl = 2*fh+fl;



    minus_f01 = [];
    minus_f02 = [];
    minus_f03 = [];
    minus_f04 = [];
    minus_f05 = [];
    minus_f06 = [];
    minus_f07 = [];
    minus_f08 = [];
    minus_f09 = [];
    minus_f010 = [];

    for j = 1:length(f0)
    minus_f01(j) = abs(f0(j)-fh_fl);
    minus_f02(j) = abs(f0(j)-fl2_fh);
    minus_f03(j) = abs(f0(j)-fh2_fl);
    minus_f04(j) = abs(f0(j)-fl__fh);
    minus_f05(j) = abs(f0(j)-fl2);
    minus_f06(j) = abs(f0(j)-fh2);
    minus_f07(j) = abs(f0(j)-fl3);
    minus_f08(j) = abs(f0(j)-fh3);
    minus_f09(j) = abs(f0(j)-fl2__fh);
    minus_f10(j) = abs(f0(j)-fh2__fl);
    end

    min_value1 = min(minus_f01);
    min_value2 = min(minus_f02);
    min_value3 = min(minus_f03);
    min_value4 = min(minus_f04);
    min_value5 = min(minus_f05);
    min_value6 = min(minus_f06);
    min_value7 = min(minus_f07);
    min_value8 = min(minus_f08);
    min_value9 = min(minus_f09);
    min_value10 = min(minus_f10);
    nearest_value1 = f0(find(minus_f01 == min_value1));
    nearest_value2 = f0(find(minus_f02 == min_value2));
    nearest_value3 = f0(find(minus_f03 == min_value3));
    nearest_value4 = f0(find(minus_f04 == min_value4));
    nearest_value5 = f0(find(minus_f05 == min_value5));
    nearest_value6 = f0(find(minus_f06 == min_value6));
    nearest_value7 = f0(find(minus_f07 == min_value7));
    nearest_value8 = f0(find(minus_f08 == min_value8));
    nearest_value9 = f0(find(minus_f09 == min_value9));
    nearest_value10 = f0(find(minus_f10 == min_value10));
    [is1,pos1] = ismember(nearest_value1,f0);
    [is2,pos2] = ismember(nearest_value2,f0);
    [is3,pos3] = ismember(nearest_value3,f0);
    [is1,pos4] = ismember(nearest_value4,f0);
    [is2,pos5] = ismember(nearest_value5,f0);
    [is3,pos6] = ismember(nearest_value6,f0);
    [is1,pos7] = ismember(nearest_value7,f0);
    [is2,pos8] = ismember(nearest_value8,f0);
    [is3,pos9] = ismember(nearest_value9,f0);
    [is3,pos10] = ismember(nearest_value10,f0);
    Pl = mean(pxx0(pos1));
    P2 = mean(pxx0(pos2));
    P3 = mean(pxx0(pos3));
    P4 = mean(pxx0(pos4));
    P5 = mean(pxx0(pos5));
    P6 = mean(pxx0(pos6));
    P7 = mean(pxx0(pos7));
    P8 = mean(pxx0(pos8));
    P9 = mean(pxx0(pos9));
    P10 = mean(pxx0(pos10));

    P_whole = [Pl P2 P3 P4 P5 P6 P7 P8 P9 P10];
    imd_12_16(i) = sqrt(sum(P_whole)/(sum(pxx0_2max)))*100;
end

% plot imd
figure
x_imd = [0.1:0.1:20];
plot(x_imd, imd_12_16)
ylabel('IMD (%)')
xlabel('Segment (0.1s each)')
title('IMD of different segments')
    





