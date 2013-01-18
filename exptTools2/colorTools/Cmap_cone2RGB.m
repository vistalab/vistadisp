function [CmapRGB, scaleFactor] = Cmap_cone2RGB(display, CmapLMS, backRGB, sensors)
% function [cmapRGB, scaleFactor] = Cmap_cone2RGB(display, cmapLMS, backRGB, sensors)
% This is a much improved version of cone2RGB in that:
% (1) cmapLMS/cmapRGB here can be real Mx3xN cmap matrix, while
%     stimLMS/stimRGB in cone2RGB.m can only be vectors.
%     In other words, we transfer all color vectors in bunch!
% (2) If input LMS exceeds monitor RGB viability, i.e., one of
%     R,G,B out of range [0,1], cone2RGB fails. However, here
%     if out of range, we scale down all vectors to make them
%     within the range, and give a warning, as well as output
%     scaleFactor (>=1). This makes colortuning much more efficient.
%
% Author: Junjie Liu, Refurbished date: 11-11-2002.

if ~exist('backRGB','var')
  % disp('Cone2RGB: Using default background of [0.5 0.5 0.5]')
  backRGB.dir = [1 1 1]';
  backRGB.scale = 0.5;
end

if ~exist('sensors','var')
  % disp('Using Stockman fundamentals')
  load stockman
  sensors = stockman;
end

if ~isfield(display,'spectra')
  error('The display structure requires a spectra field');
else
  rgb2lms = sensors'*display.spectra;
  lms2rgb = inv(rgb2lms);
end

% Check whether the background RGB values are within the unit cube
%
meanRGB = backRGB.dir * backRGB.scale;
err = checkRange(meanRGB,[0 0 0]',[1 1 1]');
if err ~= 0
  error('meanRGB out of range')
end

%  Determine the background LMS direction 
%  
lmsBack = rgb2lms*(backRGB.dir*backRGB.scale);

%--------

sizeCmap = size(CmapLMS);
if sizeCmap(2)~=3, error('Cmap size incorrect'), end,
LMS = transpose(reshape(shiftdim(CmapLMS,2),prod(sizeCmap)/3,3)); % see help for shiftdim
meanRGB = repmat(meanRGB,1,size(LMS,2));

%  Scale cmap LMS by the background LMS
%
scaledLMS = LMS .* repmat(lmsBack,1,size(LMS,2));

%  Transfer to RGB
scaledRGB = lms2rgb*scaledLMS;

% We want to find the largest scale factor such that the
% background plus stimulus fall on the edges of the unit cube.
% We begin with the zero sides of the unit cube, 
%      If scaledRGB + meanRGB < 0 out of tube
% since always meanRGB>0, we write -scaledRGB > meanRGB
sFactor = - scaledRGB ./ meanRGB;
% when factor >1, out of tube.

%  The maximum scale factor on this side is
[zsFactor, zsIndex] = max(max(sFactor,[],1),[],2);

% Now find the sFactor that limits us on the 1 side of the unit RGB cube.
% 
%       If scaledRGB + meanRGB > 1 out of tube
% since always meanRGB<1 we write scaledRGB > (1-meanRGB)
sFactor = scaledRGB ./ (1 - meanRGB);
% when factor >1 out of tube.

% when factor is negative, it actually means in tube, even if <-1
% so no abs() now, since we are now considering color points, not dir that can extends in both directions,

% The maximum scale factor on this side is
[usFactor, usIndex] = max(max(sFactor,[],1),[],2);

%  Return the larger of these two factors
index = zsIndex; scaleFactor = zsFactor;
if usFactor > zsFactor, index = usIndex; scaleFactor = usFactor; end,

if scaleFactor>1,
    disp(['Most out of range happens at direction LMS = [',num2str(LMS(:,index)'),']']);
    disp(['Out of range ratio is ',num2str(scaleFactor),', all Cmap thus scaled as divided by this ratio']);
    RGB = scaledRGB/scaleFactor + meanRGB;    
    disp(['Please recount your contrast accordingly! (max=',num2str(max(abs(LMS(:,index)))./scaleFactor),').']);
else
    RGB = scaledRGB + meanRGB;
end

CmapRGB = reshape(transpose(RGB),sizeCmap([3:end,1,2]));
CmapRGB = shiftdim(CmapRGB,size(sizeCmap,2)-2);

return
