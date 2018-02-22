%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: SetupPTBWrapper.m
%
% SetupPTBWrapper - In-place setup of PTBWrapper without network access.
%
% This script prepares an already downloaded working copy of PTBWrapper
% for use with Matlab or Octave. It sets proper paths.
%
% This setup routine is meant for people who want to install PTBWrapper
% but don't have direct access to the internet. Installation in that case
% is a three step procedure:
%
% 1. Download and unpack a full working copy of PTBWrapper into your target
% folder. Obviously you need to somehow get a copy, either via conventional
% download from a computer with network connection (See 'help
% DownloadPTBWrapper' or 'help UpdatePTBWrapper') or from a helpful
% colleague.
%
% 2. Change your Matlab/Octave working directory to the PTBWrapper installation
% folder, e.g., 'cd /Applications/PTBWrapper'.
%
% 3. Type 'SetupPTBWrapper' to run this script.
%
% Please be aware that the recommended method of installation is via the
% online Subversion system, i.e., DownloadPTBWrapper and
% UpdatePTBWrapper. Some functionality may not work with a copy that is
% set up via this script, e.g., PTBWrapperVersion may provide incomplete
% version information. Convenient upgrades via UpdatePTBWrapper may be
% impossible. Download size with this method is much higher as well.
%
% Author: Doug Bemis (Really the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SetupPTBWrapper


% Flush all MEX files: This is needed at least on M$-Windows to
% work if Screen et al. are still loaded.
clear mex

% Check if this is a 64-bit Matlab, which we don't support at all:
if strcmp(computer,'PCWIN64') | strcmp(computer,'MACI64') | strcmp(computer,'GLNXA64') %#ok<OR2>
    
    % Check for the new version
    [v_str ver_info] = PsychtoolboxVersion; %#ok<ASGLU>
    if ver_info.major < 3 || (ver_info.minor == 0 && ver_info.point < 10)    
        fprintf('Psychtoolbox does not work on a 64 bit version of Matlab or Octave.\n');
        fprintf('You need to install a 32 bit Matlab or Octave to install & use PTBWrapper.\n');
        error('Tried to setup on a 64 bit version of Matlab or Octave, which is not supported.');
    end
end

% Check OS
isWin=strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64') | strcmp(computer, 'i686-pc-mingw32');
isOSX=strcmp(computer,'MAC') | strcmp(computer,'MACI64') | strcmp(computer,'MACI') | ~isempty(findstr(computer, 'apple-darwin'));
isLinux=strcmp(computer,'GLNX86') | strcmp(computer,'GLNXA64') | ~isempty(findstr(computer, 'linux-gnu'));

% Only Mac OSX for now
% if ~isOSX & ~isWin %#ok<AND2>
%     os=computer;
% 
%     if strcmp(os,'MAC2')
%         os='Mac OS9';
%     end
% 
%     fprintf('Sorry, this installer doesn''t support your operating system: %s.\n',os);
%     fprintf([mfilename ' can only install the PTBWrapper on Mac OSX\n']);
%     error(['Your operating system is not supported by ' mfilename '.']);
% end

% Locate ourselves:
% Old style Pre Octave: targetdirectory=fileparts(which(fullfile('Psychtoolbox','SetupPsychtoolbox.m')))
targetdirectory=fileparts(mfilename('fullpath'));
if ~strcmpi(targetdirectory, pwd)
    error('You need to change your working directory to the PTBWrapper folder before running this routine!');
end

fprintf('Will setup working copy of the PTBWrapper folder inside: %s\n',targetdirectory);
fprintf('\n');
% if any(isspace(targetdirectory))
%     fprintf('Sorry. There cannot be any spaces in the target directory name:\n%s\n',targetdirectory);
%     error('Cannot be any spaces in "targetdirectory" name.');
% end

% Does SAVEPATH work?
if exist('savepath') %#ok<EXIST>
   err=savepath;
else
   err=path2rc;
end

if err
    try
        % If this works then we're likely on Matlab:
        p=fullfile(matlabroot,'toolbox','local','pathdef.m');
        fprintf(['Sorry, SAVEPATH failed. Probably the pathdef.m file lacks write permission. \n'...
            'Please ask a user with administrator privileges to enable \n'...
            'write by everyone for the file:\n\n''%s''\n\n'],p);
    catch
        % Probably on Octave:
        fprintf(['Sorry, SAVEPATH failed. Probably your ~/.octaverc file lacks write permission. \n'...
            'Please ask a user with administrator privileges to enable \n'...
            'write by everyone for that file.\n\n']);
    end
    
    fprintf(['Once "savepath" works (no error message), run ' mfilename ' again.\n']);
    fprintf('Alternatively you can choose to continue with installation, but then you will have\n');
    fprintf('to resolve this permission isssue later and add the path to the PTBWrapper manually.\n\n');
    answer=input('Do you want to continue the installation despite the failure of SAVEPATH (yes or no)? ','s');
    if ~strcmp(answer,'yes')
        fprintf('\n\n');
        error('SAVEPATH failed. Please get an administrator to allow everyone to write pathdef.m.');
    end
end

% Handle Windows ambiguity of \ symbol being the filesep'arator and a
% parameter marker:
if isWin
    searchpattern = [filesep filesep 'PTBWrapper[' filesep pathsep ']'];
    searchpattern2 = [filesep filesep 'PTBWrapper'];
else
    searchpattern  = [filesep 'PTBWrapper[' filesep pathsep ']'];
    searchpattern2 = [filesep 'PTBWrapper'];
end

% Remove "PTBWrapper" from path:
while any(regexp(path, searchpattern))
    fprintf('Your old PTBWrapper appears in the MATLAB/OCTAVE path:\n');
    paths=regexp(path,['[^' pathsep ']*'],'match');
    fprintf('Your old PTBWrapper appears %d times in the MATLAB/OCTAVE path.\n',length(paths));
    % Old and wrong, counts too many instances: fprintf('Your old Psychtoolbox appears %d times in the MATLAB/OCTAVE path.\n',length(paths));
    answer=input('Before you decide to delete the paths, do you want to see them (yes or no)? ','s');
    if ~strcmp(answer,'yes')
        fprintf('You didn''t say "yes", so I''m taking it as no.\n');
    else
        for p=paths
            s=char(p);
            if any(regexp(s,searchpattern2))
                fprintf('%s\n',s);
            end
        end
    end
    answer=input('Shall I delete all those instances from the MATLAB/OCTAVE path (yes or no)? ','s');
    if ~strcmp(answer,'yes')
        fprintf('You didn''t say yes, so I cannot proceed.\n');
        fprintf('Please use the MATLAB "File:Set Path" command or its Octave equivalent to remove all instances of "PTBWrapper" from the path.\n');
        error('Please remove PTBWrapper from MATLAB/OCTAVE path.');
    end
    for p=paths
        s=char(p);
        if any(regexp(s,searchpattern2))
            % fprintf('rmpath(''%s'')\n',s);
            rmpath(s);
        end
    end
    if exist('savepath') %#ok<EXIST>
       savepath;
    else
       path2rc;
    end

    fprintf('Success.\n\n');
end

% Add PTBWrapper to MATLAB/OCTAVE path
fprintf('Now adding the new PTBWrapper folder (and all its subfolders) to your MATLAB/OCTAVE path.\n');
p=targetdirectory;
pp=genpath(p);
addpath(pp);

if exist('savepath') %#ok<EXIST>
   err=savepath;
else
   err=path2rc;
end

if err
    fprintf('SAVEPATH failed. PTBWrapper is now already installed and configured for use on your Computer,\n');
    fprintf('but i could not save the updated Matlab/Octave path, probably due to insufficient permissions.\n');
    fprintf('You will either need to fix this manually via use of the path-browser (Menu: File -> Set Path),\n');
    fprintf('or by manual invocation of the savepath command (See help savepath). The third option is, of course,\n');
    fprintf('to add the path to the PTBWrapper folder and all of its subfolders whenever you restart Matlab.\n\n\n');
else 
    fprintf('Success.\n\n');
end

fprintf(['Now setting permissions to allow everyone to write to the PTBWrapper folder. This will \n'...
    'allow future updates by every user on this machine without requiring administrator privileges.\n']);

try
    if isOSX | isLinux %#ok<OR2>
        [s,m]=fileattrib(p,'+w','a','s'); % recursively add write privileges for all users.
    else
        [s,m]=fileattrib(p,'+w','','s'); % recursively add write privileges for all users.
    end
catch
    s = 0;
    m = 'Setting file attributes is not supported under Octave.';
end

if s
    fprintf('Success.\n\n');
else
    fprintf('\nFILEATTRIB failed. PTBWrapper will still work properly for you and other users, but only you\n');
    fprintf('or the system administrator will be able to run the UpdatePTBWrapper script to update PTBWrapper,\n');
    fprintf('unless you or the system administrator manually set proper write permissions on the PTBWrapper folder.\n');
    fprintf('The error message of FILEATTRIB was: %s\n\n', m);
end

if exist('PTBWrapperPostInstallRoutine.m', 'file')
   % Notify the post-install routine of the "pseudo-update" It will
   % determine the proper flavor by itself.
   PTBWrapperPostInstallRoutine(1);
end

% Puuh, we are done :)
return
