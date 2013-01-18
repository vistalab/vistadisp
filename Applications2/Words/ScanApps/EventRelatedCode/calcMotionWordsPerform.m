function [PC,meanRT] = calcMotionWordsPerform(ssResponses,ssRTs,params)

% This function will calculate behavioral performance of subjects during
% the motion words fMRI experiment.  This could have been written as a more
% general performance calculation function, but I was too lazy this time.
% Maybe in the future.
%
% Inputs:
%   ssResponses: The key response for each trial in a cell array
%   ssRTs: The reaction time for each trial (time of onset of trial to
%   button press).  This is 0 if there is no response
%   params: struct containing params.conditionOrder, which gives the
%   condition code (A,B,C, etc) for each trial in order
%
% Outputs:
%   PC: percent correct struct, where fields are PCs for different subsets of trials
%       e.g. PC.words is percent correct for word trials
%   meanRT: mean reaction time for correct trials, also in a struct as above
%
%   written by amr Jan 27, 2009
%

%% Some parameters to set
% Response keys
wordsCorResp = '1';
NWCorResp = '3';

% Conditions that are words and conditions that are nonwords
wordConds = {'A','B','C','D','K'};
NWConds = {'E','F','G','H','L'};


%% Code the responses

% Codes for responseCodes:
%   1: word that subject thought was word
%   2: word that subject thought was not a word
%   3: nonword that subject thought was nonword
%   4: nonword that subject did not think was nonword (wrong response or no response)

% Shouldn't do this with a for loop but can't quite figure it out
responseCodes(1:length(params.conditionOrder))=0;  % initialize
for trial = 1:length(params.conditionOrder)  % number of trials
    if find(~cellfun('isempty',strfind(wordConds,params.conditionOrder{trial})))   % word trial
        if strcmp(ssResponses{trial},wordsCorResp)  % subject got it right
            responseCodes(trial)=1;
        else
            responseCodes(trial)=2;
        end

    elseif find(~cellfun('isempty',strfind(NWConds,params.conditionOrder{trial})))  % nonword trial
        if strcmp(ssResponses{trial},NWCorResp)  % subject got it right
            responseCodes(trial)=3;
        else
            responseCodes(trial)=4;
        end
    else
        fprintf('\nSomehow you ended up with an unrecognized condition. (Condition %s)\n%s\n\n',...
            params.conditionOrder{trial},'Probably you need to change the allowable conditions in calcMotionWordsPerform.m');
    end
end

%% Calculate percent correct and mean RTs (for correct responses)
% Response codes 1 and 3 are correct responses, 2 and 4 are incorrect

% Find the indices of response codes (correct word trials, incorrect word
% trials, correct nonword trials, and incorrect nonword trials)
RC1_ind = find(responseCodes==1);  % Response code 1 index
RC2_ind = find(responseCodes==2);
RC3_ind = find(responseCodes==3);
RC4_ind = find(responseCodes==4);

% PC overall
PC.tot = (length(RC1_ind)+length(RC3_ind)) / (length(params.conditionOrder));  % correct responses/total # trials

%RT and PC for word trials (RC1 or RC2)
RT_words = cell2mat(ssRTs(RC1_ind));  % only the word trials with correct responses
meanRT.words = mean(RT_words);
PC.words = length(RC1_ind) / (length(RC1_ind)+length(RC2_ind));  % percent correct for word trials

%RT and PC for nonword trials (RC3 or RC4)
RT_NW = cell2mat(ssRTs(RC3_ind));  % only nonword trials with correct responses
meanRT.NW = mean(RT_NW);
PC.NW = length(RC3_ind) / (length(RC3_ind)+length(RC4_ind));  % percent correct for nonword trials

% Mean RT overall (for correct trials)
meanRT.tot = (sum(RT_words)+sum(RT_NW)) / (length(RT_words)+length(RT_NW));


%% Can calculate any number of statistics below
% e.g. PC for trials of condition D

% Get the indices for each condition, where indices are trial numbers
condOrderMatrix = cell2mat(params.conditionOrder');
condind.A = strfind(condOrderMatrix,'A');
condind.B = strfind(condOrderMatrix,'B');
condind.C = strfind(condOrderMatrix,'C');
condind.D = strfind(condOrderMatrix,'D');
condind.E = strfind(condOrderMatrix,'E');
condind.F = strfind(condOrderMatrix,'F');
condind.G = strfind(condOrderMatrix,'G');
condind.H = strfind(condOrderMatrix,'H');
condind.I = strfind(condOrderMatrix,'I');
condind.J = strfind(condOrderMatrix,'J');
condind.K = strfind(condOrderMatrix,'K');
condind.L = strfind(condOrderMatrix,'L');

% Calculate some stats, like PC and RT for each condition separately
if strfind(cell2mat(wordConds),'A')  % just make sure condition A is a word condition
    PC.condA = length(find(responseCodes(condind.A)==1)) / length(condind.A);
    meanRT.condA = mean(cell2mat(ssRTs(condind.A)));
end
if strfind(cell2mat(wordConds),'C')  % just make sure condition B is a word condition
    PC.condC = length(find(responseCodes(condind.C)==1)) / length(condind.C);
    meanRT.condC = mean(cell2mat(ssRTs(condind.C)));
end
if strfind(cell2mat(wordConds),'E')  % just make sure condition C is a word condition
    PC.condE = length(find(responseCodes(condind.E)==1)) / length(condind.E);
    meanRT.condE = mean(cell2mat(ssRTs(condind.E)));
end
if strfind(cell2mat(wordConds),'G')  % just make sure condition D is a word condition
    PC.condG = length(find(responseCodes(condind.G)==1)) / length(condind.G);
    meanRT.condG = mean(cell2mat(ssRTs(condind.G)));
end
if strfind(cell2mat(wordConds),'K')  % just make sure condition K is a word condition
    PC.condK = length(find(responseCodes(condind.K)==1)) / length(condind.K);
    meanRT.condK = mean(cell2mat(ssRTs(condind.K)));
end

if strfind(cell2mat(NWConds),'B')  % just make sure condition E is a nonword condition
    PC.condB = length(find(responseCodes(condind.B)==3)) / length(condind.B);
    meanRT.condB = mean(cell2mat(ssRTs(condind.B)));
end
if strfind(cell2mat(NWConds),'D')  % just make sure condition F is a nonword condition
    PC.condD = length(find(responseCodes(condind.D)==3)) / length(condind.D);
    meanRT.condD = mean(cell2mat(ssRTs(condind.D)));
end
if strfind(cell2mat(NWConds),'F')  % just make sure condition G is a nonword condition
    PC.condF = length(find(responseCodes(condind.F)==3)) / length(condind.F);
    meanRT.condF = mean(cell2mat(ssRTs(condind.F)));
end
if strfind(cell2mat(NWConds),'H')  % just make sure condition H is a nonword condition
    PC.condH = length(find(responseCodes(condind.H)==3)) / length(condind.H);
    meanRT.condH = mean(cell2mat(ssRTs(condind.H)));
end
if strfind(cell2mat(NWConds),'L')  % just make sure condition H is a nonword condition
    PC.condL = length(find(responseCodes(condind.L)==3)) / length(condind.L);
    meanRT.condL = mean(cell2mat(ssRTs(condind.L)));
end


return

% other possibly useful code for not using a for loop above
wordsExpectResponses = find(~cellfun('isempty',strfind(wordConds,params.conditionOrder)));

if(iscell(stairParams.responseSet))
    respCode = find(~cellfun('isempty',strfind(stairParams.responseSet,response.keyLabel)));
else
    respCode = strfind(stairParams.responseSet, response.keyLabel);
end
