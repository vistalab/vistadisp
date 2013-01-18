function gp=gp_presentation(gp);
% pg_presentation - present Goldmann perimetry stimulus

% load mex functions
KbCheck;GetSecs;WaitSecs(0.001);


try,
    % check for OpenGL
    AssertOpenGL;
    
    % Open the screen
    gp.display                = openScreen(gp.display);

    % wait for go signal
    Screen('FillRect', gp.display.windowPtr, gp.display.backColorRgb);
    drawFixation(gp.display);
    Screen('Flip',gp.display.windowPtr);
    HideCursor;
    pause;
    quitProg = 0;
    
    % determines direction sign
    for n=1:2, % 
        dirorder = randperm(length(gp.dot.coord));
        % determines path
        for dir=dirorder,
            direction = 1:size(gp.dot.coord(dir).coords,2);
            if n==2,
                direction = fliplr(direction);
            end
            % for each pixel in path
            for d = direction,
                % display dot
                xdot = gp.dot.coord(dir).coords(1,d);
                ydot = gp.dot.coord(dir).coords(2,d);
                drawFixation(gp.display);
                Screen('gluDisk', gp.display.windowPtr, gp.dot.colorRgb, ...
                        xdot, ydot, gp.dot.size);
                Screen('Flip',gp.display.windowPtr);
                WaitSecs(gp.dot.timePerPixel);
                
                % subjects response
                [exKeyIsDown,exSecs,exKeyCode] = KbCheck(gp.devices.keyInputExternal);
                if(exKeyIsDown),
                    if(exKeyCode(gp.display.quitProgKey)),
                        quitProg = 1;
                        break; % out of while loop
                    else, % dot detected
                        gp.response.coordDetected(ydot,xdot) = gp.response.coordDetected(ydot,xdot)+1;
                    end;
                end;
                
                % keep track of how many times is shown
                gp.response.coordShown(ydot,xdot) = gp.response.coordShown(ydot,xdot)+1;
                
                % successive breaks if quit is requested.
                if quitProg, 
                    break;
                end;
            end;
            if quitProg,
                break;
            end;
        end;
        if quitProg,
            break;
        end;
    end;
    
    % close
    ShowCursor;
    closeScreen(gp.display);
catch,
    Screen('CloseAll');
    setGamma(0);
    ShowCursor;
    rethrow(lasterror);
end;
