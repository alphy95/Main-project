%% Initialisation

clc;
disp('Initialising...')
clearvars;% clear variables
close all;
showImages=0;
performTraining = 0;
disp('Defining database path:')
db_path1 = fullfile(pwd,'trainDB');
disp(['     ',db_path1])


if ~exist(db_path1, 'dir')
    error('Database path doesnt exist.')
end



disp('Preprocessing test database...')
trainds = imageDatastore(db_path1,...
    'IncludeSubfolders',true,...
    'FileExtensions','.bmp',...
    'LabelSource','foldernames',...
    'ReadFcn',@readFingerImages);


%T = countEachLabel(trainds);
%disp(T)


numclasses = numel(unique(trainds.Labels));
numtrainFiles = numpartitions(trainds);

disp(['Number of classes:',num2str(numclasses)]);
disp(['Number of train images:',num2str(numtrainFiles)]);

%%  CNN
fprintf('\nDesigning CNN configuration ...')
layers = [imageInputLayer([65 153 1],'Name','input')
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
    title('Finger Vein Network')
end

fprintf('\nSpecifying Hyper-parameters...')
options = trainingOptions('adam',...
    'Plots','training-progress',...
    'InitialLearnRate',0.00001,...
    'MaxEpochs',30,...
    'Shuffle','every-epoch',...
    'Verbose',true,...
    'VerboseFrequency',5 );


fprintf('\nTraining the network ...\n')
if performTraining
    
    convnet = trainNetwork(trainds,layers,options);
    fprintf('\nTraining Completed.')
    
    fprintf('\nSaving trained network for future use ...')
    save convnet3.mat convnet
else
    fprintf('\nLoading trained network...')
    load('convnet3.mat')
end



[fn,pn] = uigetfile({'*.bmp';'*.jpeg'});

myImage = fullfile(pn,fn);
fprintf('\nInputFile:\n\t%s',myImage)
im = readFingerImages(myImage);

fprintf('\nPredicting person...')
label = classify(convnet,im);
my_prediction = string(label);

fprintf('\nCalculating probability...')
layer = 'softmax';
prob = activations(convnet,...
    im,layer,'OutputAs','rows');
my_probability = max(prob);

text_str = strcat('Prob:',num2str(my_probability));
position = [10,10];
box_color = 'red';
myImage = insertText(imread(myImage),position,text_str,...
    'FontSize',12,...
    'BoxColor',box_color,...
    'BoxOpacity',0.4,...
    'TextColor','white');
imshow(myImage)
 

if my_probability < 0.8
    my_prediction = "UNKNOWN PERSON";
end
title(my_prediction)
fprintf('\nPerson :\n\t%s\nProbability:\n\t%f',...
    my_prediction,my_probability)
msgbox(my_prediction,'Result');
