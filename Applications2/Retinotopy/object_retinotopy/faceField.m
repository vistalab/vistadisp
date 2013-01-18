function [img ids] = faceField(scaleFactor, nZ, varargin);
% [img ids] = faceField([scaleFactor=2], [numFrames=1], [options]);
%
% Create a field of faces, scaled with eccentricity. This will be
% used for some test stimuli for retinotopic mapping of face regions.
% In the current implementation, there is no single face presented at the
% fovea, but instead a series of iso-eccentricity bands of faces, each with
% a constant number of faces.
%
% INPUTS:
%	scaleFactor: the relative size of successively more eccentric faces.
%
%	N: number of frames. The faces at each iso-eccentricity band will
%	precess (rotate) across frames.
%
%	screenRes [nX nY] size of screen.
%
% OUTPUTS:
%	img: screenRes(2) x screenRes(1) x N matrix of images.
%
% ras, 01/2008.
if notDefined('scaleFactor'),	scaleFactor = 1.5;			end
if notDefined('nZ'),				nZ = 5;					end

%% params
screenRes = [600 600];
facesPerBand = 7;	% # faces per iso-eccentricity band
baseSize = 35;		% size (radius) of most-foveal face
bgVal = 165;		% mean gray intensity of background
gender = 'b';       % gender of faces to use: 'm', 'f', or 'b' (both)
verbose = prefsVerboseCheck;   % flag for verbose feedback

%% read in optional input arguments
for ii = 2:2:length(varargin)
    param = varargin{ii-1};
    val = varargin{ii};
    
    if ischar(val)
        eval( sprintf('%s = ''%s''', param, val) );
    elseif isnumeric(val)
        eval( sprintf('%s = %s', param, num2str(val)) );
    else
        error('Unreocognized param/value pair: %s/%s.', param, val);
    end
end

%% derived params
% determine maximum # of iso-eccentricity bands based on the scale factor
% and base size:
nEccBands = 1;
stimExtent = baseSize; % extent (radius) of face images for this many bands

while stimExtent <= min(screenRes) / 2
	nEccBands = nEccBands + 1;
	stimExtent = stimExtent + scaleFactor ^ (nEccBands-1) * baseSize;
end

% how many faces do we need?
nFaces = nEccBands * facesPerBand;

% variables related to screen size, for easy access
nX = screenRes(2); % x = columns
nY = screenRes(1); % y = rows
cenX = round(nX / 2);  % X coordinate of screen center
cenY = round(nY / 2);  % Y coordinate of scre en center

%% determine eccentricities / radii for images in each band
ecc(1) = 0;  % foveal presentation
rad(1) = baseSize;

for n = 2:nEccBands
	rad(n) = scaleFactor^(n-1) * baseSize;

	% the center eccentricity for this band is the center eccentricity for
	% the previous band, plus the radius of one of the last tier images,
	% plus the radius of one of the current-tier images:
	ecc(n) = ecc(n-1) + rad(n-1) + rad(n);
end

%% create a sampling grid for polar angle (Theta) and eccentricity (R)
[X Y] = meshgrid([1:nX] - cenX, [1:nY] - cenY);
Y = flipud(Y);  % +Y should go up, not down

[Theta R] = cart2pol(X, Y);

%% initialize output image
% img = [];
img = repmat(bgVal, [nY nX nZ]);

%%%%% loop across iso-eccentricity bands
if verbose, 
	fprintf('[%s]: Creating face fields...\n', mfilename); 
end

for z = 1:nZ
	if verbose, fprintf('Image %i/%i .', z, nZ); end
	
	%% intitialize empty image
	currImg = repmat( single(bgVal), [nY nX] );
	
	for n = 1:nEccBands
		if n==1
			% single foveal face
			nFaces = 1;
		else
			% band of faces: we take the circumference of 
			% the band center divided by the diameter of each face, plus a
			% small spacing factor:
			nFaces = ceil( 2*pi*ecc(n) / (2*rad(n)) );
		end

		%% load faces
		[faces ids] = loadFaces( zeros(1, nFaces), gender );
		for j = 1:length(faces)
			% the resize diameter should be 2*rad, but I leave a little
			% space (10%) to prevent crowding:
			faces{j} = imresize(faces{j}, 1.8 .* [rad(n) rad(n)]);
		end

		%% determine (x, y) center of each face
		faceR = repmat(ecc(n), [1 nFaces]);

		% (for the face theta, we add a slight phase precession based on
		% which image this is, as well as alternating phase shifts between
		% bands)
		zPrecess = z/nZ * 2*pi/nFaces;
		nPrecess = (i ^ (2*n)) * 0.5 * pi / nFaces;
		faceTh = linspace(0, 2*pi, nFaces) + nPrecess + zPrecess;
		faceTh = mod(faceTh, 2*pi);

		% convert from polar to cartesian
		[faceX faceY] = pol2cart(faceTh, faceR);
		facePts = [faceX + cenX; faceY + cenY];

		%% place faces
		currImg = placeFaces(currImg, faces, facePts);
		
		if verbose, fprintf( repmat('.', [1 n]) ); end
	end

	%% store this face image in the set of face images
	img(:,:,z) = currImg;
	
	if verbose, fprintf('done.\n'); end
end

if verbose,
	fprintf('...all done!\n');
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

for j = 1:length(faces)
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

