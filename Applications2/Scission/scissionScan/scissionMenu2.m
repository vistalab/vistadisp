function varargout = scissionMenu2(varargin)
% scissionMenu - gui for scission stimuli parameters.
%
% SOD 10/2005: created it, consolidating several existing gui's.
% SOD 06/2006: hacked for localizers other than retinotopies
% JW  05/2008: adapted from Serge's locMenu
% HH  12/2008: adapted from Jon's cocMenu
% HH  02/2009: Added Annulus condition and new GUI

% scissionMENU M-file for scissionMenu2.fig
%      scissionMenu2, by itself, creates a new scissionMENU or raises the existing
%      singleton*.
%
%      H = scissionMenu2 returns the handle to a new scissionMENU or the handle to
%      the existing singleton*.
%
%      scissionMenu2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in scissionMENU.M with the given input arguments.
%
%      scissionMenu2('Property','Value',...) creates a new scissionMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before scissionMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to scissionMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
% Edit the above text to modify the response to help scissionMenu
%  Modified by GUIDE v2.5 27-Oct-2005 22:38:25
%  Modified by HJW 05/2008

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @scissionMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @scissionMenu_OutputFcn, ...
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
function scissionMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to retMenu (see VARARGIN)

set(handles.experiment,     'String',setscissionParams);
fixString  = {'disk','dot','dot with grid','double disk','large cross','large cross x+', 'thin cross', 'left disk','right disk'};
set(handles.fixation(1),       'String',fixString);

% Get stored image matrices
%       All .mat files where retMenu lives are considered potentials
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmp    = dir([tmpdir filesep 'storedImagesMatrices' filesep '*.mat']);
if ~isempty(tmp),
    tmp2{1}   = 'None'; 
    for n=1:length(tmp),
        tmp2{n+1} = tmp(n).name;
    end;
    set(handles.loadMatrix,     'String',tmp2);  
else,
    set(handles.loadMatrix,     'String','None');
end;
%set(handles.saveMatrix,     'String','');  

% Get calibration directories
tmp = getDisplaysList;
mydir = ['none' tmp];
set(handles.calibration,'String',mydir);

% Set default params for retMenu
if notDefined('varargin'), data = [];
else data = varargin{1}; end
data = createDefaultDataParams(data);

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
function varargout = scissionMenu_OutputFcn(hObject, eventdata, handles) 
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
% ---  Set default values if none are input
%----------------------------------------------------------
function data = createDefaultDataParams(curdata)
% set default values for ret params
data.experiment     = 'Annulus';
data.fixation       = 'disk';
data.modality       = 'fMRI';
data.savestimparams = 0;
data.repetitions    = 1;
data.runPriority     = 7;
data.skipCycleFrames = 0;
data.prescanDuration = 12;%seconds
data.period          = 36;%seconds
data.numCycles       = 6;
data.motionSteps     = 8; % number of checkerboard positions per luminance cycle
data.tempFreq        = 2; % frequency of checkerboard flicker (Hz)
data.contrast        = 1; % checkerboard contrast
data.interleaves     = NaN;
data.tr              = 1.5;%seconds
data.loadMatrix      = 'None';
data.saveMatrix      = 'None';
data.calibration     = 'None';
data.stimSize        = 'max';
data.SizeRatio       = 0.5;
data.loadMatrix      = 'None';
data.saveMatrix      = 'None';
data.calibration     = 'None';
data.stimSize        = 'max';

data.frequency       = 1; % temporal bacse luminance modulation frequncy (Hz) <peak to peak>
data.framesPerImage  = 4; % 4 indicates that stimulus temporal frequency is 15 Hz at refresh rate 60Hz 
data.NumOfDevision   = 4;
data.WithoutContrastViolation = true;
data.NumOfReptOneCycle        = 3;
data.CentralDotsContrast      = 1;%seconds
data.SurroundDotsContrast     = 0.5;%seconds
data.frameUpdateFrequency = 1;% Num of image per one frame
data.HowManyTimesFiltSize = 1;% Only for Filter Size Experiment

data.Filtering       = true; %gaussian filter on
data.Filtersize      = 1; % 
data.Eliplisity      = 1;
data.Annulus         = false;
data.DesWidth        = 0.2;

% If we input data, then use this for all defined fields
if ~isempty(curdata)
    s = fieldnames(data);
    for ii = 1:length(s)
        if isfield(curdata, s{ii})
            data.(s{ii}) = curdata.(s{ii});
        end
    end
end

return

%----------------------------------------------------------
% ---  Copy paramaters from data struct to the GUI window
%----------------------------------------------------------
function dataToWindow(hObject)

% Get current state of handles
handles = guidata(hObject);
data = handles.data;

% Set the window parameters
v = getPopupValue(handles.experiment,data.experiment);
set(handles.experiment,         'Value',    v);
v = getPopupValue(handles.fixation(1),data.fixation);
set(handles.fixation(1),        'Value',    v);
v = getPopupValue(handles.modality, data.modality);
set(handles.modality,           'Value',    v);


set(handles.WithoutContrastViolation,         'Value',    data.WithoutContrastViolation);
set(handles.Annulus,     'Value',    data.Annulus);
set(handles.WithoutContrastViolation,     'Value',    data.WithoutContrastViolation);

set(handles.savestimparams,     'Value',    data.savestimparams);
set(handles.repetitions,        'String',   num2str(data.repetitions));
set(handles.runPriority,        'String',   num2str(data.runPriority));
set(handles.skipCycleFrames,    'String',   num2str(data.skipCycleFrames));
set(handles.prescanDuration,    'String',   num2str(data.prescanDuration));
set(handles.period,             'String',   num2str(data.period));
set(handles.numCycles,          'String',   num2str(data.numCycles));
set(handles.SizeRatio,          'String',   num2str(data.SizeRatio));
set(handles.framesPerImage,     'String',   num2str(data.framesPerImage));
set(handles.NumOfReptOneCycle,  'String',   num2str(data.NumOfReptOneCycle));
set(handles.NumOfDevision,      'String',   num2str(data.NumOfDevision));
set(handles.CentralDotsContrast,'String',   num2str(data.CentralDotsContrast));
set(handles.SurroundDotsContrast,'String',   num2str(data.SurroundDotsContrast));
set(handles.frequency,          'String',   num2str(data.frequency));
set(handles.frameUpdateFrequency,'String',   num2str(data.frameUpdateFrequency));
set(handles.Filtersize,          'String',   num2str(data.Filtersize));
set(handles.Eliplisity,          'String',   num2str(data.Eliplisity));
set(handles.HowManyTimesFiltSize,'String',  num2str(data.HowManyTimesFiltSize));
set(handles.DesWidth,             'String',   num2str(data.DesWidth));

if isfinite(data.interleaves ), set(handles.interleaves,'String', num2str(data.interleaves));
else set(handles.interleaves,'String', 'N/A'); end
set(handles.tr,'String', num2str(data.tr));
if notDefined('data.saveMatrix'), set(handles.saveMatrix, 'String','None');
else set(handles.saveMatrix, 'String',data.saveMatrix); end
v = getPopupValue(handles.loadMatrix,data.loadMatrix);
set(handles.loadMatrix,'Value',v);
v = getPopupValue(handles.calibration,data.calibration);
set(handles.calibration,'Value',v);

% data.stimSize        = str2double(get(handles.stimSize,'String'));
 if isnan(data.stimSize),
     set(handles.stimSize, 'String', 'max');
 else
    set(handles.stimSize, 'String', num2str(data.stimSize));
 end
 
return

%----------------------------------------------------------
% ---  Copy paramaters from the the GUI window to data struct
%----------------------------------------------------------
function windowToData(hObject);
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


data.Filtering                  = get(handles.Filtering,'Value');
data.WithoutContrastViolation   = get(handles.WithoutContrastViolation,'Value');
data.Annulus                    = get(handles.Annulus,'Value');
data.savestimparams             = get(handles.savestimparams,'Value');

data.repetitions     = str2num(get(handles.repetitions,     'String'));
data.runPriority     = str2num(get(handles.runPriority,     'String'));
data.skipCycleFrames = str2num(get(handles.skipCycleFrames, 'String'));
data.prescanDuration = str2num(get(handles.prescanDuration, 'String'));
data.period          = str2num(get(handles.period,          'String'));
data.numCycles       = str2num(get(handles.numCycles,       'String'));
data.interleaves     = str2num(get(handles.interleaves,     'String'));
data.tr              = str2num(get(handles.tr,              'String'));
data.SizeRatio              = str2num(get(handles.SizeRatio,       'String'));
data.NumOfReptOneCycle      = str2num(get(handles.NumOfReptOneCycle, 'String'));
data.NumOfDevision          = str2num(get(handles.NumOfDevision,   'String'));
data.CentralDotsContrast    = str2num(get(handles.CentralDotsContrast,  'String'));
data.SurroundDotsContrast   = str2num(get(handles.SurroundDotsContrast, 'String'));
data.frequency              = str2num(get(handles.frequency,            'String'));
data.frameUpdateFrequency   = str2num(get(handles.frameUpdateFrequency, 'String'));
data.Filtersize             = str2num(get(handles.Filtersize,           'String'));
data.Eliplisity             = str2num(get(handles.Eliplisity,           'String'));
data.HowManyTimesFiltSize   = str2num(get(handles.HowManyTimesFiltSize, 'String'));
data.DesWidth               = str2num(get(handles.DesWidth,             'String'));

data.loadMatrix      = get(handles.loadMatrix,              'String');      
data.saveMatrix      = get(handles.saveMatrix,              'String');
tmp                  = get(handles.calibration,             'String');
data.calibration     = tmp(get(handles.calibration,         'Value'));      
data.stimSize        = str2num(get(handles.stimSize,        'String'));
if isempty(data.stimSize),
    data.stimSize    = 'max';
end;

% we want strings from these not cells
if iscell(data.experiment),
    data.experiment = data.experiment{1};
end;

if iscell(data.fixation),
    data.fixation = data.fixation{1};
end;

if iscell(data.modality),
    data.modality = data.modality{1};
end;

if iscell(data.loadMatrix),
    data.loadMatrix = data.loadMatrix{1};
end;

if iscell(data.calibration),
    data.calibration = data.calibration{1};
end;

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
if strcmp(lower(handles.data.loadMatrix),'none')
    handles.data.loadMatrix = [];
else,
    handles.data.loadMatrix = [tmpdir handles.data.loadMatrix];
end;

if strcmp(lower(handles.data.calibration),'none'),
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
function experiment_Callback(hObject, eventdata, handles)
% returns experiment contents as cell array
contents = get(hObject,'String');
% returns selected item from experiment
handles.data.experiment = contents{get(hObject,'Value')};
% Set default options for some experiment
% This is convenient (for me) but may be tricky if you are not aware other
% settings are changing as well! So print a warning message at least.

switch handles.data.experiment,
    case {'Annulus'}
        
        handles.data.numCycles = 5; 
        set(handles.numCycles,      'String','5');    %#
        handles.data.period    = 36;
        set(handles.period,       'String','36');   %seconds
        
        handles.data.WithoutContrastViolation   = true;
        set(handles.WithoutContrastViolation,        'Value', 1 );   %true or false        
        handles.data.Filtering   = true;
        set(handles.Filtering,        'Value', 1 );   %true or false       
        
        handles.data.DesWidth  = 0.2; 
        set(handles.DesWidth,       'String','0.2');  %ratio (1 means full of circle)
        handles.data.Annulus   = true;
        set(handles.Annulus,        'Value', 1 );   %true or false
        
        handles.data.framesPerImage = 4; 
        set(handles.framesPerImage,      'String','4');    %#
        handles.data.NumOfDevision    = 4;
        set(handles.NumOfDevision,       'String','4');   %#
        
        handles.data.NumOfReptOneCycle    = 3;
        set(handles.NumOfReptOneCycle,       'String','3');   %#
        
        handles.data.Filtersize    = 1;
        set(handles.Filtersize,       'String','1');   %#
        handles.data.Eliplisity    = 1;
        set(handles.Eliplisity,       'String','1');   %#
        handles.data.HowManyTimesFiltSize    = 10;
        set(handles.HowManyTimesFiltSize,       'String','10');   %#
        
    
    case {'FilterSizeChange'},
        
        handles.data.numCycles = 3; 
        set(handles.numCycles,      'String','3');    %#
        handles.data.period    = 48;
        set(handles.period,       'String','48');   %seconds
        
        handles.data.WithoutContrastViolation   = true;
        set(handles.WithoutContrastViolation,        'Value', 1 );   %true or false
        handles.data.Filtering   = true;
        set(handles.Filtering,        'Value', 1 );   %true or false
        
        handles.data.framesPerImage = 4; 
        set(handles.framesPerImage,      'String','4');    %#
        handles.data.NumOfDevision    = 4;
        set(handles.NumOfDevision,       'String','4');   %#
        
        handles.data.NumOfReptOneCycle    = 3;
        set(handles.NumOfReptOneCycle,       'String','3');   %#

        handles.data.Filtersize    = 1;
        set(handles.Filtersize,       'String','1');   %#
        handles.data.Eliplisity    = 1;
        set(handles.Eliplisity,       'String','1');   %#
        handles.data.HowManyTimesFiltSize    = 10;
        set(handles.HowManyTimesFiltSize,       'String','10');   %#
        
        handles.data.DesWidth  = 0; 
        set(handles.DesWidth,       'String','0');  %ratio (1 means full of circle)
        handles.data.Annulus   = false;
        set(handles.Annulus,        'Value', 0 );   %true or false
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
        mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'CentSurroundRotation'},
        
        handles.data.numCycles = 3; 
        set(handles.numCycles,      'String','3');    %#
        handles.data.period    = 48;
        set(handles.period,       'String','48');   %seconds
        
        handles.data.WithoutContrastViolation   = true;
        set(handles.WithoutContrastViolation,        'Value', 1 );   %true or false
        handles.data.Filtering   = true;
        set(handles.Filtering,        'Value', 1 );   %true or false
        
        handles.data.framesPerImage = 4; 
        set(handles.framesPerImage,      'String','4');    %#
        handles.data.NumOfDevision    = 4;
        set(handles.NumOfDevision,       'String','4');   %#
        
        handles.data.NumOfReptOneCycle    = 3;
        set(handles.NumOfReptOneCycle,       'String','3');   %#

        handles.data.Filtersize    = .5;
        set(handles.Filtersize,       'String','0.5');   %#
        handles.data.Eliplisity    = 50;
        set(handles.Eliplisity,       'String','50');   %#
        handles.data.HowManyTimesFiltSize    = 1;
        set(handles.HowManyTimesFiltSize,       'String','1');   %#
        
        handles.data.DesWidth  = 0; 
        set(handles.DesWidth,       'String','0');  %ratio (1 means full of circle)
        handles.data.Annulus   = false;
        set(handles.Annulus,        'Value', 0 );   %true or false
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
        mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'SurroundRotation'},
        
        handles.data.numCycles = 5; 
        set(handles.numCycles,      'String','5');    %#
        handles.data.period    = 36;
        set(handles.period,       'String','36');   %seconds
        
        handles.data.WithoutContrastViolation   = true;
        set(handles.WithoutContrastViolation,        'Value', 1 );   %true or false
        handles.data.Filtering   = true;
        set(handles.Filtering,        'Value', 1 );   %true or false
        
        handles.data.framesPerImage = 4; 
        set(handles.framesPerImage,      'String','4');    %#
        handles.data.NumOfDevision    = 6;
        set(handles.NumOfDevision,       'String','6');   %#
        
        handles.data.NumOfReptOneCycle    = 2;
        set(handles.NumOfReptOneCycle,       'String','2');   %#

        handles.data.Filtersize    = .5;
        set(handles.Filtersize,       'String','0.5');   %#
        handles.data.Eliplisity    = 50;
        set(handles.Eliplisity,       'String','50');   %#
        handles.data.HowManyTimesFiltSize    = 1;
        set(handles.HowManyTimesFiltSize,       'String','1');   %#
        
        handles.data.DesWidth  = 0; 
        set(handles.DesWidth,       'String','0');  %ratio (1 means full of circle)
        handles.data.Annulus   = false;
        set(handles.Annulus,        'Value', 0 );   %true or false
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
        mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    
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
handles.data.tr = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function tr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function interleaves_Callback(hObject, eventdata, handles)
handles.data.interleaves = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function interleaves_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function numCycles_Callback(hObject, eventdata, handles)
handles.data.numCycles = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function numCycles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function period_Callback(hObject, eventdata, handles)
handles.data.period=str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function period_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function prescanDuration_Callback(hObject, eventdata, handles)
handles.data.prescanDuration = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function prescanDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function skipCycleFrames_Callback(hObject, eventdata, handles)
handles.data.skipCycleFrames = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function skipCycleFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function repetitions_Callback(hObject, eventdata, handles)
handles.data.repetitions = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function repetitions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function runPriority_Callback(hObject, eventdata, handles)
handles.data.runPriority=str2double(get(hObject,'String'));
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
else,
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
else,
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
handles.data.stimSize=str2double(get(hObject,'String'));
if isnan(handles.data.stimSize),
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
function savestimparams_Callback(hObject, eventdata, handles)
handles.data.savestimparams = get(hObject,'Value');
guidata(hObject,handles);
return;


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


function Filtering_Callback(hObject, eventdata, handles)
handles.data.Filtering = get(hObject,'Value');
guidata(hObject,handles);
return


function Filtersize_Callback(hObject, eventdata, handles)
handles.data.Filtersize=str2double(get(hObject,'String'));
guidata(hObject,handles);
function Filtersize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Eliplisity_Callback(hObject, eventdata, handles)
handles.data.Eliplisity=str2double(get(hObject,'String'));
guidata(hObject,handles);
function Eliplisity_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DesWidth_Callback(hObject, eventdata, handles)
handles.data.DesWidth=str2double(get(hObject,'String'));
guidata(hObject,handles);
function DesWidth_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HowManyTimesFiltSize_Callback(hObject, eventdata, handles)
handles.data.HowManyTimesFiltSize=str2double(get(hObject,'String'));
guidata(hObject,handles);
function HowManyTimesFiltSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function WithoutContrastViolation_Callback(hObject, eventdata, handles)
handles.data.WithoutContrastViolation = get(hObject,'Value');
guidata(hObject,handles);



function SizeRatio_Callback(hObject, eventdata, handles)
handles.data.SizeRatio=str2double(get(hObject,'String'));
guidata(hObject,handles);

function SizeRatio_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_Callback(hObject, eventdata, handles)
handles.data.frequency=str2double(get(hObject,'String'));
guidata(hObject,handles);

function frequency_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CentralDotsContrast_Callback(hObject, eventdata, handles)
handles.data.CentralDotsContrast=str2double(get(hObject,'String'));
guidata(hObject,handles);

function CentralDotsContrast_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SurroundDotsContrast_Callback(hObject, eventdata, handles)
handles.data.SurroundDotsContrast=str2double(get(hObject,'String'));
guidata(hObject,handles);
function SurroundDotsContrast_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumOfReptOneCycle_Callback(hObject, eventdata, handles)
handles.data.NumOfReptOneCycle=str2double(get(hObject,'String'));
guidata(hObject,handles);

function NumOfReptOneCycle_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NumOfDevision_Callback(hObject, eventdata, handles)
handles.data.NumOfDevision=str2double(get(hObject,'String'));
guidata(hObject,handles);

function NumOfDevision_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function framesPerImage_Callback(hObject, eventdata, handles)
handles.data.framesPerImage=str2double(get(hObject,'String'));
guidata(hObject,handles);

function framesPerImage_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function Annulus_Callback(hObject, eventdata, handles)
handles.data.Annulus = get(hObject,'Value');
guidata(hObject,handles);



function frameUpdateFrequency_Callback(hObject, eventdata, handles)
handles.data.frameUpdateFrequency=str2double(get(hObject,'String'));
guidata(hObject,handles);

function frameUpdateFrequency_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
