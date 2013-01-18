function bars = barApertureMask(img, directions, N);
% Mask an image behind a moving bar aperture.
%
%  bars = barApertureMask(img, [directions], [N=12]);
%
% INPUTS:
%  img: 2-D image which will be placed behind the aperture.
%
%  directions: vector with directions for each bar sweep. The directions
%  refer to the angle (° clockwise from 12-o-clock) from which the bars are
%  moving. For example:
%	0°  is a horizontal bar moving down from the top of the screen, 
%	90° is a vertical bar coming from the right, 
%	180° is a horizontal bar coming from below,
%	270° is a vertical bar coming from the left.
%
% directions can have a series of bar directions to specify several sweeps.
% The default is the order of bar sweeps used in the retinotopy 8-bar
% experiments:
%	directions = [270 135 0 225 90 315 180 45];
% 
%  N: number of frames per sweep. [default 12]
%
% OUTPUTS:
%	bars: 3-D matrix of images with each slice being one frame of the bar
%	sweeps.
%
%
% ras, 01/2009.
if notDefined('img'),	img = zeros(300, 300);		end
if notDefined('directions'),
	directions = [270 135 0 225 90 315 180 45]; 
end
if notDefined('N'),		N = 12;						end

%% other params
circleMask = 1;  % mask each frame in a circle
addBlanks = 0;   % add blank periods every other cycle
bgVal = 165;	 % background grayscale value

%% recursion: 
% if more than one direction specified, recursively call this function for
% each direction. This simplifies the code below, a little bit:
if length(directions) > 1
	bars = [];
	for d = directions
		bars = cat(3, bars, barApertureMask(img, d, N));
	end
	return
end

%% create the screen and bar mask
% initialize black screen for each position
[nY nX nZ] = size(img);
cenX = round(nX / 2);   % X coordinate of image center
cenY = round(nY / 2);   % Y coordinate of image center

%% create a rotation matrix to rotate points the appropriate angle
% Note that the orientation of the bar is 90° from the direction of motion
ori = directions + 90;  % bar orientation
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
width = min(nX, nY) / (N/2);  % width of bar in pixels
pos = round( linspace(cenMin - width/2, -(cenMin - width/2), N) );


%% CREATE THE APERTURES
% loop across frames within each direction
for n = 1:N
	% loop across input images
	for z = 1:nZ
		% initialize empty image for this frame
		% (use the corner of the image as a background color
		imgFrame = repmat(bgVal, [nY nX]);

		% copy over the part of the image which will lie behind the bar mask
		I = find( TH >= pos(n) - width/2 & TH <= pos(n) + width/2 );
		subImg = img(:,:,z);
		imgFrame(I) = subImg(I);

		% add a circular mask if requested
		if circleMask==1
			imgFrame( R > min(cenX, cenY) ) = bgVal;
		end

		% append to the list of bar images
		bars(:,:,(n-1)*nZ+z) = uint8(imgFrame);
	end
end

return
