function logFID = ewInitLogFID(stimParams,stairParams,subj)

logName = sprintf('S%02d.log',subj.num);
logFID(1) = fopen(fullfile(stimParams.dataDir,logName), 'at');
fprintf(logFID(1), '%s\n', datestr(now));
if(~isempty(stairParams.curStairVars))
    fprintf(logFID(1), '%s = [ %s ]', stairParams.curStairVars{1}, num2str(stairParams.curStairVars{2}));
end
fprintf(logFID(1), '\n');
logFID(2) = 1;