function rotateStimsinDir(stimDir, deg, outDir)
%
%      rotateStimsinDir(stimDir, deg, outDir)
%
% Rotate all images (stimuli) in stimDir (directory) by a specified amount (deg).  
% Uses imrotate to rotate the images.  Saves in outDir.
%
% amr 10/19/08
%

% Get the inputs
if notDefined('stimDir')
singleStim = mrvSelectFile('r',[],'Please point to a single Stim file in your directory of choice',pwd);
    if isempty(singleStim)
        return
    else
        stimDir = fileparts(singleStim);
    end
end
cd(stimDir)

if notDefined('deg')
    deg = input('How many degrees to rotate?  ');
end

if notDefined('outDir') || isempty(outDir)
    outDir = stimDir;
end

% Get the information about the files in the directory
dirInfo = dir(stimDir);
numFilesinDir = numel(dirInfo);

% Rotate and save each image
for imageNum = 1:numFilesinDir  % for all the images in the directory
    try
        inFname = dirInfo(imageNum).name;
        outFname = ['rot' num2str(deg) '_' inFname];  % the new file name
        outPath = fullfile(outDir, outFname);  % the full path
        curImage = imread(inFname);  % read in the image
        curImage = imrotate(curImage, deg);  % rotate the image by deg degrees (pos is counter-clockwise, neg is clockwise)
        imwrite(curImage, outPath, 'BMP');  % write out the new image
    catch
        fprintf('%s%s\n','Skipping file ',dirInfo(imageNum).name);
    end
end