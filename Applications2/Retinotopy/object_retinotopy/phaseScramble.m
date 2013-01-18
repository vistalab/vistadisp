function scr = phaseScramble(img, w);
% Scramble the phase component of an image spectrum.
%
% scr = phaseScramble(img, [w=1]);
%
% INPUTS:
%   img: image matrix.
%
%   w: optional weight to the scrambling, if you want to do partial phase
%   scrambling. w ranges from 0 (no scrambling) to 1 (full scrambling).
%   [Default: 1, full scrambling.]
%
% OUTPUTS:
%   scr: phase-scrambled version of img.
%
% ras, 01/2009.
if nargin < 2  |  isempty(w)
    w = 1;
end

% allow a cell-array of images to be provided: if so, recursively scramble
% each one
if iscell(img)
	scr = cell(size(img));
	for ii = 1:numel(img)
		scr{ii} = phaseScramble(img{ii}, w);
	end
	return
end

% remember the image class: we'll restore this class at the end
imgClass = class(img);

% enforce double
img = double(img);

% subtract the mean
mu = mean(img(:));
img = img - mu;

% get spectrum
F = fftshift( fft2(img) );

% decompose into amplitude and phase
amp = abs(F);
ph  = angle(F);

% scramble the phase
if w==1
    ph = shuffle(ph);
else
    rand_phase = ( rand(size(ph)) - 0.5 ) * pi * 2;
    ph = w * rand_phase + (1-w) * ph; 
end

% recompose the scrambled image
scr = amp .* exp(i * ph);
scr = ifft2( ifftshift(scr) );
scr = real(scr + mu);

% restore the original image class
eval( sprintf('scr = %s(scr); ', imgClass) );

return
