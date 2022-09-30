%% convert TDMS file to .mat file
clearvars
clc

%% If no input, then prompt the user a dialog window to choose the file: 
matFileName = simpleConvertTDMS;
load(matFileName{1}); %% load the .mat file






