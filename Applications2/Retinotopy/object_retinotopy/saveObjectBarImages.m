% function pths = saveFaceBarImages;
%
% pths = saveFaceBarImages;
%
% Generate and save a set of images of face bars for use with the face bar
% retinotopy.
%
% Pre-saving these images substantially reduces both the storage and CPU
% footprint of the face bar retinotopy code: the whole face database (many
% GB in size) doesn't need to be copied to each stimulus computer or
% uploaded to the CVS repository; and the bars can be quickly loaded
% instead of slowly generated at run time.
%
% There are no input arguments; the parameters determining how many images
% to generate, and how to generate them, are provided at the top of this
% m-file. Returns a list of the saved file paths.
%
% ras, 07/10/2008.

%% params
category = 'house';   % object category
nImageSets = 10;  % # of times to generate independent image sets
directions = 0:45:315; % set of bar directions to generate (° CW from vertical)
nImagesPerDirection = 12; % # image positions per bar direction
faceType = 'b';  % 'm', 'f', or 'b': face gender
screenRes = [600 600];  % size of images to generate ([X Y])
format = '.png';   % file format for images

%% get path of directory in which to save images
catName = lower(category);
catName(1) = upper(catName(1));
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'ObjectBarImages', catName);
ensureDirExists(imageDir);

%%%%% main loop 
for n = 1:nImageSets
	% generate a directory for this set of images, based on how many
	% are already saved in the image directory
	w = dir( fullfile(imageDir, 'Set*') );
	saveDir = fullfile(imageDir, sprintf('Set%i', length(w)+1));
	ensureDirExists(saveDir);

	for d = directions
		%% generate images
		bar = objectBar(category, d, nImagesPerDirection, ...
						'screenRes', screenRes);
		
		%% save images
		for ii = 1:size(bar, 3)
			fileName = sprintf('%03.0fdeg-%03.0f', d, ii);
			savePath = fullfile(saveDir, [fileName format]);
			
			imwrite(bar(:,:,ii), savePath);
			fprintf('Saved %s.\n', savePath);
		end
	end
end

fprintf('Done!\n\n');

return
