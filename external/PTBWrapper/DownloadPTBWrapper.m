%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: DownloadPTBWrapper([targetdirectory] [,downloadmethod=0] [,targetRevision][,flavor])
%
% Taken, with modifications, from DownloadPsychtoolbox. First, checks to see if psychtoolbox
% is present. Otherwise, will not download.
%
% This script downloads the latest Mac OSX PTBWrapper from the
% Subversion master server to your disk, creating your working copy, ready
% to use as a new toolbox in your MATLAB/OCTAVE application. Subject to your
% permission, any old installation of the Psychtoolbox is first removed.
% It's a careful program, checking for all required resources and
% privileges before it starts.
%
% CAUTION: Psychtoolbox *will not work* with 64 bit versions of Matlab or
% Octave or anything not Mac OSX.
%
% On Mac OSX, all parameters are optional. Your working copy of the Psychtoolbox will 
% be placed in either your /Applications or your /Users/Shared folder (depending on permissions
% and your preference), or you may specify a 'targetdirectory', as you
% prefer.
%
% There is only one flavor for now, so, you're getting it. This argument
% will be ignored for now.
%
% Normally your download should just work(TM). The installer knows three
% different methods of download and tries all of them if neccessary, ie.,
% if the preferred method fails, the 2nd best is tried etc. Should the
% installer get stuck for an inappropriate amount of time (More than 5-10
% minutes), you can try to abort it and restart it, providing the
% additional 'downloadmethod' parameter with a setting of either 1, 2 or 3,
% to change the order of tried download methods to prevent the downloader
% from getting stuck with a specific method in rare cases. Very
% infrequently, the download servers may be overloaded or down for
% maintenance, resulting in download failure. In that case, please retry a
% few hours later.
%
%
% The "targetRevision" argument is optional and should be normally omitted.
% Normal behaviour is to download the latest revision of PTBWrapper.
% If you provide a specific targetRevision, then this script will
% install a copy of Psychtoolbox according to the specified revision.
%
% This is only useful if you experience problems and want
% to revert to an earlier known-to-be-good release.
%
% Revisions can be specified by a revision number, a specific date, or by
% the special flag 'PREV' which will choose the revision before the
% most current one.
%
%
% INSTALLATION INSTRUCTIONS: Pretty easy. Make sure you've installed
% and used psychtoolbox successuflly. Otherwise, these scripts will
% be pretty useless.
%
% Usage: DownloadPTBWrapper
%
% Our standard option is in the Applications folder, but note that, as with
% installation of any software, you'll need administrator privileges. Also
% note that if you put the wrapper in the Applications folder, you'll need
% to reinstall it when MATLAB is updated on your machine. If you must
% install without access to an administrator, we offer the option of
% installing into the /Users/Shared/ folder instead. If you must install
% the PTBWrapper in some other folder, then specify it in the optional
% first argument of your call.
%
%
% That's it. Any pre-existing installation of the PTBWrapper will be
% removed (if you approve). The program will then download the latest
% PTBWrapper and update your MATLAB path and other relevant system settings.
%
% P.S. If you get stuck, first check the FAQ section and Download section of
% the psychtoolbox Wiki at http://www.psychtoolbox.org. If that doesn't help, 
% best of luck to you.
%
% UPGRADE INSTRUCTIONS:
%
% To upgrade your copy of PTBWrapper, at any time, to incorporate the
% latest bug fixes, enhancements, and new features, just type:
% UpdatedPTBWrapper
% 
% UpdatePTBWrapper cannot change the flavor of your
% PTBWrapper. To change the flavor, run PTBWrapper to
% completely discard your old installation and get a fresh copy with the
% requested flavor.
% 
% PERMISSIONS:
%
% There's a thorny issue with permissions on OS/X. It may not be possible to
% install into /Applications (or whatever the targetdirectory is) with the
% user's existing privileges. The normal situation on Mac OSX is that a few
% users have "administrator" privileges, and many don't. By default,
% writing to the /Applications folder requires administrator privileges.
%
% Thus all OSX installers routinely demand an extra authorization (if
% needed), asking the user to type in the name and password of an
% administrator before proceeding. We haven't yet figured out how to do
% that, but we want to offer that option. This conforms to normal
% installation of an application under Mac OS X.
%
% DownloadPTBWrapper creates the PTBWrapper folder with permissions set
% to allow writing by everyone. Our hope is that this will allow updating
% (by UpdatedPTBWrapper) without need for administrator privileges.
%
% Some labs that may want to be able to install without access to an
% administrator. For them we offer the fall back of installing PTBWrapper
% in /Users/Shared/, instead of /Applications/, because, by default,
% /Users/Shared/ is writeable by all users.
%
% SAVEPATH
%
% Normally all users of MATLAB use the same path. This path is normally
% saved in MATLABROOT/toolbox/local/pathdef.m, where "MATLABROOT" stands
% for the result returned by running that function in MATLAB, e.g.
% '/Applications/MATLAB.app/Contents/Matlab14.1'. Since pathdef.m is inside
% the MATLAB package, which is normally in the Applications folder,
% ordinary users (not administrators) cannot write to pathdef.m. They'll
% get an error message whenever they try to save the path, e.g. by typing
% "savepath". Most users will find this an unacceptable limitation. The
% solution is very simple, ask an administrator to use File Get Info to set
% the pathdef.m file permissions to allow write by everyone. This needs to
% be done only once, after installing MATLAB.
% web http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_env/ws_pat18.html
%
% Author: Doug Bemis (really the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DownloadPTBWrapper(targetdirectory,downloadmethod,targetRevision,flavor)

% Check for psychtoolbox first. Might have to make this more general...
try
    ptbroot = PsychtoolboxRoot;
	fprintf(['Found Psychtoolbox at ' ptbroot '. We can now proceed...\n']);
catch
    error('Could not find Psychtoolbox. Please install this first. Otherwise, this wrapper would be ridiculous.')
end

% Hmm... Haven't tried Octave yet.
if IsOctave
	error('Sorry. Haven''t tried with Octave yet. Should put on the ToDo...');
end

% Flush all MEX files: This is needed at least on M$-Windows for SVN to
% work if Screen et al. are still loaded.
clear mex

% Check OS
isWin=strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64') | strcmp(computer, 'i686-pc-mingw32');
isOSX=strcmp(computer,'MAC') | strcmp(computer,'MACI64') | strcmp(computer,'MACI') | ~isempty(findstr(computer, 'apple-darwin'));
isLinux=strcmp(computer,'GLNX86') | strcmp(computer,'GLNXA64') | ~isempty(findstr(computer, 'linux-gnu'));

% Only Mac OSX for now
% if ~isOSX
%     os=computer;
%     if strcmp(os,'MAC2')
%         os='Mac OS9';
%     end
%     fprintf('Sorry, this installer doesn''t support your operating system: %s.\n',os);
%     fprintf([mfilename ' can only install on macs for now.\n']);
%     error(['Your operating system is not supported by ' mfilename '.']);
% end

if nargin < 1
    targetdirectory = [];
end

if isempty(targetdirectory)
    if isOSX
        % Set default path for OSX install:
        targetdirectory=fullfile(filesep,'Applications');
    else
        % We do not have a default path on Windows, so the user must provide it:
        fprintf('You did not provide the full path to the directory where Psychtoolbox should be\n');
        fprintf('installed. This is required for Microsoft Windows and Linux installation. Please enter a full\n');
        fprintf('path as the first argument to this script, e.g. DownloadPsychtoolbox(''C:\\Toolboxes\\'').\n');
        error('For Windows and Linux, the call to %s must specify a full path for the location of installation.',mfilename);
    end     
end

% Strip trailing fileseperator, if any:
if targetdirectory(end) == filesep
    targetdirectory = targetdirectory(1:end-1);
end

% Override for download method provided?
if nargin < 2
    downloadmethod = [];
end

if isempty(downloadmethod)
    % Try 0 by default (http://):
    downloadmethod = 0;
else
    if downloadmethod < 0 | downloadmethod > 1
        error('Invalid downloadmethod provided. Valid are values 0 and 1.');
    end
end

if nargin < 3
    targetRevision = [];
end

if isempty(targetRevision)
    targetRevision = '';
else
    fprintf('Target revision: %s \n', targetRevision);
    targetRevision = [' -r ' targetRevision ' '];
end

% Set flavor defaults and synonyms
if nargin < 4
    flavor = [];
end

% Only one for now
%if isempty(flavor)
    flavor='beta';
%end

% Make sure that flavor is lower-case, unless its a 'Psychtoolbox-x.y.z'
% spec string which is longer than 10 characters and mixed case:
if length(flavor) < 10
    % One of the short flavor spec strings: lowercase'em:
    flavor = lower(flavor);
end

switch (flavor)
    % 'current' is a synonym for 'beta'.
    case 'beta'
    case 'current'
        flavor = 'beta';
    case 'stable'
        fprintf('\n\n\nYou request download of the "stable" flavor of Psychtoolbox.\n');
        fprintf('The "stable" flavor is no longer available, it has been renamed to "unsupported".\n');
        fprintf('If you really want to use the former "stable" flavor, please retry the download\n');
        fprintf('under the new name "unsupported".\n\n');
        error('Flavor "stable" requested. This is no longer available.');
    case 'unsupported'
        % Very bad choice! Give user a chance to reconsider...
        fprintf('\n\n\nYou request download of the "unsupported" flavor of Psychtoolbox.\n');
        fprintf('Use of the "unsupported" flavor is strongly discouraged! It is outdated and contains\n');
        fprintf('many bugs and deficiencies that have been fixed in the recommended "beta" flavor years ago.\n');
        fprintf('"unsupported" is no longer maintained and you will not get any support if you have problems with it.\n');
        fprintf('Please choose "beta" unless you have very good reasons not to do so.\n\n');
        fprintf('If you answer "no" to the following question, i will download the recommended "beta" flavor instead.\n');
        answer=input('Do you want to continue download of "unsupported" flavor despite the warnings (yes or no)? ','s');
        if ~strcmp(answer,'yes')
            flavor = 'beta';
            fprintf('Download of "unsupported" flavor cancelled, will download recommended "beta" flavor instead...\n');
        else
            fprintf('Download of "unsupported" flavor proceeds. You are in for quite a bit of pain...\n');            
        end

        fprintf('\n\nPress any key to continue...\n');
        pause;
        
    otherwise
        fprintf('\n\n\nHmm, requested flavor is the unusual flavor: %s\n',flavor);
        fprintf('Either you request something exotic, or you made a typo?\n');
        fprintf('We will see. If you get an error, this might be the first thing to check.\n');
        fprintf('Press any key to continue...\n');
        pause;
end

fprintf('DownloadPTBWrapper(''%s'',''%s'')\n',targetdirectory, flavor);
fprintf('Requested flavor is: %s\n',flavor);
fprintf('Requested location for the PTBWrapper folder is inside: %s\n',targetdirectory);
fprintf('\n');

% Check for alternative install location of Subversion:
if isWin
    % Search for Windows executable in Matlabs path:
   svnpath = which('svn.exe');
else
    % Search for Unix executable in Matlabs path:
    svnpath = which('svn.');
end

% Found one?
if ~isempty(svnpath)
    % Extract basepath and use it:
    svnpath=[fileparts(svnpath) filesep];
else
    % Could not find svn executable in Matlabs path. Check the default
    % install location on OS-X and abort if it isn't there. On M$-Win we
    % simply have to hope that it is in some system dependent search path.

    % Currently, we only know how to check this for Mac OSX.
    if isOSX
        % Try OS/X 10.5 Leopard install location for svn first:
        svnpath='/usr/bin/';
        if exist('/usr/bin/svn','file')~=2
            % This would have been the default install location of the svn
            % client bundled with OS/X 10.5.x Leopard. Let's try the
            % default install location from the web installer:
            svnpath='/usr/local/bin/';
            if exist('/usr/local/bin/svn','file')~=2
                fprintf('The Subversion client "svn" is not in its expected\n');
                fprintf('location "/usr/local/bin/svn" on your disk. Please \n');
                fprintf('download and install the most recent Subversion client from:\n');
                fprintf('web http://metissian.com/projects/macosx/subversion/ -browser\n');
                fprintf('and then run %s again.\n',mfilename);
                error('Subversion client is missing. Please install it.');
            end
        end
    end
end

if ~isempty(svnpath)
    fprintf('Will use the svn client which is located in this folder: %s\n', svnpath);
end

if any(isspace(svnpath))
    fprintf('WARNING! There are spaces (blanks) in the path to the svn client executable (see above).\n');
    fprintf('On some systems this can cause a download failure, with some error message that may look\n');
    fprintf('roughly like this: %s is not recognized as an internal or external command,\n', svnpath(1:min(find(isspace(svnpath)))));
    fprintf('operable program or batch file.\n\n');
    fprintf('Should the download fail with such a message then move/install the svn.exe program into a\n');
    fprintf('folder whose path does not contain any blanks/spaces and retry.\n\n');
    warning('Spaces in path to subversion client -- May cause download failure.');
end

% Does SAVEPATH work?
if exist('savepath')
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

% Do we have sufficient privileges to install at the requested location?
p='PTBWrapper123test';
[success,m,mm]=mkdir(targetdirectory,p);
if success
    rmdir(fullfile(targetdirectory,p));
else
	fprintf('Write permission test in folder %s failed.\n', targetdirectory);
    if strcmp(m,'Permission denied')
        if isOSX
            fprintf([
            'Sorry. You would need administrator privileges to install the \n'...
            'PTBWrapper into the ''%s'' folder. You can either quit now \n'...
            '(say "no", below) and get a user with administrator privileges to run \n'...
            'DownloadPTBWrapper for you, or you can install now into the \n'...
            '/Users/Shared/ folder, which doesn''t require special privileges. We \n'...
            'recommend installing into the /Applications/ folder, because it''s the \n'...
            'normal place to store programs. \n\n'],targetdirectory);
            answer=input('Even so, do you want to install the PTBWrapper into the \n/Users/Shared/ folder (yes or no)? ','s');
            if ~strcmp(answer,'yes')
                fprintf('You didn''t say yes, so I cannot proceed.\n');
                error('Need administrator privileges for requested installation into folder: %s.',targetdirectory);
            end
            targetdirectory='/Users/Shared';
        else
            % Windows: We simply fail in this case:
            fprintf([
            'Sorry. You would need administrator privileges to install the \n'...
            'PTBWrapper into the ''%s'' folder. Please rerun the script, choosing \n'...
            'a location where you have write permission, or ask a user with administrator \n'...
            'privileges to run DownloadPTBWrapper for you.\n\n'],targetdirectory);
            error('Need administrator privileges for requested installation into folder: %s.',targetdirectory);
        end
    else
        error(mm,m);
    end
end
fprintf('Good. Your privileges suffice for the requested installation into folder %s.\n\n',targetdirectory);

% Delete old PTBWrapper
skipdelete = 0;
while (exist('PTBWrapper','dir') | exist(fullfile(targetdirectory,'PTBWrapper'),'dir')) & (skipdelete == 0)
    fprintf('Hmm. You already have an old PTBWrapper folder:\n');
    p=fullfile(targetdirectory,'PTBWrapper');
    if ~exist(p,'dir')
        p=fileparts(which(fullfile('PTBWrapper','Contents.m')));
        if length(p)==0
            w=what('PTBWrapper');
            p=w(1).path;
        end
    end
    fprintf('%s\n',p);
    fprintf('That old PTBWrapper should be removed before we install a new one.\n');
	
	% Hmm... Not sure what the Contents file is yet...
    if ~exist(fullfile(p,'Contents.m'))
        fprintf(['WARNING: Your old Psychtoolbox folder lacks a Contents.m file. \n'...
            'Maybe it contains stuff you want to keep. Here''s a DIR:\n']);
        dir(p)
    end

    fprintf('First we remove all references to "PTBWrapper" from the MATLAB path.\n');
    pp=genpath(p);
    warning('off','MATLAB:rmpath:DirNotFound');
    rmpath(pp);
    warning('on','MATLAB:rmpath:DirNotFound');
    
    if exist('savepath')
       savepath;
    else
       path2rc;
    end

    fprintf('Success.\n');

    s=input('Shall I delete the old PTBWrapper folder and all its contents \n(recommended in most cases), (yes or no)? ','s');
    if strcmp(s,'yes')
        skipdelete = 0;
        fprintf('Now we delete "PTBWrapper" itself.\n');
        [success,m,mm]=rmdir(p,'s');
        if success
            fprintf('Success.\n\n');
        else
            fprintf('Error in RMDIR: %s\n',m);
            fprintf('If you want, you can delete the PTBWrapper folder manually and rerun this script to recover.\n');
            error(mm,m);
        end
    else
        skipdelete = 1;
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

% Remove "Psychtoolbox" from path
while any(regexp(path,searchpattern))
    fprintf('Your old PTBWrapper appears in the MATLAB path:\n');
    paths=regexp(path,['[^' pathsep ']*' pathsep],'match');
    fprintf('Your old PTBWrapper appears %d times in the MATLAB path.\n',length(paths));
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
    answer=input('Shall I delete all those instances from the MATLAB path (yes or no)? ','s');
    if ~strcmp(answer,'yes')
        fprintf('You didn''t say yes, so I cannot proceed.\n');
        fprintf('Please use the MATLAB "File:Set Path" command to remove all instances of "PTBWrapper" from the path.\n');
        error('Please remove PTBWrapper from MATLAB path.');
    end
    for p=paths
        s=char(p);
        if any(regexp(s,searchpattern2))
            % fprintf('rmpath(''%s'')\n',s);
            rmpath(s);
        end
    end
    if exist('savepath')
       savepath;
    else
       path2rc;
    end

    fprintf('Success.\n\n');
end

% Download PTBWrapper
if isOSX
    fprintf('I will now download the latest PTBWrapper for OSX.\n');
else
    if isLinux
        fprintf('I will now download the latest PTBWrapper for Linux.\n');
    else
        fprintf('I will now download the latest PTBWrapper for Windows.\n');
    end
end
fprintf('Requested flavor is: %s\n',flavor);
fprintf('Target folder for installation: %s\n',targetdirectory);
p=fullfile(targetdirectory,'PTBWrapper');

% Create quoted version of 'p'ath, so blanks in path are handled properly:
pt = strcat('"',p,'"');

% Choose initial download method. Defaults to zero, ie. http protocol:
if downloadmethod < 1
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' http://ptbwrapper.googlecode.com/svn/' flavor '/PTBWrapper/ ' pt];
else
    % Good to get through many firewalls and proxies:
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' https://ptbwrapper.googlecode.com/svn/' flavor '/PTBWrapper/ ' pt];
end


fprintf('The following CHECKOUT command asks the Subversion client to \ndownload the PTBWrapper:\n');
fprintf('%s\n',checkoutcommand);
fprintf('Downloading. It''s not very big. \nAlas there may be no output to this window to indicate progress until the download is complete. \nPlease be patient ...\n');
fprintf('If you see some message asking something like "accept certificate (p)ermanently, (t)emporarily? etc."\n');
fprintf('then please press the p key on your keyboard, possibly followed by pressing the ENTER key.\n\n');
if isOSX | isLinux
    [err]=system(checkoutcommand);
    result = 'For reason, see output above.';
else
    [err,result]=dos(checkoutcommand, '-echo');
end

if err & (downloadmethod == 1)
    % Failed! Let's retry it via http protocol. This may work-around overly
    % restrictive firewalls or otherwise screwed network proxies:
    fprintf('Command "CHECKOUT" failed with error code %d: \n',err);
    fprintf('%s\n\n',result);
    fprintf('Will retry now by use of alternative http protocol...\n');
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' http://ptbwrapper.googlecode.com/svn/' flavor '/PTBWrapper/ ' pt];
    fprintf('The following alternative CHECKOUT command asks the Subversion client to \ndownload the Psychtoolbox:\n');
    fprintf('%s\n\n',checkoutcommand);
    if isOSX | isLinux
        [err]=system(checkoutcommand);
        result = 'For reason, see output above.';
    else
        [err,result]=dos(checkoutcommand, '-echo');
    end    
end

if err & (downloadmethod == 0)
    % Failed! Let's retry it via https protocol. This may work-around overly
    % restrictive firewalls or otherwise screwed network proxies:
    fprintf('Command "CHECKOUT" failed with error code %d: \n',err);
    fprintf('%s\n\n',result);
    fprintf('Will retry now by use of alternative https protocol...\n');
    checkoutcommand=[svnpath 'svn checkout ' targetRevision ' https://ptbwrapper.googlecode.com/svn/' flavor '/PTBWrapper/ ' pt];
    fprintf('The following alternative CHECKOUT command asks the Subversion client to \ndownload the Psychtoolbox:\n');
    fprintf('%s\n\n',checkoutcommand);
    if isOSX | isLinux
        [err]=system(checkoutcommand);
        result = 'For reason, see output above.';
    else
        [err,result]=dos(checkoutcommand, '-echo');
    end    
end

if err
    fprintf('Sorry, the download command "CHECKOUT" failed with error code %d: \n',err);
    fprintf('%s\n',result);
    fprintf('The download failure might be due to temporary network or server problems. You may want to try again in a\n');
    fprintf('few minutes. It could also be that the subversion client was not (properly) installed. On Microsoft\n');
    fprintf('Windows you will need to exit and restart Matlab after installation of the Subversion client. If that\n');
    fprintf('does not help, you will need to reboot your machine before proceeding.\n');
    error('Download failed.');
end
fprintf('Download succeeded!\n\n');

% Add PTBWrapper to MATLAB path
fprintf('Now adding the new PTBWrapper folder (and all its subfolders) to your MATLAB path.\n');
p=fullfile(targetdirectory,'PTBWrapper');
pp=genpath(p);
addpath(pp);

if exist('savepath')
   err=savepath;
else
   err=path2rc;
end

if err
    fprintf('SAVEPATH failed. PTBWrapper is now already installed and configured for use on your Computer,\n');
    fprintf('but i could not save the updated Matlab path, probably due to insufficient permissions.\n');
    fprintf('You will either need to fix this manually via use of the path-browser (Menu: File -> Set Path),\n');
    fprintf('or by manual invocation of the savepath command (See help savepath). The third option is, of course,\n');
    fprintf('to add the path to the PTBWrapper folder and all of its subfolders whenever you restart Matlab.\n\n\n');
else 
    fprintf('Success.\n\n');
end

fprintf(['Now setting permissions to allow everyone to write to the PTBWrapper folder. This will \n'...
    'allow future updates by every user on this machine without requiring administrator privileges.\n']);
try
    if isOSX | isLinux
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

fprintf('You can now use your newly installed ''%s''-flavor PTBWrapper. Enjoy!\n',flavor);
fprintf('Whenever you want to upgrade your PTBWrapper to the latest ''%s'' version, just\n',flavor);
fprintf('run the UpdatePTBWrapper script.\n\n');

if exist('PTBWrapperPostInstallRoutine.m', 'file')
   % Notify the post-install routine of the download and its flavor.
   clear PTBWrapperPostInstallRoutine;
   PTBWrapperPostInstallRoutine(0, flavor);
end

% Puuh, we are done :)
return
