function [data params] = etTest(rounds,duration,order,condition)

% use condition to create a stored string so you know what you instructed
% participants to do
% trials (self explanatory), duration (time to record in ms)

% Get display params
[display] = etInitDisplay;
% Calibrate eye tracking
[params] = calibrate(display);

% If participant quits out during calibration, quit whole program
if isfield(params,'quit'), closeScreen(display); return; end

% Store predicted screen positions of each calibration point
for i=1:9
    params.screenET(:,i) = params.xform * [params.xEye(i) params.yEye(i) 1]';
end

% Remove third row, unnecessary
params.screenET = params.screenET(1:2,:);

% Set up all trial params
params.order        = order;
params.duration     = duration;
params.condition    = condition;
stimFreq            = repmat([2 2 2 2 2],1,2);
distance            = repmat([0 2.5 2.5 2.5 2.5 0 5 5 5 5],1,1);
angle               = repmat([90 90 180 270 360],1,2);
trials              = sum(stimFreq);
saveStimFreq        = stimFreq;

% Loop over all trials
for block=1:(rounds*2)
    stimFreq = saveStimFreq;
    if order==1
        cond = (2-mod(block,2));
    elseif order==2
        cond = mod(block,2)+1;
    end
    % Display instructions as well as countdown to allow preparatory time
    etDisplayInstructions(display,cond);
    for i=1:trials
        % Get trial params
        whichStim                   = select(stimFreq);
        params.distance             = distance(whichStim);
        params.angle                = angle(whichStim);

        % Run trial
        trialDat                    = etRunTrial(display,params);

        % Process the fact that we've run that condition
        stimFreq(whichStim)         = stimFreq(whichStim) - 1;

        % Compute predicted locations of eyes during trial
        for ii=1:length(trialDat.horiz)
            [trialDat.screenLoc(:,ii)] = params.xform * [trialDat.horiz(ii) trialDat.vert(ii) 1]';
        end

        % Remove third row, unnecessary
        trialDat.screenLoc = trialDat.screenLoc(1:2,:);

        % Store trial data
        data.eyeMovs{i,block}               = trialDat.eyeMovs;
        data.horiz{i,block}                 = trialDat.horiz;
        data.vert{i,block}                  = trialDat.vert;
        data.angle{i,block}                 = params.angle;
        data.distance{i,block}              = params.distance;
        data.resp{i,block}                  = trialDat.resp;
        data.screenLoc{i,block}             = trialDat.screenLoc;
        data.cond{i,block}                  = cond; % 1 = fixate, 2 = look at stimuli
    end
end

% Clean up params variable
params = rmfield(params,'distance');
params = rmfield(params,'angle');

% Clear screen
sca;
    