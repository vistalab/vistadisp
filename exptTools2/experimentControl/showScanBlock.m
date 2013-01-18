function [quitProg,ssResponses,ssRTs] = showScanBlock(display, blockInfo, quitProgKey, t0)
% [quitProg,ssResponses,ssRTs] = showScanBlock(display, blockInfo, quitProgKey, t0)
%
% Shows all the frames and collects responses within a single scan block.
% quitProg is 1 if experimenter presses 'q' during block, which ends the
% block.  ssResponses and ssRTs are cell arrays that contain the subject
% responses (and reaction times, respectively) for each trial.
%
% t0 is the time the scan started and the stimulus timing should be
% relative to t0. If t0 does not exist it is created at the start of
% this program.
%
% HISTORY:
% 2008.09.17 AMR: ported from showScanStimulus, and adapted for showing a
% single block
% 2008.09.17 RFD: we now immediately show the first frame before waiting.
% Before this change, seqtiming specified the start time of the
% corresponding frame, Now, it specifies the END time of the corresponding
% frame.
% 2008.09.25 AMR: added functionality for trials within blocks to aid key
% responses and other items associated with trials

%% Input checks

% some variables
nFrames = length(blockInfo(1).seq);
HideCursor;
%nImages = length(blockInfo(1).textures);
response.keyCode = zeros(length(blockInfo(1).seq),1);      % get 1 button max
response.secs = zeros(size(blockInfo(1).seq));             % timing
quitProg = 0;
whenToFlipOn = zeros(1,nFrames);

% % debugging
VBLstamps = zeros(1,nFrames);
allWaitTimes = zeros(1,nFrames);
% keyloopcounter = zeros(1,nFrames);
% VBLtimingstart = zeros(1,nFrames);
% VBLtimingend = zeros(1,nFrames);

%% Show trials
numTrials = length(blockInfo);
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
blockStartTime = GetSecs;
for trialNum = 1:numTrials
    
    %% Start collecting key presses
    keylist = ones(1,256);  %keys to record
    keylist(KbName('/')) = 0;  % ignore backslashes sent by Lucas 3T#2
    keylist(KbName('/?')) = 0;
    %keylist(KbName('\|')) = 0;
    KbQueueCreate(display.devices.keyInputExternal,keylist);
    KbQueueStart();
    
    %% Show the trial
    %tic
    [quitProg,timeStartTrial] = showScanTrial(blockInfo(trialNum),display,quitProgKey);
    %toc
    if quitProg, break, end
    
    %% Get key presses and RTs -- note that these are unused right now-- should probably be sent back as output of showScanBlock
    KbQueueStop();  % stops collection of responses but can still check with KbQueueCheck
    [k.pressed, k.firstPress, k.firstRelease, k.lastPress, k.lastRelease]=...
        KbQueueCheck();
    ssResponses{trialNum} = KbName(k.firstPress);  % [] if no response
    f = find(k.firstPress);
    if k.pressed
        ssRTs{trialNum} = k.firstPress(f)-timeStartTrial;   % ssRT = k.firstPress(f{frame})-VBLstamps(1);
    else ssRTs{trialNum} = 0; end
end

%% that's it for this block
timing = GetSecs-blockStartTime;
expectBlockLength = length(blockInfo) * max(blockInfo(1).seqtiming);
nLongFrames = sum(diff(VBLstamps)>diff(blockInfo(1).seqtiming)+.001);
disp(sprintf('[%s]:Block run time: %f seconds [should be: %f]. %d (of %d) frames ran long.',mfilename,timing,expectBlockLength,nLongFrames,nFrames-1));


return;