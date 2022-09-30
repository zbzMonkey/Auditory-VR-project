% close all;
clearvars

% run SigCalRP with RZ6, export calibration data to csv file. 
% calib_file = 'C:\Sound Calibration System\Data\FFT Output_2022_01_14_16_58_10.csv';
% output_file = 'C:\Sound Calibration System\Data\FIR_2P.txt';

calib_file = 'D:\LabProjects\Sound Calibration System\Data\FFT Output_400To80k_2022_07_21_18_19_42.csv';
output_file = 'D:\LabProjects\Sound Calibration System\Data\FIR_tweeter400To80k.txt';

% set sampling rate and ntaps from test.rcx
Fs = 200000;
ntaps = 1024;

fid = fopen(calib_file, 'rt');
x = fread(fid, inf, '*char');
fclose(fid);

x = x(:)';
lines = regexp(x, char(10), 'split');
l1 = lines{1};

parts = regexp(l1, char(44), 'split');
test_signal = parts{end};
temp = str2double(regexp(test_signal, '\d+.\d+', 'match'));

calib_V = temp(1)
calib_dB = temp(2)

freqs = [];
norms = [];
for i = 2:length(lines)-1
    parts = regexp(lines{i}, char(44), 'split');
    freqs = [freqs str2double(parts{1})];
    norms = [norms str2double(parts{3})];
end

freqs = freqs/(Fs/2);
% % % need to stop frequencies less than 3kHz, linearly decrese ampltidue response from 3kHz to 2kHz, and let 2kHz has 0dB loudness.
% k = (norms(23) - (norms(1) - 70))/(freqs(23) - freqs(1));
% b = norms(23) - freqs(23)*k;
% norms(1:23) = k * freqs(1:23) + b; 

% % for tweeter: need to stop frequencies less than 1.5kHz, linearly decrese ampltidue response from 1.5kHz to 400Hz, and let 400Hz has 0dB loudness.
k = (norms(51) - (norms(1) - 70))/(freqs(51) - freqs(1));
b = norms(51) - freqs(51)*k;
norms(1:51) = k * freqs(1:51) + b; 

% make sure beginning is zero
freqs = [0 freqs];
norms = [norms(1) norms];

% make sure end is 1;For 
freqs = [freqs 1];
norms = [norms norms(end)];

filtcoefs = fir2(ntaps,freqs,10.^(norms/20));
fid = fopen(output_file, 'wt+');
fprintf(fid, '%6f\n', filtcoefs);
fclose(fid);

%%
figure('position', [1000 918 560 420])
subplot(2,1,1);

filtresp=fft(filtcoefs,ntaps);
f = freqs*Fs/2;
semilogx(f, norms, 'b-o',linspace(0,Fs/2,length(filtresp)/2),20*log10(abs(filtresp(1:length(filtresp)/2))),'r');
xlabel('Frequency (Hz)'); ylabel('Gain (dB)'); 
% ylim([-20, 40]);xlim([100, 100000]);
title('FIR (High Pass @1.5kHz) for Calibration');

subplot(2,1,2)
stem(filtcoefs);
axis('tight');
xlabel('Coefficient number'); ylabel('Coefficient value');


%% phase response
phi = angle (filtresp(1:length(filtresp)/2));
figure('position', [1000 390 560 420])
subplot(2, 1, 1)
semilogx(linspace(0,Fs/2,length(filtresp)/2), phi,'r');
xlabel('Frequency (Hz)'); ylabel('Phase (radian)'); 
% ylim([-20, 40]);xlim([100, 100000]);
title('FIR (High Pass @1.5kHz) for Calibration');

% % plot group delay
gd = grpdelay(filtcoefs, 1024);
subplot(2, 1, 2)
semilogx(linspace(0,Fs/2,length(filtresp)/2), gd,'r');
ylim([511 513]);
xlabel('Frequency (Hz)'); ylabel('Group Delay'); 
title('FIR, N = 1024');

%% phase response
figure('position', [1000 390 560 420])
freqz(filtcoefs,1,[],Fs);
ax=get(gcf,'Children'); %get the axes handles
li=get(ax(1),'Children'); %get the handle for the line object in the 1st axe
r=get(ax(1),'XLabel'); %get the annotation handle
set(r,'String','log2(Frequency)') %set the string to just Magnitude
xdata=get(li,'Xdata'); %get the linear takes place here
x = log2(xdata);
set(li,'Xdata',x); %replace with log Xdata
xlim([7 17]);
% title('FIR (High Pass @3kHz) for Calibration, 1024 Order');
title('FIR (High Pass @1.5kHz) for Calibration, 1024 Order');

li=get(ax(2),'Children'); %get the handle for the line object in the 2nd axe
r=get(ax(2),'XLabel'); %get the annotation handle
set(r,'String','log2(Frequency)') %set the string to just Magnitude
xdata=get(li,'Xdata'); %get the linear takes place here
x = log2(xdata);
set(li,'Xdata',x); %replace with log Xdata
axes(ax(2));
xlim([7 17]);

%% plot group delay
gd = grpdelay(filtcoefs, 1024);
figure
plot(x(2:end), gd);
ylim([500, 520]);
grid on;
xlabel('log2(Frequency)'); ylabel('Group Delay'); 
title('FIR, N = 1024');

