function hdrPutImage(displayID,frontImage,backImage, bDoFlip, bTestMode)
% 
% Usage: hdrPutImage(displayID,frontImage,backImage)
% 
% Put the specified frontImage (LCD front) and backImage (LED back) onto
% the HDR display (displayID initialized by using openScreen or Screen).
% 
% Inputs:
% 1. displayID - a structure specifying the display parameters (see
% openScreen)
% 2. frontImage - a 2D or 3D matrix. If the size is not 1024 x 1280, it is
% resized into that size (by resize).
% 3. backImage - a 2D or 3D matrix. The size of the image is squeezed to
% fit into the array of LEDs. In the case of a 3D matrix, the values are
% averaged across the third dimension (see cart2led).
% 4. bDoFlip - 0 or 1.  If bDoFlip==1, then we will run the Screen('Flip')
% command to show the image.  Otherwise don't do this.
% 5. bTestMode - 0 or 1.  If 1, then will write to Figure 1
% 
% History:
% 03/14/06 shc (shcheung@stanford.edu) wrote it.

ledmax = 150;

% force the front image to be 1024 x 1280
frontImage = imresize(frontImage,[1024,1280]);

% TODO: separate out the rendering.
% convert the back image to a list indexed by led id
backImageByLED = hdrCart2Led(backImage);
% backImageByLED = backImageByLED/max(backImageByLED)*ledmax;

% Blank entire screen buffer

% texLCDBlank = Screen('MakeTexture', displayID.windowPtr, zeros(1024,1280));
% rect = SetRect(0,0,1280,1024);
% Screen('DrawTexture', displayID.windowPtr, texLCDBlank, rect, rect);
% Screen('Flip', displayID.windowPtr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup the LED Backlight control params
backLightCtrl        = zeros(1,1280);
backLightCtrlSrcRect = SetRect(0,0,size(backLightCtrl,2),1 );
backLightCtrlDstRect = SetRect(0,1,size(backLightCtrl,2),2 );
% texLEDBlank = Screen('MakeTexture', displayID.windowPtr, backLightCtrl);
% Screen('DrawTexture', displayID.windowPtr, texLEDBlank, backLightCtrlSrcRect, backLightCtrlDstRect);
% Screen('Flip', displayID.windowPtr);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: nargin call that sets bTestMode if not specified

if (bTestMode == 0)

    % TODO: make this all one call

    frontImage(:) = max(min(frontImage(:), 255), 0);
    texLCD = Screen('MakeTexture', displayID.windowPtr, frontImage);
    lcdRect = SetRect(0,0,size(frontImage,2),size(frontImage,1));
    Screen('DrawTexture', displayID.windowPtr, texLCD, lcdRect, lcdRect);

    % Protection code.  Make sure we can't overdrive the LEDs.
    backImageByLED(:) = max(min(backImageByLED(:), ledmax), 0);
    texLED = Screen('MakeTexture', displayID.windowPtr, backImageByLED);
    Screen('DrawTexture', displayID.windowPtr, texLED, backLightCtrlSrcRect, backLightCtrlDstRect);

    if (bDoFlip == 1)
        Screen('Flip', displayID.windowPtr);
    end
else
    
    % TODO: hacky!
%    hdrImage = hdrSimulate( repmat(frontImage, [1 1 3], ...
%        'led_pos', '../displays/hdr1/ledpos.d')
    
    frontImage(2,:) = backImageByLED;
    figure(1); 
    subplot(211); imshow(imresize(frontImage, 0.5, 'bilinear'),[0 255]);title('front');
    subplot(212); imshow(imresize(backImage, 0.5, 'bilinear'),[0 30]);title('back');
    
    %imshow(imresize(frontImage, 0.5, 'bilinear'));
%     if (bDoFlip == 1)
%         title('Immediate Flip (shrink 2x)');
%     else
%         title('Delayed Flip (shrink 2x)');
%     end
end

