function varargout = scissionMenu(varargin)
% scissionMenu - gui for scission stimuli parameters.
%
% SOD 10/2005: created it, consolidating several existing gui's.
% SOD 06/2006: hacked for localizers other than retinotopies
% JW 05/2008: adapted from Serge's locMenu

% scissionMENU M-file for scissionMenu.fig
%      scissionMENU, by itself, creates a new scissionMENU or raises the existing
%      singleton*.
%
%      H = scissionMENU returns the handle to a new scissionMENU or the handle to
%      the existing singleton*.
%
%      scissionMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in scissionMENU.M with the given input arguments.
%
%      scissionMENU('Property','Value',...) creates a new scissionMENU or raises the
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
% --- Executes just before scissionMenu is made visible.
%----------------------------------------------------------
function scissionMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to scissionMenu (see VARARGIN)

% Choose default menu params for scissionMenu

%expString = {'COC','SquareWave','EdgeOnly','Uniform', 'localizer', 'text'};
expString = {'FilterSizeChange','CentSurroundRotation','SurroundRotation','Destructor'};
set(handles.experiment,     'String',expString);
fixString  = {'disk','dot','dot with grid','double disk','large cross','large cross x+', 'thin cross', 'left disk','right disk'};
set(handles.fixation(1),       'String',fixString);
fixSideString  = {'center','right', 'left', };
set(handles.fixSide,       'String',fixSideString);

set(handles.savestimparams, 'Value',0); 
set(handles.repetitions,    'String','1');    %#
set(handles.runPriority,    'String','3');    %#
set(handles.skipCycleFrames,'String','0');    %#
set(handles.prescanDuration,'String','15');   %seconds
set(handles.period,         'String','48');   %seconds
set(handles.numCycles,      'String','3');    %#
set(handles.interleaves,    'String','N/A');    %#
set(handles.tr,             'String','1.5');  %seconds

% all .mat files where scissionMenu lives are considered potentials
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmp    = dir([tmpdir filesep '*.mat']);
if ~isempty(tmp),
    tmp2{1}   = 'None'; 
    for n=1:length(tmp),
        tmp2{n+1} = tmp(n).name;
    end;
    set(handles.loadMatrix,     'String',tmp2);  
else,
    set(handles.loadMatrix,     'String','None');
end;
set(handles.saveMatrix,     'String','');  

% Get calibration directories
tmp = getDisplaysList;
mydir = ['none' tmp];
set(handles.calibration,'String',mydir);


set(handles.stimSize,      'String','max');

% default command line output for scissionMenu = menuparams
tmp      = get(handles.experiment,'String');
data.experiment      = tmp(get(handles.experiment,'Value'));      
tmp      = get(handles.fixation(1),'String');
data.fixation      = tmp(get(handles.fixation(1),'Value'));      
tmp      = get(handles.fixSide,'String');
data.fixSide      = tmp(get(handles.fixSide,'Value'));      
data.savestimparams  = get(handles.savestimparams,'Value');
data.repetitions     = str2double(get(handles.repetitions,'String'));
data.runPriority     = str2double(get(handles.runPriority,'String'));
data.skipCycleFrames = str2double(get(handles.skipCycleFrames,'String'));
data.prescanDuration = str2double(get(handles.prescanDuration,'String'));
data.period          = str2double(get(handles.period,'String'));
data.numCycles       = str2double(get(handles.numCycles,'String'));
data.interleaves     = str2double(get(handles.interleaves,'String'));
data.tr              = str2double(get(handles.tr,'String'));
data.loadMatrix      = 'None';
data.saveMatrix      = [];
data.calibration     = '3T_Back_Bore_800x600_4_23_08.mat';

%try set(handles.data.calibration, 'String', '3T_NEC_800x600.mat'); end

data.stimSize        = str2double(get(handles.stimSize,'String'));
if isnan(data.stimSize),
    data.stimSize    = 'max';
end;

% store in handles structure
handles.data = data;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes scissionMenu wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;

%----------------------------------------------------------
% --- Outputs from this function are returned to the command line.
%----------------------------------------------------------
function varargout = scissionMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% we want strings from these not cells
if iscell(handles.data.experiment),
    handles.data.experiment = handles.data.experiment{1};
end;
if iscell(handles.data.fixation),
    handles.data.fixation = handles.data.fixation{1};
end;
if iscell(handles.data.fixSide),
    handles.data.fixSide = handles.data.fixSide{1};
end;
if iscell(handles.data.loadMatrix),
    handles.data.loadMatrix = handles.data.loadMatrix{1};
end;
if iscell(handles.data.calibration),
    handles.data.calibration = handles.data.calibration{1};
end;

% directory this file lives in
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmpdir = [tmpdir filesep];

% if we save the image matrix we put it in the directory this file lives in
if ~isempty(handles.data.saveMatrix),
    handles.data.saveMatrix = [tmpdir handles.data.saveMatrix];
end;

% if no image matrix are found to be loaded -> empty
if strcmpi(handles.data.loadMatrix,'none')
    handles.data.loadMatrix = [];
else,
    handles.data.loadMatrix = [tmpdir handles.data.loadMatrix];
end;

if strcmpi(handles.data.calibration,'none'),
    handles.data.calibration = [];
end;
    
% output
varargout{1} = handles.data;

% quit
delete(handles.figure1);
return;

%----------------------------------------------------------
% --- These are only executed when changed by user
%----------------------------------------------------------
function experiment_Callback(hObject, eventdata, handles)
% returns experiment contents as cell array
contents = get(hObject,'String');
% returns selected item from experiment
handles.data.experiment = contents{get(hObject,'Value')}; 
guidata(hObject,handles);
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
% --- Executes on selection change in fixSide.
function fixSide_Callback(hObject, eventdata, handles)
% hObject    handle to experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
handles.data.fixSide=contents{get(hObject,'Value')};
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function fixSide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to experiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%----------------------------------------------------------


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



function edit37_Callback(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit37 as text
%        str2double(get(hObject,'String')) returns contents of edit37 as a double


% --- Executes during object creation, after setting all properties.
function edit37_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu12.
function popupmenu12_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu12 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu12


% --- Executes during object creation, after setting all properties.
function popupmenu12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu13.
function popupmenu13_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu13 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu13


% --- Executes during object creation, after setting all properties.
function popupmenu13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu14.
function popupmenu14_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu14 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu14


% --- Executes during object creation, after setting all properties.
function popupmenu14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit40_Callback(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit40 as text
%        str2double(get(hObject,'String')) returns contents of edit40 as a double


% --- Executes during object creation, after setting all properties.
function edit40_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on selection change in popupmenu15.
function popupmenu15_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu15 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu15


% --- Executes during object creation, after setting all properties.
function popupmenu15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit38_Callback(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit38 as text
%        str2double(get(hObject,'String')) returns contents of edit38 as a double


% --- Executes during object creation, after setting all properties.
function edit38_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit39_Callback(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit39 as text
%        str2double(get(hObject,'String')) returns contents of edit39 as a double


% --- Executes during object creation, after setting all properties.
function edit39_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit33_Callback(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit33 as text
%        str2double(get(hObject,'String')) returns contents of edit33 as a double


% --- Executes during object creation, after setting all properties.
function edit33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit34 as text
%        str2double(get(hObject,'String')) returns contents of edit34 as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit35_Callback(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit35 as text
%        str2double(get(hObject,'String')) returns contents of edit35 as a double


% --- Executes during object creation, after setting all properties.
function edit35_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit36_Callback(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit36 as text
%        str2double(get(hObject,'String')) returns contents of edit36 as a double


% --- Executes during object creation, after setting all properties.
function edit36_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit29_Callback(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit29 as text
%        str2double(get(hObject,'String')) returns contents of edit29 as a double


% --- Executes during object creation, after setting all properties.
function edit29_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit30_Callback(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit30 as text
%        str2double(get(hObject,'String')) returns contents of edit30 as a double


% --- Executes during object creation, after setting all properties.
function edit30_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit31_Callback(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit31 as text
%        str2double(get(hObject,'String')) returns contents of edit31 as a double


% --- Executes during object creation, after setting all properties.
function edit31_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit32_Callback(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit32 as text
%        str2double(get(hObject,'String')) returns contents of edit32 as a double


% --- Executes during object creation, after setting all properties.
function edit32_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit28_Callback(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit28 as text
%        str2double(get(hObject,'String')) returns contents of edit28 as a double


% --- Executes during object creation, after setting all properties.
function edit28_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
