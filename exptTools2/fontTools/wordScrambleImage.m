function scrambledImage = wordScrambleImage(image, rows, columns)
% scrambledImage = wordScrambleImage(image, rows, columns)
% 
% Purpose
%   Given a particular image, break it up into a given amount of columns and
%   rows and scramble their order.
%
% Input
%   image - 2D matrix of numbers
%   rows - Number of rows you'd like it broken up into
%   columns - Number of columns you'd like it broken up into
%
% Output
%   scrambledImage = 2D matrix of numbers from earlier, scrambled.
%
% RFB 2009 [renobowen@gmail.com]

[height width] = size(image); % Height and width of original image
columnSize = ceil(width/columns); % Width (in pixels) of a given column
rowSize = ceil(height/rows); % Height (in pixels) of a given row

% Note: We round up these column and row sizes.  Thus, we'll chop the image
% into more/bigger blocks than possible.  To remedy this, we use CenterRect
% to center the original image inside of a box as big as is necessary to
% cut out this many boxes of this size.  We then shuffle them, and cut off
% the fat we originally created by centering it in another rect, such that
% our final image is of the original size.
    
columnEnds      = columnSize*repmat(1:columns,rows,1); % Pixel values for the end of each box along columns
columnStarts    = columnEnds - columnSize + 1; % Pixel values for the start of each box along columns
rowEnds         = rowSize*repmat((1:rows)',1,columns);% Pixel values for the end of each box along rows
rowStarts       = rowEnds - rowSize + 1; % Pixel values for the start of each box along rows
imageBlocks     = Shuffle(1:(rows*columns)); % Each box is represented by an index, all of which we will shuffle
scrambledImage  = zeros(rowEnds(end,end),columnEnds(end,end));

if size(scrambledImage,1)~=size(image,1) || size(scrambledImage,2)~=size(image,2)
    stretchedImage = imresize(image,'OutputSize',size(scrambledImage));
    %r = CenterRect([1 1 height width],[1 1 size(origImage)]); % Get pixel values necessary to center original image into the one of zeros
    %newImage(r(1):r(3),r(2):r(4)) = image; % Center it within the zeros (it is now the proper size, and we can begin shuffling it up)
else
    stretchedImage = image;
end

for i=1:length(imageBlocks) % For each block we've created
    ii = imageBlocks(i); % Figure out the shuffled index
    scrambledImage(rowStarts(i):rowEnds(i),columnStarts(i):columnEnds(i)) = ...
        stretchedImage(rowStarts(ii):rowEnds(ii),columnStarts(ii):columnEnds(ii)); % For each block 1:rxc, replace with shuffled index image
end

if size(scrambledImage)~=size(image)
    scrambledImage = imresize(scrambledImage,[height width]);
    %scrambledImage(r(1):r(3),r(2):r(4)); % Cut off the fat, returning the image to the proper size
end