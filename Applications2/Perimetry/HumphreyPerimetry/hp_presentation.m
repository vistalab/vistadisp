function gp=hp_presentation(gp);
% pg_presentation - present Goldmann perimetry stimulus

% load mex functions
KbCheck;GetSecs;WaitSecs(0.001);

% calibration
try,
    f=load('/Applications/MATLAB72/displays/Yoichiros_Monitor/gamma.mat');
    mycal = f.gamma(round(linspace(1,1024,256)),:);
catch
    mycal = ([0:255]'*[1 1 1])./255;
end    
    
try,
    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    % Screen('Preference','SkipSyncTests', 1);
    
    % Open the screen
    gp.display = openScreen(gp.display);

    
    % wait for go signal
    Screen('FillRect', gp.display.windowPtr, gp.display.backColorRgb);
    drawFixation(gp.display);
    Screen('LoadNormalizedGammaTable', gp.display.windowPtr, mycal);
    Screen('Flip',gp.display.windowPtr);
    HideCursor;
    pause;
    quitProg = 0;
    keepwaiting = 1;
    nFalseShown = 0;
    nFalseDetected = 0;
    randOrder = randperm(size(gp.dot.coord(1).coords_wBlanks,2));
    
    gp.response.coordShown    = zeros(1,size(gp.dot.coord(1).coords,2));
    gp.response.coordDetected = zeros(1,size(gp.dot.coord(1).coords,2));
    
    % for each pixel in path
    for rep=1:gp.dot.measurementsPerDot,
        randOrder = randperm(size(gp.dot.coord(1).coords_wBlanks,2));
        for d = 1:numel(randOrder),
            % wait at least a little to cross does not mask stimulus dot.
            WaitSecs(0.5);
            
            dotIndex = randOrder(d);
            
            % get dot coordinates
            xdot = gp.dot.coord(1).coords_wBlanks(1,dotIndex);
            ydot = gp.dot.coord(1).coords_wBlanks(2,dotIndex);
            % replace blank displays for stimulus, and 
            % dots that have been correctly detected more than 3 times 
            % with dots that have a detection rate 20<=80
            try, % some random bug about here
            if (rep>2 & isnan(xdot) & rand<0.7),
                tmpperformance = gp.response.coordDetected./gp.response.coordShown;
                ii = find(tmpperformance<=0.3);
                if ~isempty(ii),
                    % pick the coord that has been shown the least
                    iii = find(gp.response.coordShown(ii)==min(gp.response.coordShown(ii)));
                    ii = ii(iii);
                    % pick random one and show again
                    ri = randperm(numel(ii));
                    dotIndex = ii(ri(1));
                    xdot = gp.dot.coord(1).coords(1,dotIndex);
                    ydot = gp.dot.coord(1).coords(2,dotIndex);
                end;
            elseif (rep>3 & gp.response.coordDetected(dotIndex)==gp.response.coordShown(dotIndex) & rand<0.7),
                tmpperformance = gp.response.coordDetected./gp.response.coordShown;
                ii = find(tmpperformance>=0.3 & tmpperformance<=0.9);
                if ~isempty(ii),
                    % pick the coord that has been shown the least
                    iii = find(gp.response.coordShown(ii)==min(gp.response.coordShown(ii)));
                    ii = ii(iii);
                    % pick random one and show again
                    ri = randperm(numel(ii));
                    dotIndex = ii(ri(1));
                    xdot = gp.dot.coord(1).coords(1,dotIndex);
                    ydot = gp.dot.coord(1).coords(2,dotIndex);
                end;
            end;
            end;
            
            % draw stimulus
            drawFixation(gp.display,1);
            if ~isnan(xdot),
                Screen('gluDisk', gp.display.windowPtr, gp.dot.colorRgb, ...
                    xdot, ydot, gp.dot.size);
            end;
            Screen('Flip',gp.display.windowPtr);
            sound(sin(linspace(0,2*pi*30,1000)));
            WaitSecs(gp.dot.timePerPixel);
            
            Screen('FillRect', gp.display.windowPtr, gp.display.backColorRgb);
            drawFixation(gp.display,2);
            Screen('Flip',gp.display.windowPtr);

            % keep track of how many times is shown
            if ~isnan(xdot),
                gp.response.coordShown(dotIndex) = gp.response.coordShown(dotIndex)+1;
            else,
                nFalseShown = nFalseShown + 1;
            end;
            %--- get inputs (subject or experimentor)
            keepwaiting = 1;
            while(keepwaiting),
                % subjects response
                [exKeyIsDown,exSecs,exKeyCode] = KbCheck(gp.devices.keyInputExternal);
                if(exKeyIsDown),
                    exKey = lower(KbName(exKeyCode));
                    for n=1:numel(exKey),
                        try,
                            if ~isempty(findstr(exKey,gp.display.yesKey)),
                                if ~isnan(xdot),
                                    gp.response.coordDetected(dotIndex) = gp.response.coordDetected(dotIndex)+1;
                                else,
                                    nFalseDetected = nFalseDetected + 1;
                                end;
                                drawFixation(gp.display,1);
                                Screen('Flip',gp.display.windowPtr);
                                keepwaiting = 0;
                            elseif ~isempty(findstr(exKey,gp.display.noKey)),
                                drawFixation(gp.display,1);
                                Screen('Flip',gp.display.windowPtr);
                                keepwaiting = 0;

                            end;
                        end;
                    end;
                    % to remove the subjects input from the command line
                    %fprintf(1,'\b');
                    %FlushEvents('keyDown');
                end;

                % experimentor's input
                [exKeyIsDown,exSecs,exKeyCode] = KbCheck(gp.devices.keyInputInternal);
                if(exKeyIsDown),
                    if(exKeyCode(gp.display.quitProgKey)),
                        quitProg = 1;
                        break; % out of while loop
                    end;
                end;

                % give time back to cpu
                WaitSecs(0.01);

            end;
            % successive breaks if quit is requested.
            if quitProg,
                break;
            end;
        end;
        % successive breaks if quit is requested.
        if quitProg,
            break;
        end;
        disp(sprintf('\n[%s]:Done repetition set %d/%d',mfilename,rep,gp.dot.measurementsPerDot));
        save('~/Desktop/hptmp.mat');drawnow;
    end;
    % close
    ShowCursor;
    closeScreen(gp.display);
    disp(sprintf('\n[%s]:Percentage of false positives %.1f%% (%d).',mfilename,nFalseDetected./nFalseShown.*100,nFalseShown));
    % store false positive rate
    gp.falsepositive.shown = nFalseShown;
    gp.falsepositive.detected = nFalseDetected;
    gp.falsepositive.rate  = nFalseDetected./nFalseShown;
catch,
    Screen('CloseAll');
    setGamma(0);
    ShowCursor;
    rethrow(lasterror);
end;
