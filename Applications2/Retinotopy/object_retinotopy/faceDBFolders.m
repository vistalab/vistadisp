function [facesList ids faceDB] = faceDBFolders(gender);
% Find folders in the face database for faces of the specified gender.
%
%   [facesList ids faceDB] = faceDBFolders([gender='b']);
%
% INPUTS:
%
% gender should be a string; only the first character matters. This
% character can be either 'b' for both gender, 'm' for male, or 'f' for
% female. The code is case-insensitive.
%
% OUTPUTS:
%   
% faceList: a cell array of paths to each face folder. Each of these
% folders will contain multiple JPEG images with the naming convention
% [#]_[gender]_[ori].jpg, where the # is the face ID, 
%
% ids: array of ID #s for each of the faces
%
% faceDB: the path to the local copy of the face database. (This is 
% relative to the location of the image database, specified by the 
% function imageDB).
%
% ras, 07/2009.
faceDB = fullfile( fileparts(fileparts(locImageDB)), 'FaceDataBase' );

% Folders with complete image sets are marked "DONE"
doneFolders = dir( fullfile(faceDB, '*DONE') );
% doneFolders = dir( fullfile(faceDB, 'ORIGINAL COLOR*') );

if isempty(doneFolders)
	fprintf('Face Database path = %s.\n', faceDB);
	error('Could not find any face folders!')
end

% search each folder marked DONE for individual face folders
facesList = {};
for i = 1:length(doneFolders)
	subFolder = fullfile(faceDB, doneFolders(i).name);

	% a face directory will have an underscore, e.g '93_f':
	males = dir( fullfile(subFolder, '*_m*') );
	females = dir( fullfile(subFolder, '*_f*') );
    
	% select folders only of the appropriate gender
	switch lower(gender(1))
		case 'm', w = males;
		case 'f', w = females;
		case 'b', w = [males; females];
        otherwise, error('Invalid gender flag.')
    end
    
	for j = 1:length(w)
		facesList = [facesList {fullfile(subFolder, w(j).name)}];
    end
end

% remove directories that start with '.'
ok = logical( ones(size(facesList)) );
for j = 1:length(facesList)
    [p f ext] = fileparts(facesList{j});
    if isempty(f) | f(1)=='.'
        ok(j) = false;
    end
end
facesList = facesList(ok);


% get face IDs if requested
if nargout > 1
    for i = 1:length(facesList)
        [p f ext] = fileparts(facesList{i});
        underscore = find(f=='_');
        ids(i) = str2num( f(1:underscore(1)-1) );
    end
end

return