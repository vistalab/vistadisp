function [imgs faceFiles ids] = loadFaces(ori, gender, sz);
%
% [imgs faceFiles ids] = loadFaces(ori, gender, sz);
%
% Load a set of face images from the new face data base, and return a cell
% array of 2-D images.
%
% INPUTS:
% ori: orientation of face with respect to the viewer. Should be a multiple 
% of 15. 0 = frontal view, 180 = faceing away from viewer, positive values
% are facing right, and negative values are facing left. If a vector of
% values is provided, will load one image for each element, at the given 
% orientation.
%
% gender: one of 'm' (male), 'f' (female), 'or 'b' (both). [Default is
% both: faces are drawn from both genders]  If 'f', only female faces are
% loaded, and if 'm', only male faces are loaded.
%
% sz: Size of the image. If empty, returns each image at its native
% resolution, but only a 2D image (the images are saved as grayscale true
% color images, so they have 3 image planes (R, G, and B), but they're all
% equal).
%
% OUTPUTS:
% imgs: cell array of face images.
%
% facesList: cell array of paths to the image files for each face.
%
% ids: vector of numeric IDs corresponding to each face.
%
%
%
% ras, 01/2008.
if notDefined('gender'),	gender = 'b';		end
if notDefined('sz'),		sz = [];		end

if length(sz)==1, sz = [sz sz]; end

%% params
cropSize = 1300;
halfCrop = round(cropSize/2); 

%% get list of face folders (in facesList)
% get path to face data base; check that the expected subdirs are present
facesList = faceDBFolders(gender);

% randomly select N faces (where N is the requested #)
N = length(ori);
facesList = Shuffle(facesList);
while length(facesList) < N % repeat as needed
	facesList = [facesList shuffle(facesList)];
end
facesList = facesList(1:N);

%% load the face images, rescale if requested
for n = 1:length(ori)
	% check that the specified orientation is allowable
	if mod(ori(n), 15) ~= 0
		error('Orientation values must be multiples of 15.')
	end
	
	% get the filename for this face
	if ori(n) > 0	% we'll need a + symbol for the filename
		symb = '+';
	else 
		symb = '';
	end
	[p f] = fileparts(facesList{n});
	fname = sprintf('%s_%s%03.0f.jpg', f, symb, ori(n));
	
	% load the file
	faceFiles{n} = fullfile( facesList{n}, fname );
	imgs{n} = imread(faceFiles{n}, 'jpg');
	imgs{n} = uint8(imgs{n});  % save memory, use integer data type
	
	% crop tightly, and take only 1  Z-plane (grayscale)
% 	imgs{n} = imgs{n}(161:1560,451:1850,1);
	
	rows = round(size(imgs{n}, 1) / 2) + [-halfCrop:halfCrop];
	cols = round(size(imgs{n}, 2) / 2) + [-halfCrop:halfCrop];	
	imgs{n} = imgs{n}(rows,cols,1);
	
	% resize if needed
	if ~isempty(sz)
		imgs{n} = imresize(imgs{n}, sz);
	end		
	
	% collect subject ID if requested
	if nargout > 1
        underscore = find(f=='_');
		ids(n) = str2num(f(1:underscore(1)-1));
	end
end


return
