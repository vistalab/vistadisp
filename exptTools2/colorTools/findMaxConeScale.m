function [stimLMS, stimRGB, maxcontrast] = findMaxConeScale(display,stimLMS,backRGB,sensors, dirFlag)%%  [stimLMS,stimRGB] = findMaxConeScale(display,stimLMS,backRGB,[sensors], [dirFlag])%%AUTHOR: Wandell, Baseler, Press%DATE:   09.08.98%PURPOSE:%%   Calculate the maximum scale factor for the stimLMS given the%   background and display properties. %   %   When stimLMS.dir is in a cone isolating direction, the maximum%   scale factor is also to the max cone contrast available for that cone%   class. %   %   When stimLMS is not in a cone isolating direction, you are on%   your own.  That's why we call it scale.%  % ARGUMENTS%%  display:  .spectra is  a 361x3 display primaries%             %  stimLMS:  The field%             .dir     defines the color direction. By convention,%             .dir is a 3-vector with a maximum value of 1.0%             %  backRGB:  .dir    defines the color direction. By convention,%            .dir is a 3-vector with a maximum value of 1.0%             .scale  a single scale factor%			  (optional, [0.5 0.5 0.5] default)%  sensors:  361x3 matrix of sensor wavelength sensitivities%             (optional, Stockman are default).%  dirFlag:  if true, we assume the stimulus is a positive modulation from%              the background. If 0 or unset, we assume the stimulus%              modulates symmetrically in two directions from the%              background. This affects how we calculate the maximum scale%              along a color direction.%% RETURNS%            % stimLMS:  %           .maxScale is the highest scale factor.  This is the%           .maximum contrast when stimLMS.dir is cone isolating.%             % stimRGB: %          .dir is set to rgb direction corresponding to this%           lms direction. %% 10.29.98:	Swapped order of parameters.% 11.17.98: RFD & WAP: added scaling for lmsBack.%	NOTE: as of now, the RGB values returned are scaled by the%	background LMS so that they accurately reflect the requested%	LMS values in stimLMS.  (i.e., now you will get your requested%	LMS contrasts no matter what the background color direction.)% % 2010.04.02 RFD: allow an rgb2lms matrix in place of diaplay & sensors% 2011.02.10 JW: allow user to specify whether modulation is in only one %               direction from background or is symmetric (bi-directional) modulation% Set up input defaults%if notDefined('backRGB')  % disp('Cone2RGB: Using default background of [0.5 0.5 0.5]')  backRGB.dir = [1 1 1]';  backRGB.scale = 0.5;endif(~isstruct(display) && numel(display)==9)    % then display is a 3x3 rgb2lms matrix.    rgb2lms = display;else    if notDefined('sensors')        tmp = load('stockman');        if isfield(tmp, 'stockman'), stockman = tmp.stockman; end        if isfield(tmp, 'data'),     stockman = tmp.data;     end        sensors = stockman;    end        if ~isfield(display,'spectra')        error('The display structure requires a spectra field');    end    rgb2lms = sensors'*display.spectra;endif notDefined('dirFlag'), dirFlag = 0; endlms2rgb = inv(rgb2lms);% Check whether the background RGB values are within the unit cube%meanRGB = backRGB.dir(:) * backRGB.scale;err = checkRange(meanRGB,[0 0 0]',[1 1 1]');if err ~= 0,  error('meanRGB out of range'); end%  Determine the background LMS direction %  lmsBack = rgb2lms*(meanRGB);%  Scale stimulus LMS by the background LMS%  We do this because the stimLMS dir is a contrast. So if we want a 0.1%  contrast in the L and a 0.2 contrast in the M, then the amount of L and%  M we need would be .1*lmsBack(1) and .2*lmsBack(2).scaledStimLMS = stimLMS.dir(:) .* lmsBack;%  Determine the stimulus RGB direction that will create the desired LMS%  changes.  We should probably not create lms2rgb as above, but use the%  \ operator instead.%  stimRGB.dir = lms2rgb*scaledStimLMS; %#ok<MINV>stimRGB.dir = stimRGB.dir/max(abs(stimRGB.dir));% We want to find the largest scale factor such that the% background plus stimulus fall on the edges of the unit cube.% We begin with the zero sides of the unit cube, % %      zsFactor*(stimRGB.dir) + meanRGB = 0% % Solving this equation for zsFactor, we obtain%sFactor = -(meanRGB) ./ stimRGB.dir;%  The smallest scale factor that bumps into this side isif dirFlag, zsFactor = min(abs(sFactor(sFactor > 0))); % if we check only positive modulations from backgroundelse        zsFactor = min(abs(sFactor)); end          % if we assume symmetric, bidirectional modulation from background    % Now find the sFactor that limits us on the 1 side of the unit RGB cube.% %       usFactor*stimRGB.dir + meanRGB = 1%   sFactor = (ones(3,1) - meanRGB) ./ stimRGB.dir; if dirFlag, usFactor = min(abs(sFactor(sFactor>0))); % if we check only positive modulations from backgroundelse       usFactor = min(abs(sFactor));    end      % if we assume symmetric, bidirectional modulation from background%  Return the smaller of these two factors%  stimRGB.maxScale = min(zsFactor,usFactor);% Next, convert these values into LMS contrast terms.% % General discussion:% %  For each scale factor applied to the stimulus, there is a%  corresponding contrast.  But, this must be computed using both%  the stimLMS and the backLMS.  So, contrast and stimLMS.scale%  are not uniquely linked, but they depend on the background.% %  When stimRGB.scale is less than stimRGB.maxScale, we are sure that we%  are within the unit cube on this background.  What is the%  highest scale level we can obtain for the various cone classes%  at this edge? % % Compute the LMS coordinates of the [stimulus plus background] and% the background alone.  Use these to compute the max scale% factor we can use in the LMS direction.  This is the maximum% contrast when we are in a cone isolating direction.%  lmsStimPlusBack = ...    rgb2lms*(stimRGB.maxScale*stimRGB.dir + backRGB.dir*backRGB.scale);lmsContrast = (lmsStimPlusBack  - lmsBack) ./ lmsBack;stimLMS.maxScale = max(abs(lmsContrast));maxcontrast = norm(lmsContrast);backLMS.dir = lmsBack;backLMS.scale = 1;return