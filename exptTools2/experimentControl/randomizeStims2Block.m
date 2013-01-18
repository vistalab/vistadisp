function stimulusNameList = randomizeStims2Block(stimsDir,numStimsPerBlock)
% This function assigns stimuli randomly to a block.  You must give it a
% directory that contains all your stimulus files (stimsDir), and you must tell 
% it how many stimuli you want in your block (numStimsPerBlock).
%
%   stimulusNameList = randomizeStims2Block(stimsDir,numStimsPerBlock)
%
% written by amr 2008-09-19
%
%   7/1/09:  modified so no repeats within a block by using Shuffle
%   7/19/11, JW: allow multiple images file formats, allow for possibilty
%               that number of images is less than number of images per
%               block by repeating if necesary
%

% First get all the stimuli in the directory
jpg = dir(fullfile(stimsDir, '*.jpg'));
png = dir(fullfile(stimsDir, '*.png'));
tif = dir(fullfile(stimsDir, '*.tif'));
bmp = dir(fullfile(stimsDir, '*.bmp'));


stimFileNames = [jpg; png; tif; bmp];

% Create index of files in random order
indexList = 1:numel(stimFileNames);
indexList = Shuffle(indexList);


% Now assign the names of the files in the new random order
% There's probably a way to do this without a for loop, but not sure how.
stimulusNameList = cell(1,numStimsPerBlock);
for s = 1:numStimsPerBlock
        index = mod(s, numel(stimFileNames));
        if index == 0, index = numel(stimFileNames); end
        index = indexList(index);
        stimulusNameList{s} = fullfile(stimsDir,stimFileNames(index).name);
end

return