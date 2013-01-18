function displayName = prefsDisplayName(recompute);
% Return the name of the preferred stimulus display for the given computer
% / MATLAB installation.
%
% displayName = prefsDisplayName([recompute=0]);
%
% This checks for the preference variable 'displayName' in the 'VISTA'
% preference group. If the variable is defined, the value of that variable
% is returned. 
% 
% If it does not exist, this function presents the user with a list
% of defined display calibrations (based on the places specified in
% loadDisplayParams and loadDisplayParamsPTB), and asks the user to choose
% one, initializing if necessary. If no displays are available, gives a
% warning and returns empty.   
%
% Setting the recompute flag to 1 will force the variable to be reset,
% offering the same list as if the variable were not defined.
%
% ras, 07/08/2008.
if notDefined('recompute'),     recompute = 0;      end

if ~ispref('VISTA', 'displayName') || recompute==1
    % prompt the user
    [displayName ok] = selectDisplay;
    if ~ok, error('No display selected.'); end
    
    % initialize the preference variable with the selected name
    setpref('VISTA', 'displayName', displayName);
    fprintf('[%s]: ', mfilename);
    fprintf('Initializing VISTA preference ''displayName'' to %s. \n', displayName);
    fprintf('This will determine which calibration the display code uses.\n');
    fprintf('To modify the preferred display, use the format: \n');
	fprintf('\t setpref(''VISTA'', ''displayName'', [name]). \n');
end

displayName = getpref('VISTA', 'displayName');

return