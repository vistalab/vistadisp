% Catalog the locations of each of the backlight LEDs% HDR test


d = loadDisplayParams('hdr1');
d = openScreen(d);



% load led order
load ../displays/hdr1/ledord.dat -ascii
ledord = ledord(1:759);

% assign position data
led_x = zeros(size(ledord));
led_y = zeros(size(ledord));

% These values are all guesses
row = 0;
col = 0;
col_offset_row1 = 1280/15/2; % indented some
col_offset_row2 = 0; % no indent
col_offset = col_offset_row1;
col_spacing = 1280/16;
row_offset = 0;
row_spacing = 1024/(759/33*2);

for ii = 1:length(ledord)
	led_x( ii ) = round(col_offset + col*col_spacing);
	led_y( ii ) = round(row_offset + row*row_spacing);

	if ( (col_offset == col_offset_row1 && col == 15) || ...
	     (col_offset == col_offset_row2 && col == 16)) 
		col = 0; 
		row = row + 1;
		if (col_offset == col_offset_row1) col_offset = col_offset_row2;
		else col_offset = col_offset_row1; end
	else 
		col = col + 1; 
    end
end 


if (1==1) 
    % Write the data to LEDpos.mat
    comment1 = 'ledord contains the indices of the control values.  To control LED n, write a value to framebuffer position (x,y)=(2,2+n).';
    comment2 = 'led_x(ii) and led_y(ii) are the pixel positions of led with index ii.';
    comment3 = 'Sunnybrook HDR panel, Jan 2006 gregng';
    
    save '../displays/hdr1/ledpos.mat' -ascii led* comment*
end    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup the LED Backlight control params
% TODO: make the control a 1-dimensional array (not a 2 x n )
% Reset the backlight control pixels to 0
backLightCtrl        = zeros(2,d.numPixels(1));
backLightCtrlSrcRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );
backLightCtrlDstRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );

%--------------------------------------
% BLACKOUT
tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
Screen('Flip', d.windowPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxVal = 150;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize foreground variables
fg_voffset = 5;
fgRect = SetRect(0, fg_voffset, 1280, 1024);
img_fore = ones(1024,1280).*255;
texf = Screen('MakeTexture', d.windowPtr, img_fore((v_offset+1):1024 , : )  );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through each of the LEDs and show the LED
% and where we think it is positioned.

maxVal = 150;
ofixx = d.fixX;
ofixy = d.fixY;
for ii = 1:length(ledord);
    tmp = backLightCtrl;
    
%    tmp(2,ledord(ii)+2) = 20;
    tmp(2,:) = 11;
    tex = Screen('MakeTexture', d.windowPtr, tmp);


    % Write the foreground image
    Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);
    Screen('gluDisk', d.windowPtr, d.fixColorRgb(1,:), led_x(ii), led_y(ii), 3);

    % Write the  backlight control
    % (We write this last to make sure that the foreground doesn't
    % accidentally write over the backlight control values.)
    Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
    
    Screen('Flip', d.windowPtr);

    disp(sprintf('(%d) LED[%d]: (%d,%d)', ii, ledord(ii), led_x(ii),led_y(ii)));
    
    
    pause();
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Show the positions of all the LEDs at once

maxVal = 150;
tmp = backLightCtrl;
% tmp(2,ledord(ii)+2) = 20;
tmp(2,:) = 11;
tex = Screen('MakeTexture', d.windowPtr, tmp);

Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);
Screen('DrawDots', d.windowPtr, [led_x'; led_y'] , 3, d.fixColorRgb(1,:));
% Write the  backlight control
% (We write this last to make sure that the foreground doesn't
% accidentally write over the backlight control values.)
Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
     Screen('Flip', d.windowPtr);



