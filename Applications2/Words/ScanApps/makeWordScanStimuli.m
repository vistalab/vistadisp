function [moviesDir] = makeWordScanStimuli(sequenceFile, RenderedStimFile, saveRenderedStimFlag, exptCode, fontParams, movieParams)
%
% This function makes the word scan stimuli for a specific run, whose
% sequence is based on a text file, sequenceFile.  See buildWordScanBlocks
% for more information about the format of sequenceFile.
%
%    [moviesDir] = makeWordScanStimuli([sequenceFile], [RenderedStimFile],
%    [saveRenderedStimFlag], [exptCode], [params])
%
% hierarchy of functions:  makeWordScanStimuli --> buildWordScanBlocks -->
% buildWordBlock --> makeMoveDotForm or makeLuminanceDotForm
%
% You can run the stimuli generated here using doWordScan.
%
% written by amr 08/05/08
%

%% Input parameters
if notDefined('sequenceFile')
    if exist('/Users/Shared/AndreasWordsMatlab/WordFiles','dir')
        sequenceFile = mrvSelectFile('r','txt','Select Stimulus Sequence File','/Users/Shared/AndreasWordsMatlab/WordFiles');
    else
        sequenceFile = mrvSelectFile('r','txt','Select Stimulus Sequence File',pwd);
    end
    if isempty(sequenceFile), return; end
end
pathName = fileparts(sequenceFile);

if notDefined('RenderedStimFile')
    % No input stim file specified. Create new ones.
    RenderedStimFile = '';
    createNewRenderingsFlag = 1;
else
    % Input file specified, so we don't need to create the renderings
    createNewRenderingsFlag = 0;
    saveRenderedStimFlag = 0;
end

if notDefined('saveRenderedStimFlag'), saveRenderedStimFlag = 1; end

if notDefined('exptCode')
    while 1
        exptCode = input('Please give this sequence an experiment code/number for future reference:  ');
        moviesDir = fullfile(pathName,['MovieBlocks_exptCode_' num2str(exptCode)]);
        if ~exist(moviesDir,'dir')
            break;
        else
            fprintf('Movie directory %s\n',moviesDir)
            fprintf('already exists! Please pick new experiment code. \n\n')
        end
    end
end

if notDefined('fontParams') || notDefined('movieParams')
    if notDefined('RenderedStimFile')
        [fontParams,movieParams] = initWordParams('mr');
    else
        [fontParams,movieParams] = initWordParams('mr',RenderedStimFile);
    end
end

% Load display and keyboard information
movieParams.display = loadDisplayParams('displayName', 'NEC485words.mat');%('builtin');%'tenbit');

% would be nice to set these in a GUI
blockLength = 12; %in secs
blankLength = 3; %time between blocks in secs (i.e. fixation condition length)
stimsPerBlock = blockLength/movieParams.duration; % #stimuli per block
ISItime = 0.100; % in seconds

%number of ISI frames
ISIframes = round(ISItime * (1/movieParams.frameDuration));  % sec/ISI * frame/sec = frames per ISI

%% Write out parfile based on stimulus sequence file and block lengths
% Would be nice to be able to load in a parfile as well (replace sequence
% files with parfiles?)

fid = fopen(sequenceFile);
cols = textscan(fid,'%s%s');
fclose(fid);

% start with parIndex = 3 because first set of block + fixation is assumed to be a dummy,
% and you don't want to include the dummy in the parfile
for parIndex = 1:2:(2*(length(cols{1})))  % go by 2s because block is always paired with fixation
    par.onset(parIndex) = (floor(parIndex/2)) * (blankLength + blockLength);
    par.cond(parIndex) = 0;
    par.label{parIndex} = 'Fix';

    % Stimulus block
    par.onset(parIndex+1) = (floor(parIndex/2)) * (blankLength + blockLength) + blankLength;
    if strcmp(cols{1}(ceil(parIndex/2)),'motion')
        if strcmp(cols{2}(ceil(parIndex/2)),'word')
            par.label{parIndex+1} = 'Motion Word';
            par.cond(parIndex+1) = 3;
        elseif strcmp(cols{2}(ceil(parIndex/2)),'noise')
            par.label{parIndex+1} = 'Motion Noise';
            par.cond(parIndex+1) = 4;
        end
    elseif strcmp(cols{1}(ceil(parIndex/2)),'lumtion')
        par.label{parIndex+1} = 'Lumtion Word';
        par.cond(parIndex+1) = 1;
        
    elseif strcmp(cols{1}(ceil(parIndex/2)),'luminance')
        par.label{parIndex+1} = 'Luminance Word';
        par.cond(parIndex+1) = 2;
    end
end

% Now account for dummy block at beginning (this may be a dangerous
% assumption!)
par.onset = par.onset(3:end); % first block and fixation are deleted
par.cond = par.cond(3:end);
par.label = par.label(3:end);
par.onset = par.onset - (blankLength + blockLength);  % set back to make start equal to 0

% add fixation at end (again, a dangerous assumption!)
par.onset(end+1) = par.onset(end)+blockLength;
par.cond(end+1) = 0;   % 0 = fixation
par.label{end+1} = 'Fix';

sprintf('\n%s\n','VERY IMPORTANT: THE AUTOMATIC PARFILE ASSUMES ONE DUMMY BLOCK & FIX AT BEGINNING (and no extra dummy fixation)')
sprintf('%s\n','IT ALSO ASSUMES AN EXTRA FIXATION AT THE END')


%% Define stimulus list - could be defined in params file?
if createNewRenderingsFlag
    %     Real words
    if exist('/Users/Shared/AndreasWordsMatlab/WordFiles','dir')
        WordStimFile = mrvSelectFile('r','txt','Select file with WORD stimuli','/Users/Shared/AndreasWordsMatlab/WordFiles');
    else
        WordStimFile = mrvSelectFile('r','txt','Select file with WORD stimuli',pwd);
    end
    if isempty(WordStimFile), disp('No word stimuli selected!'); %user cancelled
        wStr=[];
    else
        fid = fopen(WordStimFile);
        tempStrs = textscan(fid,'%s');
        fclose(fid);
        for ii = 1:length(tempStrs{1})
            wStr(ii)=tempStrs{1}(ii);  % get them out of the cell array
        end
        clear tempStrs;
    end

    %     Non-words
    if exist('/Users/Shared/AndreasWordsMatlab/WordFiles','dir')
        NWordStimFile = mrvSelectFile('r','txt','Select file with NON-WORD stimuli','/Users/Shared/AndreasWordsMatlab/WordFiles');
    else
        NWordStimFile = mrvSelectFile('r','txt','Select file with NON-WORD stimuli',pwd);
    end
    if isempty(NWordStimFile), disp('No non-word stimuli selected!'); %user cancelled
        nwStr=[];
    else
        fid = fopen(NWordStimFile);
        tempStrs = textscan(fid,'%s');
        fclose(fid);
        for ii = 1:length(tempStrs{1})
            nwStr(ii)=tempStrs{1}(ii);  % get them out of the cell array
        end
        clear tempStrs;
    end
end

% % These are some useful strings for testing the code
% wStr = {'form','more','hard'}; %{'arch',  'boss', 
% nwStr = {'fuba','adsf','weer'};

% Debugging for BW
% movieParams.display.screenNumber = 0;
% On the Mac we use getDevices to fill this field.  For testing, on a PC,
% we can't because it uses a mexmac file.
% movieParams.devices = [];


%% Create the rendered outline for all words/nonwords

if createNewRenderingsFlag

    % Create the outlines and place them in the stimulus parameter
    %[data, fontParams] = wordCreateSaveTextOutline(fontParams, wStr, nwStr);
    [data] = wordCreateSaveTextOutline(fontParams, wStr); %, nwStr);
    if isempty('data.nwStrImg'), data.nwStrImg=[]; end

    % Adjust the stimulus properties for randomizing the order, saving file
    % Use PTB Shuffle to randomize the order
    data.wStrInds  = Shuffle((1:numel(wStr)));
    data.nwStrInds = Shuffle((1:numel(nwStr)));

    % Set current string to 0
    data.curWStr=0;  %initialize curWStr
    data.curNStr=0;  %initialize curNStr

else
    % Load stimulus data from a file
    if notDefined('RenderedStimFile')
        RenderedStimFile = mrvSelectFile('r','mat','Select file to load rendered stimuli');
    end

    disp('Loading rendered stim file...');
    tmp = load(RenderedStimFile);

    % rendered text is in the stimulus variable e.g. data.wStrImg{1};
    data = tmp.data;
    wStr = tmp.wStr;
    nwStr = tmp.nwStr;
    fontParams = tmp.fontParams;
    % figure; imagesc(data.wStrImg{1})
end


%% Save rendered stimulus data to file

if saveRenderedStimFlag
    if isfield(fontParams,'stimFileCache'), fName = fontParams.stimFileCache;
    else fName = ''; end

    if isempty(fName)
        fName = mrvSelectFile('w','mat','Select file to save rendered stimuli');
        if   isempty(fName), disp('User canceled saving rendered text.');
        else fontParams.stimFileCache = fName;
            save(fName,'data','wStr','nwStr','fontParams');
            fprintf('Saved rendered stimuli to file: %s\n\n',fName);
        end
    end
end

%% Make movies for all blocks and save to new directory

% pathName = fileparts(sequenceFile);
% moviesDir = fullfile(pathName,['MovieBlocks_exptCode_'
% num2str(exptCode)]);
fprintf('Building block structure: \n');
[moviesDir,totNumBlocks] = buildWordScanBlocks(sequenceFile, stimsPerBlock, data, movieParams, wStr, nwStr, exptCode, ISIframes);
fprintf('Saved in: %s\n',moviesDir);
notesFile = fullfile(moviesDir,'moreInfo.mat');
save(notesFile,'exptCode','totNumBlocks','stimsPerBlock','sequenceFile','wStr','nwStr','blockLength','blankLength','ISIframes','ISItime','fontParams','movieParams');  %save here anything that might be relevant later

[temp, parFileName] = fileparts(sequenceFile);  % give it the same name as sequence file but with .par extension
parFileName = [parFileName '.par'];
parFilePath = fullfile(pathName,parFileName);
writeParfile(par,parFilePath);
fprintf('\n%s\n%s\n','Saved parfile to:  ', parFilePath);

return;