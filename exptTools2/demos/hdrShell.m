% HDR Interactive Shell
% 
% Play with various parameters of the HDR display.
% Type 'help' or '?' at the shell prompt for help.
%
% Started by Gregory Ng 1/24/2006




description=Screen('computer');
if strcmp('PCWIN',computer)
    d = loadDisplayParams('displayName','hdr1');
    d.screenNumber = 0;
    d = openScreen(d);
    ledpos_offset = 2;
else
    if (exist('d') ~= 1)
        % HDR2 is the PC
        d = loadDisplayParams('displayName','hdr1');
        d = openScreen(d);
    end    
    % Mac
    ledpos_offset = 2;
end



% load led order
% PC: this file seems ok.
%load ../displays/hdr1/ledord.dat -ascii


try 
    % load position data
    % See hdrShowLEDs to see how data is generated.
    % This loads ledord, led_x, and led_y variables.
    % PC: this one ok.
    load '../displays/hdr1/ledpos.mat';
    ledord = ledord(1:759);

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

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize foreground variables
    fg_voffset = 5;
    fgRect = SetRect(0, fg_voffset, 1280, 1024);
    img_fore = ones(1024,1280).*255;
    texf = Screen('MakeTexture', d.windowPtr, img_fore );

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loop over leds.  The fixation dot displays the
    % center of the guessed center of the dot.



    maxVal = 150;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Interactive section allowing you to set the
    % intensities of the LEDs
    resp = '';
    lcdx = 255;
    x = 20;
    draw_led_pos = 0;
    single_led_idx = 387;
    mode_single_led = 0;

    while (0==strcmp(resp,'q'))



        tmp = backLightCtrl;
        %tmp(2,ledord(387:388)+2) = maxVal;
        if (mode_single_led) 
            % Turn on only a single LED
            tmp(2,ledord(single_led_idx)+ledpos_offset  ) = x;

            disp(sprintf('Backlight LED = %d; LCD = %d.  LED %d at (%d,%d)',x, lcdx, single_led_idx, led_x(single_led_idx), led_y(single_led_idx)));

        else
            % Turn on all LEDs
            tmp(2,ledord(:)+ledpos_offset) = x;
            disp(sprintf('Backlight LED = %d; LCD = %d',x, lcdx));
        end


        tex = Screen('MakeTexture', d.windowPtr, tmp);



        % Write the foreground image
        Screen('DrawTexture', d.windowPtr, texf, fgRect, fgRect);


        if (draw_led_pos) 
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Show the LED points
            Screen('DrawDots', d.windowPtr, [led_x'; led_y'] , 4, d.fixColorRgb(1,:));

            if (mode_single_led)
                Screen('gluDisk', d.windowPtr, [0 255 32 255], led_x(single_led_idx), led_y(single_led_idx), 5);
            else
                Screen('DrawDots', d.windowPtr, [led_x(single_led_idx);  led_y(single_led_idx)], 4, [0 255 32 255]);
            end
        end


        % Write the  backlight control
        % (We write this last to make sure that the foreground doesn't
        % accidentally write over the backlight control values.)
        Screen('DrawTexture', d.windowPtr, tex, backLightCtrlSrcRect, backLightCtrlDstRect);

        Screen('Flip', d.windowPtr);


        resp = input('Command (h for help) : ', 's');
        if (strcmp(resp,'h') || strcmp(resp,'help') || strcmp(resp,'?'))
            disp('HDR Shell Help\n');
            disp('+/- Increase or decrease the Backlight LED intensity');
            disp('g   Toggle the LED position grid');
            disp('m   Toggle display mode (single LED or uniform)');
            disp('  ');
            disp('ledval   Input the Backlight LED intensity numerically');
            disp('lcdval   Input the front LCD intensity numerically');
            disp('ledidx   Input the index of the LED to display (single LED mode)');
            disp('mode     Show the current mode of operation');
            disp('q   Quit HDRShell');
            disp('  ');
        elseif (strcmp(resp,'+') || strcmp(resp,'=')) 
            if (x < 255) x = x + 1; end

        elseif (strcmp(resp,'-')) 
            if (x > 0) x = x - 1; end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Mode toggling commands

        elseif (strcmp(resp,'g')) % Toggle LED position grid
            draw_led_pos = ~draw_led_pos;
            disp(sprintf('Show LED grid: %d', mode_single_led));

        elseif (strcmp(resp,'m')) % Toggle display mode
            mode_single_led = ~mode_single_led;
            disp(sprintf('Single LED mode: %d', mode_single_led));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extended input commands

        elseif (strcmp(resp,'ledval'))
            resp = input('LED Value: ');
            if (resp < maxVal && resp >= 0) x = resp; else
            disp('The LED intensity you specified is out of range.'); end
        elseif (strcmp(resp,'lcdval'))
            resp = input('LCD Value: ');
            if (resp < 256 && resp >= 0) 
                lcdx = resp; 
                img_fore = ones(1024,1280).*lcdx;
                texf = Screen('MakeTexture', d.windowPtr, img_fore  );
            else
                disp('The LCD intensity you specified is out of range.'); 
            end
        elseif (strcmp(resp, 'ledidx'))
            resp = input('LED Index (1-759): ');
            if (resp >= 1 && resp <= 759) 
                single_led_idx = resp;
            else
                disp('The LED index you specified is out of range.');
            end
        end


    end

catch
    if (ispc) 
        Screen('CloseAll');
    end
	rethrow(lasterror);
end

description=Screen('computer');
if strcmp('PCWIN',computer)
    pause(1);
    Screen('Close',d.windowPtr);

elseif strcmp('MAC2',computer)
else
    error('Unknown operating system.');
end
