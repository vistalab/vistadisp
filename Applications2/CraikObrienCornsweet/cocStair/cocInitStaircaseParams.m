function [stairParams] = cocInitStaircaseParams

% name of expt
stairParams.conditionName           = {'ContrastMatch'};

% decision subject will make
stairParams.alternativeVarName      = 'MatchFirstOrSecond';

% decision values
stairParams.alternativeVarValues    = ['1' '2'];

% decision keys
stairParams.responseSet             = 'al';

% variable that is adjusted by staircase
stairParams.adjustableVarName       = 'edgeAmplitdue';

% values that edge amplitude can take
stairParams.adjustableVarValues     = (1:40)/100;

% put things in here to run the staircase separately for a given condition
stairParams.curStairVars            = {'testContrast',[.05 .1 .2]}; 

% put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
stairParams.randomVars              = {'fixationSide', [-1 1]};  

% num right answers before stair val changes
stairParams.numCorrectForStep       = 1;

% num wrong answers before stair val changes
stairParams.numIncorrectForStep     = 1;

% limit expt in case of lack of convergence
stairParams.maxNumTrials            = 200;

% end expt after this many reversals
stairParams.maxNumReversals         = 10;

% increment size for correct answers for each successive reversal (normally
% these numbers should go down as num reversals incr)
stairParams.correctStepSize         = [-4 -3 -3 -2 -1];
stairParams.incorrectStepSize       = [4 3 3 2 1];

% auditory feedback?
stairParams.feedback                = 'none'; %{'auditory')

% display dur of stimulus on control screen
stairParams.showTiming              = false;


% intertrial interval in seconds
stairParams.iti = 0.5;

% don't udnerstand this (copied from word staircase expt)
if(~isempty(stairParams.curStairVars))
    stairParams.adjustableVarStart = repmat(2, size(stairParams.curStairVars{2}));
else
    stairParams.adjustableVarStart = 2;
end
