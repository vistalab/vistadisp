function verbGeneration
%
% This function runs a verb generation paradigm, which is intended to
% activate as much of the language network as possible.  
% 
% This paradigm is a block design very similar to doWordLocalizer, which is
% intended to localize pOTS (the "Visual Word Form Area").  Generally, the
% present paradigm will have a longer ISI (or longer stim length)
% to allow the subject to generate verbs between stimuli.
%
% The subject should be instructed to covertly say verbs that match the
% nouns which are presented.  ("Word that describe what the object does or what you can do with the object")
% In the control condition, scrambled words can
% be presented, to which the subject should be instructed to always
% covertly say "yes".
%
%       verbGeneration
%
% written: amr 2008-11-01
%
% Typically, this script will run 162 seconds (6+24*6+12) per run, with the
% current parameters (May 17, 2010)
%

%% PARAMETERS

ScanName = 'VerbGeneration';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/AndreasWordsMatlab/' ScanName]; % directory that contains stim folder with stimuli
        % Note that the stim folder must have folder names within it
        % corresponding to the condition names. These should contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
        
% Block Parameters (in seconds)
params.blockLength = 12;                           % usually 12
params.fixLength = 12;  % between stimulus blocks  % usually 12
params.stimLength = 3.5;
params.ISItime = 0.5;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.initFix = 6;

% Set the condition names here
conds.A = 'Nouns';
conds.B = 'ScrambledNouns'; 

stimChooseAlgorithm = 'list';  % will read from a text file in main stim directory, called 'stimOrder.txt'

%% BLOCK ORDERING

autoChooseBlocks = 1;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here
 
blockOrder = 'ABABAB';   %run1
%blockOrder = 'BABABA';   %run2

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
dummyBlockType = 'Fix'; %'B';  % A,B,C, 'Fix', or []  ([] if you don't want dummy block, 'Fix' if you just want a fixation)


%% RUN SCAN
runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm);

return