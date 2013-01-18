function [imgs faceFiles gender] = loadFacesByID(id, ori, sz);
%
% [imgs faceFiles gender] = loadFacesByID(id, ori, sz);
%
% Load a set of face images, specified by face ID, from the new face data
% base.
%
% INPUTS:
%
% id: single value, or vector of values, specifying the id of the face to
% load. The current version of the database has ids from 1-99, although
% another 50 or so could be added to the database with the right level of
% help.
%
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
% imgs: {m x n} cell array of face images, where m is the number of faces
% specified in id, and n is the number of orientations specified in ori.
%
% faceFiles: cell array of paths to the image files for each face.
%
% gender: [1 x m] char vector indicating the gender of each face ID ('m' or
% 'f').
%
%
% ras, 01/2008.
if notDefined('gender'),	gender = 'b';		end
if notDefined('sz'),		sz = [];		end

if length(sz)==1, sz = [sz sz]; end

%% check that the specified orientations are allowable
if any( mod(ori, 15) ~= 0 )
    error('Orientation values must be multiples of 15.')
end

%% params
cropSize = 1300;
halfCrop = round(cropSize/2); 

%% get list of face folders (in facesList)
% first, get the folder paths and ID numbers of all avalable faces
[facesList allIDs] = faceDBFolders('b');

%% find the specified ids in the list of all IDs
if ~all( ismember(id, allIDs) );
    badIDs = setdiff(id, allIDs);
    error('Invalid face IDs specified: %s.', num2str(badIDs));
end

% subIndex will map from the requested IDs to the face folders list. 
for m = 1:length(id)
    subIndex(m) = find(allIDs==id(m));
end
facesList = facesList(subIndex);

%% load the face images, rescale if requested
for ii = 1:length(id)
    for jj = 1:length(ori)
        % get the filename for this face
        if ori(jj) > 0	% we'll need a + symbol for the filename
            symb = '+';
        elseif ori(jj) < 0
            symb = '-';
        else
            symb = '';
        end
        
        % infer the face gender from the folder name
        gender(ii) = facesList{ii}(end);
        
        fname = sprintf('%02.0f_%s_%s%03.0f.jpg', id(ii), gender(ii), symb, ...
                        abs(ori(jj)));
        faceFiles{ii,jj} = fullfile( facesList{ii}, fname );
        
        % load the file
        imgs{ii,jj} = imread(faceFiles{ii,jj}, 'jpg');
        imgs{ii,jj} = uint8(imgs{ii,jj});  % save memory, use integer data type

        rows = round(size(imgs{ii,jj}, 1) / 2) + [-halfCrop:halfCrop];
        cols = round(size(imgs{ii,jj}, 2) / 2) + [-halfCrop:halfCrop];
        imgs{ii,jj} = imgs{ii,jj}(rows,cols,1);
        
        % resize if needed
        if ~isempty(sz)
            imgs{ii,jj} = imresize(imgs{ii,jj}, sz);
        end
    end
end


return
