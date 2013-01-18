% Measure Human Dynamic Range with a flash-probe test
%
% Begun 15 Mar 2006 gregng
% QuestDemo.m
%
% By commenting and uncommenting five lines below, you can use
% this file to implement three QUEST-related procedures for measuring
% threshold.
%
% QuestMode: In the original algorithm of Watson & Pelli (1983)
% each trial and the final estimate are at the MODE of the posterior pdf.
%
% QuestMean: In the improved algorithm of King-Smith et al. (1994).
% each trial and the final estimate are at the MEAN of the posterior pdf.
%
% QuestQuantile & QuestMean: In the ideal algorithm of Pelli (1987)
% each trial is at the best QUANTILE, and the final estimate is at 
% the MEAN of the posterior pdf.
%
% King-Smith, P. E., Grigsby, S. S., Vingrys, A. J., Benes, S. C., and Supowit, A.
% (1994) Efficient and unbiased modifications of the QUEST threshold method: theory, 
% simulations, experimental evaluation and practical implementation. 
% Vision Res, 34 (7), 885-912.
%
% Pelli, D. G. (1987) The ideal psychometric procedure. Investigative Ophthalmology 
% & Visual Science, 28 (Suppl), 366.
%
% Watson, A. B. and Pelli, D. G. (1983) QUEST: a Bayesian adaptive psychometric 
% method. Percept Psychophys, 33 (2), 113-20.
% Copyright (c) 1996-9 Denis G. Pelli
%
% 3/3/97  dhb  Cosmetic editing.
% NOTE: GetSecs.mex is part of the Psychophysics Toolbox and only works on
% Macs.  If you are running QuestDemo on some other machine, use CPUTIME 
% instead of GetSecs.
%fprintf('The intensity scale is abstract, but usually we think of it as representing log contrast.\n');
% Do approximations of the screen command.
TestMode = 1;
% We'll need this for the simulation.
tActual=input('[questdemo] Specify true threshold of simulated observer: ');
% Get psychometric function parameters.
tGuess=input('Estimate threshold: ');
tGuessSd=2.0; % sd of Gaussian before clipping to specified range
pThreshold=0.82;
beta=3.5;delta=0.01;gamma=0.5;
q=QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);
% fprintf('Your initial guess was %g ± %g\n',tGuess,tGuessSd);
% fprintf('Quest''s initial threshold estimate is %g ± %g\n',QuestMean(q),QuestSd(q));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the stimulus
% Terms:
% The adaptive field is the ambient area that surrounds the main field.
% Within the main field is a flash, and within that flash is a probe that
% we are trying to figure out.
intensityAdaptiveField_cdm2 = 1;  % cd/m^2
intensityMainField_cdm2 = 0.5;      % cd/m^2
intensityFlash_cdm2 = 20;          % cd/m^2
durationFlash = 0.5;
sizeFlash = 100; % size of the flash in pixels
sizeProbe = 50;
% Nominal LCD level. This is the level that we set
% the front LCD to.  This gives us enough headroom to flash the
% threshold probe.  
% If you set it too high, you won't be able to make the probe bright enough.
% If you set it too low, you may overdrive the LEDs and cause variation in the power.
LCDLevel_MainField = 128; 
screen_w = 1280;
screen_h = 1024;
% TODO: (xc,yc) = ledpos(387)
yc = screen_h/2;
xc = screen_w/2;
[xgrid ygrid] = meshgrid(1:1280, 1:1024);
% This probably ought to be a function.  Probably using interp2
gamma_led = 1:255;
% Back LED image.  This will have to be modified.
patBackLED = (xgrid > (xc-sizeFlash/2)) .* (xgrid < (xc+sizeFlash/2)) ...
	.* (ygrid > (yc-sizeFlash/2)) .* (ygrid < (yc+sizeFlash/2));
	
%imageBackLED = intensityAdaptiveField .* patBackLED;
intensityAdaptiveField_back_dv = 30 .* (intensityAdaptiveField_cdm2 / 100);
imageBackLED = intensityAdaptiveField_back_dv .* patBackLED;
imageFrontLCD = LCDLevel_MainField.* patBackLED; 
% imageFrontLCD( (yc-sizeFlash/2+1):(yc+sizeFlash/2),  (xc-sizeFlash/2+1):(yc+sizeFlash/2) ) = LCDLevel_MainField;
%imageFrontLCD( :, : ) = LCDLevel_MainField;
%% TODO: make this what it ought to be
% This is 0 for emphasis.
imageFrontLCD_blank = zeros(size(imageFrontLCD));
% Use the gamma curve to figure out what LED setting is necessary
% in combination with LCD = LCDLevel_MainField to achieve a particular luminance.
% TODO: load gamma curves
% TODO: ambient conditions (viewing distance, etc)
try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set up the PsychToolbox screen
    
    if (TestMode == 0)
        if (ispc)
            d = loadDisplayParams('displayName','hdr1');
            d.screenNumber = 0;
            d = openScreen(d);
        elseif (exist('d') ~= 1)
            % HDR2 is the PC
            d = loadDisplayParams('displayName','hdr1');
            d = openScreen(d);
        end
    elseif (TestMode == 1)
        d = [0];
        figure(1); title('Screen Output Sim');
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Simulate a series of trials.
    trialsDesired=10;
    wrongRight=str2mat('wrong','right');
    timeZero=GetSecs;
    for k=1:trialsDesired
        % Get recommended level.  Choose your favorite algorithm.
        tTest=QuestQuantile(q);
        %tTest=QuestMean(q);
        %tTest=QuestMode(q);
        %tTest=tTest+Sample([-0.1,0,0.1]);
        % Simulate a trial
        timeSplit=GetSecs; % omit simulation and printing from reported time/trial.
        % TODO: fix the units.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Construct the probe image based on the current threshold
        % TODO: incorporate gamma function
        % TODO: move this line out of the loop?
        % TODO: should it be tTest or (1+tTest)?
        imageFrontLCD_probe = imageFrontLCD;
        imageFrontLCD_probe( ...
            (yc-sizeProbe/2+1):(yc+sizeProbe/2), ...
            (xc-sizeProbe/2+1):(xc+sizeProbe/2)) = round(tTest*LCDLevel_MainField);
        imageBackLED_probe = imageBackLED;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
        flash_idx = floor(rand()*2);
        % TODO: refactor this so that we don't have 
        % to compute the hdrCart2LED every time.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show the flash for the 1st period
        if (flash_idx == 0) 
            disp('   period1 Showing probe flash');
            hdrPutImage(d, imageFrontLCD_probe, imageBackLED_probe, 0, TestMode);
        else
            disp('   period1 Showing regular flash');
            hdrPutImage(d, imageFrontLCD, imageBackLED, 0, TestMode);
        end
        beep;
        if (TestMode==0)
            Screen('Flip', d.windowPtr);
        else 
            pause(0.1);
        end
        t0 = clock;
        hdrPutImage(d, imageFrontLCD_blank, imageBackLED, 0, TestMode);
        while (etime(clock,t0) < durationFlash)
            % Do nothing.
        end
        if (TestMode==0)
            Screen('Flip', d.windowPtr);
        else 
            pause(0.1);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show the flash for the 2nd period
        if (flash_idx == 1) 
            disp('   period2 Showing probe flash');
            hdrPutImage(d, imageFrontLCD_probe, imageBackLED, 0, TestMode);
        else
            disp('   period2 Showing regular flash');
            hdrPutImage(d, imageFrontLCD, imageBackLED, 0, TestMode);
        end
        beep; pause(0.1); beep;
        if (TestMode==0)
            Screen('Flip', d.windowPtr);
        else 
            pause(0.1);
        end
        t0 = clock;
        hdrPutImage(d, imageFrontLCD_blank, imageBackLED, 0, TestMode);
        while (etime(clock,t0) < durationFlash)
            % Do nothing.
        end
        if (TestMode==0)
            Screen('Flip', d.windowPtr);
        else 
            pause(0.1);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Collect the input
        response=QuestSimulate(q,tTest,tActual);
    
        fprintf('Trial %3d at %4.1f is %s\n',k,tTest,wrongRight(response+1,:));
        timeZero=timeZero+GetSecs-timeSplit;
        % Update the pdf
        q=QuestUpdate(q,tTest,response);
        
        
    end
    if (TestMode == 0) 
        if (ispc)
        Screen('Close');
        end
    end
        
    % Print results of timing.
    fprintf('%.0f ms/trial\n',1000*(GetSecs-timeZero)/trialsDesired);
    % Get final estimate.
    t=QuestMean(q);
    sd=QuestSd(q);
    fprintf('Mean threshold estimate is %4.2f ± %.2f\n',t,sd);
    %t=QuestMode(q);
    %fprintf('Mode threshold estimate is %4.2f\n',t);
    %fprintf('\nQuest beta analysis. Beta controls the steepness of the Weibull function.\n');
    QuestBetaAnalysis(q); % optional
    fprintf('Actual parameters of simulated observer:\n');
    fprintf('logC	beta	gamma\n');
    fprintf('%5.2f	%4.1f	%5.2f\n',tActual,q.beta,q.gamma);
catch
    if (ispc && TestMode == 0) 
        Screen('CloseAll');
    end
	rethrow(lasterror);
end
