%% Initialisation

clc;
disp('Initialising...')
clearvars;% clear variables
close all;
tic
showImages = 01;% 01 or 0

disp('Defining database path:')
db_path = fullfile(pwd,'tinyDB');
disp(['     ',db_path])

if ~exist(db_path, 'dir')
    error('Database path doesnt exist.')
end

if verLessThan('matlab','9.4')
    error(['imageDatastore is available in R2018a or newer. ', ...
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

