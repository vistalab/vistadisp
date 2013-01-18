function scaledImage = faceScaleContrast(img, C, varargin);
% contrast-scale the image to a mean RMS contrast specified by C. 
% The maskVal argument specifies the grayscale value of the background in
% the unscaled images (for the face data base, this is 161, and reflects a
% circular mask used to hide hair information). This value will not be
% considered in computin the contrast, and will be replaced by the
% background color in bgCol. 

% params
maskVal = 161; % gray value of mask which crops out the hair in the face images
bgVal = 127;
display = [];

for ii = 1:2:length(varargin)
    assignin('caller', varargin{ii}, varargin{ii+1});
end

% enforce double precision for the meantime
img = double(img);

% mask out background values in the image
mask = (img ~= maskVal);

%% Figure out the intended rescaled range of the image values
% (this is the tricky part, and will likely iterate several times)
% For this iteration, set the low and high limits for the rescaled image
% based on the distribution of grayscale intensities in the input image.
% First, I estimate the spread of image intensities about the mean
% (ignoring the masked-out parts). I then compute what the target std. dev.
% would be to achieve (C %) RMS contrast. The ratio of these values tells
% me how far I should "squeeze" the distribution of intensity values in the
% rescaled image. (This ignores the display calibration for now.)

% get the values in the image mask
vals = img(mask);

% subtract out the mean
vals = vals - mean(vals);

% get the estimated deviation about the mean
sigma = std(vals);

% what is the target sigma value after rescaling?
tgtSigma = C * bgVal;

% set the new color limit values for the rescaling 
% based on the ratio of the target and actual sigmas:
clipRange = minmax( img(mask) );
newRange = bgVal + clipRange .* (tgtSigma / sigma);

% scale the image
scaledImage = rescale2(img, clipRange, newRange);

% make sure the mean of the image matches the background color
% I use the heuristic that the top left corner is background
offset = scaledImage(1) - bgVal;
scaledImage = scaledImage - offset;

% enforce uint8 type
scaledImage = uint8( round(scaledImage) );

return
