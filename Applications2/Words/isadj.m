function isAdjFlag = isadj(word)
%
%  function isAdjFlag = isadj(word)
%
% Function returns 1 if word is an adjective, 0 if it is not an adjective.  Must have
% WordNet (http://wordnet.princeton.edu/) installed to run.
%
% Note that a word can be an adjective but still be another part of speech as
% well. (e.g. warm is an adjective and a verb)
%
% WordNet is NOT case sensitive.
%
%  see also isnoun.m, isverb.m
%
% written by amr & lmp June 30, 2009
%

if notDefined('word')
    word = input('What is the word?  ','s');
end

% build system command
cmd = ['wn ' char(word) ' -domna'];

outtxt='';
[x outtxt] = system(cmd);

if isempty(outtxt)
    isAdjFlag = 0;
else
    isAdjFlag = 1;
end

isAdjFlag = logical(isAdjFlag);

return