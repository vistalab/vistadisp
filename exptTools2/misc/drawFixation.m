function drawFixation(d, colIndex)
%
% drawFixation(display, [colIndex=1])
%
% Draws the fixation point specified in the display struct.
%
% HISTORY:
% 2005.02.23 RFD: wrote it.
% 2005.06.29 SOD: added colIndex for fixation dot task
%                 added largeCrosses options
% 2008.05.11 JW:  added 'dot and 'none' options 
%                 added 'lateraldots'
if nargin < 2, colIndex = 1; no_color_flag = true; end;

% draw a grid if specified
if isfield(d, 'fixGrid') && d.fixGrid==1
	%% draw a polar grid to help the eye find fixation
    maxX = d.numPixels(1);
    maxY = d.numPixels(2);
    cenX = maxX ./ 2;
    cenY = maxY ./ 2;
    
	maxR = min([cenX, cenY]);
	rangeR = 0:100:maxR;
	rangeTheta = 0:30:330;
	
	for r = rangeR
        col = d.backColorIndex + 20;
		Screen('FrameOval', d.windowPtr, col, [cenX-r cenY-r cenX+r cenY+r]);
	end
		
	for th = rangeTheta
        col = d.backColorIndex + 20;
		[x y] = pol2cart(deg2rad(th), maxR);
		x = x + cenX;
		y = y + cenY;
		Screen('DrawLine', d.windowPtr, col, cenX, cenY, x, y);
	end
    
end

switch(lower(d.fixType))
    case {'none'}
        %do nothing
        
    case{'digits'}
        % when digits are ranging from 0 to 9
        display_digit = mod(colIndex, 10)
        % colIndex ranging from 0 to 19 for digits 0-9 in black and white, blank when colIndex = 20
        if colIndex < 20
            %Screen('DrawText', d.windowPtr, num2str(display_digit), d.fixX, d.fixY,  d.fixColorRgb(colIndex+1,:));
            DrawFormattedText(d.windowPtr, num2str(display_digit), 'center', 'center', d.fixColorRgb(colIndex+1,:));
            Screen('TextSize',d.windowPtr, d.fixSizePixels);
        end
        
    case {'dot' 'dot with grid' 'small dot'}
        Screen('glPoint', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
    
    case {'lateraldot'}
        % Hack: use colIndex to control both color and fixation location
        col = ceil(colIndex/3); 
        loc = mod(colIndex, 3); if loc == 0, loc = 3; end
        %so for colIndex vals [1:6], col= [1 1 1 2 2 2], loc = [1 2 3 1 2 3];
        Screen('glPoint', d.windowPtr, d.fixColorRgb(col,:), ...
            d.fixStim(loc), d.fixY, d.fixSizePixels);
    
    case {'disk','left disk','right disk', 'upper left', 'lower left', 'upper right', 'lower right', 'left', 'right', 'upper', 'lower'}
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
    
    case {'double disk','left double disk','right double disk'}
        % draw mean luminance 'edge' big one first
        Screen('gluDisk', d.windowPtr, [128 128 128], d.fixX, d.fixY, d.fixSizePixels.*2);
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
            
    % no task (colIndex) for large crosses
    case {'large cross' , 'largecross','large cross x+','largecrossx+'},
        % Colors: 1 = black, 2 = white
                
        fix_type = colIndex;  
        
        switch fix_type
            case 1, colIndex = [1 1 1]; % all black
            case 2, colIndex = [2 2 2]; % all white
            case 3, colIndex = [1 2 2]; % cue both sides
            case 4, colIndex = [1 2 1]; % cue left
            case 5, colIndex = [1 1 2]; % cue right
        end    
        
        % Draw whole cross
        Screen('DrawDots', d.windowPtr, d.fixCoords{1}, d.fixSizePixels, d.fixColorRgb(colIndex(1),:));
        
        % Draw left arm
        Screen('DrawDots', d.windowPtr, d.fixCoords{2}, d.fixSizePixels, d.fixColorRgb(colIndex(2),:));
        
        % Draw right arm
        Screen('DrawDots', d.windowPtr, d.fixCoords{3}, d.fixSizePixels, d.fixColorRgb(colIndex(3),:));

        
    case {'double large cross' , 'doublelargecross'},
        Screen('DrawDots', d.windowPtr, d.fixCoords, d.fixSizePixels, d.fixColorRgb(1,:));
        Screen('DrawDots', d.windowPtr, d.fixCoords, ceil(d.fixSizePixels./2), d.fixColorRgb(end,:));
    
	case {'simon task'}
		Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,colIndex));
		
    case {'thin cross'},
		if numel(d.fixCoords) > 1, colIndex2=colIndex; else, colIndex2 = 1; end;
        Screen('DrawDots', d.windowPtr, d.fixCoords{colIndex2}, d.fixSizePixels(colIndex2), d.fixColorRgb(colIndex,:));

    case {'pointer lines'} % add the fields LpixWidth and CpixWidth to display - length of lines which cross at center and diameter of circle which occludes them to create empty gap (in pixels)
        Screen('DrawLine', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX-d.LpixWidth/2, d.fixY+d.LpixWidth/2, d.fixX+d.LpixWidth/2, d.fixY-d.LpixWidth/2, 1);
        Screen('DrawLine', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX-d.LpixWidth/2, d.fixY-d.LpixWidth/2, d.fixX+d.LpixWidth/2, d.fixY+d.LpixWidth/2, 1);
        Screen('gluDisk', d.windowPtr, d.backColorRgb, d.fixX, d.fixY, d.CpixWidth/2);

    case {'chung dots'} % add the fields gapSize and dotSize to display - indicates how far from fixation each dot will be drawn and diameter of dots (in pixels)
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY-(d.gapSize/2),d.dotSize);
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY+(d.gapSize/2),d.dotSize);

    otherwise,
        error('Unknown fixationType!');
end
return
