function stimOrder = assignWordStims2Conditions(wordlist,NWlist,conditionOrder,condNames,useWordsFlag)
%
% Randomly assigns stimuli from a list of words and list of nonwords to
% conditions that have the string "words" or "NW" in their name.
%
%     stimOrder =
%     assignWordStims2Conditions(wordlist,NWlist,conditionOrder,condNames,[useWordsFlag])
%
% If useWordsFlag == 1, then a real word will always be used instead of a
% nonword, except on fixation trials.  This is useful e.g. for the response
% sorting detection trials, where both conditions should be made from a
% word (but the 2nd condition is fully phase scrambled).
%
% Note that you must have at least as many stimuli in your wordlist as
% there are trials.  Note also that even control stimuli have a
% word/nonword attached to them, since many of them are made using words (e.g.
% MotionControl).
%
%  written by amr Feb 4, 2009
%
%  6/29/09:  amr added useWordsFlag option
%

% Initialize useWordsFlag
if notDefined('useWordsFlag')
    useWordsFlag = 0;
end

% Randomize order of stimuli using Shuffle
wordlist = Shuffle(wordlist);
NWlist = Shuffle(NWlist);

% Get the condition names as they correspond to trial numbers
condNamesOrder = condNames(conditionOrder);

% For each trial, if the condition name has 'Word' in it, assign a
% stimulus from wordlist, otherwise assign stimulus from nonword list
wordcount = 1;
NWcount = 1;
for trialNum = 1:length(conditionOrder)
    i = strfind(condNamesOrder{trialNum},'Word');  % does the condition name have 'Word' in it?
    if strcmp(condNamesOrder{trialNum},'Fix') || strcmp(condNamesOrder{trialNum},'Fix ')  % don't need to assign anything to fixation condition
        stimOrder{trialNum}='Fix';
    elseif ~isempty(i) || useWordsFlag  % i.e. if it's a word trial OR you want to use wordlist regardless
        stimOrder{trialNum}=wordlist{wordcount};
        wordcount = wordcount+1;
    else  % either nonword stimulus or doesn't matter, so pick from nonword list
        stimOrder{trialNum}=NWlist{NWcount};
        NWcount = NWcount+1;
    end
end

return