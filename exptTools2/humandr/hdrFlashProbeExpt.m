function data = hdrFlashProbeExpt(flashLUM)

if(~exist('flashLUM','var') || isempty(flashLUM))
    flashLUM = 0.75;
end

thresh_method = 2;

d = loadDisplayParams('hdr1');
d.screenNumber = 0;
d = openScreen(d);

hdrDisplay.ledSlope = 1;
hdrDisplay.ledMax   = 200;
hdrDisplay.lcdGamma = 2.6;
hdrDisplay.lcdMax   = 255;

% Set up the location of the stimulus (which LED to use, position)
stim.ledCenter = [8 24];
stim.lcdCenter = [640 512];

% lum is the absolute luminance (which is then gamma corrected)
adaptField.led.lum = 0.5;
adaptField.led.level = hdrLedLinearCorrect(adaptField.led.lum, ...
    hdrDisplay.ledSlope, hdrDisplay.ledMax);
adaptField.lcd.lum = 0.5;
adaptField.lcd.level = hdrLcdGammaCorrect(adaptField.lcd.lum, ...
    hdrDisplay.lcdGamma, hdrDisplay.lcdMax);
    
% generate led index for the adapting field
% alternating horizontal lines with 3 leds
% Adapting field measured 3/18/06 to be 965.6 cd/m2
adaptField.led.x = [ repmat([stim.ledCenter(1)-1:stim.ledCenter(1)+1],1,5), ...
    repmat([stim.ledCenter(1):stim.ledCenter(1)+1],1,4) ];
adaptField.led.y = [ repmat([stim.ledCenter(2)-4:2:stim.ledCenter(2)+4],1,3), ...
    repmat([stim.ledCenter(2)-3:2:stim.ledCenter(2)+3],1,2) ];
    
adaptField.led.im = zeros(46,17);
adaptField.led.im(adaptField.led.y,adaptField.led.x) = adaptField.led.level;
adaptField.lcd.im = ones(1024,1280)*adaptField.lcd.level;
adaptField.im = adaptField.lcd.im;
adaptField.im(2,:) = hdrCart2Led(adaptField.led.im);
adaptField.texture = Screen('MakeTexture', d.windowPtr, adaptField.im);

% Generate the LED and LCD patterns for the flash field
flash.led.lum = flashLUM;
flash.led.level = hdrLedLinearCorrect(flash.led.lum, ...
    hdrDisplay.ledSlope, hdrDisplay.ledMax);
% generate led index for the flash
flash.led.x = [ repmat([stim.ledCenter(1)-1:stim.ledCenter(1)+1],1,2), ...
    repmat(stim.ledCenter(1),1,3) ];
flash.led.y = [ repmat([stim.ledCenter(2)-1:stim.ledCenter(2)+1],1,2), ...
    stim.ledCenter(2) stim.ledCenter(2)-2 stim.ledCenter(2)+2 ];
flash.led.im = adaptField.led.im;
flash.led.im(flash.led.y,flash.led.x) = flash.led.level;

flash.lcd.lum = adaptField.lcd.lum;
flash.lcd.level = hdrLcdGammaCorrect(flash.lcd.lum, ...
    hdrDisplay.lcdGamma, hdrDisplay.lcdMax);
flash.im = ones(1024,1280)*flash.lcd.level;
%flash.im = adaptField.lcd.im;

flash.im(2,:) = hdrCart2Led(flash.led.im);
flash.texture = Screen('MakeTexture', d.windowPtr, flash.im);

probe.sizeInPixels = 10;
[probe.lcd.x probe.lcd.y] = meshgrid(stim.lcdCenter(1)-round(probe.sizeInPixels/2):stim.lcdCenter(1)+round(probe.sizeInPixels/2),...
    stim.lcdCenter(2)-round(probe.sizeInPixels/2):stim.lcdCenter(2)+round(probe.sizeInPixels/2));

% Set up the Quest and probe parameters
data.probe.init.thresGuess = -1; % log10 delta
data.probe.init.thresGuessSd = 2;
data.probe.init.beta = 3.5;    % 
data.probe.init.lapse = 0.01;  % gamma; chance of error
data.probe.init.PChance = 0.5; % chance of correct guess at random
data.thresLevel = 0.8;         % percent correct needed for this Quest
data.trialNum = 10;             % Number of trials ntrials
data.flashLum = flashLUM;
data.threshMethod = thresh_method;

data.quest = QuestCreate(data.probe.init.thresGuess,data.probe.init.thresGuessSd,...
    data.thresLevel,data.probe.init.beta,data.probe.init.lapse,data.probe.init.PChance,0.01);

data.quest.normalizePdf=1;

% Draw the adapting field 
% (only needed on the first run, because showStimulus handles this for us)
% Moving outside the loop reduces false flickers
Screen('DrawTexture', d.windowPtr, adaptField.texture, d.rect, d.rect);
Screen('Flip', d.windowPtr);

for cTrial=1:data.trialNum

    data.trials(cTrial).log10Delta = QuestQuantile(data.quest);
    if (thresh_method == 1) % 3/17/2006
        % Method 1 (disabled)
        % Make the probe intensity ledlum*(10^log10Delta luminance units brighter)
        probe.lcd.lum = adaptField.lcd.lum + 10^data.trials(cTrial).log10Delta;
        if (probe.lcd.lum > 1.0)
            probe.lcd.lum = 1.0;
            % Compute corresponding luminance
            log10d = log10(probe.lcd.lum - adaptField.lcd.lum);
            data.trials(cTrial).log10Delta = log10d;
        end

    else % 3/18/2006
        % Method 2:
        % Make the probe intensity 10^log10Delta percent brighter
        % probe.lcd.lum = adaptField.lcd.lum + 
        % 10^data.trials(cTrial).log10Delta .* adaptField.lcd.lum;
        probe.lcd.lum = adaptField.lcd.lum .* (1 + 10^data.trials(cTrial).log10Delta);

        if (probe.lcd.lum > 1.0)
            probe.lcd.lum = 1.0;
            % Compute corresponding luminance
            log10d = log10(probe.lcd.lum / adaptField.lcd.lum - 1);
            data.trials(cTrial).log10Delta = log10d;
        end
        
    end
    
        
    
    probe.lcd.level = hdrLcdGammaCorrect(probe.lcd.lum, ...
        hdrDisplay.lcdGamma, hdrDisplay.lcdMax);
    probe.lcd.im = adaptField.lcd.im;
    probe.lcd.im(probe.lcd.y(:),probe.lcd.x(:)) = probe.lcd.level;
    probe.im = probe.lcd.im;
    probe.im(2,:) = hdrCart2Led(flash.led.im);
    probe.texture = Screen('MakeTexture', d.windowPtr, probe.im);

    % Show the flash during what interval?
    data.trials(cTrial).interval = round(rand)+1;
    data.trials(cTrial).probeLcdLevel = probe.lcd.level;
    data.trials(cTrial).flashLcdLevel = flash.lcd.level;
    
    if (probe.lcd.level == flash.lcd.level)
        disp('Warning: probe level = flash level');
    end
    
    if(data.trials(cTrial).interval==1)
        firstInterval.texture = probe.texture;
        secondInterval.texture = flash.texture;
    else
        firstInterval.texture = flash.texture;
        secondInterval.texture = probe.texture;
    end
    
    
    % Pause key is handled internally
    % pause();
    showStimulus(d, flash, firstInterval, adaptField, 1);
    % Inter-stimulus pause is handled internally
    % pause(0.5);
    showStimulus(d, flash, secondInterval, adaptField, 2);
    

%    % Prepare the flash field
%    Screen('DrawTexture', d.windowPtr, flash.texture, d.rect, d.rect);
%    pause;

%    beep;
%    t0 = clock;
%    Screen('Flip', d.windowPtr);
%    t1 = clock;
%    Screen('DrawTexture', d.windowPtr, firstInterval.texture, d.rect, d.rect);
%    while(etime(clock,t1)<0.25),end  
%    Screen('Flip', d.windowPtr);
%    t2 = clock;
%    Screen('DrawTexture', d.windowPtr, flash.texture, d.rect, d.rect);
%    while(etime(clock,t2)<0.05),end
%    Screen('Flip', d.windowPtr);
%    Screen('DrawTexture', d.windowPtr, adaptField.texture, d.rect, d.rect);
%    while(etime(clock,t0)<0.5),end
%    Screen('Flip', d.windowPtr);

%    Screen('DrawTexture', d.windowPtr, flash.texture, d.rect, d.rect);
%    pause(0.5);

%    beep; pause(0.15); beep;
%    t0 = clock;
%    Screen('Flip', d.windowPtr);
%    t1 = clock;
%    Screen('DrawTexture', d.windowPtr, secondInterval.texture, d.rect, d.rect);
%    while(etime(clock,t1)<0.25),end
%    Screen('Flip', d.windowPtr);
%    t2 = clock;
%    Screen('DrawTexture', d.windowPtr, flash.texture, d.rect, d.rect);
%    while(etime(clock,t2)<0.05),end
%    Screen('Flip', d.windowPtr);
%    Screen('DrawTexture', d.windowPtr, adaptField.texture, d.rect, d.rect);
%    while(etime(clock,t0)<0.5),end
%    Screen('Flip', d.windowPtr);

    % Get key.
    % gregng: Actually, I don't understand how noAns gets set.
    FlushEvents('keyDown');
    noAns = 1;
    cKey = [];
    while(noAns)
        [keyIsDown,secs,keyCode] = KbCheck;
        cKeyCode = find(keyCode);
        if(~isempty(cKeyCode))
            cKey = KbName(cKeyCode(1));
        end
        if(~isempty(cKey) & (str2num(cKey)==1 | str2num(cKey)==2)), noAns = 0; end;
    end
    FlushEvents('keyDown');

    data.trials(cTrial).response = (str2num(cKey)==data.trials(cTrial).interval);
    data.quest = QuestUpdate(data.quest,data.trials(cTrial).log10Delta,data.trials(cTrial).response);

end

% Save data with default name
filename = sprintf('humandr_lum_%d_%s', round(data.flashLum*1000), datestr(now,30));
save(filename,'data');



Screen('closeall')

return;

% flashStimulus is the stimulus for the normal flash
% intervalStimulus is the "stimulus" structure as defined above
% adaptFieldStimulus is the stimulus for the adapting field

% This routine 

% beeps once or twice, 
% [0,0.25] displays flash stimulus
% (0.25,0.25+0.05] displays the interval stimulus, 
% (0.30,0.50] displays the flash stimulus
function retcode = showStimulus(d,flashStimulus, intervalStimulus, adaptFieldStimulus, interval)
    
    % Prep the flash texture
    Screen('DrawTexture', d.windowPtr, flashStimulus.texture, d.rect, d.rect);
    
    if (interval == 1)
        pause; % Wait for a key
        beep;
    else
        pause(0.5); % Just wait for half a second.
        beep; pause(0.15); beep;
    end

    % Draw the flash 
    t0 = clock;
    Screen('Flip', d.windowPtr);

    % Draw the probe (or non probe)
    t1 = clock;
    Screen('DrawTexture', d.windowPtr, intervalStimulus.texture, d.rect, d.rect);
    while(etime(clock,t1)<0.25),end  
    Screen('Flip', d.windowPtr);

    t2 = clock;
    Screen('DrawTexture', d.windowPtr, flashStimulus.texture, d.rect, d.rect);
    while(etime(clock,t2)<0.05),end
    Screen('Flip', d.windowPtr);

    % Reset to adapting field
    Screen('DrawTexture', d.windowPtr, adaptFieldStimulus.texture, d.rect, d.rect);
    while(etime(clock,t0)<0.5),end
    Screen('Flip', d.windowPtr);

return


function cKey = getAnyKey
    % Get key
    FlushEvents('keyDown');
    noAns = 1;
    cKey = [];
    while(noAns)
        [keyIsDown,secs,keyCode] = KbCheck;
        cKeyCode = find(keyCode);
        if(~isempty(cKeyCode))
            cKey = KbName(cKeyCode(1));
        end
        %if(~isempty(cKey) & (str2num(cKey)==1 | str2num(cKey)==2)), noAns = 0; end;
    end
    FlushEvents('keyDown');
return