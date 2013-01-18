function doRotatingWordLoc(params,conds)
%
% This function will sweep out word-like stimuli along some parameter, such
% as wordiness as defined by letter frequency, bigram freq, trigram freq,
% quad freq, and real words (c.f. Vinckier et al 2008 Neuron).
%
% The idea is to have a continuous parameter which can be mapped onto
% anatomical space, just like phase or eccentricity is mapped onto visual
% cortex.  In the pRF model, sigma represents the width of the population
% receptive field.  We would like something analagous in the space of words
% that represents the specificity of the response within the space.
%
% First thing to do is to analyze it like an expanding ring experiment
% (where eccentricity maps onto wordiness).
%

%% PARAMETERS

ScanName = 'RotatingWordLocalizer';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
        % Note that the stim folder must have folder names within it
        % corresponding to the condition names. These should contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
        
% Block Parameters (in seconds)
if notDefined('params')
    params.blockLength = 6;                           % usually 12
    params.fixLength = 0;  % between stimulus blocks  % usually 12
    params.stimLength = 0.4;  % doesn't include ISItime
    params.ISItime = 0.1;
    params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
    params.nRepeats = 1;  % number of times to repeat sequence of blocks
    params.initFix = 6;  % first fixation length
    params.postFix = 0;
end


% Set the condition names here
if notDefined('conds')
    conds.A = '0';
    conds.B = '22';
    conds.C = '45';
    conds.D = '67';
    conds.E = '90';
end


%% BLOCK ORDERING

autoChooseBlocks = 0;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here
if isfield(params,'blockOrder')
    blockOrder = params.blockOrder;
else
    blockOrder = 'ABCDE';  % basic block order, will be repeated n times; predictable
    %blockOrder = 'AEDBCEDACB';  % unpredictable
        blockOrder = repmat(blockOrder,1,params.nRepeats);
end
numBlocks = length(blockOrder);

%scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix;

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
%dummyBlockType = params.dummyBlockType; %'A';  % A,B,C, or []  ([] if you don't want dummy block)
dummyBlockType = 'Fix';

stimChooseAlgorithm = 'random';  % if 'list', will read from a text file in main stim directory, called 'stimOrder.txt'
%stimChooseAlgorithm = params.stimChooseAlgorithm;

preloadBlockFlag = 1;  % makes sure to load in all the blocks beforehand, since there is no fixation

%% RUN SCAN
runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm,preloadBlockFlag);

return
