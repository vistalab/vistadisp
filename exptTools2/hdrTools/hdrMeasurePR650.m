% HDR gamma mesurement
% Gregory Ng
% Based on code by Kanako Hayashi 2/27/2006
% Atted RGB mode  by Sing 3/13/2006

% Measure the light output of the Brightside HDR using the PR650.

% display_input should be an n x 1 row matrix where each row represents one
% stimulus to measure.

% The stimulus presented depends on the stimulus_mode
%
% if stimulus_mode == 0, then
%    display_input(:,1) is the value to set all the LCD pixels to
%    display_input(:,2) is the value to set a single pre-defined LED to.
%                       All other LEDs are set to 0.
% 
% if stimulus_mode == 1, then
%    display_input(:,1) is the value to set all the LCD pixels to
%    display_input(:,2) is the value to set all LEDs to.
%
%
% rgb is a vector of length 3, each element specifying the channel to be
% turned on. e.g., [1 0 0] means using the red channel only
%
%
% If measure luminance (Y),  set pr650Opt == 'xyz'. 
% Else if measure color luminamce set pr650Opt == 'spectral'.

function data = hdrMeasurePR650(display_input, stimulus_mode, param1, rgb, pr650Opt) 
%function data = hdrMeasurePR650(display_input, stimulus_mode, param1, pr650Opt) 
led_num = 1;
if (stimulus_mode == 0) 
    led_num = param1; %388;
    if (param1 < 0) led_num = param1; end;
end
    
% Begin with setting the path so that you can access the routines
% We should put these routines somewhere else as well

% You're going to need to add
% PDC/Applications/ctToolbox/ctDataCollection
% in order to properly control the PR650 (or something else with cMeter
% in it)

%cd 'C:\CVSDirectry\PDC-Applications\ctToolBox\ctDataCollection'
%addpath(genpath(pwd));

% Initialize the PR650
ieClearSerialPorts;
if ieNotDefined('nCommPort')
    nCommPort=4;
end;
% Make sure it works
try
    PR650 = cmeter(nCommPort);
catch
    uiwait(errordlg('Error accessing the photometer, please check the device...', 'Error', 'modal'));
    PR650=[];
end;

if (stimulus_mode < 0 || stimulus_mode > 1) 
    disp('Bad stimulus mode');
    return;
end

% load position data
% See hdrShowLEDs to see how data is generated.
% This loads ledord, led_x, and led_y variables.
load '../displays/hdr1/ledpos.mat';

load ../displays/hdr1/ledord.dat -ascii
ledord = ledord(1:759);

try

    if(ispc)
        d = loadDisplayParams('hdr1');
        d.screenNumber = 0;
        d = openScreen(d);
    end
    % Blank entire screen buffer

    texblank = Screen('MakeTexture', d.windowPtr, zeros(1280,1024));
    rect = SetRect(0,0,1280,1024);
    Screen('DrawTexture', d.windowPtr, texblank, rect, rect);
    Screen('Flip', d.windowPtr);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Setup the LED Backlight control params
    % TODO: make the control a 1-dimensional array (not a 2 x n )
    % Reset the backlight control pixels to 0
    backLightCtrl        = zeros(2,1280);
    backLightCtrlSrcRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );
    backLightCtrlDstRect = SetRect(0,0,size(backLightCtrl,2),size(backLightCtrl,1) );
    tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
    Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
    Screen('Flip', d.windowPtr);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ledmax = 150;
    lcdmax = 255;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (stimulus_mode == 0) 
        led_num_x = led_x(led_num);
        led_num_y = led_y(led_num);
        led_screen = ledord(led_num);
    end
   % img_fore = ones(1024,1280);

    for ii=1:size(display_input,1);

        % Draw foreground
        img_fore = zeros(1024,1280);
        img_fore(:) = min(display_input(ii, 1) , lcdmax);
        img_fore = repmat(img_fore,[1,1,3]);
        for(jj=[1:3])
            if(~rgb(jj)), img_fore(:,:,jj)=0; end
        end
        
        texf = Screen('MakeTexture', d.windowPtr, img_fore  );
        fgRect = SetRect(0,0,size(img_fore,2),size(img_fore,1));
        Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);

        % Draw backlight
        backLightCtrl(:)=0;

        if (stimulus_mode == 0) 
            % Single LED mode
            backLightCtrl(2, 2+led_screen) = min(ledmax, display_input(ii,2));
        elseif (stimulus_mode == 1)
            % Flat field
            backLightCtrl(2, 2+ledord(:)) = min(ledmax, display_input(ii,2));
            backLightCtrl;
        end


        tex = Screen('MakeTexture', d.windowPtr, backLightCtrl);
        Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);
  
        disp(sprintf('fore=%d,back=%d',display_input(ii,1), display_input(ii,2)));
        Screen('Flip', d.windowPtr);
        pause(.2); % wait for the Flip to settle (just in case)

        %Screen('Flip', d.windowPtr);
        %pause(0.1);
        %Screen('Flip', d.windowPtr);
        

        % Now you can use the PR650 - put this section inside a loop
        %aXYZ = [0,0,0];
        if(strcmp(pr650Opt,'xyz'))
            aXYZ=getdata(PR650, 'xyz');
            data(ii,1:3) = aXYZ; % Y = aXYZ(3);
        elseif(strcmp(pr650Opt,'spectral'))
            [spect,wavelength] = getdata(PR650, 'spectral');
            data(ii).spectrum = spect;
            data(ii).wavelength = wavelength;
        end

    end
    % When you are done with your measurements, be sure to exit gracefully
    delete(PR650)
    if (ispc)
        Screen('CloseAll');
    end
catch
    % Close window in case of error.
    Screen('CloseAll');

    % Also close the PR650
    delete(PR650);
    rethrow(lasterror);
end


%

% toc