% Script for running response sorting experiment for either detection or
% lexical decision.

maxRuns = 10;  % this is the number of runs per subject within detection or within lexical decision
exptChoice = input('\nDo you want to run (1) detection (word/noise) or (2) lexical decision (word/nonword)?  ');
if exptChoice == 1, exptType = 'detect'; elseif exptChoice == 2, exptType = 'lexical'; else exptType = 'NA'; end

% Get in-scanner threshold by running staircase
[thresh,subjectParams] = PhaseScrambleStaircase(exptType);
fprintf('\nCalculated threshold based on Weibull fit:  %0.3f\n',thresh)

% Keep running until user stops-- will need a way to run the runs in a
% different order across subjects
subjectParams.subjNum = input('\nPlease enter subject number to determine condition ordering:  ');
[parfileorder,stimlistorder] = conditionOrder(subjectParams.subjNum);
if isempty(parfileorder)  % that means this subject number wasn't defined in conditionOrder.m
    return
end

cont = 'a';
runNum = 1;
ScanName = 'ResponseSorting';  % Enter the name of your functional scan here (important)
baseDir = ['/Users/Shared/AndreasWordsMatlab/EventRelatedCode/' ScanName];
stimDir = fullfile(baseDir,'stim');

while ~strcmp(cont,'q') && runNum<=maxRuns
    
    % Make the proper stimuli and save trial information for 1 run
    parfilenum = parfileorder(runNum);
    stimlistnum = stimlistorder(runNum);
    exptDir = makeResponseSorting(baseDir,stimDir,thresh,exptType,parfilenum,stimlistnum,runNum,subjectParams.name);
    
    % Save subject information within the experiment directory-- do we need
    % to save this on every run?
    subjFile = fullfile(exptDir,'Subjects.mat');
    if exist(subjFile,'file')
        save(subjFile,'subjectParams','-APPEND');
    else
        save(subjFile,'subjectParams');
    end
    
    % Run the experiment just created
    fprintf('\nStarting run number:  %0.0f\n',runNum);
    runResponseSorting(exptDir);
    
    % See if user wants to go on to next run
    runNum = runNum+1;
    if runNum==maxRuns
        fprintf('\nALL RUNS COMPLETED!  CONGRATULATIONS.')
    else
        fprintf('\n')
        cont = input('Press return to go onto next run, q to quit:  ','s');
    end
end