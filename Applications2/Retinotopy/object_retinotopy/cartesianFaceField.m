function [img ids] = cartesianFaceField(nZ, sz, spacing, gender, varargin);
% [img ids] = cartesianFaceField( [numFrames=1], [size=120], [spacing=60], [gender='b'], [options]);
%
% Create a field of faces centered along a Cartesian grid. This will be
% used for some test stimuli for retinotopic mapping of face regions.
%
% INPUTS:
%	numFrames: number of frames. The faces at each iso-eccentricity band will
%	precess (rotate) across frames.
%
%	sz: size (diameter) of face images in the field, in pixels. [default
%	120]
%	
%	spacing: spacing between faces, in units of pixels. This is in addition
%	to the spacing imposed by the size. So if size = 120 and spacing = 0,
%	the center of adjacent faces will be 120 pixels apart, while if spacing
%	= 100, they will be 220 pixels apart. [default 60]
%
%	gender: of 'm' (or 'male'), 'f' (or 'female'), or 'b' (or 'both'), 
%	gender of faces to show. [default: 'b']
%
% OPTIONS: 
%	xoffset	  offset (in pixels) along the x axis for the first face image.
%			  the first image will have a face centered at (y=0,
%			  x=xoffset). Later images may precess the images, but this
%			  guarantees that when you create multiple images with
%			  different face sizes, there are faces centered in the same
%			  place. [x=-85, equal to about 4deg to the left of the fovea
%			  in the Lucas Center 3T#1's projector display.]
%	nPrecessCycles  # of cycles to precess the faces, when making multiple
%			images. (Each precessing involves one face drifting to a
%			different point on the initial grid of face centers.
%	screenRes [nX nY] size of screen.
%	bgVal    value [from 0-255] of grayscale background 
%	verbose   flag for verbose feedback
%
% OUTPUTS:
%	img: screenRes(2) x screenRes(1) x N matrix of images.
%	ids:  ID #s of the faces usd, returned from loadFaces.
%
% ras, 04/2009.
if notDefined('nZ'),				nZ = 5;					end
if notDefined('sz'),				sz = 120;				end
if notDefined('spacing'),			spacing = 60;			end
if notDefined('gender'),			gender = 'b';			end

%% params
screenRes = [600 600];
bgVal = 165;		% mean gray intensity of background
verbose = prefsVerboseCheck;   % flag for verbose feedback
xoffset = -114; % x-axis offset of face image: ~4 deg at Lucas 3T#1
nPrecessCycles = 1; % # of cycles to precess the faces, for multiple images
jitter = [0 0];   % position jitter for faces in the [x y] directions

%% read in optional input arguments
for ii = 1:2:length(varargin)
	eval( sprintf('%s = [%s];', varargin{ii}, num2str(varargin{ii+1})) );
end

%% derived params
% variables related to screen size, for easy access
nX = screenRes(2); % x = columns
nY = screenRes(1); % y = rows
cenX = round(nX / 2);  % X coordinate of screen center
cenY = round(nY / 2);  % Y coordinate of scre en center

%% determine # of face centers, and spacing, for each image
delta = sz + spacing;  % distance between face centers
nFacesX = ceil(nX / delta);
nFacesY = ceil(nY / delta);
nFaces = nFacesX * nFacesY + (nPrecessCycles-1);


%% compute initial face centers
% this is going to be a little tricky below: because we can show parts of
% faces within the screen, it's possible for a face center to be outside
% the screen range (which runs from 1:nX, 1:nY). How far should it go
% before we wrap the face around again? This will be kept in the variables
% modX and modY. We compute the (x, y) centers modulo these values.
modX = nFacesX * delta;
modY = nFacesY * delta;

% create a [2 x nFaces] matrix indicating the initial [x; y] center of each
% face in the grid. For images after the first one, these centers will
% precess a bit, but we want the first to tile the screen out from the
% location (x=cenX+xoffset, y=cenY). Or, in centered coordinates, 
% [xoffset 0].
xrng = mod(xoffset + cenX, modX); % mod([0:delta:nX] + xoffset + cenX, modX);
yrng = mod([0:delta:nY] + cenY, modY);
[faceX faceY] = meshgrid(sort(xrng), yrng);
faceX = faceX(:)';
faceY = faceY(:)';

%% create a sampling grid for X, Y directions
[X Y] = meshgrid(1:nX, 1:nY);
Y = flipud(Y);  % +Y should go up, not down

%% initialize output image
img = repmat(bgVal, [nY nX nZ]);

if verbose, 
	fprintf('[%s]: Creating Cartesian face fields...', mfilename); 
end

%% load faces
[faces ids] = loadFaces( zeros(1, nFaces), gender );
for j = 1:length(faces)
	faces{j} = imresize(faces{j}, [sz sz]);
end


%% loop across frames
for z = 1:nZ
	%% intitialize empty image
	currImg = repmat( single(bgVal), [nY nX] );
	
	%% determine (x, y) center of each face
	% precess by a phase distance (only in Y direction)
	phi = nPrecessCycles * delta * (z-1) / nZ;
	facePts = [mod(faceX, modX); ...
			   mod(faceY+phi, modY)];
	
	% add jitter to face centers
	if jitter(1) > 0
		frameJitter = jitter(1) * rand(1, size(facePts, 2));
		frameJitter = round( frameJitter - jitter(1) / 2 );
		facePts(1,:) = mod(facePts(1,:) + frameJitter, modX);
	end
	if jitter(2) > 0
		frameJitter = jitter(2) * rand(1, size(facePts, 2));
		frameJitter = round( frameJitter - jitter(2) / 2 );
		facePts(2,:) = mod(facePts(2,:) + frameJitter, modY);
	end
	
		   
	%% place faces
	currImg = placeFaces(currImg, faces, facePts);

	%% store this face image in the set of face images
	img(:,:,z) = currImg;
	
	if verbose, fprintf('.'); end
end

if verbose,
	fprintf('...done.\n');
end

%% enforce uint8 data type for images
if isa(img, 'double') | isa(img, 'single')
	img = uint8( round(img) );
end

return
% /------------------------------------------------------------/ %




% /------------------------------------------------------------/ %
function img = placeFaces(img, faces, facePts);
%% place face images within an existing image, at the center points
%% provided by facePts (first row, x centers, 2nd row, y centers), and with
%% the diameter provided by faceSz.
%% this newer method places only the content of a circle inscribed within
%% the box of each face image, rather than the full rectangle. This avoids
%% issues with empty corners from different face images lying on top of one
%% another.
nX = size(img, 2);
nY = size(img, 1);

%% create a sampling grid for the face images
fszX = size(faces{1}, 2);
fszY = size(faces{1}, 1);
[X Y] = meshgrid( [1:fszX] - fszX/2, [1:fszY] - fszY/2 );
R = sqrt( X .^ 2 + Y .^ 2 );

% find rows, cols of points to keep within each face
radius = min( [fszX fszY] ) / 2;
[srcRows srcCols] = find(R <= radius);

for j = 1:min(length(faces), size(facePts, 2))
	% find the corresponding rows, cols for this face in the target image
	x0 = round( facePts(1,j) );
	y0 = round( facePts(2,j) );

	% (the extra fsz/2 factor is needed to center the face at (x0, y0))
	tgtRows = round(srcRows + y0 - fszY / 2);
	tgtCols = round(srcCols + x0 - fszX / 2);

	% sub-select points lying within the image
	ok = find( tgtRows >= 1 & tgtRows <= nY & ...
		tgtCols >= 1 & tgtCols <= nX );

	if isempty(ok)
		continue; % face lies entirely off screen
	end

	% convert into indices
	Isrc = sub2ind( [fszY fszX], srcRows(ok), srcCols(ok) );
	Itgt = sub2ind( [nY nX], tgtRows(ok), tgtCols(ok) );

	% place face
	img(Itgt) = faces{j}(Isrc);
end

return



%  % Old method: places face as a rectangle
% 	% intended x/y range subtended by whole face
% 	faceCenter = round(facePts(:,j));
% 	xrng = round([1:faceSz] - faceSz/2 + faceCenter(1));
% 	yrng = round([1:faceSz] - faceSz/2 + faceCenter(2));
%
% 	% allow for the face to extend past the screen:
% 	% find only those 'ok' x/y pts within the screen bounds
% 	xok = find(xrng >= 1 & xrng <= nX);
% 	yok = find(yrng >= 1 & yrng <= nY);
%
% 	if isempty(yok) | isempty(xok)
% 		continue;  % face entirely off screen
% 	end
% 	% place the face
% 	img(yrng(yok),xrng(xok)) = faces{j}(yok,xok);

