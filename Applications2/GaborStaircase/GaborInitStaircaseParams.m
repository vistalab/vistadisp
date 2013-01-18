function stairParams = GaborInitStaircaseParams(display)

% name of expt
stairParams.conditionName           = {'contrast detect'};

% decision subject will make
%stairParams.alternativeVarName      = 'testPosition'; 
%stairParams.alternativeVarName      = 'present';
stairParams.alternativeVarName      = 'orientDegrees';

% decision values
switch stairParams.alternativeVarName
    case 'testPosition'
        stairParams.alternativeVarValues    = ['L' 'R'];
    case 'orientDegrees'
        stairParams.alternativeVarValues    = [0 90];
    case 'present'
        stairParams.alternativeVarValues    = [1 0];
end

% decision keys
stairParams.responseSet             = 'zm';

% variable that is adjusted by staircase
stairParams.adjustableVarName       = 'contrast';

% values that staircase variable can take
%   With 10-bits, the minimum contrast is just about 0.001 (the exact value
%   depends on your gamma correction). Most 10-bit systems should be able
%   to achieve 0.0016 (10^-2.8), and many can hit 0.001 (10^-3)
stairParams.adjustableVarValues     = 10.^(0:-.2:-3);

% put things here to randomly vary the value e.g. {'formDir',[0 90 180 270]}
stairParams.randomVars              = {};

% put things in here to run interleaved staircases 
stairParams.curStairVars = {'cyclesPerDegree',[.25 1 2]};

% num right answers before stair val changes
stairParams.numCorrectForStep       = 2;

% num wrong answers before stair val changes
stairParams.numIncorrectForStep     = 1;

% limit expt in case of lack of convergence
stairParams.maxNumTrials            = 75;

% end expt after this many reversals
stairParams.maxNumReversals         = 8;

% increment size for correct answers for each successive reversal (normally
% these numbers should go down as num reversals incr)
stairParams.correctStepSize         = [4 3 3 2 1];
stairParams.incorrectStepSize       = -1 * stairParams.correctStepSize;

% auditory feedback?
stairParams.feedback = 'auditory';

% intertrial interval in seconds
stairParams.iti = 0.25;

% ??
stairParams.adjustableVarStart = repmat(2, size(stairParams.curStairVars{2}));

% Check whether spatial frequency range is within display capability
maxSF = 1/pix2angle(display,2);
fprintf('Maximum spatial frequency (SF) with current display params = %0.2f CPD.\n', maxSF);
if(max(stairParams.curStairVars{2})>maxSF)
    error('Requested spatial frequency exceeds maximum.');
elseif(max(stairParams.curStairVars{2})>maxSF/1.5)
    disp('Requested SF exceeds max/2; stimulus SF and phase will be adjusted.');
end
