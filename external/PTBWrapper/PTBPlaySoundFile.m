%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBPlaySoundFile.m
%
% Plays a given .wav file
%
% Args:
%	- soundfile: The file to play
%       - E.g. 'Test.wav'
%       - NOTE: Only .wav files are playable so far
%	- duration: How long to show the the text. This should also be in a
%           cell, and can be any one or a mixture of a couple of options:
%       - 'end': This will play the sound file until it's over.
%       - Relative time (e.g. {.5}) will display for that amount of seconds
%       - Absolute time (e.g. {3.6517e+005}) will display until that system
%           time is reached. This number can come from either GetSecs or
%           PTBLastKeyPRessTime. Be warned, if you try to use this and the
%           calculation is not correct, your program will just hang.
%               NOTE: Any time greater than 1000 is assumed to be an
%               absolute time.
%       - Key press: (e.g. {'a'}) will wait until that key is pressed.
%           - Can also use {'any'} for any key.
%       - Sound trigger: {'sound'} will wait for a sound. The volume is
%           controlled by PTBSetSoundKeyLevel.
%       * NOTE: If you combine these, the display will wait until the first
%       is reach. So, {'any',2} will wait 2 seconds for any key to be
%       pressed.
%
% NOTE: For now, calling this on its own will not clear the previous
%   screen. To have a new screen shown at the same time, set this duration
%   to -1 and put the screen call with the duration afterwards.
%   * If you do the same with another file, it will play both at once.
%       - E.g. a chord out of single notes.
%
% Usage: PTBPlaySoundFile('soundfile.wav',{.3})
%
% Author: Doug Bemis
% Date: 1/21/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Take variable args and parse.
% TODO: Error checking.
function PTBPlaySoundFile(soundfile, duration, varargin)

% Buffers and ports to fill
global PTBNextSoundPort;

% NOTE: These are for chords...
global currWaveData;
global currNrchannels;
global currFreq;

% Parse any optional arguments and get the correct window
[trigger  trigger_delay key_condition] = PTBParseDisplayArguments(duration, varargin);

% Perform basic initialization of the sound driver, to be sure
PTBInitSound(1);

% Get the data
[y, freq] = wavread(soundfile);
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

% Open the default audio device [], with default mode [] (==Only playback),
% and a required latencyclass of zero 0 == no low-latency mode, as well as
% a frequency of freq and nrchannels sound channels.
% This returns a handle to the audio device:
if PTBNextSoundPort < 0
    PTBNextSoundPort = PTBOpenSoundPort(freq, nrchannels);
    
% Otherwise, add, chord-like
else

    % Make sure things match
    if freq ~= currFreq
        error('Different frequencies in sound files. Exiting...');
    end
    if size(y,2) ~= currNrchannels
        error('Different number of frequencies in sound files. Exiting...');
    end
    
    % And add...
    wavedata = currWaveData+y';
end

% Hold for chords...
currWaveData = wavedata;
currNrchannels = nrchannels;
currFreq = freq;

% See if we've got an 'end' duration
for d = 1:length(duration)
    if strcmp(duration{d},'end')
        
        % TODO: Allow absolute time
        duration{d} = size(wavedata,2) / freq;
    end
end


% Fill the audio playback buffer with the audio data 'wavedata':
PsychPortAudio('FillBuffer', PTBNextSoundPort, wavedata);

% Set the type...
global PTBAudioStimulus;
PTBAudioStimulus = 1;

% And go...
PTBPresentStimulus(duration, 'Soundfile', soundfile, trigger,  trigger_delay, key_condition);

