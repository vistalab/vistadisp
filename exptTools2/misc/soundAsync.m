function soundAsync(y,fs,bits)
% soundAsync Play vector as sound, asynchronously.
%   soundAsync(Y,FS) sends the signal in vector Y (with sample frequency
%   FS) out to the speaker on platforms that support sound. Values in
%   Y are assumed to be in the range -1.0 <= y <= 1.0. Values outside
%   that range are clipped.  Stereo sounds are played, on platforms
%   that support it, when Y is an N-by-2 matrix.
%
%   soundAsync(Y) plays the sound at the default sample rate of 8192 Hz.
%
%   soundAsync(Y,FS,BITS) plays the sound using BITS bits/sample if
%   possible.  Most platforms support BITS=8 or 16.
%
%   Example:
%     load handel
%     soundAsync(y,Fs)
%   You should hear a snippet of Handel's Hallelujah Chorus.
%
%   See also SOUND, SOUNDSC, WAVPLAY.
%
% NOTE: this is a replacement for Matlab's sound.m. It uses the Java
% audioplayer rather than the playsnd function. This works much better 
% on linux and some varieties of OS-X. Note that this replacement plays
% asynchronously.

if nargin<1, error('Not enough input arguments.'); end
if nargin<2, fs = 8192; end
if nargin<3, bits = 16; end
if nargin<4, async = 0; end

% Make sure y is in the range +/- 1
y = max(-1,min(y,1));

% Make sure that there's one column
% per channel.
if ndims(y)>2, error('Requires 2-D values only.'); end
if size(y,1)==1, y = y.'; end

% Verify data is real and double.
if ~isreal(y) || issparse(y) || ~strcmp(class(y), 'double')
    error('MATLAB:playsnd:invalidDataType', 'Audio data must be real and double-precision.');
end

player=audioplayer(y,fs,bits); 
play(player);
% if(~async)
%     % Wait for the sound to finish
%     while(strcmp(get(player,'Running'),'on'))
%         pause(0.02);
%     end
% end
return;
