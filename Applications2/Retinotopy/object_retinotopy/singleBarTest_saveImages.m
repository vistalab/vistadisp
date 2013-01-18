% script singleBarTest_saveImages:
%
% Saves face bar images for the single-bar-position test.
% 
% This experiment is designed to test predictions from our scaled-faces pRF
% mapping experiment. The objective is to place a single bar aperture at a
% fixed location of the visual field, and have different sizes of faces
% behind the aperture. If the pRF results hold, we would predict that
% larger face images will produce a wider spatial extent of responses in 
% ventral cortex, extending into regions (like the ipsilateral cortical 
% hemisphere) which under other conditions would not represent the retinal
% position of the bar aperture. For instance, if the single bar is
% distinctly in the left visual field, we would not expect strong responses
% in left ventral cortex, since the contralateral visual field is never
% stimulated. But if the pRFs in these regions reflect the perceived extent
% of the object, then we may see some response to large faces, which are
% perceived as behind an aperture, but extending into the right visual
% field.
%
%
% ras, 04/2009.

tic

%% image params
sizes = [150];  % sizes (diameter) of faces in each condition
ori = 270;			  % orientation of single bar (270=coming from left)
nSteps = 11;		  % # image positions per bar direction (we only use 1: pos)
pos = 6;			  % position of aperture (out of nSteps)
spacing = 20;		  % spacing between faces in a given image, in pixels
nImagesPerTrial = 9;   % # images for each position
scrambleImages = 0;	  % flag to phase-scramble images
screenRes = [600 600];  % size of images to generate ([X Y])
bgVal = 165;		  % image background color
saveName = 'foveal_bar_localizer';  % name of image set, script: should be descriptive
trialsPerBlock = 5;	  % # of face-bar trials per block
nBlocksPerCond = 6;   % for each size, how many blocks? 

% derived params
nConds = length(sizes);

%% get path of directory in which to save images
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'SingleBarImages');
ensureDirExists(imageDir);


%% make and save the images (intact images)
% ensure the directory exists for this set
% we choose a number for this set, based on the number of directories 
% that already exist with the same save prefix:
N = 1;
saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);
while exist(saveDir, 'dir')
	N = N + 1;
	saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);
end
mkdir(saveDir);

% make many images for each size and gender
% we make one image for each trial for both male and female faces. In the
% script-building part of the code, we flip a coin on each trial to
% determine whether to show the male or female faces for a given trial.
for n = [nConds:-1:1]     % size
	for gender = 'mf'
		for t = 1:trialsPerBlock*nBlocksPerCond
			for ii = 1:nImagesPerTrial
				% make the un-masked face field images
				if n==4
					% for the last 2 conditions (both large-size faces), we
					% do a different maniupation: we modify the X center of
					% the single face, so that the viewer either sees the
					% left half or right half of the face. In one case, the
					% perceived face behind the aperture extends into the
					% contralateral visual field, in the other it doesn't.
					xoffset = -228;
				elseif n==5
					xoffset = 0;
				else 
					xoffset = -114;
				end
					
				sz = sizes(n);
				imgs = cartesianFaceField(nImagesPerTrial, sz, spacing, ...
									     gender, 'xoffset', xoffset);

				% the different images will have the same set of faces sliding
				% up and down: we want each image to be a different set of
				% faces as well as a different position. So, take the ii-th
				% position, but only if the size is relatively small;
				% otherwise we take the 1st position:
				if n < 4
					imgs = imgs(:,:,ii);
				else
					imgs = imgs(:,:,1);
				end

				% if phase-scrambling, scramble the images before masking
				if scrambleImages==1
					imgs = phaseScramble(imgs);
				end

				% mask through bars
				bar = barApertureMask(imgs, ori, nSteps);

				% grab the one bar position we want to keep
				bar = bar(:,:,pos);

				% save the image
				sz = sizes(n);
				imgName = sprintf('%s%i-%i-%i.png', gender, n, t, ii);
				imgPath = fullfile(saveDir, imgName);
				imwrite(bar, imgPath);
				fprintf('Saved %s.\n', imgPath);
			end
		end
	end
end

% fprintf('[%s]: done. \t(%s)', mfilename, secs2text(toc));

return
