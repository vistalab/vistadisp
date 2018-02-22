function runme_MEG_PRF_Retinotopy_MEG_06_04_2017(run)


% startup_vs
% tbUse('psychtoolbox-3');
% addpath(genpath('~/matlab/git/vistadisp'));


PTBInitStimTracker;
global PTBTriggerLength
PTBTriggerLength = 0.001;

tr = 1.3;
stimfile = sprintf('MEG_retinotopy_stimulus_run_%d.mat',run);

cal = 'meg_lcd';
d   = loadDisplayParams(cal);

% Hacked these lines from Eline's runme_MEG_OnOffLeftRight_ET_M2008

params = retCreateDefaultGUIParams;         % Some default parameters
% Check what these lines below do to the code...
params.modality         = 'meg';
params.prescanDuration  = 0;
params.interleaves      = NaN;
params.tr               = tr;
params.calibration      = cal;
params.framePeriod      = tr;
params.startScan        = 0;
params.motionSteps      = 2;
params.tempFreq         = 6/tr;
params.repetitions      = 1;
params.experiment       = 'Experiment From File';
params.period           = 12*params.tr;
params.numCycles        = 6;
params.skipSyncTests    = 1;
params.triggerKey       = '`';
params.fixation         = 'dot with grid';

params.loadMatrix = stimfile;
ret(params)

f = dir('~/Desktop/2017*.mat');
load(fullfile('~', 'Desktop', f(end).name));

% desired inter-stimulus duration
desired_timing = stimulus.seqtiming';
true_timing = response.flip - response.flip(1);
lag = true_timing - desired_timing;

figure;
plot(desired_timing,'b');
hold on;
plot(true_timing,'r');
legend('Desired timing','True timing');
ylabel('Seconds')
xlabel('Frame')

figure;
plot(lag)
ylabel('Seconds')
xlabel('Frame')
title('Lag (true timing - desiredtiming)');

figure;
plot(diff([0 lag]))
title('Lag increments (diff([0 lag]))')
ylabel('Seconds')
xlabel('Frame')

figure(101); clf

% desired inter-stimulus duration
plot(diff(stimulus.seqtiming));

% measured inter-stimulus duration
hold on; plot(diff(response.flip), 'r-');

ylim(median(diff(response.flip)) + [-.001 .001])
% frames between stimuli
frames = round(diff(response.flip) / (1/60));

% how many interstimulus frames differed from the median?
disp(sum(frames ~= median(frames)))



end





















