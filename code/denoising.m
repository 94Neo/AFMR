%% Disclaimer
% The data used in this code are synthetically generated, not real Raman spectra,
% and are provided solely for demonstrating the reconstruction performance of the AFMR method.

clear; clc; close all;

% ============ Load intermediate matrix ============
inputFolderR = '..\experiments\intermediateMatrices';

% ============ Load noisy data ============
noisyDataFolderM = '..\experiments\testData\noisyData';   


startIndex = 3501;
numSpectra = 10; %1500;
endIndex =   startIndex + numSpectra-1;
threshold_ratio = 0.4;
data_denoisedR = zeros(467,575);

% STFT parameters
Fs = 1;  
windowLength = 32;
nfftSele = 10;
wind = hamming(windowLength); 
olen = round(0.75 * windowLength);
nfft = windowLength * nfftSele;

for j = startIndex:endIndex

    fileName = sprintf('%d-normalizedNoisySNR=5Spectrum-WL=32+Hamming+olen=24+Nfft=320_denoised.mat', j);
    fullPath = fullfile(inputFolderR, fileName);


    if ~exist(fullPath, 'file')
        warning('File not found：%s，...', fullPath);
        continue;
    end

    load(fullPath);

    R_abs = abs(denoisedComplex);
    
    % figure;
    % imagesc(R_abs);
    % title('Magnitude of intermediate matrix',j);
    
    % Thresholding and binarization
    threshold_valueI_R = threshold_ratio * max(R_abs(:));
    mask_Rabs = R_abs >= threshold_valueI_R; 
    mask_Rabs = double(mask_Rabs);
    
    % figure;
    % imagesc(mask_Rabs); 
    % title(sprintf('Mask for %s', fileName));

    % Load noisy data
    fileNameII = sprintf('%d-normalizedNoisySNR=5Spectrum-WL=32+Hamming+olen=24+Nfft=320.mat', j);
    fullPathII = fullfile(noisyDataFolderM, fileNameII);
    load(fullPathII);
    

    % denoising using mask
    complexR = s .* mask_Rabs; 
    
    % figure;
    % imagesc(abs(complexR));
    % title('STFT after applying spectral mask');


    % ISTFT
    [ix2R,~] = istft(complexR, Fs, 'Window', wind, 'OverlapLength', olen, 'FFTLength', nfft);
    x_denoisedR = real(ix2R');
    x_denoisedR = x_denoisedR(1,100:100+574);

    
    % Min-max normalization
    nor_x_denoisedR = (x_denoisedR-min(x_denoisedR))/(max(x_denoisedR)-min(x_denoisedR));

    data_denoisedR(j,:) = nor_x_denoisedR; 
    
    % reconstructed spectrum
    figure;
    plot(nor_x_denoisedR,'r');
    title('AFMR reconstructed spectrum');
    hold on;

    % clean spectrum
    load('..\demoData\demoData.mat');
    cleanData = demoData;
    plot(cleanData(j,:)+1,'k');

    % noisy spectrum
    load('..\demoData\demoNoisyData.mat');
    noisyData = demoNoisySpectrum;
    plot(noisyData(j,:)+2,'b');
    legend('AFMR reconstructed spectrum','clean spectrum','noisy spectrum');
end
