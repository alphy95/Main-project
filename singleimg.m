function varargout = singleimg(varargin)
% SINGLEIMG MATLAB code for singleimg.fig
%      SINGLEIMG, by itself, creates a new SINGLEIMG or raises the existing
%      singleton*.
%
%      H = SINGLEIMG returns the handle to a new SINGLEIMG or the handle to
%      the existing singleton*.
%
%      SINGLEIMG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLEIMG.M with the given input arguments.
%
%      SINGLEIMG('Property','Value',...) creates a new SINGLEIMG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singleimg_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singleimg_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help singleimg

% Last Modified by GUIDE v2.5 25-Apr-2019 12:37:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singleimg_OpeningFcn, ...
                   'gui_OutputFcn',  @singleimg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before singleimg is made visible.
function singleimg_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to singleimg (see VARARGIN)

% Choose default command line output for singleimg
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes singleimg wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = singleimg_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,pn] = uigetfile('*.bmp');

myImage = fullfile(pn,fn);
fprintf('\nInputFile:\n\t%s',myImage)
im = readFingerImages(myImage);

axes(handles.axes1);
imshow(im);title('Input Image');
handles.ImgData1 = im;
guidata(hObject,handles);
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc
set(handles.edit1,'string','');
  I3 = handles.ImgData1;
disp('Loading saved network...')
load('convnet3.mat');

fprintf('\nPredicting person...')
label = classify(convnet,I3);
my_prediction = string(label);

fprintf('\nCalculating probability...')
layer = 'softmax';
prob = activations(convnet,...
    I3,layer,'OutputAs','rows');
my_probability = max(prob);

text_str = strcat('Prob:',num2str(my_probability));

if my_probability < 0.8
    my_prediction = "UNKNOWN PERSON";
end
title(my_prediction)
fprintf('\nPerson :\n\t%s\nProbability:\n\t%f',...
    my_prediction,my_probability)
%msgbox(my_prediction,'result');
set(handles.edit1,'string',my_prediction);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
