function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.
% 11.09.15 JW added a check for modality. If modality is ECoG, then call
%           ShowScanStimulus with the argument timeFromT0 == false. See
%           ShowScanStimulus for details. 

% defaults
if ~exist('params', 'var'), error('No parameters specified!'); end
if ~isfield(params, 'skipSyncTests'), skipSyncTests = true;
else                                  skipSyncTests = params.skipSyncTests; end

% make/load stimulus
stimulus = retLoadStimulus(params);

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
    AssertOpenGL;
    
    % to skip annoying warning message on display (but not terminal)
    Screen('Preference','SkipSyncTests', skipSyncTests);
    
    % Open the screen
    params.display                = openScreen(params.display);
    params.display.devices        = params.devices;
    
    % to allow blending
    Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    % Store the images in textures
    stimulus = createTextures(params.display,stimulus);
    
    % If necessary, flip the screen LR or UD  to account for mirrors
    % We now do a single screen flip before the experiment starts (instead
    % of flipping each image). This ensures that everything, including
    % fixation, stimulus, countdown text, etc, all get flipped.
    retScreenReverse(params, stimulus);
            
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        retResetColorMap(params);
        
        % wait for go signal
        onlyWaitKb = false;
        time0Stim = pressKey2Begin(params.display, onlyWaitKb, [], [], params.triggerKey);


        % If we are doing ECoG/MEG/EEG, then initialize the experiment with
        % a patterned flash to the photodiode
        stimulus.flashTimes = retInitDiode(params);
        
        % countdown + get start time (time0)
        time0Scan = countDown(params.display,params.countdown,params.startScan, params.trigger);
        time0Scan = time0Scan + params.startScan; % we know we should be behind by that amount
                  
        switch lower(params.trigger)
            case {'scanner triggers computer' 'no trigger (manual)'}
                time0 = time0Stim; 
            case 'computer triggers scanner'            
                time0 = time0Scan;
            otherwise
                error('Unknown trigger condition')
        end
        [response, timing, quitProg] = showScanStimulus(params.display,stimulus,time0); %#ok<ASGLU>
                
        % reset priority
        Priority(0);
        
        % get performance
        [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        fprintf('[%s]: percent correct: %.1f %%, reaction time: %.1f secs',mfilename,pc,rc);
        
        % save
        if params.savestimparams,
            filename = ['~/Desktop/' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.',mfilename,filename);
        end;
        
        % don't keep going if quit signal is given
        if quitProg, break; end;
        
    end;
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);

catch ME
    % clean up if error occurred
    Screen('CloseAll'); 
    setGamma(0); Priority(0); ShowCursor;
    %warning(ME.identifier, ME.message);
    rethrow(ME)
end;


return;








