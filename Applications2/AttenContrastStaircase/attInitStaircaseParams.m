function [stairParams] = attInitStaircaseParams(stimParams)

% name of expt
stairParams.conditionName           = {'ContrastMatch'};

% decision subject will make
stairParams.alternativeVarName      = 'upper_or_lower';

% decision values
stairParams.alternativeVarValues    = [1 2]; % 1 is upper, 2 is lower

% decision keys
stairParams.responseSet             = 'as';  % a is upper, s is lower

% variable that is adjusted by staircase
stairParams.adjustableVarName       = 'contrast_decrement';

% contrast decrement values of test probe
stairParams.adjustableVarValues     = stimParams.TestContrasts;

% put things in here to run the staircase separately for a given condition
stairParams.curStairVars            = {}; %{'testContrast',.5}; 

% put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
% stairParams.randomVars              = {'fixationSide', [-1 1]};  
stairParams.randomVars              = {...
    'start_frame', stimParams.StartFrames;...
    'probe_side', stimParams.LeftOrRight; ...
    'upper_or_lower_distractor', stimParams.UpperOrLowerDistractor};

% limit expt in case of lack of convergence
stairParams.maxNumTrials            = 200;

% end expt after this many reversals
stairParams.maxNumReversals         = 200;

% increment size for correct answers for each successive reversal (normally
% these numbers should go down as num reversals incr)
stairParams.correctStepSize         = -1 * [1 1 1 1 1 1 1 1 1 1]; %[-4 -3 -3 -2 -1];
stairParams.incorrectStepSize       =  1 * [1 1 1 1 1 1 1 1 1 1]; % [4 3 3 2 1];
stairParams.numIncorrectForStep     = 1;
stairParams.numCorrectForStep       = 2;

% auditory feedback?
stairParams.feedback                = 'none'; %{'auditory')

% display dur of stimulus on control screen
stairParams.showTiming              = false;


% intertrial interval in seconds
stairParams.iti = 0.5;

% This specifies the intitial value of the staircase, as an index into
% stairParams.alternativeVarValues. If there are multiple interleaved
% staircases, then we separately set the intial value for each staircase.
initIndex = round(length(stairParams.adjustableVarValues)/1.5);
if ~isempty(stairParams.curStairVars)
    stairParams.adjustableVarStart = repmat(initIndex, size(stairParams.curStairVars{2}));
else
    stairParams.adjustableVarStart = initIndex;
end
