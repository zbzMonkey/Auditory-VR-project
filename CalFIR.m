% run SigCalRP with RZ6, export calibration data to csv file. 
calib_file = 'D:\LabProjects\Sound Calibration System\Data\FFT Output_400To80k_2022_07_21_18_19_42.csv';
output_file = 'D:\LabProjects\Sound Calibration System\Data\FIR_tweeter400To80k.txt';

% set sampling rate and ntaps from test.rcx
Fs = 200000;
ntaps = 256;

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

% make sure beginning is zero
freqs = [0 freqs];
norms = [norms(1) norms];

% make sure end is 1;
freqs = [freqs 1];
norms = [norms norms(end)];

filtcoefs = fir2(ntaps,freqs,10.^(norms/20));
fid = fopen(output_file, 'wt+');
fprintf(fid, '%6f\n', filtcoefs);
fclose(fid);

figure
subplot(2,1,1);

filtresp=fft(filtcoefs,1000);
f = freqs*Fs/2;
plot(f, norms, 'b-o',linspace(0,Fs/2,length(filtresp)/2),20*log10(abs(filtresp(1:length(filtresp)/2))),'r');
axis([min(f) max(f) -30 30]);

xlabel('Frequency (Hz)'); ylabel('Gain (dB)');

subplot(2,1,2)
stem(filtcoefs);
axis('tight');
xlabel('Coefficient number'); ylabel('Coefficient value');

%% plot in log scale
figure('position', [1000 918 560 420])
subplot(2,1,1);

% plot(log2(f), norms, 'b-o',log2(linspace(0,Fs/2,length(filtresp)/2)),20*log10(abs(filtresp(1:length(filtresp)/2))),'r');
% axis([8.5 17 -30 40]);
% xlabel('log2(Frequency)'); ylabel('Gain (dB)'); 
semilogx(f, norms, 'b-o',linspace(0,Fs/2,length(filtresp)/2),20*log10(abs(filtresp(1:length(filtresp)/2))),'r');
xlabel('Frequency (Hz)'); ylabel('Gain (dB)');
title('FIR (400 to 80kHz) for Calibration');

subplot(2,1,2)
stem(filtcoefs);
axis('tight');
xlabel('Coefficient number'); ylabel('Coefficient value');