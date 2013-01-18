function images = loadCategoryImages(num,varargin);
% images = loadCategoryImages(numImages,categories);
%
% load, from the imageDB, a specified # of images from the selected
% categories.
% 
% The categories can be any category specified in categoryDirs.m.
%
% The code will load a total of num files, broken down evenly
% among the selected categories.
%
% ras, 10/04
images = {};

if nargin < 2
    help loadCategoryImages;
    return
end

% will want to add code here to parse
% flags, like 'shuffle' to shuffle images

categories = varargin;
nCats = length(categories);
imgsPerCat = ceil(num/nCats);

for c = 1:nCats
    % get the list of image names for this category
    imlist = categoryImages(categories{c},'fullpath');

    imlist = Shuffle(imlist);

    % load the images
    for ii = 1:imgsPerCat
        images = [images {imread(imlist{ii},'jpg')}];
    end
end

% cut any extra, roundoff-error images
images = images(1:num);

return      

