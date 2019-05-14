%% Initialisation

clc;
disp('Initialising...')
clearvars;% clear variables
close all;
tic
showImages = 0;% 01 or 0
train = 0;

disp('Defining database path:')
db_path = fullfile(pwd,'newDB');
disp(['     ',db_path])

if ~exist(db_path, 'dir')
    error('Database path doesnt exist.')
end

if verLessThan('matlab','8.6')
    error(['imageDatastore is available in R2015b or newer. ', ...
        'For older releases, use dir() based code instead.'])
end

disp('Creating image datastore...')
imds = imageDatastore(db_path,...
    'IncludeSubfolders',true,...
    'FileExtensions','.bmp',...
    'LabelSource','foldernames',...
    'ReadFcn',@readFingerImages);


T = countEachLabel(imds);
disp(T)

[trainds,testds] = splitEachLabel(imds,.8);

numclasses = numel(unique(imds.Labels));
numFiles = numpartitions(imds);
numtrainFiles = numpartitions(trainds);
numtestFiles = numpartitions(testds);

disp(['Total number of images:',num2str(numFiles)]);
disp(['Number of train images:',num2str(numtrainFiles)]);
disp(['Number test of images:',num2str(numtestFiles)]);

if showImages
    montage(imds,...
        'BorderSize',[1,1],...
        'BackgroundColor',[.9 .8 .8])
    title('Image dataset')
    xlabel(strcat(num2str(numFiles),' images'))
end

%% Use CNN
fprintf('\nDesigning CNN configuration ...')
layers = [imageInputLayer([65 153 1],'Name','input')%'Normalization','zerocenter'
    convolution2dLayer([5,5],153,'Stride',1,'Name','CL1')
    maxPooling2dLayer(2,'Stride',2,'Name','M1')
    convolution2dLayer([5,5],512,'Stride',1,'Name','CL2')
    maxPooling2dLayer(2,'Stride',2,'Name','M2')
    convolution2dLayer([5,5],768,'Stride',1,'Name','CL3')
    maxPooling2dLayer(2,'Stride',2,'Name','M3')
    convolution2dLayer([4,15],1024,'Stride',1,'Name','CL4')
    reluLayer('Name','R1')
    fullyConnectedLayer(numclasses,'Name','fc6')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','final')];

lgraph = layerGraph(layers);

if showImages
    figure
    plot(lgraph)
end

fprintf('\nSpecifying Training Options...')
options = trainingOptions('adam',...
    'Plots','training-progress',...
    'InitialLearnRate',0.00001,...
    'MaxEpochs',30,...
    'Shuffle','every-epoch',...
    'LearnRateSchedule','none',...
    'Verbose',true,...
    'VerboseFrequency',5 );
if train
    
fprintf('\nTraining the network ...\n')
convnet = trainNetwork(trainds,layers,options);
fprintf('\nTraining Completed.')
 
fprintf('\nSaving trained network for future use ...')
save convnet2 convnet
else
fprintf('\nLoading trained network \n')
load('convnet2.mat');
end
 
 fprintf('\nTesting the network on Test Database ...')
 YPred = classify(convnet,testds);
 Ytest = testds.Labels;
 
 format compact

 accuracy = sum(YPred == Ytest)/numel(Ytest)*100; 
 fprintf('\n\t\tAccuracy :%f ',accuracy)
 %plotconfusion(Ytest,YPred)
 disp('Program completed .')
 t1 = toc;
 timeString = datestr(t1/(24*60*60), 'MM:SS.FFF');
 fprintf('\nTime taken : %s\n',timeString)
 

       
       