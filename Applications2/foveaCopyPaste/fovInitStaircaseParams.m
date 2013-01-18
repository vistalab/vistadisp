function [stairParams] = fovInitStaircaseParams
% Set variables for fovStaircase
%
%

% ******************************
% ** Independent variables ***** 
% ******************************

% Each of these values gets a separate staircase
[distractorPos, shapeClass, stairParams.conditionName] = fovStairPermuations;
stairParams.curStairVars            = {'distractorPosition', distractorPos;
                                       'shapeClass', shapeClass};


% ******************************
% ** Random Variables **********
% ******************************

% These will be randomly changed by staircase. They are here to give the
% subject variety, but aren't expected to impact performance.
stimPositions                       = 15:15:180;  % angle (deg)
offsetDirs                          = 1;     %[-1 1]; % increase or decrease stimVal for discrimination 
matchReferenceOrOffset              = [1 2]; % on same sub-trials, either use (1) the referent stimulus or (2) the offset stimulus
stairParams.randomVars              = { 'stimulusPosition1', stimPositions;...
                                        'stimulusPosition2',stimPositions;...
                                        'offsetDir', offsetDirs;...
                                        'matchReferenceOrOffset', matchReferenceOrOffset ...
                                        };  

% ******************************
% ** Dependent variable ******** 
% ******************************
% Decision subject will make
stairParams.alternativeVarName      = 'firstOrSecond';

% Decision values
stairParams.alternativeVarValues    = ['1' '2'];

% Decision keys
stairParams.responseSet             = 'al';

% Variable that is adjusted by staircase
stairParams.adjustableVarName       = 'stimulusOffset';

% Values that parameterized shapes can take (difference between match and sample)
stairParams.adjustableVarValues     = 1:900;

% ******************************
% ** Staircase params ******** 
% ******************************
% Num right answers before stair val changes
stairParams.numCorrectForStep       = 2;

% Num wrong answers before stair val changes 
stairParams.numIncorrectForStep     = 1;

% Limit expt in case of lack of convergence
stairParams.maxNumTrials            = 800;

% End expt after this many reversals
stairParams.maxNumReversals         = 12;

% Increment size for correct answers for each successive reversal (normally
% these numbers should go down as num reversals incr)
%stairParams.incorrectStepSize       =  ([4 3 3 2 1]).^3;
stairParams.incorrectStepSize       =  ([200 100 50 25]);
stairParams.correctStepSize         = -stairParams.incorrectStepSize;

% ******************************
% ** Trial stuff *************** 
% ******************************

% Auditory feedback?
stairParams.feedback                = 'none'; %{'auditory')


% Display dur of stimulus on control screen -  huh?
stairParams.showTiming              = false;


% Intertrial interval in seconds
stairParams.iti                     = 0.5;

% start values of staircase variables (try to start at middle of range)
ind = round(length(stairParams.adjustableVarValues)/2);
val = stairParams.adjustableVarValues(ind);
stairParams.adjustableVarStart = repmat(val, 1 ,length(stairParams.curStairVars{end}));

end




% -------------------------------------------------------------------------
function [distractorPosition, shapeClass, name]    = fovStairPermuations
% Staircase variables
% [distractorPosition, shapeClass]    = fovStairPermuations
%
% The number of shape classes * the number of distractor positions is 
% the number of simultaneous interleaved staircases to run.
%       distractorPosition: 0 = none, 1 = foveal, 2 = parafoveal
%       shapeClasses: 1 = Circles, 2 = Squares, 3= shape silhouettes, etc.
%                       (defined as stimParams.shapeClasses in fovInitStimParams)
shapeClasses = [1 15];% 
distractorPositions = [0 1 2]; %[0 1 2]; %[1 2]; % [0 1 2]
ind     = 0;
for s = shapeClasses
   for d = distractorPositions;
       ind = ind+1;
       shapeClass(ind) = s; %#ok<*AGROW>
       distractorPosition(ind) = d; 
       name{ind} = sprintf('Class %d; Pos %d', s, d);
   end
end

end
