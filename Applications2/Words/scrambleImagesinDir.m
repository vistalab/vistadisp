function scrambleImagesinDir(imageDir,scrambleLevel,forceOverwrite,cropsize)
%
%   scrambleImagesinDir(imageDir,[scrambleLevel=1],[forceOverwrite=0])
%
% Function to scramble all images in a particular directory at the level
% set by scrambleLevel.  If forceOverwrite == 1, the new scrambled images
% will overwrite the existing images.  If cropsize is defined and not
% empty, then all the images will be resized and cropped to the desired
% size.  (Note, there is not guarantee some of the picture won't be cut
% off.)
%

if notDefined('imageDir')
   imageDir = uigetdir(pwd,'Choose directory with image files');
end
if notDefined('scrambleLevel'), scrambleLevel = 1; end
if notDefined('forceOverwrite'), forceOverwrite = 0; end
if notDefined('cropsize'), cropsize = []; end

stimFileNames = dir(fullfile(imageDir,'*.bmp'));  % get any bmp files
stimFileNames = [stimFileNames dir(fullfile(imageDir,'*.jpg'))];  % add any jpg files

for curStim = 1:length(stimFileNames)
   imgPath = fullfile(imageDir,stimFileNames(curStim).name);
   curImg = imread(imgPath);
   
   % Resize/crop image to desired cropsize
   if ~isempty(cropsize)  % resize picture to desired size
       
       % One way of resizing is to resize along one dimension and crop along the other
       resizedImg = imresize(curImg,[NaN (cropsize(2))]);  % resize with same aspect ratio
       cropImg = imcrop(resizedImg,[0 (size(curImg,2)/3) cropsize(2) cropsize(1)]);
       curImg = cropImg;
       % Another way is just to resize without keeping aspect ratio (distorts image)
       %scrImg = imresize(curImg,cropsize);  % resize with same aspect ratio
   end
%   figure; imagesc(curImg); colormap gray; truesize
   
   scrImg = scrambleImage(curImg,scrambleLevel);

   if forceOverwrite
       imwrite(scrImg,imgPath)
   else
       imgPath = fullfile(fileparts(imgPath),[stimFileNames(curStim).name(1:end-4) '_scr' scrambleLevel '.bmp']);
       imwrite(scrImg,imgPath)
   end
end


return