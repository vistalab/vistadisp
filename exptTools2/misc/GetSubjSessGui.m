function ret = GetSubjSessGui(varargin)
% This is a function, intended to be called from launch.
global h f LAUNCHSessList LAUNCHSubjList retvals 

subjSelect = 1;
newSubj = 2;
returningSubj = 3;
newSubjBox = 4;
newSubjEditBox = 5;
newSubjEditBoxLabel = 18;
newSubjMale = 6;
newSubjFemale = 7;
newSubjEthnicity = 8;
newSubjAge = 9;
newSubjAgeLabel = 19;
newSubjEnroll = 10;
returningSubjBox = 11;
returningSubjHeader = 12;
returningSubjList = 13;
sessFrame = 14;
sessNumText = 15;
sessNumDisp = 16;
runButton = 17;

ethnicityList = {'Select best ethnicity match' 'Asian' ...
    'Black/African-American' 'Chicano/Latino' 'Native American' ...
    'Pacific Islander' 'White/Caucasian' 'Other' 'Unknown'};
%Initialize the GUI
%    close all
if strcmp(varargin{1}, 'Initialize') == 1   
    % Save information passed in so it can be used in the callbacks
    LAUNCHSubjList = varargin{2};
    LAUNCHSessList = varargin{3};
    Demographics = varargin{4};
    fn = fieldnames(Demographics);
    if ~isempty(strmatch('Sex', fn))
        Demographics.Sex = [];
    end
    if ~isempty(strmatch('Ethnicity', fn))
        Demographics.Ethnicity = [];
    end
    if ~isempty(strmatch('Age', fn))
        Demographics.Age = [];
    end
    retvals = struct('GotGood', false, 'NewSubj', false, 'SubjNum', [], ...
        'SessNum', [], 'SubjName', [], 'Demographics', Demographics);
    
    % Create the GUI
    f=figure;
    set(f, 'menu', 'none', 'resize', 'off', ...
        'Name', 'Subject-Session Selection',...
        'Number', 'off', 'position', [321 269 500 400], 'color', 'w');

    %--------Subject type selection header
    h(subjSelect)=uicontrol('units', 'norm', 'style', 'text',...
        'string', 'Select Subject Type', 'fontsize', 14, ...
        'fore', 'b', 'back', 'w', 'position', [.05 .86 .9 .09]);

    %----Radio buttons for selecting the subject type
    h(newSubj)=uicontrol('units', 'norm', 'style', 'radio', ...
        'string', 'New', 'fontsize', 12, 'fore', 'b', 'back', 'w', ...
        'fontwei', 'bold', 'position', [.20 .8 .25 .1], ...
        'callback', 'GetSubjSessGui(''newSubj'')');      %New button

    h(returningSubj)=uicontrol('units', 'norm', 'style', 'radio', ...
        'string', 'Returning', 'fontsize', 12, 'fore', 'b', 'back', 'w', ...
        'fontwei', 'bold', 'position', [.65 .8 .3 .1], ...
        'callback', 'GetSubjSessGui(''oldSubj'')');      %Return button

    %----Frame for New Subject Choices
    h(newSubjBox)=uicontrol('units', 'norm', 'style', 'frame', ...
        'position', [.025 .2 .45 .6], 'fore', 'k', 'back', 'w');
    
    %---Box to enter in new name
    h(newSubjEditBoxLabel)=uicontrol('units', 'norm', 'style', 'text',...
        'string', 'Name', 'fontsize', 12,  'Enable', 'off', ...
        'fore', 'b', 'back', 'w', 'position', [.04 .72 .11 .05]);
    h(newSubjEditBox)=uicontrol('units', 'norm', 'style', 'edit', ...
        'fore', 'b', 'back', 'w', 'position', [.15 .71 .32 .07], ...
        'fontsi', 12, 'HorizontalAlignment', 'left', 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjName'')');          %Edit box

    %----Radio buttons for selecting the subject sex
    h(newSubjMale)=uicontrol('units', 'norm', 'style', 'radio', ...
        'string', 'Male', 'fontsize', 12, 'fore', 'b',  'back', 'w', ...
        'position', [.27 .60 .2 .1], 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjMale'')');   %New subj is male

    h(newSubjFemale)=uicontrol('units', 'norm', 'style', 'radio', ...
        'string', 'Female', 'fontsize', 12, 'fore', 'b', 'back', 'w', ...
        'position', [.04 .60 .2 .1], 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjFemale'')'); %New subj is female
    if isempty(strmatch('Sex', fn))
        set(h([newSubjMale newSubjFemale]), 'Visible', 'off');
    end

    %-----Listbox for ethnicity
    h(newSubjEthnicity)=uicontrol('units', 'norm', 'style', 'list', ...
        'position', [.04 .42 .42 .19], 'back', 'w', 'fore', 'b', ...
        'string', ethnicityList, 'fontsi', 11, 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjEthnicity'')');  % Ethnicity list
    if isempty(strmatch('Ethnicity', fn))
        set(h(newSubjEthnicity), 'Visible', 'off');
    end
    
    %---Box to enter age
    h(newSubjAgeLabel)=uicontrol('units', 'norm', 'style', 'text',...
        'string', 'Age', 'fontsize', 12,  'Enable', 'off', ...
        'fore', 'b', 'back', 'w', 'position', [.04 .33 .11 .05]);
    h(newSubjAge)=uicontrol('units', 'norm', 'style', 'edit', ...
        'fore', 'b', 'back', 'w', 'position', [.15 .32 .12 .07], ...
        'fontsi', 12, 'HorizontalAlignment', 'center', 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjAge'')');    % New subj age
    if isempty(strmatch('Age', fn))
        set(h([newSubjAgeLabel newSubjAge]), 'Visible', 'off');
    end
    
    %---- Enroll button
    h(newSubjEnroll)= uicontrol('units', 'norm', 'string', 'Enroll', ...
        'position', [.2 .21 .12 .08], 'fore', 'b', 'back', 'w', ...
        'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''newSubjEnroll'')');% Submit new name

    %----Frame for Returning Subject Choices
    h(returningSubjBox)=uicontrol('units', 'norm', 'style', 'frame', ...
        'position', [.525 .2 .45 .6], 'fore', 'k', 'back', 'w', ...
        'Enable', 'off');
    %--------Enrolled subject list header
    h(returningSubjHeader)=uicontrol('units', 'norm', 'style', 'text',...
        'string', 'Enrolled Participants', 'fontsize', 12, 'Enable', 'off', ...
        'fore', 'b', 'back', 'w', 'position', [.55 .72 .4 .05]);
    %-----Listbox for returning subjects
    h(returningSubjList)=uicontrol('units', 'norm', 'style', 'list', ...
        'position', [.55 .225 .4 .48], 'back', 'w', 'fore', 'b', ...
        'string', LAUNCHSubjList, 'fore', 'b', 'fontsi', 11, ...
        'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''oldSubjList'')');  % Returning list

    %----Frame for Session number
    h(sessFrame)=uicontrol('units', 'norm', 'style', 'frame', ...
        'position', [.14 .03 .5 .15], 'fore', 'k', 'back', 'w');

    %----Text box for session number
    h(sessNumText)=uicontrol('units', 'norm', 'style', 'text', ...
        'position', [.18 .05 .28 .08], 'string', 'Session #', ...
        'fontsi', 14, 'fontwe', 'bold', 'fore', 'b', 'back', 'w', ...
        'Enable', 'off');

    %---------actual session number box
    h(sessNumDisp)=uicontrol('units', 'norm', 'style', 'text', ...
        'position', [.45 .05 .1 .08], ...
        'fore', 'b', 'back', 'w', 'fontsi', 14, 'fontwe', 'bold', ...
        'string', ' ', ...
        'Enable', 'off');

    %-----Start button to initiate the experiment
    h(runButton)=uicontrol('units', 'norm', 'position', [.70 .06 .2 .1], ...
        'fore', 'r', 'back', 'w', 'string', 'Run', 'fontsi', 14, ...
        'fontwe', 'bold', 'Enable', 'off', ...
        'callback', 'GetSubjSessGui(''start'')');

    % Wait for the GUI interaction to complete then return results
    uiwait(f);
    ret = retvals;

    %------------CALLBACKS-------------------------
elseif strcmpi(varargin{1}, 'newSubj')==1
    % User has indicated a new subject
    % 1. Turn off the returning subject radio buttonbut leave it enabled
    % 2. Be sure other irrelevant controls are disabled
    % 3. Clear out the string in the new subject edit box and sessNum
    % 4. Change the color of the bounding boxes of Old/New subjects
    % 5. Set focus on the edit box
    set(h(returningSubj), 'value', 0);
    set(h([returningSubjBox returningSubjHeader returningSubjList ...
        sessNumText sessNumDisp runButton]), 'Enable', 'off');
    set(h([newSubjEditBox newSubjEditBoxLabel]), 'Enable', 'on');
    set(h(newSubjEditBox), 'string',  '', 'Selected', 'on');
    set(h([returningSubjBox sessFrame]), 'fore', 'k');
    set(h(newSubjBox), 'fore', 'b');
    set(h(sessNumDisp), 'string',  '');
    uicontrol(h(newSubjEditBox))

elseif strcmpi(varargin{1}, 'oldSubj')==1
    % User has indicated a returning subject
    % 1. Turn off the new subject radio button,  but leave it enabled
    % 2. Be sure other irrelevant controls are disabled
    % 3. Enable the returning subject list
    % 4. Change colors of the old/new subject enclsoing boxes
    % 5. Clear out the string in the new subject edit box and sessNum
    set(h(newSubj), 'value', 0);    
    set(h([newSubjBox newSubjEditBox newSubjEditBoxLabel newSubjMale ...
        newSubjFemale newSubjEthnicity newSubjAge newSubjEnroll ...
        sessNumText sessNumDisp runButton]), 'Enable', 'off');
    set(h([returningSubjHeader returningSubjList returningSubjBox]), ...
        'Enable', 'on');
    set(h([returningSubjBox sessFrame]), 'fore', 'b');
    set(h([newSubjBox sessFrame]), 'fore', 'k');
    set(h(sessNumDisp), 'string', ' ');
    set(h(newSubjEditBox), 'string', '');

elseif strcmpi(varargin{1}, 'newSubjName')==1
    % Here user has entered a potenially new subject name
    subjName=get(h(newSubjEditBox), 'string');
    % Be sure it is new
    if strmatch(subjName, LAUNCHSubjList, 'exact')
        % No. Name is already in our list. Put up an error and reset
        errordlg('That identifier is already in use. Please enter a different identifier.')
    else
        % Name is new. Save it and enable any demographic tests.
        retvals.SubjName = subjName;
        fn = fieldnames(retvals.Demographics);
        if ~isempty(strmatch('Sex', fn))
            retvals.Demographics.Sex = [];
            set(h(newSubjFemale), 'value', 0);
            set(h(newSubjMale), 'value', 0);
            set(h([newSubjMale newSubjFemale]), 'Enable', 'on');
        end
        if ~isempty(strmatch('Ethnicity', fn))
            retvals.Demographics.Ethnicity = [];
            set(h(newSubjEthnicity), 'value', 1);
            set(h(newSubjEthnicity), 'Enable', 'on');
        end
        if ~isempty(strmatch('Age', fn))
            retvals.Demographics.Age = [];
            set(h(newSubjAge), 'string', '')
            set(h([newSubjAge newSubjAgeLabel]), 'Enable', 'on');
        end
        set(h(newSubjEnroll), 'Enable', 'on');
    end%newsubj
    
elseif strcmpi(varargin{1}, 'newSubjMale')==1
    retvals.Demographics.Sex = 'Male';
    set(h(newSubjFemale), 'value', 0); 

elseif strcmpi(varargin{1}, 'newSubjFemale')==1
    retvals.Demographics.Sex = 'Female';
    set(h(newSubjMale), 'value', 0); 

elseif strcmpi(varargin{1}, 'newSubjEthnicity')==1
    indx = get(h(newSubjEthnicity), 'value');
    if indx == 1
        errordlg('Please select an ethnicity descriptor.')
    else
        retvals.Demographics.Ethnicity = ethnicityList{indx};
    end

elseif strcmpi(varargin{1}, 'newSubjAge')==1
    age = str2double(get(h(newSubjAge), 'string'));
    if isnan(age)
        errordlg('Please enter a number for age.');
        set(h(newSubjEditBox), 'string', '');
    elseif age <= 0 || age > 100
        errordlg('Please enter an age between 0 and 100.');
        set(h(newSubjEditBox), 'string', '');
    else
        retvals.Demographics.Age = age;
    end

elseif strcmpi(varargin{1}, 'newSubjEnroll')==1
    fn = fieldnames(retvals.Demographics);
    if ~isempty(strmatch('Sex', fn)) && isempty(retvals.Demographics.Sex)
        errordlg('Please select a Male/Female.');
    elseif ~isempty(strmatch('Ethnicity', fn)) && ...
            isempty(retvals.Demographics.Ethnicity)
        errordlg('Please select an ethnicity.');
    elseif ~isempty(strmatch('Age', fn)) && ...
            isempty(retvals.Demographics.Age)
        errordlg('Please enter an age.');
    else
        retvals.NewSubj = true;
        retvals.SubjNum = length(LAUNCHSubjList)+1;
        retvals.SessNum = 1;
        set(h(sessFrame), 'fore', 'b');
        set(h([sessNumText sessNumDisp runButton]), 'Enable', 'on');
        set(h(sessNumDisp), 'string', '1');
    end
elseif strcmpi(varargin{1}, 'oldSubjList')==1
    % Here user has selected an old subject
    % 1. Enable the session number display and the Run button
    % 2. Display the number of the next session
    subjNum=get(h(returningSubjList), 'value');
    
    % ADDED IN PROTECTION IN CASE YOU DIDN'T FINISH THE FIRST SESSION - RFB
    % 07/15/09
    if numel(LAUNCHSessList)<subjNum
        LAUNCHSessList(subjNum)=0;
    end
    sessNum = LAUNCHSessList(subjNum)+1;
    retvals.NewSubj = false;
    retvals.SubjNum = subjNum;
    retvals.SessNum = sessNum;
    retvals.SubjName = [];
    set(h(sessFrame), 'fore', 'b');
    set(h([sessNumText sessNumDisp runButton]), 'Enable', 'on');
    set(h(sessNumDisp), 'string', num2str(sessNum));

elseif strcmpi(varargin{1}, 'start')==1
    close all;
    retvals.GotGood = true;
else
    error('Bad OP %s', varargin{1});
end%callbacks
end