function savedTrialsDir = makePhaseScrambleERScan(baseDir,stimDir,exptCode,loadParfileFlag)
% This is the function that creates a new event related motion words
% experiment.  It is currently called from PhaseScrambleEventRelated, only if
% the user has entered an experiment code that was not previously created/saved.
%
%  savedTrialsDir = makePhaseScrambleERScan(baseDir,stimDir,exptCode,[loadParfileFlag])
%
% Note that right now your Phase Scrambled stims must be in your stims
% directory in a separate directory named "PhaseScrambleWord" and
% "PhaseScrambleNW".  Params.ScrambleLevel is saved as an output but
% doesn't actually do anything.  (It is just for checking back to see what
% level of scrambling you had.)  It would be nice to actually use this
% level to choose the correct stimulus files, but this is not trivial because of
% makeMovingWordTrial.m
%
% written by amr Feb 28, 2009
%

%% PARAMETERS

% Parameters specific to moving words
[fontParams,movieParams] = initWordParams('mr');
%movieParams.display = loadDisplayParams('displayName', '3T_projector_800x600');
movieParams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');

% Experimental Parameters common to both modes (pre-generated parfile and stimOrder file)
params.blankColor = 128;        % ISI uniform color e.g. 128 for gray
params.preStimBase = 12; %0; %12        % how many seconds before stimuli start; allows MR signal to settle
params.postStimBase = 0;        % how many seconds after last stimulus for a blank (in addition to last ITI)
params.RT = 0;                  % time after stimulus display to allow user to respond
params.ScrambleLevelW = input('Phase scramble level (words):  ');     % extra parameter for phase scrambling (b/w 0 and 1, where 1 is fully scrambled)
params.ScrambleLevelNW = input('Phase scramble level (nonwords), -1 for fully phase scrambled WORDS:  ');

if ~exist('loadParfileFlag','var'), loadParfileFlag = 0; end
if ~loadParfileFlag  % then create parfile from scratch using a stimOrderFile
    % Note: stimlength + RT + ITI = length of trial
    params.stimLength = movieParams.duration;     % trial length, not including ISI (seconds), set by initWordParams
    methodForITIs = 'poisson';      % will run setITIs differently depending on your choice here.  'poisson', 'rand', or 'textfile'
    meanITI = 4;                    % in seconds; only used for poisson distribution way of generating ITIs
    minITI = 1;                     % useful for rand ITI generation; if using poisson, make sure to set very low for accurate poisson stats
    maxITI = 20;                    % useful for rand ITI generation; if using poisson, set very high to allow accurate poisson distribution

elseif loadParfileFlag  % some extra parameters to specify length of experiment (i.e. to get final ITI)
    [parFilePath,onsets,params.conditionOrder,labels,colors]=loadParfile(baseDir);
    params.scan.TR = 2;                                              % secs for time of repetition
    params.scan.frames = 90;  %12                                       % how many frames collected (TR*frames = scan length)
    params.scan.scanlength = params.scan.TR * params.scan.frames;    % let's hold on to total scan length value (not including pre-stim base)
    params.stimLength = min(diff(onsets));                           % trial length, INCLUDING RT, assuming there are some back-to-back trials (no ITI)
    params.stimLength = params.stimLength - params.RT;               % by convention, code was written to assume RT isn't included in stimLength
    movieParams.duration = params.stimLength;                        % overwrite the stimulus duration so that frame length will be correct later
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

if ~loadParfileFlag  % then we just assign conditions names, which we need to make sure will match parfile
    % usually, we just use the first two conditions, word and nonword.
    % Nonword does not necessarily mean nonword, but could be any condition
    % that is not the word condition (e.g. consonant string, fully
    % scrambled word, or nonword).  This makes the analysis stage easier,
    % e.g. in calcPerformanceMW
    params.condNames{1} = 'PhaseScrambleWord';
    params.condNames{2} = 'PhaseScrambleNW';

elseif loadParfileFlag
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
end

%% WHERE TO SAVE TRIALS
savedTrialsDir = fullfile(stimDir,['TrialMovies_' num2str(exptCode)]);  % where to save the trial information/images
if ~exist(savedTrialsDir,'dir')
    mkdir(savedTrialsDir);
else
    fprintf('Trials directory %s',savedTrialsDir,' already exists.  Please try again.')  % just in case
    return
end

%% INITIALIZE PARFILE
if ~loadParfileFlag  % if we are loading parfile, user chooses parFilePath
    % [temp, parFileName] = fileparts(sequenceFile);  % give it the same name as sequence file but with .par extension
    parFileName = ['parfile_' num2str(exptCode) '.par'];
    parFilePath = fullfile(savedTrialsDir,parFileName);
end

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
    stimOrderFile = fullfile(baseDir,'stim','stimOrder.txt');
    fprintf('\nReading in stimulus order from default location:\n %s\n',stimOrderFile);
    fid = fopen(stimOrderFile);
    cols = textscan(fid,'%s%f');
    fclose(fid);
    params.stimOrder = cols{1};
    params.conditionOrder = cols{2};
    
elseif loadParfileFlag
    stimOrderFile = 'nothing-loadedParfile';
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
    return
end

%% MAKE STIMULI AND SAVE THEM OUT

% First load or create the word outlines
% note that if you choose to load the renderings (rather than cancelling so
% it creates them from scratch), they must match the order given in
% stimOrderFile
fprintf('\n%s\n','STEP 1: GETTING RENDERED STIMULI');
%[wStrImages,RenderedStimFile,fontParams] = loadRenderedWords(fontParams,params.stimOrder);
RenderedStimFile='N/A';

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
    %curWordImage = wStrImages{trialNum};                  % actual word image to make movie out of
    curWordImage = [];  % temporary initialization for debugging PhaseScrambleER since you presumably don't need an image (read from file)
    fprintf('%s%s\n','Creating stimulus frames for: ',trialInfo.stimName);
    
    % make the movie frames depending on the condition (trialInfo.condition)
    trialInfo.ScrambleLevelW = params.ScrambleLevelW;
    trialInfo.ScrambleLevelNW = params.ScrambleLevelNW;
    [trialInfo.images,numFrames] = makeMovingWordTrial(curWordImage,movieParams,trialInfo,stimDir);
    
    % specify sequence of images (for now, just play them in order)
    % for example, you could alternate between 2 images by making .seq [1 2 1 2 ...]
    trialInfo.seq = [1:numFrames];
    
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
save(paramInfoFile,'params','methodForITIs','meanITI','minITI','maxITI','fontParams','movieParams','RenderedStimFile','stimOrderFile','parFilePath');
% note that RenderedStimFile is empty if you have just created the renderings from scratch

% Save parfile if you created a new one
% Note that par.cond = 0 means fixation.
if ~loadParfileFlag
    writeParfile(par,parFilePath);
end

fprintf('%s%s\n','Saved all expt information in: ',savedTrialsDir);
return


function [parFilePath,onsets,conditionOrder,labels,colors] = loadParfile(baseDir)
%% Get the parfile
parFilePath = mrvSelectFile('r',{'par','txt'},'Select your parfile',baseDir);

% If it is an optseq parfile, convert to our format.
optseqflag = input('Was this parfile created directly by optseq2? (1=yes, 0=no) ');
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
