function [images cmapRGB cmapLMS scaleFactor] = colorContrastImages(contrastType, display, varargin);
%
% [images RGB LMS scaleFactor] = colorContrastImages(contrastType, [display=load], [options]);
%
% Create a series of truecolor images representing a contrast-reversing
% sinusoidal grating which stimulates the specified LMS cone contrast.
%
%
% INPUTS:
%   contrastType: specify the LMS contrast type. This can be one of the
%   following (can be either an [L M S] vector or a non-case-sensitive character):
%
%       'S', [0 0 1]: S-cone isolating contrast. Default contrast level is
%       10 ^ (-0.3).
%
%       'L-M', [1 -1 0]: L-M cone contrast. Default contrast level is
%       10^(-1.05).
%
%       'L+M', [1 1 0]: L+M luminance contrast. Default contrast level is
%       10^(-1.2).
%
%       'L+M+S', [1 1 1]: L+M+S luminance contrast. Default contrast level
%       is 10^(-1.05).
%
%       'blank', [0 0 0]: produce a blank image. This is a dummy value,
%       used for other display code which may call this function.
%
%   To manually specify a contrast level other than the defaults given
%   above, you can add ..., 'contrast', [value], ... to the list of
%   optional arguments.
%
%   display: display parameters structure for the calibrated display. See
%   loadDisplayParams. An accurate calibration is necessary for a correct
%   color-calibrated display.
%
%   This code will find the best R/G/B gun values to produce this contrast, 
%   given the calibration provided in the display structure. 
%
%
% OUTPUTS:
%	images: {1 x nImages} cell array of true color images (each truecolor
%	image is a [sz(1) by sz(2) by 3] image of [R G B] color planes.
%
%	scaleFactor: see notes on the 'lms' argument above; returns the factor
%	by which the requested lms contrast had to be scaled back to be
%	achievable using the RGB guns in the display. If the requested contrast
%	was within the dynamic range, scaleFactor is 1.
%
%	RGB: [nCmap x 3] list of points in RGB space corresponding to the
%	contrast reversals. Each row represents the RGB gun values used to get
%	a corresponding point in LMS space.
%
%   LMS: [nCmap x 3] list of points in LMS points correspdonding to the RGB
%   points. The points are evenly spaced along the LMS input vector, and -1
%   times the LMS vector.
%
% OPTIONS:
%   Options can be specified as 'Parameter', [value] pairs after the first
%   3 arguments. The options [default values] are:
%		
%		'fixationPos', [0]: flag indicating where the grating should be
%		centered (and where the fixation point would go). The default
%		value, 0, indicates the grating will be centered in the center of
%		the image. Values of 1-4 indicate that the grating will be centered
%		in one of the four corners of the image: 1=upper left hand corner,
%		2=upper right hand corner, 3=lower left hand corner, 4=lower right
%		hand corner. If fixationPos > 0, the grating will not be masked out
%		to form a circle, but will fill the size of the image (except for a
%		small region around the fixation, determined by 'fixationRad').
%
%       'fixationRad', [10]: pixel radius from the image center to leave
%       empty for the fixation point.
%
%       'phi_0', [0]: phase offset of the spatial grating.
%
%       'sz', [480 480]: [2 x 1] vector indicating the rows and columns,
%       respectively, in the output images.
%
%       'nImages', [24]: number of images to create for the block.
%
%       'nCycles', [5]: number of spatial cycles in the grating.
%
%       'truecolor', [0]: flag to return the set of images as a 4D matrix
%       of true color images. If 1, will return a 4D (sz(1) x sz(2) x 3 x
%       nImages) array suitable for use with the MPLAY utitlity in
%       VISTASOFT. Otherwise, returns a 3D (sz(1) x sz(2) x nImages) matrix
%       of images, in which the values of each image indexes into the RGB
%       color map.
%
% This is an attempt to re-implement the contrast stimuli originally
% written by Junjie Liu for his thesis. I am using True Color images to
% take advantage of the improved display capabilities of modern computers /
% OSes / PsychToolobx tools, and to make the resulting code more modular
% and easier to understand.
%
% ras, 07/02/2008.
% ras, 08/13/2008: added 'fixationPos' option, specifying where the grating
% should be centered.
scaleFactor = 1;
images = {};

if notDefined('display')
    % get the display
    display = loadDisplayParams('screenNumber', 0);
end

if notDefined('contrastType'),
    error('Need to specify the LMS contrast.');
end

%% parse the contrast type, set the default contrast level
if ischar(contrastType)
    switch lower(contrastType)
        case 's', contrast = 10^(-0.3);         vec = [0 0 1];
        case 'l+m', contrast = 10^(-1.2);       vec = [1 1 0];
        case 'l-m', contrast = 10^(-1.05);      vec = [1 -1 0];
        case 'l+m+s', contrast = 10^(-1.05);    vec = [1 1 1];
        case 'blank', contrast = 0;             vec = [0 0 0];
        otherwise, error('invalid contrast type.');
    end
else
    switch contrastType
        case [0 0 1], contrast = 10^(-0.3);
        case [1 1 0], contrast = 10^(-1.2);
        case [1 -1 0], contrast = 10^(-1.05);
        case [1 1 1], contrast = 10^(-1.05);
        case [0 0 0], contrast = 0;
        otherwise, error('invalid contrast type.');
    end
    
    vec = contrastType;

end


%% default params
fixationPos = 0; % flag indicating fixation position, grating center
fixationRad = 10; % radius of empty space for fixation point
sz = [480 480]; % image size
nImages = 24;   % # of images
nCycles = 5;    % # of spatial frequency cycles
phi_0 = 0;		% spatial phase offset of sinewave
truecolor = 0;  % flag for returning a 4D array of true color images
nCmap = 63;     % number of colors in the color map


%% parse any optional parameters
for ii = 1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
			case {'fixpos' 'fixationpos'}, fixationPos = varargin{ii+1};
            case {'fixationrad' 'fixationradius'}, fixationRad = varargin{ii+1};
            case {'imagesize' 'sz'}, sz = varargin{ii+1};
            case {'nimages' 'numimages'}, nImages = varargin{ii+1};
            case {'ncycles' 'numcycles'}, nCycles = varargin{ii+1};
            case {'phaseoffset' 'phi_0'}, phi_0 = varargin{ii+1};
            case {'contrast'}, contrast = varargin{ii+1};
            case {'truecolor'}, truecolor = varargin{ii+1};
            case {'ncmap' 'ncolors' 'nlevels'}, nCmap = varargin{ii+1};
        end
    end
end



%% create an image of the sinewave amplitude at each pixel (AMP)
% first, create a radial matrix R
% (we force an odd image size here, by having X and Y go from -sz/2 to +sz/2)
xsize = floor(sz(2) / 2);   % columns = X dimension
ysize = floor(sz(1) / 2);   % rows = Y dimension
switch fixationPos
	case 0,  % center
		xRng = [1:sz(2)] - xsize;
		yRng = [1:sz(1)] - ysize;
	case 1,  % upper left-hand corner
		xRng = 1:sz(2);
		yRng = 1:sz(1);
		nCycles = nCycles / 2;  % the full grating will be twice the image size
	case 2,  % upper right-hand corner
		xRng = -sz(2):-1;
		yRng = 1:sz(1);		
		nCycles = nCycles / 2;  % the full grating will be twice the image size
	case 3,  % lower left-hand corner
		xRng = 1:sz(2);
		yRng = -sz(1):-1;		
		nCycles = nCycles / 2;  % the full grating will be twice the image size
	case 4,  % lower right-hand corner
		xRng = -sz(2):-1;
		yRng = -sz(1):-1;		
		nCycles = nCycles / 2;  % the full grating will be twice the image size
	otherwise,
		error('Invalid fixationPos flag.')
end
		
[X Y] = meshgrid(xRng, yRng);
R = single( sqrt( X .^ 2 + Y .^ 2 ) );

% update the size: this will force evenly-speficied sizes to be odd
% (sorry about that, but this makes the stimulus center properly)
sz = size(R);

% compute the phase of each pixel
period = min(sz) / (2 * nCycles);
PHI = period - abs( mod(R, period) - period/2 );

PHI = normalize(PHI, -pi, pi);

% the amplitude is a sine of this phase
AMP = sin((PHI - phi_0) / (2*pi));

% mask out the max radius and min radius
if fixationPos==0
	AMP( R < fixationRad | R > min(sz)/2 ) = NaN;
else
	AMP( R < fixationRad ) = NaN;	
end

%% expand the amplitude image into a series of images 
% each image reflects the relative position along a line in the color space
% determined by the LMS vector. The actual conversion of each 2D image
% created here into a 3D truecolor image will happen after this step.
images = AMP(:) * sin( linspace(0, 2*pi, nImages) );
images = reshape(images, [sz(1) sz(2) nImages]);

% normalize Z to match the number of colors in the color map
images = rescale2(images, [], [1, nCmap]);

%% mask out regions outside the annulus (if needed)
if fixationPos==0
	% make a 3-D mask for gray background regions
	bgMask = repmat( (R < fixationRad | R > min(sz)/2), [1 1 nImages] );

	% make the mask gray
	images(bgMask) = ceil(nCmap/2);
end

%% get a color map from amplitudes (in Z) to RGB color space, via LMS
% create a set of points along the line specified by lms
lms = contrast * vec;   % LMS vector
cmapLMS = [linspace(-1, 1, nCmap)]' * lms;

% add a gray entry at the end of both cmaps: this is for the masked region
cmapLMS(end+1,:) = [.5 .5 .5];

% convert lms points into RGB space
[cmapRGB scaleFactor] = Cmap_cone2RGB(display, cmapLMS);


%% convert images to true color format if specified
if truecolor==1
    % re-initialize images as a 4-D matrix; store the 3-D matrix in tmp
    tmp = images;
    images = repmat(.5, [sz(1) sz(2) 3 nImages]);
    
    for n = 1:nImages
        images(:,:,:,n) = ind2rgb(tmp(:,:,n), cmapRGB);
    end
end


return
