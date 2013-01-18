function stim = makeTextures(display, stim)
%stim = makeTextures(display, stimulus)
%
%  - Note that there is another command, createTextures, that does the
%  same basic function.  We need to decide which we want and merge -
%  Bob thinks at the moment that we should use createTextures, but we're
%  not sure.
%
% Replace images within stimulus (stimulus.images) with textures
% (stimulus.textures).
%
% Stimulus can be a 1xn array of stimuli.  It generates OpenGL textures
% and destroys the original image field (freeing up the memory and speeding 
% up bit-blitting of the stimulus).
% 
% The stimulus.images field should be a 1xN cell array of image data. The image
% data can be XxYx1 for grayscale, XxYx3 for RGB, or XxYx4 for RGBA. The
% values in each image array should run between 0 and display.maxRgbValue. 
%
% HISTORY:
% 10/16/98: Modified by Bill, Bob, and Ben
%
% 10/27/98	Bob: added code to clean up any non-null image pointers before 
% creating new ones.
% 10/30/98   Bob: Fixed code that cleans up non-null image pointers for 
% backwards compatability.
% 2005.02.23 RFD: ported from createImagePointers
for stimNum = 1:length(stim)
	nImages = length(stim(stimNum).images);
        	
	% clean up nicely if any of the textures are not null.
    if(isfield(stim(stimNum), 'textures') && ~isempty(stim(stimNum).textures))
    	nonNull = find(stim(stimNum).textures);
    	for(ii=nonNull(:))
    		Screen('Close', stim(stimNum).textures(ii));
    	end
    end
    stim(stimNum).textures = zeros(nImages, 1);
   
	for imNum = 1:nImages
        stim(stimNum).textures(imNum) = Screen('MakeTexture', display.windowPtr, ...
                                       stim(stimNum).images{imNum});
	end
	stim(stimNum).images = {};
end
return;