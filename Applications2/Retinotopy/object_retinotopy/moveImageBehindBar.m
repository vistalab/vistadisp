function images = moveImageBehindBar(img, directions, N, width, pos);
% Create a set of images showing an image sliding behind a static aperture.
%
%  images = moveImageBehindBar(img, [directions], [N=12], [width=1/11 image size], [pos]);
%
% This is similar to barApertureMask, except for the relative motion of the
% bar aperture and the underlying image. In barApertureMask, the underlying
% image remains static, and the bar moves across the screen. In this code,
% the bar remains static (centered in the middle of the screen), while the
% image appears to slide across the aperture.
%
% INPUTS:
%  img: 2-D image which will be placed behind the aperture.
%
%  directions: vector with directions for each image sweep. The directions
%  refer to the angle (° clockwise from 12-o-clock) from which the images are
%  moving. For example:
%	0°: the image slides down from the top of the screen, while the aperture 
%		is a horizontal bar in the middle of the screen.
%	90°: the image moves horizontally from the left to the right, while the
%		aperture is a vertical bar in the screen center.
%	180° the image slides up from the bottom of the screen, while the aperture 
%		is a horizontal bar in the middle of the screen.
%	270°: the image moves horizontally from the right to the left, while the
%		aperture is a vertical bar in the screen center.
%
% The "directions" argument can have a series of bar directions to 
% specify several sweeps. The default is the order of bar sweeps used in 
% the retinotopy 8-bar experiments:
%	directions = [270 135 0 225 90 315 180 45];
% 
%  N: number of frames per sweep. [default 12]
%
%  width: bar aperture width in pixels. [default: chosen based on N]
%
%  pos: vector of shift positions in pixels. [default: +258:-258, linearly space in 
%       N steps.] Note that the default value goes backward: for apparent
%       motion along the direction, the values in pos should be decreasing
%       (and pos=0 means the face is centered on the bar). 
%
%
% OUTPUTS:
%	images: 3-D matrix of images with each slice being one frame of the bar
%	sweeps.
%
%
% SEE ALSO: barApertureMask.
%
% ras, 10/2009.
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
	images = [];
	for d = directions
		images = cat(3, images, moveImageBehindBar(img, d, N));
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
	
%% create a sampling matrix for bar positions (rotatedY)
% first, we get an X, Y grid of the screen space
[X Y] = meshgrid([1:nX] - cenX, [1:nY] - cenY);
Y = flipud(Y);  % +Y should go up, not down

% now, we rotate this grid the appropriate amount
rotPts = rot * [X(:) Y(:)]';

% the sampling matrix will be the rotated Y matrix. As the bar moves across
% the screen, it will occupy a different subset of this sampling matrix.
% * an important correction: to get this to work, we actually want rotatedY to
% represent a rotation in the opposite direction to the rot matrix (this is
% because the pos vector, defined below, has slightly different
% interpretations for masking the bar and positioning faces --
% unfortunately, it's pretty complicated)
rotatedY =  reshape(rotPts(2,:), [nY nX]);

% we also compute a sampling matrix of radius from the screen center --
% this will be used to mask each image in a circle, to constrain to a
% particular eccentricity
R = sqrt(X.^2 + Y.^2);

%% compute set of image positions for each frame
% these positions will be used to shift the bar up/down for each frame
% (we start and finish one half bar's width outside the screen window)
cenMin = min(cenX, cenY);  
if notDefined('width')
	width = min(nX, nY) / 6;  % width of bar in pixels
end

if notDefined('pos')
    pos = linspace(cenMin - width/2 - 1, -(cenMin - width/2) + 1, N);
end
pos = round(pos);

%% find indices for a bar aperture in the middle of the screen
barIndices = find( rotatedY >= -width/2 & rotatedY <= width/2  );
[barRows barCols] = ind2sub([nY nX], barIndices);

%% CREATE THE APERTURES
% loop across frames within each direction
for n = 1:N
	% find the indices for the part of the face images to show underneath
	% the bar (this shift is what effectively moves the face);
%     try
        shiftedCols = mod( barCols + pos(n) - 1, nX ) + 1;
     	faceIndices = sub2ind([nY nX], barRows, shiftedCols);	
%     catch
%         keyboard
%         % the pos shift may shift the face out of the field of view of the
%         % bar. If so, we'll just return blank images for this frame.
%         for z = 1:nZ
%             images(:,:,(n-1)*nZ+z) = uint8( repmat(bgVal, [nY nX]) );
%         end
%         continue
%     end
	
	% for positions where we're showing the edge of the face, I may point
	% to pixels not present in the input image. So, we sub-select indices
	% which are okay in both the bar indices, and the faceIndices:
	[rows cols] = ind2sub([nY nX], faceIndices);
	ok = find( rows >= 1 & rows <= nY & cols >= 1 & cols <= nX );
	
	% loop across input images
	for z = 1:nZ
		% initialize empty image for this frame
		% (use the corner of the image as a background color
		imgFrame = repmat(bgVal, [nY nX]);

		% copy over the part of the image which will lie behind the bar
		% mask
		subImg = img(:,:,z);
		imgFrame(barIndices(ok)) = subImg(faceIndices(ok));

		% add a circular mask if requested
		if circleMask==1
			imgFrame( R > min(cenX, cenY) ) = bgVal;
		end

		% append to the list of bar images
		images(:,:,(n-1)*nZ+z) = uint8(imgFrame);
	end
end

return
