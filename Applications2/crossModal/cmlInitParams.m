function stimParams = cmlInitParams
% flip interval 13.33 ms

% Stimulus Timing
stimParams.visDur = 1; % Duration of Visual Stimulus
stimParams.audDur = 1; % Duration of Auditory Stimulus
stimParams.visOnset = .5; % Onset visual
stimParams.audOnset = .5; % Onset auditory

% Audio Parameters
stimParams.audFreq = 1000;
stimParams.audAmp = .3;

% Visual Parameters
stimParams.width = 3; % Visual Angle Width
stimParams.color = [255 0 0]; % Color of Stim
stimParams.shape = 'circle'; % Type of Stimulus - Cell Array {'Triangle' 'Square' 'Circle' 'Line'};

stimParams.angle = 0; % angle around a circle centered on screen, 0 starts on right
stimParams.distance = 0; % radius of circle about which stimuli are being placed
stimParams.respKey = [KbName('1') KbName('3') KbName('7')]; % 1 = yes, 2 = no, 3 = quit
% Possible ramping of stimuli?
% Offsets?
% Feedback parameters?
% Placement (computePosition fxn) - distance and angle (0, 0 if centered)