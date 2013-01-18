function runSyntheticText
%

%% PARAMETERS

ScanName = 'SyntheticText';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/Stimulus/' ScanName]; % directory that contains stim folder with stimuli
% Shared/ScanData/' ScanName
        % Note that the stim folder must have folder names within it
        % corresponding to the condition names. These should contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
        
% Block Parameters (in seconds)
params.blockLength = 12;                           % usually 12
params.fixLength = 12;  % between stimulus blocks  % usually 12
params.stimLength = 0.100;
params.ISItime = 0.100;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.initFix = 0;
params.fixationPixelSize = 5;
params.displayName = 'CNI_LCD_2011_03_13';

% For doing left-right scans
conds.A = 'Text';
conds.B = 'SyntheticText';
conds.C = 'Mix';
stimChooseAlgorithm = 'random';  % will read from a text file in main stim directory, called 'stimOrder.txt'

%% BLOCK ORDERING

autoChooseBlocks = 0;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here
 
blockOrder = 'ABCABCABC';   %run1
%blockOrder = 'BABABA';   %run2

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
dummyBlockType = 'C'; %'B';  % A,B,C, 'Fix', or []  ([] if you don't want dummy block, 'Fix' if you just want a fixation)


%% RUN SCAN
runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm);

return
