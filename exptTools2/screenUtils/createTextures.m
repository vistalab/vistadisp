function stimulus = createTextures(display, stimulus, removeImages);
%stimulus = createTextures(display, stimulus, [removeImages=1]);
%
%Replace images within stimulus (stimulus.image) with textures
%(stimulus.textures).
%
%Stimulus can be a 1xn array of stimuli.  It creates the textures
%(like loading in off-screen memory in OS9).
% If the removeImages flag is set to 1 [default value], the code
% destroys the original image field (freeing up the memory and speeding up
% pass-by-copy calls of stimulus). For stimuli with many images, this is
% strongly recommended; however, for a small number of images, the field
% may not slow things too much; setting the flag to 0 keeps the images.
%
%If you're trying to create an texture starting at something
%other than the first image, use addTextures.

%2005/06/09   SOD: ported from createImagePointers
%31102005    fwc:	changed display.screenNumber into display.windowPtr
if notDefined('removeImages'),      removeImages = 1;       end

%c = getReservedColor(display, 'background');
try
	c = display.backColorIndex;
catch
	c = display.backColorRgb;
end;

for stimNum = 1:length(stimulus)

	% if stored as cell?!
	% maybe everything should be cell based and not based on the 3 image
	% dimension - this would allow easy support for rgb images
	if iscell(stimulus(stimNum).images),
		stimulus(stimNum).images = cell2mat(stimulus(stimNum).images);
	end;

	% number of images
	nImages = size(stimulus(stimNum).images,3);

	% make Rects
	stimulus(stimNum).srcRect = [0,0,size(stimulus(stimNum).images, 2), ...
		size(stimulus(stimNum).images, 1)];
	if ~isfield(display,'destRect'),
		stimulus(stimNum).destRect = CenterRect(stimulus(stimNum).srcRect, display.rect);
	else
		stimulus(stimNum).destRect = CenterRect(display.destRect, display.rect);
	end;
	% clean up nicely if any of the textures are not null.
	if isfield(stimulus(stimNum), 'textures'),
		nonNull = find(stimulus(stimNum).textures);
		for i=1:length(nonNull),
			% run this from eval to suppress any errors that might ensue if the texture isn't valid
            % converted eval to try, as two argument use of eval is now deprecated (jw)
            try
                Screen(stimulus(stimNum).textures(nonNull(i)), 'Close');
            end
		end;
	end;
	stimulus(stimNum).textures = zeros(nImages, 1);
    
	% make textures
	for imgNum = 1:nImages,
        %jw: flip for back bore inverted display
%         if (isfield(display, 'flipLR') && display.flipLR),
%             stimulus(stimNum).images(:,:,imgNum) = fliplr(stimulus(stimNum).images(:,:,imgNum));
%         end
%         if (isfield(display, 'flipUD') &&display.flipUD),
%             stimulus(stimNum).images(:,:,imgNum) = flipud(stimulus(stimNum).images(:,:,imgNum));
%         end
        
        stimulus(stimNum).textures(imgNum) = ...
			Screen('MakeTexture',display.windowPtr, ...
			double(stimulus(stimNum).images(:,:,imgNum)));  % fwc:	changed display.screenNumber into display.windowPtr
	end;

	% clean up
	if removeImages==1
		stimulus(stimNum).images = [];
	end
end;

% call/load 'DrawTexture' prior to actual use (clears overhead)
Screen('DrawTexture', display.windowPtr, stimulus(1).textures(1), ...
	stimulus(1).srcRect, stimulus(1).destRect);

return
