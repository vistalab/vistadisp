function stim = cmlGenerateAudStim(display,stimParams)

%% Set default params
Freq = stimParams.audFreq;                          % Frequency of the sine wave (Hertz)
Fs = 48000;                                         % Sample rate of the playback (windows audio standard)
Dur = stimParams.audDur*display.flipInterval;       % Length of the playback (seconds)
Amp = stimParams.audAmp;                            % Height of the sine wave (scaled 0 to 1)

% %% Wave generation (don't mess with these)
% step = 2*pi*Freq/Fs;
% xmax = 2*pi*Dur*Freq;
% x = 0:step:xmax;
% y = Amp*sin(x)';
% 
% stim = y';

dt = 1/Fs;

t = 0:dt:Dur;

stim = sin(2*pi*Freq*t)*Amp;