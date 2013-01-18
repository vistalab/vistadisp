function [trial, data] = makePhaseScrambleTrial(display, stimParams, data)
% Function used to generate a trial of the phase scrambled word stimuli for
% the phase scramble staircase.

% Load Word/Nonword lists
wordlist = ['/Users/Shared/PsychophysData/PhaseScrambleStaircase/' stimParams.exptType '/wordlist.mat'];
NWlist = ['/Users/Shared/PsychophysData/PhaseScrambleStaircase/' stimParams.exptType '/NWlist.mat'];
load(wordlist)    % wStr
load(NWlist)      % nStr

% Set word storage file name (used for keeping track of individual subjects
% and which words they've seen).
%ssFile = sprintf('/Users/Shared/PsychophysData/PhaseScrambleStaircase/ssWordFiles/%s_WordList.mat',stimParams.subjName);
%
% % Check for word storage file
% if(exist(ssFile,'file'));
%     tempData = load(ssFile);
% end

% Stimuli for testing
%wStr = {'arch', 'boss', 'coat'};
%nStr = {'absy', 'ceap', 'eara'};

if(~isfield(data,'wStrInds'))   % initalization step for cache

    % Check the cache file first
    if(exist(stimParams.stimFileCache,'file'))
        disp('Loading stim cache...');
        tmp = load(stimParams.stimFileCache);
        data = tmp.data;
        data.wStrInds = Shuffle([1:numel(data.wStrInds)]);
        data.nStrInds = Shuffle([1:numel(data.nStrInds)]);
        clear tmp;
    end
    
    trial=[];   %Set this to nothing just so you can return
    data.curWStr=0;  %initialize curWStr
    data.curNStr=0;  %initialize curNStr
    
    % The following code is for seeing which stimuli have been run on a particular subject.
%     if exist('tempData','var')
%         data.wStrInds = tempData.wStrInds;
%         data.nStrInds = tempData.nStrInds;
%         data.curWStr = tempData.curWStr;
%         data.curNStr = tempData.curNStr;
%     end
        
    % Shuffle order of stimulus presentation
    data.wStrInds = Shuffle([1:numel(wStr)]);
    data.nStrInds = Shuffle([1:numel(nStr)]);
    
    % Save to cache
    save(stimParams.stimFileCache,'data','wStr','nStr','stimParams');
    
    return;          %If it was in this if statement, it was before the first trial, so return.
end


%% First, get the current word
% Check which type of trial (word/nonword) and store current stimulus (curStrImg) %%
if(stimParams.wordType=='W')
    data.curWStr = data.curWStr+1;
    
    % If we've exhausted the list of words, repeat word list
    if(data.curWStr>numel(data.wStrInds))
        data.curWStr = 1;
        data.wStrInds = Shuffle(data.wStrInds);
        disp('NOTE: Repeating the word list.');
    end
    
    % Set current stimulus to the next word in the list
    %curStrImg = data.wStrImg{data.wStrInds(data.curWStr)};
    % Store words that have been used
    data.word = wStr{data.wStrInds(data.curWStr)};
    data.wordType = 1;
    
elseif(stimParams.wordType=='N')
    data.curNStr = data.curNStr+1;
    
    % If we've exhausted the list of nonwords, repeat nonword list
    if(data.curNStr>numel(data.nStrInds))
        data.curNStr = 1;
        data.nStrInds = Shuffle(data.nStrInds);
        disp('NOTE: Repeating the nonword list.');
    end
    
    % Set current stimulus to the next nonword in the list
    %curStrImg = data.nStrImg{data.nStrInds(data.curNStr)};
    % Store words that have been used
    data.word = nStr{data.nStrInds(data.curNStr)};
    data.wordType = 2;   
end

%% Update file of words that have been used already
%save(ssFile, '-struct', 'data', 'wStrInds', 'nStrInds', 'curWStr' ,'curNStr');

%% Create scrambled word from current word (data.word)
% scramble level is used if it is the lexical decision task (always) or if
% it is a word (not noise) in the detection task
if stimParams.wordType =='W'
    scrWordImg = scrambleWord(data.word,1-stimParams.scrambleLevel);  %we use 1-scramble level for Weibull
elseif stimParams.wordType =='N'  % for nonwords, stimulus depends on task
    if strcmp(stimParams.exptType,'lexical')  % scramble nonword at appropriate level
        scrWordImg = scrambleWord(data.word,1-stimParams.scrambleLevel);   %we use 1-scramble level for Weibull
    elseif strcmp(stimParams.exptType,'detect')  % noise, so fully phase scramble and use a word stimulus
        %data.curWStr = data.curWStr+1;  % increase curWStr so that a new word is used (even for phase scramble)
        %data.word = wStr{data.wStrInds(data.curWStr)};  % overwrite data.word to be a word, not nonword
        scrWordImg = scrambleWord(data.word,1);  % 1 is fully phase scrambled
    end
end

% % try fitting to a certain specified size (if specified size is bigger)
% -- not currently functional
% newscrWordImg = zeros(stimParams.stimSizePix, 'uint8')*128;
% sz = size(scrWordImg);
% % rect is [left,top,right,bottom]. Matlab array is usually y,x
% r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
% newscrWordImg(r(1):r(3),r(2):r(4)) = uint8(scrWordImg);
% scrWordImg = newscrWordImg;
            
            
blankImg = ones(size(scrWordImg))*128;  % gray (blank) image

%% Create stim struct

duration.stimframe  = stimParams.duration;
sequence            = [1];
timing              = [duration.stimframe];
cmap                = display.gammaTable;
fixSeq              = ones(size(sequence));

stim        = createStimulusStruct(scrWordImg,cmap,sequence,[],timing,fixSeq);
stim        = createTextures(display, stim);
blankstim        = createStimulusStruct(blankImg,cmap,sequence,[],0.05,fixSeq);
blankstim        = createTextures(display, blankstim);

trial = addTrialEvent(display,[],'stimulusEvent', 'stimulus', stim);
trial = addTrialEvent(display,trial,'ISIEvent', 'stimulus', blankstim, 'duration', stimParams.ISI);

return