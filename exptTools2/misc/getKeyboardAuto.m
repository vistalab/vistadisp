
function [k pauseKey quitKey resumeKey tenKeyFlag] = getKeyboardAuto

d = getDevices;
if isempty(d.keyInputExternal)
    fprintf('\n\n10-key not found! Using internal keyboard.\n\n');
    k = d.keyInputInternal;
    pauseKey = 'p';
    resumeKey = 'r';
    quitKey = 'q';
    tenKeyFlag = 0;
else
    k = d.keyInputExternal;
    pauseKey = '/';
    resumeKey = '*';
    quitKey = '7';
    tenKeyFlag = 1;
end
