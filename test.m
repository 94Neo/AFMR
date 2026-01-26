%% Disclaimer
% The data used in this code are synthetically generated, not real Raman spectra,
% and are provided solely for demonstrating the reconstruction performance of the AFMR method.

clear; clc;

% ============ Load data ============
noisyFolder = '..\experiments\testData\noisyData';
outputFolder = '..\experiments\intermediateMatrices';

if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% ============ Load the trained model ============
load('trained_UNet_windowWidth=32.mat', 'net');


% ============ Get test data ============
noisyFiles = dir(fullfile(noisyFolder, '*.mat'));
numSamples = length(noisyFiles);

targetHeight = 320;   
targetWidth  = 96;   

for i = 1:numSamples
    % === Load noisy data ===
    noisyPath = fullfile(noisyFolder, noisyFiles(i).name);
    noisy = load(noisyPath);
    fieldN = fieldnames(noisy);
    noisyData = noisy.(fieldN{1});   

    originalWidth = size(noisyData, 2);  

    % === Similarly pad or crop cleanData to match the target width ===
    if originalWidth < targetWidth
        pad = targetWidth - originalWidth;    
        padLeft  = floor(pad / 2);            
        padRight = pad - padLeft;             

        noisyData = padarray(noisyData, [0 padLeft],  'replicate', 'pre');
        noisyData = padarray(noisyData, [0 padRight], 'replicate', 'post');

    elseif originalWidth > targetWidth
        noisyData = noisyData(:, 1:targetWidth);
        padLeft = 0;
    else
        padLeft = 0;
    end

    % === Construct network input ===
    input = zeros(targetHeight, targetWidth, 2, 'single');
    input(:,:,1) = single(real(noisyData));
    input(:,:,2) = single(imag(noisyData));

    % === Perform prediction ===
    denoised = predict(net, input); 

    % === Restore complex form ===
    denoisedComplex = ...
        squeeze(denoised(:,:,1)) + 1i * squeeze(denoised(:,:,2));

    % === Crop back to original width [320×93] ===
    if originalWidth < targetWidth
        denoisedComplex = denoisedComplex(:, ...
            padLeft+1 : padLeft+originalWidth);
    elseif originalWidth > targetWidth
        denoisedComplex = denoisedComplex(:, 1:originalWidth);
    end

    % === Save results ===
    [~, name, ~] = fileparts(noisyFiles(i).name);
    save(fullfile(outputFolder, [name '_denoised.mat']), 'denoisedComplex');
end

