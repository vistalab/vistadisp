% HDR edge generation
% Started by Gregory Ng 1/24/2006

d = loadDisplayParams('hdr1');
description=Screen('computer');
if strcmp('PCWIN',computer)
    d.screenNumber = 0;
    ledpos_offset = 2;
else
    % Mac
    ledpos_offset = 2;
end
d = openScreen(d);


% load led order
%load ../displays/hdr1/ledord.dat -ascii
%ledord = ledord(1:759);

% load position data
% See hdrShowLEDs to see how data is generated.
% This loads ledord, led_x, and led_y variables.
load '../displays/hdr1/ledpos.mat';



% Blank entire screen buffer

texblank = Screen('MakeTexture', d.windowPtr, zeros(1280,1024));
rect = SetRect(0,0,1280,1024);
Screen('DrawTexture', d.windowPtr, texblank, rect, rect);
Screen('Flip', d.windowPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup the LED Backlight control params
% TODO: make the control a 1-dimensional array (not a 2 x n )
% Reset the backlight control pixels to 0
backLightCtrl        = zeros(2,d.numPixels(1));
backLightCtrlSrcRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );
backLightCtrlDstRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );
 
tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
Screen('Flip', d.windowPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

maxVal = 150;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Horizontal Edge 
% (set with variable v_edge_loc)
%

% Vertical position of the edge
v_edge_loc = 512;
edge_sign = 1;
modulate_lcd = 1;
led_intensity = 30;
lcd_intensity = 255;

for v_edge_loc = 400:8:500

    % Construct the edge image
    [xgrid ygrid] = meshgrid( 1:1280, 1:1024 );

    if (modulate_lcd)
        img_fore = ( edge_sign*ygrid > edge_sign*v_edge_loc ) * lcd_intensity;
    else
        img_fore = ones(size(xgrid)) * lcd_intensity;
    end
    idx_back = ledord(find(edge_sign*led_y > edge_sign*v_edge_loc));


    % Draw foreground
    texf = Screen('MakeTexture', d.windowPtr, img_fore  );
    fgRect = SetRect(0,0,size(img_fore,2),size(img_fore,1));
    Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);

    % Draw backlight
    backLightCtrl(:)=0;
    backLightCtrl( 2, ledpos_offset+idx_back ) = min(maxVal, led_intensity);
    tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
    Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);

    pause(2);
    Screen('Flip', d.windowPtr);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Vertical Edge 
% (set with variable v_edge_loc)
%

% Vertical position of the edge
h_edge_loc = 640;
edge_sign = -1;
modulate_lcd = 1;
led_intensity = maxVal / 5;
lcd_intensity = 255;

% Construct the edge image
[xgrid ygrid] = meshgrid( 1:1280, 1:1024 );
if (modulate_lcd)
    img_fore = ( edge_sign*xgrid > edge_sign*h_edge_loc ) * lcd_intensity;
else
    img_fore = lcd_intensity * ones(size(xgrid));
end
idx_back = ledord(find(edge_sign*led_x > edge_sign*h_edge_loc));
%idx_back = ledord(:);


% Draw foreground
texf = Screen('MakeTexture', d.windowPtr, img_fore  );
fgRect = SetRect(0,0,size(img_fore,2),size(img_fore,1));
Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);

% Draw backlight
backLightCtrl(:)=0;
backLightCtrl( 2, ledpos_offset+idx_back ) = min(maxVal, led_intensity);
tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);

Screen('Flip', d.windowPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pause(2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Diagonal Edge
% Draw a 60 degree edge through the center.
slope = tan(30*pi/180);
xc = 640; % Intercept X
yc = 512; % Intercept Y
edge_sign = -1; % Set to 1 or -1 to set which way edge goes.


img_fore = (edge_sign*ygrid < edge_sign*(slope.*(xgrid - xc) + yc) ) * maxVal;
idx_back = ledord(find(edge_sign*led_y < edge_sign*(slope.*(led_x-xc)+yc)) );

% Write the edge image
texf = Screen('MakeTexture', d.windowPtr, img_fore );
%fgRect  = SetRect(0,v_offset,size(img_fore,2),size(img_fore,1));
fgRect  = SetRect(0,0,size(img_fore,2),size(img_fore,1));
%fgRect  = SetRect(0,v_offset,size(img_fore,2),size(img_fore,1));
Screen('DrawTexture', d.windowPtr, texf, fgRect,fgRect);

% Write backlight control
backLightCtrl(:)=0;
backLightCtrl( 2, ledpos_offset+idx_back ) = maxVal/2;
tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);


Screen('Flip', d.windowPtr);

description=Screen('computer');
if strcmp('PCWIN',computer)
    pause(2);
    Screen('Close',d.windowPtr);

elseif strcmp('MAC2',computer)
else
    error('Unknown operating system.');
end
