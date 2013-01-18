function displayID = closeScreen(displayID)
% 
% Usage: displayID = closeScreen(displayID)
% 
% closeScreen closes an opened PTB window which had been opened by
% running openScreen.
% 
% History:
% ##/##/## rfd & sod wrote it.
% 04/12/06 shc (shcheung@stanford.edu) cleaned it and added the help
% comments.

if(isfield(displayID,'oldGamma') & ~isempty(displayID.oldGamma))
    Screen('LoadNormalizedGammaTable', displayID.screenNumber, displayID.oldGamma);
end
Screen('CloseAll');
displayID.windowPtr = [];
ShowCursor;