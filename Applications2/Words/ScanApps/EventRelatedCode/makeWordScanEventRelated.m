function savedTrialsDir = makeWordScanEventRelated(params,loadParfileFlag,numFramesPerContrastImage)
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
[params.font,params.movie] = initWordParams('mr');
%params.movie.display = loadDisplayParams('displayName', '3T_projector_800x600');
params.movie.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
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
params.preStimBase = 18;  %12 for regular MotionWords expt       % how many seconds before stimuli start; allows MR signal to settle
params.postStimBase = 0;        % how many seconds after last stimulus for a blank (in addition to last ITI)
params.RT = 0; %1 for regular MotionWords Expt                  % time after stimulus display to allow user to respond

if ~loadParfileFlag  % then create parfile from scratch using a stimOrderFile
    % Note: stimlength + RT + ITI = length of trial
    params.stimLength = params.movie.duration;     % trial length, not including ISI (seconds), set by initWordParams
    methodForITIs = 'poisson';      % will run setITIs differently depending on your choice here.  'poisson', 'rand', or 'textfile'
    meanITI = 4;                    % in seconds; only used for poisson distribution way of generating ITIs
    minITI = 1;                     % useful for rand ITI generation; if using poisson, make sure to set very low for accurate poisson stats
    maxITI = 20;                    % useful for rand ITI generation; if using poisson, set very high to allow accurate poisson distribution

elseif loadParfileFlag  % some extra parameters to specify length of experiment (i.e. to get final ITI)
    if ~isfield(params,'parfile')
        params.parfile = [];
    end
    [onsets,params.conditionOrder,labels,colors]=loadParfile(fullfile(params.baseDir,'parfiles'),params.parfile);
    par.onset = onsets; par.cond = params.conditionOrder; par.label = labels; par.color = colors;  % for saving later
    params.scan.TR = 2; %2  %3                                           % secs for time of repetition
    params.scan.frames = 150; %150   %120                                      % how many frames collected (TR*frames = scan length)
    params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value (not including pre-stim base)
    params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
    params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
    params.stimLength = 2; %input('Stimulus duration (secs): ');                % allow user to put in stimulus duration (needed for case of no back-to-back trials)
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
%     params.condNames{1} = 'Word0Lum100Mot';  % should these be 0% coherence luminance, or all 1 color luminance?
%     params.condNames{2} = 'NW0Lum100Mot';
%     params.condNames{3} = 'Word100Lum0Mot';  % should these be static or 0% coherence motion?
%     params.condNames{4} = 'NW100Lum0Mot';     % contrast edge defined words (non-scrambled)
%     params.condNames{5} = 'Word50Lum50Mot';
%     params.condNames{6} = 'NW50Lum50Mot';
%     params.condNames{7} = 'MotionControl';   % uniform plane of black moving dots -- maybe should be a nonword form for better control
%     params.condNames{8} = 'StaticDotWords';  % 1 frame of 100% luminance coherence
%     params.condNames{9} = 'StaticDotNW';
%     params.condNames{10} = 'ContrastEdgeWords';
%     params.condNames{11} = 'ContrastEdgeNW';       % contrast edge defined nonwords (non-scrambled)
%     params.condNames{12} = 'LuminanceControl';  % field of static dots (set coherence in makeMovingWordTrial.m)
    
% see makeMovingwordTrial2.m for possible condition names
    params.condNames{1} = 'MW_mot-100.lum-0_W';
    params.condNames{2} = 'MW_mot-66.lum-0_W';
    params.condNames{3} = 'MW_mot-33.lum-0_W';
    params.condNames{4} = 'MW_mot-0.lum-0_W';
    params.condNames{5} = 'MW_mot-100.lum-0_NW';
    params.condNames{6} = 'MW_mot-66.lum-0_NW';
    params.condNames{7} = 'MW_mot-33.lum-0_NW';
    params.condNames{8} = 'MW_mot-0.lum-0_NW';
    %params.condNames{9} = 'StaticDotNW';
    %params.condNames{10} = 'ContrastEdgeWords';
    %params.condNames{11} = 'ContrastEdgeNW';       % contrast edge defined nonwords (non-scrambled)
    %params.condNames{12} = 'LuminanceControl';  % field of static dots (set coherence in makeMovingWordTrial.m)

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
parFileName = [params.subjName '_Scan' num2Str(params.scanNumber) '_' datestr(now,'ddmmyyyy_HH-MM') '.par'];
parFilePath = fullfile(params.baseDir,'parfiles',params.subjName,parFileName);

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
    stimOrderFile = fullfile(params.stimDir,params.subjName,'stimOrder.txt');
    fprintf('\nReading in stimulus order from default location:\n %s\n',stimOrderFile);
    fid = fopen(stimOrderFile);
    cols = textscan(fid,'%s%f');
    fclose(fid);
    params.stimOrder = cols{1};
    params.conditionOrder = cols{2};
    
elseif loadParfileFlag
    stimOrderFile = 'nothing-loadedParfile';
    % Select the path for the word list
    if ~isfield(params,'curList')
        try
            wordstimFilePath = mrvSelectFile('r','txt','Select your word list',[params.baseDir '/stim/general']);
        catch
            wordstimFilePath = mrvSelectFile('r','txt','Select your word list',pwd);
        end
    else
        wordstimFilePath = fullfile(params.baseDir,'stim','general',sprintf('20WordList-%d.txt',params.curList));
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
    if ~isfield(params,'curList')
        
        try
            NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',fileparts(wordstimFilePath));
        catch
            NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',pwd);
        end
    else
        NWstimFilePath = fullfile(params.baseDir,'stim','general',sprintf('20NWList-%d.txt',params.curList));
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


function [onsets,conditionOrder,labels,colors] = loadParfile(baseDir,parfilePath)
%% Get the parfile
if isempty(parfilePath)
    parfilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',baseDir);
    if isempty(parfilePath)
        disp('User aborted')
        return
    end
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
