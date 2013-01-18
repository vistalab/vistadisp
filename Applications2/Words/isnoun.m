function isNounFlag = isnoun(word)
%
%  function isNounFlag = isnoun(word)
%
% Function returns 1 if word is a noun, 0 if it is not a noun.  Must have
% WordNet (http://wordnet.princeton.edu/) installed to run.
%
% Note that a word can be a noun but still be another part of speech as
% well. (e.g. (e.g. Watch is a noun and a verb)
%
% WordNet is NOT case sensitive.
%
%  see also isnoun.m, isadj.m
%
% written by amr & lmp June 30, 2009
%

if notDefined('word')
    word = input('What is the word?  ','s');
end

% build system command
cmd = ['wn ' char(word) ' -domnn'];  % use char in case it's a cell

outtxt='';
[x outtxt] = system(cmd);

if isempty(outtxt)
    isNounFlag = 0;
else
    isNounFlag = 1;
end

isNounFlag = logical(isNounFlag);

return