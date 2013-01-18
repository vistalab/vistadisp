function [responseCodes,ssRTs,ssResponses,wordConds,NWConds] = codeWordResponses(ssResponses,ssRTs,params,tenKeyFlag,tooLongFlag)

if notDefined('tenKeyFlag')
    tenKeyFlag = 0;
end

%% Some parameters to set
if tenKeyFlag  % then just use normal 1 and 2
    if isfield(tenKeyFlag,'newTenKey') && tenKeyFlag.newTenKey == 1
        % do something to correct for the new tenKey recording responses as
        % follows:  {'NumLockClear'    '2'}
        
    else
        wordsCorResp = '1';
        NWCorResp = '2';
        ControlCorResp = '3';
    end
else   % Response keys for 3T#2 at Lucas
    wordsCorResp = '1!';
    NWCorResp = '2@';
    ControlCorResp = '3#';
end

% Flag to count responses that take too long as fixation rather than
% opposite response.  This will also discount trials where subject didn't
% respond, instead of counting the RT from these as 0! (therefore I highly
% recommend leaving this flag on unless you change the code for processing
% trials where subjects didn't respond at all).
if ~exist('tooLongFlag','var'), tooLongFlag = 1;  end

% this is really silly but I just want to get out the first response on
% each trial-- sure there's a better way to do it
for trialNum = 1:length(params.conditionOrder)
    try
        firstRespInd = find(ssRTs{trialNum}==min(ssRTs{trialNum}));  % index of minimum RT (not always first one)
        sz = size(ssResponses{1});
        if iscell(ssResponses{trialNum})
            ssResponses{trialNum}=cell2mat(ssResponses{trialNum}(firstRespInd));
        end
        ssRTs{trialNum}=ssRTs{trialNum}(firstRespInd);
    catch
        fprintf('Could not count trial:  %0.0f.   ',trialNum)
    end
end

allowedRT = params.RT+params.stimLength;
ssRTs = cell2mat(ssRTs);  % convert to matrix form
if tooLongFlag
    toolong = find(ssRTs>allowedRT);  % trials where subject took too long to respond
    ssRTs(toolong) = 0;
    if ~isempty(toolong)
        for xx=1:length(toolong)
            ssResponses{toolong(xx)} = '99';  % 99 will identify responses where subject took too long to respond
        end
    end
end

% Find any trials where subject did not respond, and exclude
for xx=1:length(ssResponses)
    if isempty(ssResponses{xx})
        ssResponses{xx}='99';  % we'll also use 99 for responses where subject didn't respond at all
    end
end


wordConds = [];
NWConds = [];
% Find conditions that are words and conditions that are nonwords
for condNum = 1:length(params.condNames)
    if ~isempty(params.condNames{condNum})  % if that condition doesn't exist, don't check for it
        i = strfind(params.condNames{condNum},'Word');  % does the condition name have 'Word' in it?
        if ~isempty(i)
            wordConds = union(wordConds,condNum);
        else
            i = strfind(params.condNames{condNum},'NW');  % is this condition a nonword?
            if ~isempty(i)  % check if nonword because could be control stimulus
                NWConds = union(NWConds,condNum);
            end
        end
    end
end

%% Code the responses

% Codes for responseCodes:
%   1: word that subject thought was word (correct, hit)
%   2: word that subject thought was not a word (incorrect, miss)
%   3: nonword that subject thought was nonword (correct, correct reject)
%   4: nonword that subject thought was a word (incorrect, false alarm)
%   5: control trial that subject got right
%   6: control trial that subject got wrong
%   9: subject took too long to respond and response is counted as fixation (i.e. tooLongFlag = 1 & ssResponse='99')

% Shouldn't do this with a for loop but can't quite figure it out
responseCodes(1:length(params.conditionOrder))=0;  % initialize
for trial = 1:length(params.conditionOrder)  % number of trials
    try
        if any(wordConds==params.conditionOrder(trial))   % word trial
            if strcmp(ssResponses{trial},wordsCorResp)  % subject got it right
                responseCodes(trial)=1;
            elseif tooLongFlag && strcmp(ssResponses{trial},'99') % subject took too long to response or didn't respond
                responseCodes(trial)=9;
            else
                responseCodes(trial)=2;
            end
            
        elseif any(NWConds==params.conditionOrder(trial))  % nonword trial
            if strcmp(ssResponses{trial},NWCorResp)  % subject got it right
                responseCodes(trial)=3;
            elseif tooLongFlag && strcmp(ssResponses{trial},'99') % subject took too long to response
                responseCodes(trial)=9;
            else
                responseCodes(trial)=4;
            end
        else   % some control condition, neither word nor nonword
            if strcmp(ssResponses{trial},ControlCorResp)  % subject got it right
                responseCodes(trial)=5;
            elseif tooLongFlag && strcmp(ssResponses{trial},'99') % subject took too long to response
                responseCodes(trial)=9;
            else
                responseCodes(trial)=6; % control trial subject got wrong
            end
        end
    catch
        fprintf('Trial num %0.0f does not seem to exist.\n',trial)
    end
end
