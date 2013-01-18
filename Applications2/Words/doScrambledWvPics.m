function doScrambledWvPics
%
% This function runs a block design aimed at showing activations
% corresponding to phase-scrambled words and phase-scrambled objects (faces
% or houses) in a particular ROI, such as VWFA.  We actually want to make
% sure that VWFA doesn't respond more to the power spectrum of words than
% the power spectrum of other things, because we want to know what our
% "baseline" is for a noise condition.
%
%       doScrambledWvPics
%
% written: amr March 8, 2010
%
% Number of seconds to delete is 18 (9 frames at TR=2).  This is 12 seconds
% of dummy stimulus and 6 seconds of initFix.
%

%% PARAMETERS

ScanName = 'ScrambledWvPics';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/ScanData/' ScanName]; % directory that contains stim folder with stimuli
        % Note that the stim folder must have folder names within it
        % corresponding to the condition names. These should contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
        
% Block Parameters (in seconds)
params.blockLength = 12;                           % usually 12
params.fixLength = 12;  % between stimulus blocks  % usually 12
params.stimLength = 0.4;
params.ISItime = 0.1;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.initFix = 6;

% Set the condition names here
conds.A = 'Words';
conds.B = 'ScrambledWords';
conds.C = 'ScrambledFaces';
conds.D = 'ScrambledHouses';

stimChooseAlgorithm = 'random';  % will read from a text file in main stim directory, called 'stimOrder.txt'

%% BLOCK ORDERING

autoChooseBlocks = 0;  % flag to choose block order based on session number (that user enters)

% If you don't have autoChooseBlocks on, then you can set your block order here
 
%blockOrder = 'ABCDABCD';   % run1
%blockOrder = 'BDCABDCA';     % run2
%blockOrder = 'CADBBDAC';        % run 3
blockOrder = 'DBACBDCA';   % run 4
%blockOrder = 'CBA';            % testing

% Dummy block is an additional block BEFORE the beginning of your normal blocks.
dummyBlockType = 'A'; %'B';  % A,B,C, 'Fix', or []  ([] if you don't want dummy block, 'Fix' if you just want a fixation)


%% RUN SCAN
runFuncBlockScan(ScanName,params,conds,blockOrder,dummyBlockType,baseDir,autoChooseBlocks,stimChooseAlgorithm);

return