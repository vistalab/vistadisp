function params = locAssignImages(params)
% Assign the name (path and file name) of each image to be shown in each
% block of fMRI localizer scan
%
% params = locAssignImages(params)


% blockInfo is a cell array. the length of the array is the number of
% conditions. for each condition, we store the condition number, condition
% name, and stimulus list (including full path to each image).
blockInfo = cell(1, length(params.stim.blockOrder));

% for each condition, image files are assumed to reside in subdirectories
% named setN where N is an integer. This enables us to ensure that each
% block gets a different set of images. We randomize which setnumber is
% assigned to which block.
numConditions = numel(params.stim.blockDirs);
setnum = zeros(1, length(params.stim.blockOrder));
for ii = 1:numConditions
    % how many block for this conidtion?
    blocks = params.stim.blockOrder == ii;
    
    % randomize the order in which setnums are assigned to blocks
    setnum(blocks) = Shuffle(1:sum(blocks));
end


for blockIndex = 1:length(params.stim.blockOrder)  % for each block
    % get the condition type ]
    cond = params.stim.blockOrder(blockIndex);
    blockInfo{blockIndex}.condition = cond;
    blockInfo{blockIndex}.conditionName = params.stim.condNames(cond);
    
    setnum(cond) = checkSets(params, cond, setnum(blockIndex));
    thisdir = fullfile(params.stim.baseDir, params.stim.blockDirs{cond},...
        ['set' num2str(setnum(cond))]);
    
    blockInfo{blockIndex}.stimulusList = ...
        randomizeStims2Block(thisdir,params.stim.stimsPerBlock);
end

params.blockInfo = blockInfo;

return


function blocknum = checkSets(params, cond,  blocknum)
    pth = fullfile(params.stim.baseDir, params.stim.blockDirs{cond});
    n  = numel(dir(fullfile(pth, 'set*')));
    blocknum = mod(blocknum, n);
    if blocknum == 0, blocknum = n; end
return

