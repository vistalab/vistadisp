function logFID = prepStaircaseFile(dataDir, subjectParams, stairParams)
% set up file to write results for psychophysical staircase experiment
%
% logFID = prepStaircase(dataDir, subjectParams, stairParams)
%

logFID(1) = fopen(fullfile(dataDir,[subjectParams.name '.log']), 'at');
fprintf(logFID(1), '%s\n', datestr(now));
fprintf(logFID(1), '%s\n', subjectParams.comment);

if~isempty(stairParams.curStairVars)
    fprintf(logFID(1), '%s = [ %s ]', stairParams.curStairVars{1}, num2str(stairParams.curStairVars{2}));
end
fprintf(logFID(1), '\n');
logFID(2) = 1;
%hideCursor = false;

end