% Script to make checkerboard
%
%  written by amr July 2, 2009
%


n = 15; %num pixels per side within a square
p = 10; %number of rows / 2
q = 20; %number of columns / 2
cropsize = [0 0 236*0.95 74*0.60];  % optional cropping size e.g. to make same size as word images  (wordImg = imread(wordImgPath); size(wordImg))
outdir = '/Users/Shared/AndreasWordsMatlab/WordHierarchy/stim/';

black = zeros(n);
white = ones(n);

% make the 2x2 tiles
tile = [black white; white black];
revtile = [white black; black white];

% make the checkerboard
BWcheck = repmat(tile,p,q);
BWrevCheck = repmat(revtile,p,q);
check = BWcheck+0.5;  %make gray?
revcheck = BWrevCheck+0.5;

% crop if you want
if ~notDefined('cropsize')
    BWcheck = imcrop(BWcheck,cropsize);
    BWrevCheck = imcrop(BWrevCheck,cropsize);
    check = imcrop(check,cropsize);
    revcheck = imcrop(revcheck,cropsize);
end

% display
figure; imagesc(BWcheck); colormap gray; truesize
figure; imagesc(BWrevCheck); colormap gray; truesize
figure; imshow(check); truesize
figure; imshow(revcheck); truesize


% save
imwrite(BWcheck,fullfile(outdir,'BWcheck.bmp'),'bmp')
imwrite(BWrevCheck,fullfile(outdir,'BWrevcheck.bmp'),'bmp')
imwrite(check,fullfile(outdir,'check.bmp'),'bmp')
imwrite(revcheck,fullfile(outdir,'revcheck.bmp'),'bmp')