function savedTrialsDir = makeResponseSorting(baseDir,stimDir,thresh,exptType,parfilecounter,stimlistcounter,runNum,subjID)
% This is the function that creates a new response sorting
% experiment.  It is currently called from responseSorting.m.
%
%  savedTrialsDir = makeResponseSorting(baseDir,stimDir,thresh,exptType,[parfilecounter],[stimlistcounter],[subjID])
%
% parfilecounter determines which parfile will be used (e.g. 1.par)
% stimlistcounter determines which stimulus list will be used (e.g. 1.txt),
% and this is also differentiated based on exptType.
%
% runNum is only used for determining where to save the trial information--
% could probably clean up the baseDir,stimDir,runNum inputs-- don't need
% them all necessarily
%
% Note that right now your stim BMPs must be in your stims
% directory in a separate directory named "Word" and "NW".  They are put
% there automatically by the program.
%
% written by amr June 28, 2009
%

%% PARAMETERS

% Parameters specific to moving words
params = initPhaseScrambleParams(exptType);
params.display = loadDisplayParams('displayName', '3T_projector_800x600');
%params.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');

if exist('subjID','var')
    params.subjID = subjID; % save this in params for later use, but if not defined, keep it that way
end

% Experimental Parameters common to both modes (pre-generated parfile and stimOrder file)
params.blankColor = 128;        % ISI uniform color e.g. 128 for gray
params.preStimBase = 12; %0; %12        % how many seconds before stimuli start; allows MR signal to settle
params.postStimBase = 0;        % how many seconds after last stimulus for a blank (in addition to last ITI)
params.RT = 0;                  % time after stimulus display to allow user to respond
params.ScrambleLevelW = thresh;     % b/w 0 and 1, where 1 is fully scrambled
if strcmp(exptType,'detect')
    params.ScrambleLevelNW = 1;  % fully phase scramble NW for detection
elseif strcmp(exptType,'lexical')
    params.ScrambleLevelNW = thresh;
end
if notDefined('parfilecounter')  % determines parfile number
    initPath = baseDir;
else
    initPath = fullfile(stimDir,'parfiles',[num2str(parfilecounter) '.par']);
end
[parFilePath,onsets,params.conditionOrder,labels,colors]=loadParfile(initPath,0);
params.scan.TR = 2;                                              % secs for time of repetition
params.scan.frames = 90;  %12                                    % how many frames collected (TR*frames = scan length)
params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value (not including pre-stim base)
params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
params.duration = params.stimLength;                             % overwrite the stimulus duration so that frame length will be correct later
% Get ITIs from parfile
params.ITIs = diff(onsets)-(params.stimLength+params.RT);  % any time additional to stimulus length is ITI
% Last stimulus is required to have an ITI also.  This is the length of the last blank after the last stimulus
params.ITIs(end+1)= (params.scan.scanlength) - onsets(end) - (params.stimLength+params.RT);  % total scan length minus last stimulus onset
meanITI = mean(params.ITIs);
minITI = min(params.ITIs);
maxITI = max(params.ITIs);
methodForITIs = 'readFromParfile';


%% GET CONDITION NAMES/LABELS
% Check makeMovingWordTrial.m to see the parameters that are used for these conditions

% We get the condition names based on the labels in the parfile (matched to
% the condition number).  We end up with a cell array called condNames, so
% condNames{1} is the label for condition number 1.
if ~isempty('labels')
    uniqueConds = unique(params.conditionOrder);
    uniqueConds = setdiff(uniqueConds,0);  % fixation condition is ignored
    for condnum = 1:length(uniqueConds)
        index = find(params.conditionOrder==uniqueConds(condnum));
        curLabels = labels(index);
        % note you need a +1 here to deal with fixation (0) condition
        params.condNames{uniqueConds(condnum)}=curLabels{1};  % first instance should be the same as all others
    end
end

% ignore the fixation condition after assigning labels-- will come out through ITIs
params.conditionOrder = params.conditionOrder(params.conditionOrder ~= 0);  % ignore 0s


%% WHERE TO SAVE TRIALS
exptCode = strcat(exptType,num2str(thresh));  % base exptCode name on threshold
savedTrialsDir = fullfile(baseDir,'savedTrials',['SavedTrials_' exptCode],['run' num2str(runNum)]);  % where to save the trial information/images for that run
if ~exist(savedTrialsDir,'dir')
    mkdir(savedTrialsDir);
else
    fprintf('Trials directory %s\n',savedTrialsDir,' already exists.  Ready to run.')  % rare case of same threshold
    return
end


%% STIMULUS ORDERING
% The parfile is chosen above based on the run number for that particular
% subject (which determines parfilecounter).  Now we select the stimuli to
% go with each run, which is determined by stimlistcounter.  (Again, the
% order varies according to subject number.)
%
wordstimFilePath = fullfile(stimDir,'wordlists',exptType,'Word',[num2str(stimlistcounter) '.txt']);
NWstimFilePath = fullfile(stimDir,'wordlists',exptType,'NW',[num2str(stimlistcounter) '.txt']);
if ~exist(wordstimFilePath,'file')
    try
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',[baseDir '/stim']);
    catch
        wordstimFilePath = mrvSelectFile('r','txt','Select your word list',pwd);
    end
end
fid = fopen(wordstimFilePath);
cols = textscan(fid,'%s');
fclose(fid);
wordlist=cols{1};
if ~exist(NWstimFilePath,'file')
    try
        NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',[baseDir '/stim']);
    catch
        NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',pwd);
    end
end
fid = fopen(NWstimFilePath);
cols = textscan(fid,'%s');
fclose(fid);
NWlist=cols{1};
% IMPORTANT:  conditions that use words must have 'Word' in their label
% name for assignWordStims2Conditions to work

% Note that we are now just assigning real words to the nonword list for
% the detection experiment, so you do not need to force using the word
% list.  Instead, we use the NW list, which contains real words that will
% be completely phase scrambled (so they will be "not a word").
% if strcmp(exptType,'detect')
%     useOnlyWords = 1;  % to prevent nonwords from being used for detection trials (should all be made from words)
% else
%     useOnlyWords = 0;
% end

% Randomly assign stimuli within the lists to the conditions
params.stimOrder = assignWordStims2Conditions(wordlist,NWlist,params.conditionOrder,params.condNames);

%% Check with user that scan length is correct
numTrials = length(params.conditionOrder);
params.scan.scanlength = params.preStimBase + (numTrials)*(params.stimLength+params.RT) + sum(params.ITIs(1:numTrials)) + params.postStimBase;
fprintf('\n%s%0.1f%s\n','Total scan length will be:  ', params.scan.scanlength, '  seconds');
cont = input('Does this sound okay?  (y/n)  ','s');
if strcmp(cont,'n')
    return
end

%% MAKE TRIALS AND SAVE THEM OUT

fprintf('\n%s\n','CREATING TRIALS...please be patient.');

% remove any previously cached bmp files
for cond = 1:length(params.condNames)
    stimCacheDir = fullfile(stimDir,params.condNames{cond});
    delete(fullfile(stimCacheDir,'*'));
end

% create all trials
for trialNum = 1:length(params.conditionOrder)
    
    % clear the previous trial to get ready for the next one
    clear trialInfo;
    clear trialFile;
    
    % get some information about the trial, which we will save in mat file
    trialInfo.condition = params.conditionOrder(trialNum);       % condition of this trial
    trialInfo.conditionName = params.condNames{trialInfo.condition};       % condition name of this trial
    trialInfo.stimName = params.stimOrder{trialNum};             % stimulus name for this trial
    
    % make the phase scrambled image and write it out
    trialInfo.ScrambleLevelW = params.ScrambleLevelW;
    trialInfo.ScrambleLevelNW = params.ScrambleLevelNW;
    trialInfo.imagePath = fullfile(stimDir,trialInfo.conditionName,[trialInfo.stimName '.bmp']);
    if trialInfo.condition==1  % word stimulus
        img = scrambleWord(trialInfo.stimName,trialInfo.ScrambleLevelW);
    elseif trialInfo.condition==2  % nonword stimulus or noise stimulus, depending on exptType
        img = scrambleWord(trialInfo.stimName,trialInfo.ScrambleLevelNW);
    end
    imwrite(img,trialInfo.imagePath,'bmp');
    
    % specify sequence of images (in this case, just one image)
    % for example, you could alternate between 2 images by making .seq [1 2 1 2 ...]
    trialInfo.seq = 1;
    
    % specify timing of images/frames
    % for now we just leave each frame on for equal time
    % note that .seqtiming gives the END time for each frame
    frameLength = params.stimLength;
    trialInfo.seqtiming = trialInfo.seq .* frameLength;
    
    %% Save the trial to file
    % give a name to the file
    trialFile = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
    % save the trial
    save(trialFile,'trialInfo');
end

%% SAVE PARAMETERS AND OTHER INFO IN A SEPARATE FILE WITHIN THE DIRECTORY
paramInfoFile = fullfile(savedTrialsDir,'paramInfoFile.mat');
save(paramInfoFile,'params','methodForITIs','meanITI','minITI','maxITI','parFilePath');
fprintf('\n%s\n%s\n\n','Saved all expt information in: ',savedTrialsDir);
return


function [parFilePath,onsets,conditionOrder,labels,colors] = loadParfile(parFilePath,optseqflag)
% parFilePath can be the path to a parfile or the baseDir name (i.e. place to start looking for parfile)

%% Get the parfile
if ~exist(parFilePath,'file')
    parFilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',parFilePath);
end
%parFilePath =
%fullfile(baseDir,'stim','OptSeq_PhaseScrambleER','WordVScramble','2secStim_0secRT_Words_Scramble','PhaseScrambleER_2secStimuli_0secRT-001_vista.par');

% If it is an optseq parfile, convert to our format.
if notDefined('optseqflag')
    optseqflag = input('Was this parfile created directly by optseq2? (1=yes, 0=no) ');
end
if optseqflag
    parFilePath = convertOptseqtoParfile(parFilePath);
end

% Then read the parfile
try
    [onsets,conditionOrder,labels,colors] = readParFile(parFilePath);
catch
    fprintf('\nParfile is not in proper format. See help readParfile\n\n')
end

% Disregard fixation conditions
nonfixIndex = find(conditionOrder); % non-fixation condition indices
onsets = onsets(nonfixIndex);
conditionOrder = conditionOrder(nonfixIndex);
labels = labels(nonfixIndex);
colors = colors(nonfixIndex);
