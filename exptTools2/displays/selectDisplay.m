function [displayName ok] = selectDisplay(commandLine);
% Present the user a menu to select a calibrated display.
%
%  [displayName ok] = selectDisplay([commandLine=0]);
%
% This function provides a dialog to the user with a list of the saved
% displays. (The displays are stored in the VISTADISP repository, in the
% directory returned by 'getDisplayPath'. Use 'getDisplaysList' to get a
% list of all installed displays.)
%
% If commandLine is set to 1, the user is prompted in the command window
% (no GUIs). If 0, a GUI dialog pops up.
%
% Returns the name of the selected display, and a status (1 if the user
% selected a valid display, 0 if invalid or the user canceled.)
%
% ras, 07/08/2008.
if notDefined('commandLine'),       commandLine = 0;        end


%% get a list of the displays
list = getDisplaysList;

if isempty(list)
    warning('No display settings files found.')
    displayName = '';
    ok = 0;
    return
end

%% prompt the user
if commandLine==1
    % use command line
    fprintf('Select the number corresponding to the desired display: \n\n');
   
    for n = 1:length(list)
        fprintf(' (%i) %s\n', n, list{n});
    end
    fprintf('\n');
    
    displayNum = input('Which display file to use?  ');
    
    try
        displayName = list{displayNum};
        ok = 1;
    catch
        error('Invalid selection.')
    end
    
else
    % put up a dialog
    dlg.fieldName = 'displayName';
    dlg.style = 'listbox';
    dlg.string = 'Which display file to use?';
    dlg.list = [list 'default'];
    dlg.value = 1;
    
    [resp ok] = generalDialog(dlg, mfilename, [.2 .2 .25 .3]);
    
    if ok==1
        displayName = resp.displayName{1};
    end
    if strcmpi(displayName, 'default'), displayName = ''; end
end

return
    
    