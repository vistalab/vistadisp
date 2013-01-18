function savedTrialsDir = ecogWordMakeStimulationReading(params,loadParfileFlag)
% This is the function that creates a new event related experiment for ecog.  
% It is currently called from things like ecogStimulationReading, only if
% the user has entered a run number that was not previously created/saved.
%
%  savedTrialsDir = ecogWordMakeWordMixture(params,loadParfileFlag)
%
% same code as ecogWordMakeWordMixture by amr on Jan 11, 2010-- just some
% different params-- should just allow you to already have some params set.
%  Most of the code here is unnecessary for this easy experiment, but alas.
%
%
% 
%

%% PARAMETERS

% Parameters specific to moving words
[params.font,params.movie] = initWordParams('mr');
%params.movie.display = loadDisplayParams('displayName', '3T_projector_800x600');
%params.movie.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');
params.movie.display = loadDisplayParams('displayName', 'MacBookProBluemoon.mat');
lettersFname = fullfile(params.stimDir,'general','letters.mat');
if exist(lettersFname,'file')
    load(lettersFname);
else  % render the letters first
    fprintf('\nCreating letters with default parameters and saving in:  \n%s\n',lettersFname)
    letters = wordGenLetterVar(lettersFname,params.font);  % use font params from initWordParams to create rendered letters if they don't already exist
end
params.movie.letters = letters;

% Experimental Parameters common to both modes (pre-generated parfile and stimOrder file)
params.movie.duration = 1.5;      % set stimulus duration manually here (overwrite from initWordParams)
params.blankColor = 128;        % ISI uniform color e.g. 128 for gray
params.preStimBase = 0.5;         % how many seconds before stimuli start; allows MR signal to settle, not necessary for ecog
params.postStimBase = 0.5;        % how many seconds after last stimulus for a blank (in addition to last ITI)
params.RT = 0.1;                  % time after stimulus display to allow user to respond; ITI is in addition to the RT between trials

if ~loadParfileFlag  % then create parfile from scratch using a stimOrderFile
    % Note: stimlength + RT + ITI = length of trial
    params.stimLength = params.movie.duration;          % trial length, not including ISI (seconds)
    methodForITIs = 'rand';         % will run setITIs differently depending on your choice here.  'poisson', 'rand', or 'textfile'
    meanITI = 300;                  % in millisecs; only used for poisson distribution way of generating ITIs
    minITI = 300;                   % useful for rand ITI generation; if using poisson, make sure to set very low for accurate poisson stats
    maxITI = 300;                  % useful for rand ITI generation; if using poisson, set very high to allow accurate poisson distribution

elseif loadParfileFlag  % some extra parameters to specify length of experiment (i.e. to get final ITI)
    [onsets,params.conditionOrder,labels,colors]=loadParfile(fullfile(params.baseDir,'parfiles'));
    par.onset = onsets; par.cond = params.conditionOrder; par.labels = labels; par.colors = colors;  % for saving later
    params.scan.TR = 3; %2                                             % secs for time of repetition
    params.scan.frames = 120; %150                                       % how many frames collected (TR*frames = scan length)
    params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value (not including pre-stim base)
    params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
    params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
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
    params.condNames{1} = 'CE_in-255.out-128_Words_4letters';
    params.condNames{2} = 'CE_in-255.out-128_Words_6letters';
    params.condNames{3} = 'CE_in-255.out-128_Words_8letters';
    params.condNames{4} = 'CE_in-255.out-128_NW_4letters';
    params.condNames{5} = 'CE_in-255.out-128_NW_6letters';
    params.condNames{6} = 'CE_in-255.out-128_NW_8letters';
    params.condNames{7} = 'CE_in-255.out-128_CS_4letters';
    params.condNames{8} = 'CE_in-255.out-128_CS_6letters';
    params.condNames{9} = 'CE_in-255.out-128_CS_8letters';
    
    params.condNames{10} = 'PS_level-67_Words_4letters';
    params.condNames{11} = 'PS_level-67_Words_8letters';
    params.condNames{12} = 'PS_level-67_NW_4letters';
    params.condNames{13} = 'PS_level-67_NW_8letters';
    
    params.condNames{14} = 'PS_level-100_NW_4letters';
    params.condNames{15} = 'PS_level-100_NW_8letters';
    
    params.condNames{16} = 'ROT-90_PS_level-100_NW_8letters';
    
    params.condNames{17} = 'ROT-30_CE_in-255.out-128_Words_4letters';
    params.condNames{18} = 'ROT-30_CE_in-255.out-128_Words_8letters';
    params.condNames{19} = 'ROT-30_CE_in-255.out-128_NW_4letters';
    params.condNames{20} = 'ROT-30_CE_in-255.out-128_NW_8letters';
    
    params.condNames{21} = 'ROT-90_CE_in-255.out-128_Words_4letters';
    params.condNames{22} = 'ROT-90_CE_in-255.out-128_Words_8letters';
    params.condNames{23} = 'ROT-90_CE_in-255.out-128_NW_4letters';
    params.condNames{24} = 'ROT-90_CE_in-255.out-128_NW_8letters';
    
    params.condNames{25} = 'ROT-180_CE_in-255.out-128_Words_4letters';
    params.condNames{26} = 'ROT-180_CE_in-255.out-128_Words_8letters';
    params.condNames{27} = 'ROT-180_CE_in-255.out-128_NW_4letters';
    params.condNames{28} = 'ROT-180_CE_in-255.out-128_NW_8letters';
    
    params.condNames{29} = 'CE_in-255.out-128_Words_4letters_ECC-L'; %'ECC-L_CE_in-255.out-128_Words_4letters';
    params.condNames{30} = 'CE_in-255.out-128_Words_8letters_ECC-L'; %'ECC-L_CE_in-255.out-128_Words_8letters';
    params.condNames{31} = 'CE_in-255.out-128_NW_4letters_ECC-L'; %'ECC-L_CE_in-255.out-128_NW_4letters';
    params.condNames{32} = 'CE_in-255.out-128_NW_8letters_ECC-L'; %'ECC-L_CE_in-255.out-128_NW_8letters';
    params.condNames{33} = 'CE_in-255.out-128_Words_4letters_ECC-R'; %'ECC-R_CE_in-255.out-128_Words_4letters';
    params.condNames{34} = 'CE_in-255.out-128_Words_8letters_ECC-R'; %'ECC-R_CE_in-255.out-128_Words_8letters';
    params.condNames{35} = 'CE_in-255.out-128_NW_4letters_ECC-R'; %'ECC-R_CE_in-255.out-128_NW_4letters';
    params.condNames{36} = 'CE_in-255.out-128_NW_8letters_ECC-R'; %'ECC-R_CE_in-255.out-128_NW_8letters';
    
    params.condNames{37} = 'File-Object';
    
    

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

%% WHERE TO SAVE TRIALS
savedTrialsDir = params.savedTrialsDir;  % where to save the trial information/images
if ~exist(savedTrialsDir,'dir')
    mkdir(savedTrialsDir);
else
    fprintf('Trials directory %s',savedTrialsDir,' already exists.  Please try again.')  % just in case
    return
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
    stimOrderFile = fullfile(params.stimDir,params.subjName,['stimOrder' num2str(params.scanNumber) '.txt']);  % try based on scan number
    if exist(stimOrderFile,'file')
        fprintf('\nReading in stimulus order from location:\n %s\n',stimOrderFile);
    else
        stimOrderFile = fullfile(params.stimDir,params.subjName,'stimOrder.txt');  % just use a generic stimOrder file
        if exist(stimOrderFile,'file')
            fprintf('\nReading in stimulus order from GENERIC location:\n %s\n',stimOrderFile);
        else  % no stimOrder file
            error('You need a stimOrder file unless you are loading in a parfile instead.')
        end
    end
    fid = fopen(stimOrderFile);
    cols = textscan(fid,'%s%f');
    fclose(fid);
    params.stimOrder = cols{1};
    params.conditionOrder = cols{2};
    
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
    params.ITIs = params.ITIs/1000; % convert from ms to secs
end

%% Check with user that scan length is correct
numTrials = length(params.conditionOrder);
params.scan.scanlength = params.preStimBase + (numTrials)*(params.stimLength+params.RT) + sum(params.ITIs(1:numTrials)) + params.postStimBase;
fprintf('\n%s%0.2f%s\n','Total scan length will be:  ', params.scan.scanlength, '  seconds');
cont = input('Does this sound okay?  (y/n)  ','s');
if strcmp(cont,'n')
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
    if ~(trialInfo.condition==37)  % which is to read from file
        [trialInfo.images,numFrames] = makeMovingWordTrial2(curWordImage,params.movie,params.font,trialInfo,params.stimDir);
    elseif trialInfo.condition==37
        trialInfo.imagePath = fullfile(params.baseDir,'stim','general','Objects',trialInfo.stimName,[trialInfo.stimName '_i110.png']);
        numFrames = 1;
    end
    
    % specify sequence of images (for now, just play them in order)
    % for example, you could alternate between 2 images by making .seq [1 2 1 2 ...]
    trialInfo.seq = 1:numFrames;
    
    % specify timing of images/frames
    % for now we just leave each frame on for equal time
    % note that .seqtiming gives the END time for each frame
    frameLength = params.stimLength / numFrames;
    trialInfo.seqtiming = trialInfo.seq .* frameLength;
    
    % get stimulus position information if not in center
    if strfind(trialInfo.conditionName,'ECC-L')
        trialInfo.angle = 180;
        trialInfo.distance = 10;
    elseif strfind(trialInfo.conditionName,'ECC-R')
        trialInfo.angle = 0;
        trialInfo.distance = 10;
    end
    
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
%if ~loadParfileFlag
if ~exist(fileparts(parFilePath),'dir'), mkdir(fileparts(parFilePath)); end
writeParfile(par,parFilePath);
%end

fprintf('%s%s\n','Saved all expt information in: ',savedTrialsDir);
return


function [onsets,conditionOrder,labels,colors] = loadParfile(baseDir)
%% Get the parfile
parfilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',baseDir);

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
