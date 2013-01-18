function [bar ids] = faceBar(direction, N, screenRes, varargin);
%
%  [bar ids] = faceBar([direction=0], [numPositions=12], [screenRes = [640 480]], [options]);
%
% Create a bar or set of bars containing faces.
%
% INPUTS:
%	direction: direction of bar motion, in degrees CW from 12-o-clock. 
%	For example:
%	0°  [the default] is a horizontal bar moving down from the top of the screen, 
%	90° is a vertical bar coming from the right, 
%	180° is a horizontal bar coming from below,
%	270° is a vertical bar coming from the left.
%
%	numPositions: number of unique positions for the bar. [default 12]
%		the total number of images in the bar will be this number
%		multiplied by the number of frames per position. By default,
%		framesPerPosition is 6, but this can be changed as an optional
%		parameter.
%
%	options: modify parameters from their default values by setting in
%	pairs: ..., 'parameter', [value], ... 
%	Parameters include:
%		'width', [100]					bar width in pixels
%		'bgval', [110]					background gray intensity
%		'fgval', [146]					foreground gray intensity
%		'framesperposition', [6]		# frames / bar position
%		'framespercycle' [6]			period of the face
%										phase-precession. That is, every
%										framesPerCycle frames, a face will
%										shift along the bar one inter-face
%										distance.
%		'facesperbar', [8]				# faces on the bar at once
%
% OUTPUTS:
%	bar: cell array of images of a whole screen.
%
%
% For this function, the screen resolution, width and number of faces 
% of each bar is constant to keep things simple.
% For multiple bars, the code will consistently use faces, and alter their
% relative phase such that the faces appear to be sliding along the bar.
% (I'm guessing this will be tricky to implement. :)
% 
%
% ras, 01/2008.
if notDefined('screenRes'),		screenRes = [600 600];		end
if notDefined('direction'),		direction = 0;				end
if notDefined('N'),				N = 12;						end

%% params
width = min(screenRes)/(N/2);  % width of bar in pixels
bgVal = 127;  % mean gray intensity of background
fgVal = 146; % 146;  % mean gray intensity of foreground (bar and faces)
framesPerPosition = 12;
framesPerCycle = 6;  % # of frames for faces to slide 1 inter-face distance
facesPerBar = 7;	% max # faces in a bar for one frame
texture = 'none';  % 'dots', 'checkerboard', or 'none'
circleMask = 0;		% flag to add a circular mask for the image

% we rescale each face to slightly less than the whole bar width:
% this prevents the face image corners from peeking past the bar
faceSz = .7 * width;

%% parse the optional input arguments
for ii = 1:2:length(varargin)
	switch lower(varargin{ii})
		case 'width',	width = varargin{ii+1};
		case 'bgval',	bgVal = varargin{ii+1};
		case 'fgval',	fgVal = varargin{ii+1};
		case 'framesperposition',	framesPerPosition = varargin{ii+1};
		case 'framespercycle',	framesPerCycle = varargin{ii+1};
		case 'facesperbar',	facesPerBar = varargin{ii+1};
		case 'texture',	texture = varargin{ii+1};
		case 'circlemask', circleMask = varargin{ii+1};			
	end
end

% figure out the total number of frames
nFrames = N * framesPerPosition;

%% create the screen and bar mask
% initialize black screen for each position
nX = screenRes(1); 
nY = screenRes(2);
cenX = round(nX / 2);   % X coordinate of screen center
cenY = round(nY / 2);   % Y coordinate of screen center

%% create a rotation matrix to rotate points the appropriate angle
% Note that the orientation of the bar is 90° from the direction of motion
ori = direction + 90;  % bar orientation
theta = deg2rad(90 - ori); % convert from °CW to radians CCW from +x axis
rot = [cos(-theta) -sin(-theta); sin(-theta) cos(-theta)];
	
%% create a sampling matrix for bar positions (TH)
% first, we get an X, Y grid of the screen space
[X Y] = meshgrid([1:nX] - cenX, [1:nY] - cenY);
Y = flipud(Y);  % +Y should go up, not down

% now, we rotate this grid the appropriate amount
rotPts = rot * [X(:) Y(:)]';

% the sampling matrix will be the rotated Y matrix. As the bar moves across
% the screen, it will occupy a different subset of this sampling matrix.
% * an important correction: to get this to work, we actually want TH to
% represent a rotation in the opposite direction to the rot matrix (this is
% because the pos vector, defined below, has slightly different
% interpretations for masking the bar and positioning faces --
% unfortunately, it's pretty complicated)
TH =  reshape(rotPts(2,:), [nY nX]);

% we also compute a sampling matrix of radius from the screen center --
% this will be used to mask each image in a circle, to constrain to a
% particular eccentricity
R = sqrt(X.^2 + Y.^2);

%% compute set of bar positions for each frame
% these positions will be used to shift the bar up/down for each frame
% (we start and finish one half bar's width outside the screen window)
cenMin = min(cenX, cenY);  
pos = round( linspace(cenMin - width/2, -(cenMin - width/2), N) );

%% load a set of faces for the bar
% how many faces are needed?
% Say I want 5 faces at each frame; the distance between the center of each
% face will be a "cycle". I'll precesss the faces along the bar at a rate
% of 4 frames / cycle. So, we'll need 5 faces to start, plus a new face
% every 4 frames. (also add 3 "buffer" faces)
nFaces = facesPerBar * ceil(1 + nFrames / framesPerCycle);

% load / rescale the faces
fprintf('Loading faces...')
[faces ids] = loadFaces(zeros(1, nFaces), 'b', [faceSz faceSz]);
fprintf('done.\n');

% % normalize each face to have a mean 
% faces = scaleContrast(faces, fgVal);
for n = 1:nFaces
	% each face is a circle circumscribed in a background gray;
	% so, we subtract an offset to make the corner value = the bar value
	offset = faces{n}(1,1) - fgVal; % use first corner pixel for offset
	faces{n} = faces{n} - offset;
end

% create a set of initial center positions for each face: we'll precess
% these, and rotate, in the main loop
cycleDist = ceil(min(nX, nY) ./ facesPerBar);
stepSize = cycleDist ./ framesPerCycle;  % size of each precession step
maxPoint = cycleDist * (nFaces-1); % initial position of last face
initPts = [ [0:cycleDist:maxPoint] - maxPoint/2; zeros(1, nFaces) ];

%% create a texture that will serve as the background for the bar
switch lower(texture)
	case 'dots'
		% add random dots to bar
		rand('state', sum(100*clock));
		texture = uint8(255 .* rand(nY, nX));
		
	case 'checkerboard'
		% Not Yet Implemented
	otherwise
		% plain foreground color
		texture = repmat(fgVal, [nY nX]);
end

%% main loop, across positions
for n = 1:N
	for f = 1:framesPerPosition
		% get index for this bar image
		ii = (n-1)*framesPerPosition + f;
		
		% create empty screen image
		% (slightly dimmer than gray -- the bar will be slightly brighter)
		bar{ii} = uint8( repmat(bgVal, [nY nX]) ); 

		%% create the bar background
		I = find( TH >= pos(n) - width/2 & TH <= pos(n) + width/2 );
		bar{ii}(I) = texture(I);

		%% place the faces
		% phase precess the initial face centers
		facePts = initPts;
		facePts(1,:) = facePts(1,:) + ii*stepSize;

		% translate the face to the appropriate bar position
		facePts(2,:) = facePts(2,:) - pos(n);

		% rotate the initial face centers about the screen center
		facePts = rot * facePts;

		% the rotation was about the screen center, so the points span
		% [-cenY, +cenY] and [-cenX, +cenX]; account for this shift:
		facePts = facePts + [repmat([cenX; cenY], [1 nFaces])];

		% place the faces
		for j = 1:nFaces
			% intended x/y range subtended by whole face
			faceCenter = round(facePts(:,j));
			xrng = round([1:faceSz] - faceSz/2 + faceCenter(1));
			yrng = round([1:faceSz] - faceSz/2 + faceCenter(2));

			% allow for the face to extend past the screen:
			% find only those 'ok' x/y pts within the screen bounds
			xok = find(xrng >= 1 & xrng <= nX);
			yok = find(yrng >= 1 & yrng <= nY);

			if isempty(yok) | isempty(xok)
				continue;  % face entirely off screen
			end

			% place the face
			bar{ii}(yrng(yok),xrng(xok)) = faces{j}(yok,xok);
		end

		%% mask the image in a circle inscribed in the screen
		if circleMask==1
			bar{ii}(R > min([cenX cenY])) = bgVal;
		end
	end
end

%% convert from cell to 3D matrix
tmp = bar;
bar = uint8([]);
for i = 1:length(tmp)
	bar(:,:,i) = uint8(tmp{i});
end


return
