%% Disclaimer
% The data used in this code are synthetically generated, not real Raman spectra,
% and are provided solely for demonstrating the reconstruction performance of the AFMR method.

clear; clc; close all;
%% clean data
% Load demo data
load('..\demoData\demoData.mat');
[xLength,yLength] = size(demoData);

% Pad zeros at both ends to fully utilize edge information
padding = zeros(xLength,100);
spectrum = [padding demoData padding];

Fs = 1;  
windowLength = 32;
nfftSele = 10;
wind = hamming(windowLength); 
olen = round(0.75 * windowLength);
nfft = windowLength * nfftSele;

% Output complex matrix s obtained from STFT
sOutputFilePath = '..\demoData\demoSpectrogram\cleanData';


for i = 1:5000

    data = spectrum(i,:);

    s = stft(data,Fs,'Window',wind,'OverlapLength',olen,'FFTLength',nfft);

    fileName = sprintf('%d-Spectrum-WL=%d+Hamming+olen=%d+Nfft=%d.mat',i,windowLength,olen,nfft);
    outputFilePath = fullfile(sOutputFilePath,fileName);
    save(outputFilePath,"s");

end


%% noisy data

% Load noisy demo data
load('..\demoData\demoNoisyData.mat');
[xLength,yLength] = size(demoNoisySpectrum);

% Pad zeros at both ends to fully utilize edge information
padding = zeros(xLength,100);
spectrum = [padding demoNoisySpectrum padding];

Fs = 1;  
windowLength = 32;
nfftSele = 10;
wind = hamming(windowLength); 
olen = round(0.75 * windowLength);
nfft = windowLength * nfftSele;

% Output complex matrix s obtained from STFT
sOutputFilePath = '..\demoData\demoSpectrogram\noisyData';


for i = 1:5000

    data = spectrum(i,:);
    
    s = stft(data,Fs,'Window',wind,'OverlapLength',olen,'FFTLength',nfft);

    fileName = sprintf('%d-normalizedNoisySNR=5Spectrum-WL=%d+Hamming+olen=%d+Nfft=%d.mat',i,windowLength,olen,nfft);
    outputFilePath = fullfile(sOutputFilePath,fileName);
    save(outputFilePath,"s");

end
