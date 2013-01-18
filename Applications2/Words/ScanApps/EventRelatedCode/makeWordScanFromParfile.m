function savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)

% This function creates a new Motion Words experiment (event-related) from
% a pre-generated parfile.
%
%   THIS FUNCTION SHOULD NOW BE OBSOLETE-- INCORPORATED INTO
%   MAKEWORDSCANEVENTRELATED
%
%  savedTrialsDir = makeWordScanFromParfile(baseDir,stimDir,exptCode)
%
% written by amr Feb 5, 2009
%

%% PARAMETERS

% Parameters specific to moving words
[fontParams,movieParams] = initWordParams('mr');
%movieParams.display = loadDisplayParams('displayName', '3T_projector_800x600');
movieParams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');

%% Get the parfile
parfilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',baseDir);

% If it is an optseq parfile, convert to our format.
optseqflag = input('Was this parfile created directly by optseq2? (1=yes, 0=no) ');
if optseqflag
    parfilePath = convertOptseqtoParfile(parfilePath);
end

% Then read the parfile
try
    [onsets,params.conditionOrder,labels,colors] = readParFile(parfilePath);
catch
    fprintf('\nParfile is not in proper format. See help readParfile\n\n')
end

% Disregard fixation conditions
nonfixIndex = find(params.conditionOrder); % non-fixation condition indices
onsets = onsets(nonfixIndex);
params.conditionOrder = params.conditionOrder(nonfixIndex);
labels = labels(nonfixIndex);
colors = colors(nonfixIndex);

%% Experimental Parameters
% Note that this is a very different structure than
% makeWordScanEventRelated.  Here, the ITIs are extracted FROM the parfile
% based on the following assumptions:
%   1) There are some back-to-back trials (without ITI)
%   2) The code treats stimLength as being the stimulus length not
%   including RT
%   3) There is a constant stimLength across conditions/stimuli
params.scan.TR = 2;                                              % secs for time of repetition
params.scan.frames = 150;                                        % how many frames collected (TR*frames = scan length)
params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value
params.RT = 1; %0.5;                                             % time after stimulus display to allow user to respond
params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
movieParams.duration = params.stimLength;                        % overwrite the stimulus duration so that frame length will be correct later

params.blankColor = 128;         % ISI uniform color e.g. 128 for gray
params.preStimBase = 12;         % how many seconds before stimuli start; allows MR signal to settle
params.postStimBase = 12;        % how many seconds after last stimulus for a blank (in addition to last ITI)

% Get ITIs from parfile
params.ITIs = diff(onsets)-(params.stimLength+params.RT);  % any time additional to stimulus length is ITI

% Last stimulus is required to have an ITI also.  This is the length of the last blank after the last stimulus
params.ITIs(end+1)= (params.scan.scanlength) - onsets(end) - (params.stimLength+params.RT);  % total scan length minus last stimulus onset

% Set the condition names here
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

% Where to save the trials
savedTrialsDir = fullfile(stimDir,['TrialMovies_' num2str(exptCode)]);  % where to save the trial information/images
if ~exist(savedTrialsDir,'dir')
    mkdir(savedTrialsDir);
else
    fprintf('Trials directory %s',savedTrialsDir,' already exists.  Please try again.')  % just in case
    return
end

%% ASSIGN STIMULI RANDOMLY TO THE CONDITIONS
try
    wordstimFilePath = mrvSelectFile('r','txt','Select your word list',[baseDir '/stim']);
catch
    wordstimFilePath = mrvSelectFile('r','txt','Select your word list',pwd);
end
fid = fopen(wordstimFilePath);
cols = textscan(fid,'%s');
fclose(fid);
wordlist=cols{1};
try
    NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',[baseDir '/stim']);
catch
    NWstimFilePath = mrvSelectFile('r','txt','Select your nonword list',pwd);
end
fid = fopen(NWstimFilePath);
cols = textscan(fid,'%s');
fclose(fid);
NWlist=cols{1};
% IMPORTANT:  conditions that use words must have 'Words' in their label
% name for this next line to work
params.stimOrder = assignWordStims2Conditions(wordlist,NWlist,params.conditionOrder,params.condNames);

%% MAKE STIMULI AND SAVE THEM OUT

% First load or create the word outlines
% note that if you choose to load the renderings (rather than cancelling so
% it creates them from scratch), they must match the order given in
% stimOrderFile (this is now kind of obsolete concept)
fprintf('\n%s\n','STEP 1: GETTING RENDERED STIMULI');
[wStrImages,RenderedStimFile,fontParams] = loadRenderedWords(fontParams,params.stimOrder);

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
    [trialInfo.images,numFrames] = makeMovingWordTrial(curWordImage,movieParams,trialInfo,stimDir);
    
    % specify sequence of images (for now, just play them in order)
    % for example, you could alternate between 2 images by making .seq [1 2 1 2 ...]
    trialInfo.seq = [1:numFrames];
    
    % specify timing of images/frames
    % for now we just leave each frame on for equal time
    % note that .seqtiming gives the END time for each frame
    frameLength = params.stimLength / numFrames;
    trialInfo.seqtiming = trialInfo.seq .* frameLength;
    
    %% Save the trial to file
    fprintf('Saving information for trial %0.0f\n',trialNum);
    % give a name to the file
    trialFile = fullfile(savedTrialsDir,['trial_' num2str(trialNum) '.mat']);
    % save the trial
    save(trialFile,'trialInfo');
end

%% SAVE PARAMETERS AND OTHER INFO IN A SEPARATE FILE WITHIN THE DIRECTORY
paramInfoFile = fullfile(savedTrialsDir,'paramInfoFile.mat');
save(paramInfoFile,'params','fontParams','movieParams','RenderedStimFile');
% note that RenderedStimFile is empty if you have just created the
% renderings from scratch


fprintf('%s%s\n','Saved all expt information in: ',savedTrialsDir);

return