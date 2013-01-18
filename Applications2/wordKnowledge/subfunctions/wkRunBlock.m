function [data quitFlag] = wkRunBlock(params,display)
% Run Block
% [data quitFlag] = RunBlock(stimParams,blk)
%
% [SUMMARY]
% Runs an indicated experimental block.
%
% [INPUT(S)]
% stimParams
% Stimulus parameters file containing variables to control
% structure/frequency of stimulus presentation.
%
% blk
% Block number.
%
% [OUTPUT(S)]
% data
% Matrix with all of the data for that block
%
% [AUTHOR(S)]
% RFB 03/19/09
% CEW - General Structure (Ted Wright [cewright@uci.edu])

wkDisplayInstructions(params,display);

itrial = 1;

while sum(params.stimFreq) > 0 % Run as long as there are trials to be run
    whichStim       = select(params.stimFreq); % Select a random index from stimFreq that isn't 0
    [resp rt]       = wkRunTrial(params,display,whichStim);
    data{itrial, 1} = whichStim; % stim index?
    data{itrial, 2} = params.lexicon(whichStim); % lexical status?
    data{itrial, 3} = params.stimList{whichStim}; % which word?
    data{itrial, 4} = resp; % correct?
    data{itrial, 5} = rt * 1000; % response time? (milliseconds)
    
    % Indicate completion by subtracting 1 from that index in stimFreq (iff
    % they get it right)
    if resp==1
        params.stimFreq(whichStim) = params.stimFreq(whichStim) - 1; 
    end
    
    % If subject responded with the quit choice, set the quitflag and hop
    % out of the function.
    if resp==3
        quitFlag = 1;
        return
    end
    
%     Reset the stimulus frequencies after the 1st two, practice trials 
%     if itrial == 2
%         stimParams.stimFreq = saveStimFreq;
%         testTrial = 1;
%     end

    itrial = itrial + 1;
end
