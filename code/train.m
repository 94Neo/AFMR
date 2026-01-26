%% Disclaimer
% The data used in this code are synthetically generated, not real Raman spectra,
% and are provided solely for demonstrating the reconstruction performance of the AFMR method.

clear; clc;

% ============ Load input data ============
cleanFolder = '..\experiments\trainingData\cleanData';
noisyFolder = '..\experiments\trainingData\noisyData';

% ============ Get file names and sort them ============
cleanFiles = dir(fullfile(cleanFolder, '*.mat'));
noisyFiles = dir(fullfile(noisyFolder, '*.mat'));

numSamples = length(cleanFiles);
inputSize = [320 96 2];  
NumClasses = 2;          

targetWidth = inputSize(2); 

% ============ Construct training data ============
X = zeros([inputSize, numSamples], 'single');
Y = zeros([inputSize, numSamples], 'single');

for i = 1:numSamples
    noisyData = load(fullfile(noisyFolder, noisyFiles(i).name));
    fieldN = fieldnames(noisyData);
    noisyData = noisyData.(fieldN{1});

    % Automatically pad or crop noisyData to match targetWidth
    originalWidth = size(noisyData, 2);
    if originalWidth < targetWidth
        pad = targetWidth - originalWidth;
        padLeft = floor(pad / 2);
        padRight = pad - padLeft;
        noisyData = padarray(noisyData, [0 padLeft], 'replicate', 'pre');
        noisyData = padarray(noisyData, [0 padRight], 'replicate', 'post');
    elseif originalWidth > targetWidth
        noisyData = noisyData(:, 1:targetWidth);
    end

    % Load clean data
    cleanData = load(fullfile(cleanFolder, cleanFiles(i).name));
    fieldC = fieldnames(cleanData);
    cleanData = cleanData.(fieldC{1});

    % Similarly pad or crop cleanData to match the target width
    originalWidthC = size(cleanData, 2);
    if originalWidthC < targetWidth
        padC = targetWidth - originalWidthC;
        padLeftC = floor(padC / 2);
        padRightC = padC - padLeftC;
        cleanData = padarray(cleanData, [0 padLeftC], 'replicate', 'pre');
        cleanData = padarray(cleanData, [0 padRightC], 'replicate', 'post');
    elseif originalWidthC > targetWidth
        cleanData = cleanData(:, 1:targetWidth);
    end

    X(:,:,1,i) = single(real(noisyData));
    X(:,:,2,i) = single(imag(noisyData));
    Y(:,:,1,i) = single(real(cleanData));
    Y(:,:,2,i) = single(imag(cleanData));
end

% ======= % Split data into training and validation sets =======
rng(0); 
idx = randperm(numSamples);

numTrain = floor(0.874 * numSamples) + 1; 
trainIdx = idx(1:numTrain);
valIdx = idx(numTrain+1:end);

% Create training datastore
trainDS = combine(...
    arrayDatastore(X(:,:,:,trainIdx), 'IterationDimension', 4),...
    arrayDatastore(Y(:,:,:,trainIdx), 'IterationDimension', 4));

% Create validation datastore
valDS = combine(...
    arrayDatastore(X(:,:,:,valIdx), 'IterationDimension', 4),...
    arrayDatastore(Y(:,:,:,valIdx), 'IterationDimension', 4));

% ============  Construct U-Net ============
lgraph = unet(inputSize, NumClasses);

% ============ Remove default output layer ============
toRemove = {'Segmentation-Layer','Softmax-Layer','Classification-Layer'};
existLayers = string({lgraph.Layers.Name});
validRemove = toRemove(ismember(toRemove, existLayers));
if ~isempty(validRemove)
    lgraph = removeLayers(lgraph, validRemove);
end

% ============ Add regression output layer ============
preOutputLayerName = lgraph.Layers(end).Name;
outputConv = convolution2dLayer(1, NumClasses, 'Name', 'regression_conv', ...
    'WeightsInitializer', 'he', 'BiasInitializer', 'zeros');
regressionOut = regressionLayer('Name', 'regression_output');
lgraph = addLayers(lgraph, [outputConv regressionOut]);
lgraph = connectLayers(lgraph, preOutputLayerName, 'regression_conv');


options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.3, ...      
    'LearnRateDropPeriod', 20, ...       
    'MaxEpochs', 80, ...
    'MiniBatchSize', 8, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', valDS, ...
    'ValidationFrequency', 10, ...
    'ValidationPatience', 6, ...         
    'Plots', 'training-progress', ...
    'Verbose', true, ...
    'ExecutionEnvironment','gpu');



% ============ Start training the network ============
lgraph = layerGraph(lgraph);
net = trainNetwork(trainDS, lgraph, options);

% ============ Save the trained model ============
save('trained_UNet_windowWidth=32.mat', 'net');
