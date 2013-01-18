function wordEccentricityScan
%
% This function runs a block-design scan using words at different eccentricities.
%
% These stimuli may reveal a map within the ventral temporal lobe (OTS).
%
% For now, we'll just have a fixation task.
%
%       wordEccentricityScan
%
% written: rfb % amr 2009-09-01
%
% nframes typically would be 153 frames (306 seconds)

%% PARAMETERS

ScanName = 'wordEccentricity';  % Enter the name of your functional block scan here (used in saving data)

baseDir = ['/Users/Shared/ScanData/' ScanName]; % directory that contains stim folder with stimuli
% Shared/ScanData/' ScanName
        % Note that the stim folder must have folder names within it
        % corresponding to the condition names. These should contain the stimulus pictures.
        % Checkerboard stimulus is in the stim directory also.
        
% Block Parameters (in seconds)
params.blockLength = 12;                           % usually 12
params.fixLength = 12;  % between stimulus blocks  % usually 12
params.stimLength = 0.300;
params.ISItime = 0.200;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.initFix = 6;
params.fixLoc   = [ .5 .5 .5 .5 .5 .5; ...
                    .5 .5 .5 .5 .5 .5];
params.distance = [ 1 1 3 3 6 6];

params.displayName = '3T2_projector_2010_09_01';

% For doing left-right scans
params.angle    = [0 180 0 180 0 180 ];
params.conds = {    '1degRight';
                    '1degLeft';
                    '3degRight';
                    '3degLeft';
                    '6degRight';
                    '6degLeft'};


% % For doing up-down scans
% params.angle    = [ 90 270 90 270 90 270];
% params.conds = {    '1degUp';
%     '1degDown';
%     '3degUp';
%     '3degDown';
%     '6degUp';
%     '6degDown'};

%% RUN SCAN
runFuncBlockScan2(params,'ScanName',ScanName,'dummyBlockType','Fix','baseDir',baseDir,'autoChooseBlocks',1,'stimChooseAlgorithm','list');

return