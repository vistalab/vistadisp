function [PC,meanRT] = calcPerformanceMW(ssResponses,ssRTs,params,tenKeyFlag)

% This function will calculate behavioral performance of subjects during
% the motion words fMRI (and TMS) experiment.  This could have been written as a more
% general performance calculation function.
%
% Inputs:
%   ssResponses: The key response for each trial in a cell array
%   ssRTs: The reaction time for each trial (time of onset of trial to
%   button press).  This is 0 if there is no response
%   params: struct containing params.conditionOrder, which gives the
%   condition code (A,B,C, etc) for each trial in order
%   tenKeyFlag:  optional flag if being used on data not from Lucas Center (uses 1 instead of '1!' etc)
%
% Outputs:
%   PC: percent correct struct, where fields are PCs for different subsets of trials
%       e.g. PC.words is percent correct for word trials
%   meanRT: mean reaction time for correct trials, also in a struct as above
%
%   written by amr Jan 27, 2009
%
%   modifield June 5, 2010:  you can now re-run this code with an extra
%      field in params called params.trialsToExclude.  Then, it will
%      recalculate PC and meanRT without counting those trials at all.
%      Those trials are numbered in the order they appeared in the
%      experiment.  You might want to exclude trials if, for example, the
%      TMS coil did not fire during that trial (or it fired while not being
%      on target).
%

if notDefined('tenKeyFlag')
    tenKeyFlag = 0;
end

%% Code the responses (responseCodes) as the following for each trial:
% %   1: word that subject thought was word (correct, hit)
% %   2: word that subject thought was not a word (incorrect, miss)
% %   3: nonword that subject thought was nonword (correct, correct reject)
% %   4: nonword that subject thought was a word (incorrect, false alarm)
% %   5: control trial that subject got right
% %   6: control trial that subject got wrong
% %   9: subject took too long to respond and response is counted as fixation (i.e. tooLongFlag = 1 & ssResponse='99')

if isfield(params,'tooLongFlag')
    tooLongFlag = params.tooLongFlag;
else
    tooLongFlag = 1;  % does not count responses where subject took too long to respond if tooLongFlag = 1
end

if tooLongFlag
    warning('Not counting trials where subject took too long to respond! See line 44 in calcPerformanceMW.')
end

[responseCodes,ssRTs,ssResponses,wordConds,NWConds] = codeWordResponses(ssResponses,ssRTs,params,tenKeyFlag,tooLongFlag);

if isfield(params,'trialsToExclude')
   responseCodes(params.trialsToExclude) = 101;  % 101 will be the code to just not count that trial 
end

%% Calculate percent correct and mean RTs (for correct responses)
% Response codes 1 and 3 are correct responses, 2 and 4 are incorrect

% Find the indices of response codes (correct word trials, incorrect word
% trials, correct nonword trials, and incorrect nonword trials)
RC1_ind = find(responseCodes==1);  % Response code 1 index
RC2_ind = find(responseCodes==2);
RC3_ind = find(responseCodes==3);
RC4_ind = find(responseCodes==4);
RC5_ind = find(responseCodes==5);
RC6_ind = find(responseCodes==6);
RC9_ind = find(responseCodes==9);

% PC overall
PC.tot = (length(RC1_ind)+length(RC3_ind)+length(RC5_ind)) / (length(params.conditionOrder));  % correct responses/total # trials


%RT and PC for word trials (RC1 or RC2)
RT_words = (ssRTs(RC1_ind));  % only the word trials with correct responses
meanRT.words = mean(RT_words);
PC.words = length(RC1_ind) / (length(RC1_ind)+length(RC2_ind));  % percent correct for word trials

%RT and PC for nonword trials (RC3 or RC4)
RT_NW = (ssRTs(RC3_ind));  % only nonword trials with correct responses
meanRT.NW = mean(RT_NW);
PC.NW = length(RC3_ind) / (length(RC3_ind)+length(RC4_ind));  % percent correct for nonword trials

%RT and PC for control trials (RC5 or RC6)
RT_control = (ssRTs(RC5_ind));  % only control trials with correct responses
meanRT.control = mean(RT_control);
PC.control = length(RC5_ind) / (length(RC5_ind)+length(RC6_ind));  % percent correct for control trials

% Mean RT overall (for correct trials)
meanRT.tot = (sum(RT_words)+sum(RT_NW)+sum(RT_control)) / (length(RT_words)+length(RT_NW)+length(RT_control));

PC.notes = 'PC.words and PC.NW only count trials where subject responded in time';
PC.notes2 = 'PC.byCond counts all trials of that condition (whether or not subject responded)';
PC.notes3 = 'PC.tot counts all trials (whether or not subject responded)';
meanRT.notes = 'meanRT only counts correct trials';

%% Can calculate any number of statistics below
% e.g. PC for trials of condition 3

% Calculate some stats, like PC and RT for each condition separately
for condNum = 1:length(params.condNames)
    if ~isempty(params.condNames{condNum})  % don't calculate if you don't have this condition
        trialsinCondIndices = find(params.conditionOrder==condNum);
        if isfield(params,'trialsToExclude')  % exclude trials
            trialsinCondIndices = setdiff(trialsinCondIndices,params.trialsToExclude);
        end
        PC.numTotalTrials(condNum) = length(trialsinCondIndices);
        
        if any(wordConds==condNum)   % if it's a word condition
            PC.numCorrectTrials(condNum) = length(find( responseCodes(find(params.conditionOrder==condNum))==1) );
            PC.byCond(condNum) = PC.numCorrectTrials(condNum) / PC.numTotalTrials(condNum);
        elseif any(NWConds==condNum)  % if it's a nonword condition
            PC.numCorrectTrials(condNum) = length(find( responseCodes(find(params.conditionOrder==condNum))==3) );
            PC.byCond(condNum) = PC.numCorrectTrials(condNum) / PC.numTotalTrials(condNum);
        else % control condition
            PC.numCorrectTrials(condNum) = length(find( responseCodes(find(params.conditionOrder==condNum))==5) );
            PC.byCond(condNum) = PC.numCorrectTrials(condNum) / PC.numTotalTrials(condNum);  % undefined if no correct response for that type of condition
        end
        
        % mean RTs by condition
        RTsum = 0;
        numCor = 0;
        for trialCounter = 1 : PC.numTotalTrials(condNum)  % go through each trial to see if RT should be counted as part of mean
            trialNum = trialsinCondIndices(trialCounter);
            meanRT.allTrials(trialCounter,condNum) = ssRTs(trialNum);  % takes all RTs for all trials of each condition
            if responseCodes(trialNum) == 1 || responseCodes(trialNum) == 3 || responseCodes(trialNum)==5 % only count correct responses
                RTsum = RTsum + (ssRTs(trialNum));
                numCor = numCor + 1;
                meanRT.correctTrials(trialCounter,condNum) = ssRTs(trialNum);
            else
                meanRT.correctTrials(trialCounter,condNum) = NaN;
            end
        end
        if numCor > 0
            meanRT.byCond(condNum) = RTsum/numCor;
        else  % in case no correct responses, don't compute mean
            meanRT.byCond(condNum) = NaN;
        end
    end
end


return
