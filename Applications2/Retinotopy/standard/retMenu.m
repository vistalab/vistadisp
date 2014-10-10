function varargout = retMenu(varargin)
% retMenu - gui for retinotopic mapping program parameters.
%
% SOD 10/2005: created it, consolidating several existing gui's.
% JW 1/2009: Some updates to allow user to open GUI with pre-set
%            parameters. These parameters are then copied into the GUI
%            window. Subroutines dataToWindow and windowToData make it
%            easier to pass field settings between the GUI and the data
%            struct that will be passed back to ret code.
%           

% RETMENU M-file for retMenu.fig
%      RETMENU, by itself, creates a new RETMENU or raises the existing
%      singleton*.
%
%      H = RETMENU returns the handle to a new RETMENU or the handle to
%      the existing singleton*.
%
%      RETMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RETMENU.M with the given input arguments.
%
%      RETMENU('Property','Value',...) creates a new RETMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before retMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to retMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help retMenu


% Last Modified by GUIDE v2.5 23-Aug-2011 10:54:48
% Last Modified by GUIDE v2.5 04-Feb-2009 10:05:20


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @retMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @retMenu_OutputFcn, ...
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

%----------------------------------------------------------
% --- Executes just before retMenu is made visible.
%----------------------------------------------------------
function retMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to retMenu (see VARARGIN)

set(handles.experiment,     'String',retSetExperimentParams);
set(handles.fixation(1),    'String',retSetFixationParams);

% Get stored image matrices
%       All .mat files where retMenu lives are considered potentials
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmp    = dir([tmpdir filesep 'storedImagesMatrices' filesep '*.mat']);
if ~isempty(tmp),
    tmp2 = cell(1, length(tmp)+1); % stored image matrices + 'none'
    tmp2{1}   = 'None'; 
    for n=1:length(tmp),
        tmp2{n+1} = tmp(n).name;
    end;
    set(handles.loadMatrix,     'String',tmp2);  
else
    set(handles.loadMatrix,     'String',{'None'});
end;

% Get calibration directories
tmp = getDisplaysList;
mydir = ['none' tmp];
set(handles.calibration,'String',mydir);

% Set default params for retMenu
if notDefined('varargin'), data = [];
else data = varargin{1}; end
data = retCreateDefaultGUIParams(data);

% Add default values to handles
handles.data = data;

% Update GUI Object
guidata(hObject, handles);

% Put the parameters in the GUI Window
dataToWindow(hObject);

% UIWAIT makes retMenu wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;

%----------------------------------------------------------
% --- Outputs from this function are returned to the command line.
%----------------------------------------------------------
function varargout = retMenu_OutputFcn(hObject, eventdata, handles)  %#ok<*INUSD>
% varargout  cell array for returning output args (see VARARGOUT);

% if not parameters set, exit gracefully
if notDefined('handles'); varargout{1} = []; disp('User aborted...'); return; end

% copy parameter values from the GUI window the data struct
windowToData(hObject);

setFullFileNames(hObject);    

handles = guidata(hObject);

% output
varargout{1} = handles.data;

% quit
delete(handles.figure1);
return;


%----------------------------------------------------------
% ---  Copy paramaters from data struct to the GUI window
%----------------------------------------------------------
function dataToWindow(hObject)

% Get current state of handles
handles = guidata(hObject);
data = handles.data;

% Set the popup window parameters
v = getPopupValue(handles.experiment,data.experiment);
set(handles.experiment,         'Value',    v);
v = getPopupValue(handles.fixation(1),data.fixation);
set(handles.fixation(1),        'Value',    v);
v = getPopupValue(handles.modality, data.modality);
set(handles.modality,           'Value',    v);
v = getPopupValue(handles.trigger, data.trigger);
set(handles.trigger,           'Value',    v);

% set the numberical parameters
set(handles.savestimparams,     'Value',    data.savestimparams);
set(handles.repetitions,        'String',   num2str(data.repetitions));
set(handles.runPriority,        'String',   num2str(data.runPriority));
set(handles.skipCycleFrames,    'String',   num2str(data.skipCycleFrames));
set(handles.prescanDuration,    'String',   num2str(data.prescanDuration, 10));
set(handles.period,             'String',   num2str(data.period, 10));
set(handles.numCycles,          'String',   num2str(data.numCycles));
set(handles.countdown,          'String',   num2str(data.countdown));
set(handles.startScan,          'String',   num2str(data.startScan));
set(handles.motionSteps,        'String',   num2str(data.motionSteps));
set(handles.tempFreq,           'String',   num2str(data.tempFreq));
set(handles.contrast,           'String',   num2str(data.contrast));

% set the string parameters
if isfinite(data.interleaves ), set(handles.interleaves,'String', num2str(data.interleaves));
else set(handles.interleaves,'String', 'N/A'); end
set(handles.tr,'String', num2str(data.tr, 10));
if ~isfield(data, 'saveMatrix') || isempty(data.saveMatrix), 
    set(handles.saveMatrix, 'String','None');
else
    [pth fname ext] = fileparts(data.saveMatrix);
    if isempty(fname), fname = pth; end
    if isempty(ext) && ~strcmpi(fname, 'None'), ext = '.mat'; end
    set(handles.saveMatrix, 'String',[fname ext]);
end
v = getPopupValue(handles.loadMatrix,data.loadMatrix);
set(handles.loadMatrix,'Value',v);
v = getPopupValue(handles.calibration,data.calibration);
set(handles.calibration,'Value',v);
set(handles.triggerKey, 'String', data.triggerKey);

     
% data.stimSize        = str2double(get(handles.stimSize,'String'));
 if isnan(data.stimSize),
     set(handles.stimSize, 'String', 'max');
 else
    set(handles.stimSize, 'String', num2str(data.stimSize, 10));
 end
 
return

%----------------------------------------------------------
% ---  Copy paramaters from the the GUI window to data struct
%----------------------------------------------------------
function windowToData(hObject)
% Copy parameters from the GUI window to the data struct

% get the handles
handles = guidata(hObject);

% get the current data values
data = handles.data;

% default command line output for retMenu = menuparams
tmp                  = get(handles.experiment,'String');
data.experiment      = tmp(get(handles.experiment,'Value'));      

tmp                  = get(handles.fixation(1),'String');
data.fixation        = tmp(get(handles.fixation(1),'Value'));      

tmp                  = get(handles.modality(1),'String');
data.modality        = tmp(get(handles.modality(1),'Value'));      

data.savestimparams  = get(handles.savestimparams,'Value');
data.repetitions     = str2num(get(handles.repetitions,     'String')); %#ok<*ST2NM>
data.runPriority     = str2num(get(handles.runPriority,     'String'));
data.skipCycleFrames = str2num(get(handles.skipCycleFrames, 'String'));
data.prescanDuration = str2num(get(handles.prescanDuration, 'String'));
data.countdown       = str2num(get(handles.countdown,       'String'));
data.startScan       = str2num(get(handles.startScan,       'String'));
data.period          = str2num(get(handles.period,          'String'));
data.numCycles       = str2num(get(handles.numCycles,       'String'));
data.motionSteps     = str2num(get(handles.motionSteps,     'String'));
data.tempFreq        = str2num(get(handles.tempFreq,        'String'));
data.contrast        = str2num(get(handles.contrast,        'String'));
data.interleaves     = str2num(get(handles.interleaves,     'String'));
data.tr              = str2num(get(handles.tr,              'String'));
data.triggerKey      = get(handles.triggerKey,              'String');
data.saveMatrix      = get(handles.saveMatrix,              'String');      

tmp                  = get(handles.loadMatrix,              'String');
data.loadMatrix      = tmp(get(handles.loadMatrix,          'Value'));      

tmp                  = get(handles.calibration,             'String');
data.calibration     = tmp(get(handles.calibration,         'Value'));      

data.stimSize        = str2num(get(handles.stimSize,        'String'));
if isempty(data.stimSize),  data.stimSize    = 'max'; end;


% we want strings from these not cells
if iscell(data.experiment),  data.experiment = data.experiment{1};   end;

if iscell(data.fixation),    data.fixation = data.fixation{1};       end;

if iscell(data.modality),    data.modality = data.modality{1};       end;

if iscell(data.loadMatrix),  data.loadMatrix = data.loadMatrix{1};   end;

if iscell(data.calibration), data.calibration = data.calibration{1}; end;

if iscell(data.trigger),     data.trigger = data.trigger{1};         end;

% store in handles structure
handles.data = data;

% Update handles structure
guidata(hObject, handles);


return



%----------------------------------------------------------
% --- Set full file paths upon GUI exit (after clicking 'done')
%----------------------------------------------------------
function setFullFileNames(hObject)

handles = guidata(hObject);

% directory files lives in
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmpdir = [tmpdir  filesep 'storedImagesMatrices' filesep];

% if we save the image matrix we put it in the directory this file lives in
if  strcmpi(handles.data.saveMatrix, 'none')
    handles.data.saveMatrix = [];
else
    handles.data.saveMatrix = [tmpdir handles.data.saveMatrix];
end;

% if no image matrix are found to be loaded -> empty
if strcmpi(handles.data.loadMatrix,'none')
    handles.data.loadMatrix = [];
else
    handles.data.loadMatrix = [tmpdir handles.data.loadMatrix];
end;

if strcmpi(handles.data.calibration,'none'),
    handles.data.calibration = [];
end;

guidata(hObject, handles)
return


%----------------------------------------------------------
% --- Subroutine to get the value from a popup menu
%----------------------------------------------------------
function ii = getPopupValue(h,target)
% Given a handle to a popup, h, find the value

str = get(h,'String');
if ~iscell(str)  % Only one term
    if strcmpi(str,target), ii = 1; return; end
else
    for ii=1:length(str)
        if strcmpi(str{ii},target)
            return;
        end
    end
end

% Returns a safe value, but maybe it should be null?
ii = 1;

return;


%----------------------------------------------------------
% --- These are only executed when changed by user
%----------------------------------------------------------
function experiment_Callback(hObject, eventdata, handles) %#ok<*INUSL,*DEFNU>
% returns experiment contents as cell array
contents = get(hObject,'String');
% returns selected item from experiment
handles.data.experiment = contents{get(hObject,'Value')};
% Set default options for some experiments
% This is convenient (for me) but may be tricky if you are not aware other
% settings are changing as well! So print a warning message at least.
switch handles.data.experiment,
    case {'8 bars','8 bars with blanks','8 bars (sinewave-soft)','8 bars (sinewave-soft) with blanks', '8 bars with blanks, fixed check size', '8 bars with blanks thin', '8 bars with blanks thick'},
        handles.data.numCycles = 1; 
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 192;
        set(handles.period,         'String','192');   %seconds

        fprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!\n',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period);
    case {'8 bars (sinewave)','8 bars (LMS)'},
        handles.data.numCycles = 1;
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 288;
        set(handles.period,         'String','1');   %seconds
        fprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!\n',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period);
    case {'8 bars (LMS) with blanks'},
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',2);      
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.repetitions    =10 ;    %#
        set(handles.repetitions,    'String','10');    %#

        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 288;
        set(handles.period,    'String','288');   %seconds
        fprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!\n',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period);
    otherwise,
        % do nothing
end;
    
guidata(hObject,handles);

% Update the data parameters struct 
windowToData(hObject);

return;

function experiment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function tr_Callback(hObject, eventdata, handles)
handles.data.tr = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function tr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function interleaves_Callback(hObject, eventdata, handles)
handles.data.interleaves = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function interleaves_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function numCycles_Callback(hObject, eventdata, handles)
handles.data.numCycles = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function numCycles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function period_Callback(hObject, eventdata, handles)
handles.data.period=str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function period_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function prescanDuration_Callback(hObject, eventdata, handles)
handles.data.prescanDuration = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function prescanDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function skipCycleFrames_Callback(hObject, eventdata, handles)
handles.data.skipCycleFrames = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function skipCycleFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function repetitions_Callback(hObject, eventdata, handles)
handles.data.repetitions = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function repetitions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function runPriority_Callback(hObject, eventdata, handles)
handles.data.runPriority=str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function runPriority_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function fixation_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
handles.data.fixation=contents{get(hObject,'Value')};
guidata(hObject,handles);
return;

function fixation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% now continue and finish
uiresume(handles.figure1);
return;


%----------------------------------------------------------
function saveMatrix_Callback(hObject, eventdata, handles)
handles.data.saveMatrix=get(hObject,'String');
guidata(hObject,handles);
return;

function saveMatrix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function loadMatrix_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
if iscell(contents),
    handles.data.loadMatrix=contents{get(hObject,'Value')};
else
    handles.data.loadMatrix=contents;
end;
guidata(hObject,handles);
return

function loadMatrix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function calibration_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
if iscell(contents),
    handles.data.calibration=contents{get(hObject,'Value')};
else
    handles.data.calibration=contents;
end;
guidata(hObject,handles);
return

function calibration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function stimSize_Callback(hObject, eventdata, handles)
handles.data.stimSize=str2num(get(hObject,'String'));
if isempty(handles.data.stimSize),
    handles.data.stimSize = 'max';
end;
guidata(hObject,handles);
return;


function stimSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function tempFreq_Callback(hObject, eventdata, handles)
handles.data.tempFreq = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function tempFreq_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function motionSteps_Callback(hObject, eventdata, handles)
handles.data.motionSteps = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function motionSteps_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function contrast_Callback(hObject, eventdata, handles)
handles.data.contrast = str2num(get(hObject,'String'));
guidata(hObject,handles);
return;

function contrast_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
% --- Executes on selection change in modality.
function modality_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));               %returns modality contents as cell array
handles.data.modality = contents{get(hObject,'Value')};  % returns selected item from modality
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function modality_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%----------------------------------------------------------
function savestimparams_Callback(hObject, eventdata, handles)
handles.data.savestimparams = get(hObject,'Value');
guidata(hObject,handles);
return;


function trigger_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));               %returns modality contents as cell array
handles.data.trigger = contents{get(hObject,'Value')};  % returns selected item from modality
guidata(hObject,handles);
return

function trigger_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return


function triggerKey_Callback(hObject, eventdata, handles)
handles.data.triggerKey=get(hObject,'String');
guidata(hObject,handles);
return

% --- Executes during object creation, after setting all properties.
function triggerKey_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return


function startScan_Callback(hObject, eventdata, handles)
handles.data.startScan = str2num(get(hObject,'String'));
guidata(hObject,handles);
return

function startScan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return


function countdown_Callback(hObject, eventdata, handles)
handles.data.countdown = str2num(get(hObject,'String'));
guidata(hObject,handles);
return

function countdown_CreateFcn(hObject, eventdata, handles)
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return
