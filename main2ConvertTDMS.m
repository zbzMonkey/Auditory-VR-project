%% convert TDMS file to .mat file
clearvars
clc

%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file

%% To convert/load a single file:
% % specify the file path and file name
% fileName = '/Users/hongjiang/Desktop/BCM/Sound Calibration System/Data/Test_B1_2017_08_02_10_43_10.tdms'; %% for MAC
% % fileName = 'C:\...\Sound Calibration System\Data\Test_B1_2017_08_02_10_43_10.tdms'; %% for Windows
% matFileName = simpleConvertTDMS(fileName);
% load(matFileName{1});  %% load the .mat file

%% To convert/load n files:
% n = 2;
% fileName = cell(1, n);
% % specify the file path and file name
% fileName{1} = '/Users/hongjiang/Desktop/BCM/Sound Calibration System/Data/Test_B1_2017_08_02_10_43_10.tdms'; %% for MAC
% % fileName = 'C:\...\Sound Calibration System\Data\Test_B1_2017_08_02_10_43_10.tdms'; %% for Windows
% fileName{2} = '/Users/hongjiang/Desktop/BCM/Sound Calibration System/Data/Test_B4_2017_06_30_12_31_47.tdms'; %% for MAC
% % fileName = 'C:\...\Sound Calibration System\Data\Test_B4_2017_06_30_12_31_47.tdms'; %% for Windows
% matFileName = simpleConvertTDMS(fileName);
% load(matFileName{1}); %% load the first .mat file

% % To save the sound signal as wav file (Treadmill project)
% sound = UntitledPXI1Slot5ai0.Data; %%
% sound = UntitledSoundO2.Data; %%
% sound = sound/max(sound); %% to avoid amplitude > 1V
% fileName0 = strcat('\', fileName(1:end-5));
% wavFileName = strcat(fileFolder, '\', fileName0, '.wav');
% Fs = 48000;
% audiowrite(wavFileName, sound, Fs);
% 
% % To save the sound signal as wav file
% sound = UntitledSoundO.Data; %% if load xxx_Sound.tdms, fs of 200kHz
sound = UntitledPXI1Slot4ai0.Data;
sound = sound./max(sound);
fileName0 = strcat('\', fileName(1:end-5));
wavFileName = strcat(fileFolder, '\', fileName0, '.wav');
Fs = 200000;
audiowrite(wavFileName, sound, Fs);
% 
% % read wav file
% filename = 'C:\Users\Hong\Desktop\sFM_1k_0Hz.wav';
% [sound,Fs] = audioread(filename);
% % check the spectrum using wavelet
% % sound1 = sound(1:3*200000); % choose 3s of data at the beginning
% sound1 = sound(18*200000+1 : 22*200000); % choose 18s-22s of data at the beginning
% sound1 = sound;
% [wt, frq] = cwt(sound1, Fs);
% t = 0 : 1/Fs : (length(sound1)-1)/Fs;
% figure
% surface(t, frq, abs(wt));
% ylabel('f (Hz)');
% surface(t, log2(frq), abs(wt));
% shading flat;
% title('Wavelet Transform');
% ylabel('log2(f (Hz))');
% xlabel('Time (s)');

