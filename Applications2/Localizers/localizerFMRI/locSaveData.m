function P = locSaveData(P)
% Write out variables for fMRI localizer experiment. The struct P contains
% many fields pertaining to stimulus, responses, display, etc. We write
% them all to the matlab file P.logfile. We also write out the parfile
% P.parfile, which is a text file containt the onset time, numerical code,
% and name of each block.
%
% P = locSaveData(P)

pth = fileparts(P.logFile);

if ~exist(pth, 'dir'), mkdir(pth); end

save(P.logFile, '-struct', 'P');

writeParfile(P.par,P.parFilePath, P.exptLength);

fprintf('\n%s\n%s\n','Saved variables (information about block structure/stimuli to:  ', P.logFile);

fprintf('\n%s\n%s\n','Saved parfile to:  ', P.parFilePath);

return
