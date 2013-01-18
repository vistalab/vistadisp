function savedTrialsDir = makeHelpDyslexiaMotionPsychophys(params,loadParfileFlag,numFramesPerContrastImage)
% This is the function that creates a new event related motion words
% experiment.  It is currently called from MotionWordsEventRelated, only if
% the user has entered an experiment code that was not previously created/saved.
%
%  savedTrialsDir = makeWordScanEventRelated(params,loadParfileFlag,[numFramesPerContrastImage])
%
% written by amr Dec 16, 2008
%   Feb 16, 2009:  added functionality for reading from a pre-generated parfile
%   March 18, 2010:  numFramesPerContrastImage allows you to make movies of
%   a single frame, useful if you want to change fixations in the middle of
%   stimuli
% %%
% %% CURRENTLY ONLY WORKS FOR CASE WHERE YOU READ IN A PARFILE DUE TO
% CHANGES IN MOTION WORDS CODE
% %%

%% PARAMETERS

if notDefined('numFramesPerContrastImage')
    numFramesPerContrastImage = [];  % when empty, it won't do anything
end

% Parameters specific to moving words
[params.font,params.movie] = initHelpDyslexiaParams;
%params.movie.display = loadDisplayParams('displayName', '3T_projector_800x600');
params.movie.display = loadDisplayParams('displayName', 'bluemoon1.mat');%('builtin');%'tenbit');
screens=Screen('Screens'); % find the number of screens
params.movie.display.screenNumber = max(screens); % put this on the highest number screen
params.font.stimSizePix = [150 1500];

lettersFname = fullfile(params.stimDir,'general','letters.mat');
if exist(lettersFname,'file')
    load(lettersFname);
else  % render the letters first
    fprintf('\nCreating letters with default parameters and saving in:  \n%s\n',lettersFname)
    letters = wordGenLetterVar(lettersFname,params.font);  % use font params from initWordParams to create rendered letters if they don't already exist
end
params.movie.letters = letters;

% Experimental Parameters common to both modes (pre-generated parfile and stimOrder file)
params.blankColor = 128;        % ISI uniform color e.g. 128 for gray
params.preStimBase = 0;  %12       % how many seconds before stimuli start; allows MR signal to settle
params.postStimBase = 0;        % how many seconds after last stimulus for a blank (in addition to last ITI)
params.RT = 1;                  % time after stimulus display to allow user to respond

if ~loadParfileFlag  % then create parfile from scratch using a stimOrderFile
    % Note: stimlength + RT + ITI = length of trial
    params.stimLength = params.movie.duration;     % trial length, not including ISI (seconds), set by initWordParams
    methodForITIs = 'rand';      % will run setITIs differently depending on your choice here.  'poisson', 'rand', or 'textfile'
    meanITI = 3;                    % in seconds; only used for poisson distribution way of generating ITIs
    minITI = 3;                     % useful for rand ITI generation; if using poisson, make sure to set very low for accurate poisson stats
    maxITI = 3;                    % useful for rand ITI generation; if using poisson, set very high to allow accurate poisson distribution

elseif loadParfileFlag  % some extra parameters to specify length of experiment (i.e. to get final ITI)
    [onsets,params.conditionOrder,labels,colors]=loadParfile(fullfile(params.baseDir,'parfiles'));
    par.onset = onsets; par.cond = params.conditionOrder; par.label = labels; par.color = colors;  % for saving later
    params.scan.TR = 2; %2  %3                                           % secs for time of repetition
    params.scan.frames = 150; %150   %120                                      % how many frames collected (TR*frames = scan length)
    params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value (not including pre-stim base)
    params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
    params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
    params.stimLength = input('Stimulus duration (secs): ');                % allow user to put in stimulus duration (needed for case of no back-to-back trials)
    params.movie.duration = params.stimLength;                        % overwrite the stimulus duration so that frame length will be correct later
    % Get ITIs from parfile
    params.ITIs = diff(onsets)-(params.stimLength+params.RT);  % any time additional to stimulus length is ITI
    % Last stimulus is required to have an ITI also.  This is the length of the last blank after the last stimulus
    params.ITIs(end+1)= (params.scan.scanlength) - onsets(end) - (params.stimLength+params.RT);  % total scan length minus last stimulus onset
    meanITI = mean(params.ITIs);
    minITI = min(params.ITIs);
    maxITI = max(params.ITIs);
    methodForITIs = 'readFromParfile';
end

%% GET CONDITION NAMES/LABELS
% Check makeMovingWordTrial.m to see the parameters that are used for these conditions

if ~loadParfileFlag  % then we just assign conditions names, which we need to make sure will match
    
% see makeMovingwordTrial2.m for possible condition names
    params.condNames{1} = 'MW_mot-100.lum-100.in-0.out-128.noise-128_MotionWords';
    params.condNames{2} = 'MW_mot-100.lum-100.in-0.out-128.noise-128.static_LuminanceWords';


elseif loadParfileFlag
    % We get the condition names based on the labels in the parfile (matched to
    % the condition number).  We end up with a cell array called condNames, so
    % condNames{1} is the label for condition number 1.
    if ~isempty('labels')
        uniqueConds = unique(params.conditionOrder);
        uniqueConds = setdiff(uniqueConds,0);  % fixation condition is ignored
        for condnum = 1:length(uniqueConds)
            index = params.conditionOrder==uniqueConds(condnum);
            curLabels = labels(index);
            % note you need a +1 here to deal with fixation (0) condition
            params.condNames{uniqueConds(condnum)}=curLabels{1};  % first instance should be the same as all others
        end
    end
    
    % ignore the fixation condition after assigning labels-- will come out through ITIs
    params.conditionOrder = params.conditionOrder(params.conditionOrder ~= 0);  % ignore 0s
end


%% INITIALIZE PARFILE
% [temp, parFileName] = fileparts(sequenceFile);  % give it the same name as sequence file but with .par extension
parFileName = ['Parfile_' params.stimType '_' datestr(now,'ddmmyyyy_HH-MM') '.par'];
parFilePath = fullfile(params.baseDir,'parfiles',params.stimType,parFileName);

%% CONDITION AND STIMULUS ORDERING
% For when we don't read in a pre-generated parfile, the order of stimuli
% will be read from a text file for now.
% We read in a text file that specifies the stimuli (strings) in column 1
% and the conditions (numbers) in column 2.
% This means you manually need to make sure the right stimuli are going
% with the right conditions (e.g. words/nonwords).

% For reading in from a parfile, we automatically randomly assign stimuli
% from a list of words and a list of nonwords, which user chooses.

if ~loadParfileFlag
    stimOrderFile = fullfile(params.stimDir,sprintf('words-%s-%s.txt',params.listType,params.form));
    fprintf('\nReading in stimulus order from default location:\n %s\n',stimOrderFile);
    fid = fopen(stimOrderFile);
    cols = textscan(fid,'%s%f');
    fclose(fid);
    params.stimOrder = cols{1};
    if strcmp(params.stimType,'motion')
        params.conditionOrder = ones(1,length(params.stimOrder))*1;  % signifies the condition numbers are all 1s (motion)
    elseif strcmp(params.stimType,'static')
        params.conditionOrder = ones(1,length(params.stimOrder))*2;  % signifies the condition numbers are all 2s (static)
    end
    
elseif loadParfileFlag
    stimOrderFile = 'nothing-loadedParfile';
    % Select the path for the word list
    try
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',[params.baseDir '/stim/general']);
    catch
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',pwd);
    end
    % Open the word list
    fid = fopen(wordstimFilePath);
    % Use textscan to read out all of the strings from the list
    cols = textscan(fid,'%s');
    % Close the word list
    fclose(fid);
    % Assign the list of word strings to the variable wordlist
    wordlist=cols{1};
    
    % Select the path for the non word list
    try
        NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',fileparts(wordstimFilePath));
    catch
        NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',pwd);
    end
    % Open the non word list
    fid = fopen(NWstimFilePath);
    % Use textscan to read out all of the strings from the list
    cols = textscan(fid,'%s');
    % Close the non word list
    fclose(fid);
    % Assign the list of non word strings to the variables NWlist
    NWlist=cols{1};
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Insert path selection and word list generation for control condition
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % IMPORTANT:  conditions that use words must have 'Words' in their label
    % name for this next line to work
    params.stimOrder = assignWordStims2Conditions(wordlist,NWlist,params.conditionOrder,params.condNames);
end


%% GET ITIs -- only relevant for non-pre-generated-parfile case
% (if you already have a parfile, you just read in the ITIs, see above)
if ~loadParfileFlag
    numITIs = length(params.conditionOrder);  % there will be an ITI for every trial (even the last one)
    params.ITIs = setITIs(methodForITIs,numITIs,meanITI,minITI,maxITI);
end

%% Check with user that scan length is correct
numTrials = length(params.conditionOrder);
params.scan.scanlength = params.preStimBase + (numTrials)*(params.stimLength+params.RT) + sum(params.ITIs(1:numTrials)) + params.postStimBase;
fprintf('\n%s%0.1f%s\n','Total scan length will be:  ', params.scan.scanlength, '  seconds');
cont = input('Does this sound okay?  (y/n)  ','s');
if strcmp(cont,'n')
    savedTrialsDir = [];
    return
end

%% WHERE TO SAVE TRIALS
savedTrialsDir = params.savedTrialsDir;  % where to save the trial information/images
if ~exist(savedTrialsDir,'dir')
    mkdir(savedTrialsDir);
else
    fprintf('Trials directory %s',savedTrialsDir,' already exists.  Please try again.')  % just in case
    return
end

%% MAKE STIMULI AND SAVE THEM OUT

% First load or create the word outlines
% note that if you choose to load the renderings (rather than cancelling so
% it creates them from scratch), they must match the order given in
% stimOrderFile
fprintf('\n%s\n','STEP 1: GETTING RENDERED STIMULI');
[wStrImages] = wordCreateSaveTextOutline(params,params.stimOrder);

% Then make a movie for each stimulus using this outline and given the condition
fprintf('\n%s\n','STEP 2: CREATING TRIALS OUT OF RENDERED STIMULI');
for trialNum = 1:length(params.conditionOrder)
    
    % clear the previous trial to get ready for the next one
    clear trialInfo;
    clear trialFile;
    
    % get some information about the trial, which we will save in mat file
    trialInfo.condition = params.conditionOrder(trialNum);       % condition of this trial
    trialInfo.conditionName = params.condNames{trialInfo.condition};       % condition name of this trial
    trialInfo.stimName = params.stimOrder{trialNum};             % stimulus name for this trial
    curWordImage = wStrImages{trialNum};                  % actual word image to make movie out of
    fprintf('%s%s\n','Creating stimulus frames for: ',trialInfo.stimName);
    
    % make the movie frames depending on the condition (trialInfo.condition)
    [trialInfo.images,numFrames] = makeMovingWordTrial2(curWordImage,params.movie,params.font,trialInfo,params.stimDir);
    
    
    % if it's a 1 frame movie, make it multiple frames so more chances for changing fixation
    if ~isempty(numFramesPerContrastImage) && numFrames == 1  % contrast edge images
        numFrames = numFramesPerContrastImage;
        for xx = 2:numFramesPerContrastImage
            trialInfo.images{xx} = trialInfo.images{1};  % just copy the same frame multiple times
        end
    end
    
    for frameNum = 1:numFrames
        img = (trialInfo.images{frameNum}./255);
        M(frameNum) = im2frame(img);
    end
    movFname = fullfile(savedTrialsDir,['movie_' num2str(trialNum) '.avi']);
    fprintf('Saving movie to: %s\n',movFname)
    movie2avi(M,movFname,'FPS',params.movie.framesPerSec)
    
    % specify sequence of images (for now, just play them in order)
    % for example, you could alternate between 2 images by making .seq [1 2 1 2 ...]
    trialInfo.seq = 1:numFrames;
    
    % specify timing of images/frames
    % for now we just leave each frame on for equal time
    % note that .seqtiming gives the END time for each frame
    frameLength = params.stimLength / numFrames;
    trialInfo.seqtiming = trialInfo.seq .* frameLength;
    
    %% Parfile information -- only relevant if you need to create a new parfile
    if ~loadParfileFlag
        % first for fixation between trials
        if trialNum==1  % don't count preStimBase time for first trial
            par.onset(trialNum*2-1) = (trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-2));
        else
            par.onset(trialNum*2-1) = params.preStimBase + (trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-2));
        end
        par.cond(trialNum*2-1) = 0;
        par.label{trialNum*2-1} = 'Fix';
        
        % then for trials
        par.onset(trialNum*2) = params.preStimBase + (trialNum-1)*(params.stimLength+params.RT) + sum(params.ITIs(1:trialNum-1));
        par.cond(trialNum*2) = trialInfo.condition;
        par.label{trialNum*2} = trialInfo.conditionName;
    end
    
    %% Save the trial to file
    fprintf('Saving information for trial %0.0f\n',trialNum);
    % give a name to the file
    trialFile = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
    % save the trial
    save(trialFile,'trialInfo');
end

%% SAVE PARAMETERS AND OTHER INFO IN A SEPARATE FILE WITHIN THE DIRECTORY
paramInfoFile = fullfile(savedTrialsDir,'paramInfoFile.mat');
save(paramInfoFile,'params','methodForITIs','meanITI','minITI','maxITI','stimOrderFile','parFilePath');
% note that RenderedStimFile is empty if you have just created the renderings from scratch

% Save parfile if you created a new one
% Note that par.cond = 0 means fixation.
if ~loadParfileFlag
    if ~exist(fileparts(parFilePath),'dir'), mkdir(fileparts(parFilePath)); end
    writeParfile(par,parFilePath);
end

fprintf('%s%s\n','Saved all expt information in: ',savedTrialsDir);
return


function [onsets,conditionOrder,labels,colors] = loadParfile(baseDir)
%% Get the parfile
parfilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',baseDir);
if isempty(parfilePath)
    disp('User aborted')
    return
end

% If it is an optseq parfile, convert to our format.
if isempty(strfind(parfilePath,'vista'))
    optseqflag = input('Was this parfile created directly by optseq2? (1=yes, 0=no) ');
else  % assume that it's a vista parfile if it has "vista" in the name
    optseqflag = 0;
end
if optseqflag
    parfilePath = convertOptseqtoParfile(parfilePath);
end

% Then read the parfile
try
    [onsets,conditionOrder,labels,colors] = readParFile(parfilePath);
catch
    fprintf('\nParfile is not in proper format. See help readParfile\n\n')
end

% Disregard fixation conditions
nonfixIndex = find(conditionOrder); % non-fixation condition indices
onsets = onsets(nonfixIndex);
conditionOrder = conditionOrder(nonfixIndex);
labels = labels(nonfixIndex);
colors = colors(nonfixIndex);

return


function  [paramsA, paramsB] = initHelpDyslexiaParams(stimFile)

% Initializes the stairParams and stimParams used for the psychophysical or
% MR word experiments
%    
%    Psychophysical Case:
%    [stimParams, stairParams] = initWordParams(expType,stimFile)
%    MR Case:
%    [fontParams, movieParams] = initWordParams(expType,stimFile)
%
% Example:
%    [stimParams, stairParams] = initWordParams('psychophysics');
%    fontParams = initWordParams('mr');
%
% Author: amr 5/30/08
%
%
%  desired params:  8.8 deg/sec, 4 frames @ 50 Hz frames, dot density 12 dots/deg^2 (Talcott 2000 Neuropsychologia)
%      see also Maunsell and van Essen (1983) J. Neurophysiology
%


%% Check parameters

% Was stimFile defined?
if notDefined('stimFile')
    % Set cache to empty if undefined
    fontParams.stimFileCache = [];
else
    % Check for the existence of a stimFile itself
    if exist(stimFile,'file')
        % Set cache to stimFile
        fontParams.stimFileCache = stimFile;
        load(stimFile);
    else
        % Set cache to empty, user indicated a nonexistent stimFile
        fprintf('ERROR: stimFile does not exist @ %s\n',stimFile);
        fontParams.stimFileCache = [];
    end
end

%fontParams.stimFileCache = [];

%% Common Stimulus Parameters
% Font Properties
fontParams.fontName = 'Monospaced'; %'SansSerif';
fontParams.fontSize = 9; %10;  %regular value 10
fontParams.sampsPerPt = 8; %regular value 8
fontParams.antiAlias = 0;
fontParams.fractionalMetrics = 0;
fontParams.boldFlag = true;
fontParams.stimSizePix = [180 1000]; % in pixels, [y,x]  [180 600]
fontParams.spread = fontParams.stimSizePix/5; %4.5

% Moving Dot Properties
movieParams.conditionType = 'motion';  %'luminance' or 'motion' or 'polar'  % if you choose polar here, it will overwrite motCoherence and lumCoherence
movieParams.duration = 1;	% in seconds, default 1 or 2
movieParams.motCoherence = 1.0;
movieParams.lumCoherence = 0;
movieParams.dotDensity = 0.6;  %0.3
movieParams.dotLife = 20; %4;  % dotLife<=0 means infinite
movieParams.dotDisplacement = 1; % in pixels, def = 1
movieParams.framesPerSec = 30;  % determines speed of dots in movie

% The noise directions are one of 16 directions given by numDir.
movieParams.numDir = 2; % def = 16
movieParams.dotDir = [270 90]; % direction for each form ind [form=0 form=1 ... form=n], def = [270 (left) 90 (right)]

assumedRefresh = 60;  % was 75 before
fprintf('\n\nCurrent frameDuration assumes monitor refresh of %0.1f\n',assumedRefresh);
fprintf('This value is set in initWordParams.m if you need to change it.\n\n');
movieParams.frameDuration = 1/assumedRefresh*2; % in seconds; as far as I can tell, 2 is arbitrary (slows down the stimulus)-- 3 works, too

%movieParams.wordType = 'W';

movieParams.eccentricity = 2;

movieParams.inFormRGB = [0 0 0];   %[255 255 255]
movieParams.backRGB = [128 128 128];   %[128 128 128] for gray background
movieParams.outFormRGB = [255 255 255];

% Make some RGB values for noise dots (for luminance condition)
% noiseValues = (0:16:256)';
% movieParams.noiseRGB = repmat(noiseValues,1,3);
movieParams.noiseRGB = [0 0 0; 255 255 255];
    
% Properly Assign Names for Output
paramsA = fontParams;
paramsB = movieParams;

return
