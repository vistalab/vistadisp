function [wordlist nounFlags verbFlags adjFlags] = partsOfSpeech(words)
%
%   function [words,nounFlag,verbFlag,adjFlag] = partsOfSpeech(words)
%
% Function to classify list of words as being a noun, verb, or adjective
% (or any combination of those).  Returns several arrays composed of 1s or 
% 0s that classify the word as being a noun, verb, or adjective.
%
% words can be either a cell array or a txt file of a column of words
%
% You must have WordNet (http://wordnet.princeton.edu/) installed to run
% (required for isnoun, isverb, and isadj.
%
% Note that a word can be a noun but still be another part of speech as
% well. (e.g. (e.g. Watch is a noun and a verb), etc.
%
% WordNet, and therefore this function, is NOT case sensitive.
%
%  written by amr June 30, 2009
%

% load in wordlist from txt file or from cell array
if ischar(words)  % then it's probably a path
    fid = fopen(words);
    cols = textscan(fid,'%s');
    fclose(fid);
    wordlist=cols{1};
elseif iscell(words)
    wordlist = words;  % if it's not a file, we assume it's a list of words
else
    disp('Not a valid wordlist.  Must be cell array or txt file path.')
    return
end

% initalize
nounFlags = zeros(1,length(wordlist));
verbFlags = zeros(1,length(wordlist));
adjFlags = zeros(1,length(wordlist));

% classify each word
for wordNum = 1:length(wordlist)
    nounFlags(wordNum)=isnoun(wordlist(wordNum));
    verbFlags(wordNum)=isverb(wordlist(wordNum));
    adjFlags(wordNum)=isadj(wordlist(wordNum));
end


return