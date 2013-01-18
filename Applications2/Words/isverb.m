function isVerbFlag = isverb(word)
%
%  function isVerbFlag = isverb(word)
%
% Function returns 1 if word is a verb, 0 if it is not a verb.  Must have
% WordNet (http://wordnet.princeton.edu/) installed to run.
%
% Note that a word can be a verb but still be another part of speech as
% well. (e.g. Watch is a noun and a verb)
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
cmd = ['wn ' char(word) ' -domnv'];

outtxt='';
[x outtxt] = system(cmd);

if isempty(outtxt)
    isVerbFlag = 0;
else
    isVerbFlag = 1;
end

isVerbFlag = logical(isVerbFlag);

return