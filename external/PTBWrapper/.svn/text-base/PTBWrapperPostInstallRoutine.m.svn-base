%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWrapperPostInstallRoutine(isUpdate [, flavor])
%
% NOTE: Internal function. DO NOT CALL.
%
% PTBWrapper post installation routine. You should not call this
% function directly! This routine is called by DownloadPTBWrapper,
% or UpdatePTBWrapper after a successfull download/update of
% PTBWrapper. The routine performs tasks that are common to
% downloads and updates, so they can share their code/implementation.
%
% As PTBWrapperPostInstallRoutine itself is downloaded or updated,
% it can contain code specific to each PTBWrapper revision/release
% to perform special setup procedures for new features, to announce
% important info to the user, whatever...
%
% Currently the routine performs the following tasks:
%
% 1. Clean up the Matlab path to PTBWrapper: Remove unneeded .svn subfolders.
% 2. Contact the Psychtoolbox server to perform online registration of this
%    working copy of Psychtoolbox.
%
% Author: Doug Bemis (really the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBWrapperPostInstallRoutine(isUpdate, flavor)

fprintf('\n\nRunning post-install routine...\n\n');

if nargin < 1
   error('PTBWrapperPostInstallRoutine: Required argument isUpdate missing!');
end;

if nargin < 2
    % No flavor provided: Default to 'unknown', but try to determine it from the
    % flavor file if this is an update.
    flavor = 'unknown';
    try
        if isUpdate>0
            % This is an update of an existing working copy. Check if flavor-file
            % is available:
            flavorfile = [PTBWrapperRoot 'ptbwrapperflavorinfo.txt'];
            if exist(flavorfile, 'file')
                fd=fopen(flavorfile);
                if fd > -1
                    flavor = fscanf(fd, '%s');
                    fclose(fd);
                end
            end
            
            % Still unknown?
            if strcmp(flavor, 'unknown')
				error('Not using this yet');
                % Yep: Retry in users PTBWrapperConfigDir:
                flavorfile = [PTBWrapperConfigDir 'ptbwrapperflavorinfo.txt'];
                if exist(flavorfile, 'file')
                    fd=fopen(flavorfile);
                    if fd > -1
                        flavor = fscanf(fd, '%s');
                        fclose(fd);
                    end
                end
            end
        end
    catch
        fprintf('Info: Failed to determine flavor of this PTBWrapper. Not a big deal...\n');
    end
else
    % Handle 'current' as synonym for 'beta', and 'unsupported' as synonym
    % for former 'stable'.
    switch (flavor)
        case 'current'
            flavor = 'beta';
        case 'unsupported'
            flavor = 'stable';
    end
    
    % Flavor provided: Write it into the flavor file for use by later update calls:
    try
        flavorfile = [PTBWrapperRoot 'ptbwrapperflavorinfo.txt'];
        fd=fopen(flavorfile, 'wt');
        if fd > -1
            fprintf(fd, '%s\n', flavor);
            fclose(fd);
        end
    catch
        fprintf('Info: Failed to store flavor of this PTBWrapper to file. Not a big deal...\n');
        % Retry with users PTBWrapperConfigDir:
        try
			error('Not using this yet.');
            flavorfile = [PTBWrapperConfigDir 'ptbwrapperflavorinfo.txt'];
            fd=fopen(flavorfile, 'wt');
            if fd > -1
                fprintf(fd, '%s\n', flavor);
                fclose(fd);
            end
        catch
            fprintf('Info: Failed to store flavor of this PTBWrapper to file a 2nd time. Not a big deal...\n');
        end
    end
end

% Get rid of any remaining .svn folders in the path.
try
    path(RemoveSVNPaths);
    if exist('savepath')
        savepath;
    else
        path2rc;
    end
catch
    fprintf('Info: Failed to remove .svn subfolders from path. Not a big deal...\n');
end

% Check for operating system minor version on Mac OS/X when running under
% Matlab:
if IsOSX
    if ~IsOctave %#ok<AND2>
        % Running on Matlab + OS/X. Find the operating system minor version,
        % i.e., the 'y' in the x.y.z number, e.g., y=3 for 10.3.7:

        % Get 32-digit binary encoded minor version from Gestalt() MEX file:
        binminor = Gestalt('sys2');

        % Decode into decimal digit:
        minorver = 0;
        for i=1:32
            minorver = minorver + binminor(i) * 2^(32-i);
        end
    else
        % Running on Octave + OS/X: Query kernel version via system() call:
        [s, did]=system('uname -r');
        if s == 0
            % Parse string for kernel major number, then translate to OS
            % minor version by subtracting 4:
            minorver = sscanf(did, '%i') - 4;
        else
            % Failed to query: Assume we're good for now...
            minorver = inf;
        end
    end
    
    % Is the operating system minor version 'minorver' < 4?
    if minorver < 4
        % Yes. This is MacOS/X 10.3 or earlier, i.e., older than 10.4
        % Tiger. In all likelihood, this current PTB release won't work on
        % such a system anymore, because some of the binary MEX files are
        % linked against incompatible runtimes and frameworks. Output a
        % clear warning message about this, with tips on how to resolve the
        % problem:
        fprintf('\n\n\n\n\n\n\n\n==== WARNING WARNING WARNING WARNING ====\n\n');
        fprintf('Your operating system is Mac OS/X version 10.%i.\n\n', minorver);
        fprintf('This release of PTBWrapper is likely not to be compatible\n');
        fprintf('to OS/X versions older than 10.4 "Tiger".\n\n');
        fprintf('That means that some or many crucial functions will fail.\n');
        fprintf('We strongly recommend that you upgrade your system to a more recent OS/X version soon.\n\n');
        fprintf('Thanks for your attention and good luck!');
        fprintf('\n\n\n==== WARNING WARNING WARNING WARNING ====\n\n\n');
        fprintf('Press any key on keyboard to continue with setup...\n');
        pause;
    end
end

% Special case handling for Octave:
if IsOctave
	error('Shouldn''t get here yet.');
	% OS/X or Linux under Octave. Need to prepend the proper folder with
    % the pseudo-MEX files to path:
    rc = 0;
    rdir = '';
    
    try
        % Remove binary MEX folders from path:
        rmpath([PsychtoolboxRoot 'PsychBasic' filesep 'Octave3LinuxFiles']);
        rmpath([PsychtoolboxRoot 'PsychBasic' filesep 'Octave3OSXFiles']);
        rmpath([PsychtoolboxRoot 'PsychBasic' filesep 'Octave3WindowsFiles']);
        
        % Encode prefix and Octave major version of proper folder:
        octavev = sscanf(version, '%i.%i');
        octavemajorv = octavev(1);
        octaveminorv = octavev(2);
        
        rdir = [PsychtoolboxRoot 'PsychBasic' filesep 'Octave' num2str(octavemajorv)];
        
        % Add proper OS dependent postfix:
        if IsLinux
            rdir = [rdir 'LinuxFiles'];
        end
        
        if IsOSX
            rdir = [rdir 'OSXFiles'];
        end
        
        if IsWin
            rdir = [rdir 'WindowsFiles'];
        end

        fprintf('Octave major version %i detected. Will prepend the following folder to your Octave path:\n', octavemajorv);
        fprintf(' %s ...\n', rdir);
        addpath(rdir);
        
        if exist('savepath')
            rc = savepath;
        else
            rc = path2rc;
        end
    catch
        rc = 2;
    end

    if rc > 0
        fprintf('=====================================================================\n');
        fprintf('ERROR: Failed to prepend folder %s to Octave path!\n', rdir);
        fprintf('ERROR: This will likely cause complete failure of PTB to work.\n');
        fprintf('ERROR: Please fix the problem (maybe insufficient permissions?)\n');
        fprintf('ERROR: If everything else fails, add this folder manually to the\n');
        fprintf('ERROR: top of your Octave path.\n');
        fprintf('ERROR: Trying to continue but will likely fail soon.\n');
        fprintf('=====================================================================\n\n');
    end
    
    if octavemajorv < 3 | octaveminorv < 2
        fprintf('\n\n=================================================================================\n');
        fprintf('WARNING: Your version %s of Octave is obsolete. We strongly recommend\n', version);
        fprintf('WARNING: using the latest stable version of at least Octave 3.2.0 for use with Psychtoolbox.\n');
        fprintf('WARNING: Stuff may not work at all or only suboptimal with earlier versions and we\n');
        fprintf('WARNING: don''t provide any support for such old versions.\n');
        fprintf('\nPress any key to continue with setup.\n');
        fprintf('=================================================================================\n\n');
        pause;
    end
    
    try
        % Rehash the Octave toolbox cache:
        path(path);
        rehash;
        clear WaitSecs;
    catch
        fprintf('WARNING: rehashing the Octave toolbox cache failed. I may fail and recommend\n');
        fprintf('WARNING: Quitting and restarting Octave, then retry.\n');
    end
    
    try
        % Try if Screen MEX file works...
        WaitSecs(0.1);
    catch
        % Failed! Either screwed setup of path or missing VC++ 2005 runtime
        % libraries.
        fprintf('ERROR: WaitSecs-MEX does not work, most likely other MEX files will not work either.\n');
        fprintf('ERROR: One reason might be that your version %s of Octave is incompatible. We recommend\n', version);        
        fprintf('ERROR: use of the latest stable version of Octave-3.2.x as announced on www.octave.org website.\n');
        fprintf('ERROR: Another conceivable reason would be missing or incompatible required system libraries on your system.\n\n');
        fprintf('ERROR: After fixing the problem, restart this installation/update routine.\n\n');
        fprintf('\n\nInstallation aborted. Fix the reported problem and retry.\n\n');
        return;
    end
    
    % End of special Octave setup.
end

% Special case handling for different Matlab releases on MS-Windoze:
if IsWin & ~IsOctave
    rc = 0;
    try
        % Remove DLL folders from path:
        rmpath([PsychtoolboxRoot 'PsychBasic\MatlabWindowsFilesR11\']);
        rmpath([PsychtoolboxRoot 'PsychBasic\MatlabWindowsFilesR2007a\']);
        
        % Is this a Release2007a or later Matlab?
        if ~isempty(strfind(version, '2007')) | ~isempty(strfind(version, '2008')) | ~isempty(strfind(version, '2009')) | ~isempty(strfind(version, '2010'))
            % This is a R2007a or post R2007a Matlab:
            % Add PsychBasic/MatlabWindowsFilesR2007a/ subfolder to Matlab
            % path:
            rdir = [PsychtoolboxRoot 'PsychBasic\MatlabWindowsFilesR2007a\'];
            fprintf('Matlab release 2007a or later detected. Will prepend the following\n');
            fprintf('folder to your Matlab path: %s ...\n', rdir);
            addpath(rdir);
        else
            % This is a pre-R2007a Matlab:
            % Add PsychBasic/MatlabWindowsFilesR11/ subfolder to Matlab
            % path:
            rdir = [PsychtoolboxRoot 'PsychBasic\MatlabWindowsFilesR11\'];
            fprintf('Matlab release prior to R2007a detected. Will prepend the following\n');
            fprintf('folder to your Matlab path: %s ...\n', rdir);
            addpath(rdir);
        end

        if exist('savepath')
            rc = savepath;
        else
            rc = path2rc;
        end
    catch
        rc = 2;
    end

    if rc > 0
        fprintf('=====================================================================\n');
        fprintf('ERROR: Failed to prepend folder %s to Matlab path!\n', rdir);
        fprintf('ERROR: This will likely cause complete failure of PTB to work.\n');
        fprintf('ERROR: Please fix the problem (maybe insufficient permissions?)\n');
        fprintf('ERROR: If everything else fails, add this folder manually to the\n');
        fprintf('ERROR: top of your Matlab path.\n');
        fprintf('ERROR: Trying to continue but will likely fail soon.\n');
        fprintf('=====================================================================\n\n');
    end
    
    try
        % Rehash the Matlab toolbox cache:
        path(path);
        rehash('pathreset');
        rehash('toolboxreset');
        clear WaitSecs;
    catch
        fprintf('WARNING: rehashing the Matlab toolbox cache failed. I may fail and recommend\n');
        fprintf('WARNING: Quitting and restarting Matlab, then retry.\n');
    end
    
    try
        % Try if Screen MEX file works...
        WaitSecs(0.1);
    catch
        % Failed! Either screwed setup of path or missing VC++ 2005 runtime
        % libraries.
        fprintf('ERROR: WaitSecs-MEX does not work, most likely other MEX files will not work either.\n');
        fprintf('ERROR: Most likely cause: The Visual C++ 2005 runtime libraries are missing on your system.\n\n');
        fprintf('ERROR: Visit http://www.mathworks.com/support/solutions/data/1-2223MW.html for instructions how to\n');
        fprintf('ERROR: fix this problem. That document tells you how to download and install the required runtime\n');
        fprintf('ERROR: libraries. It is important that you download the libraries for Visual C++ 2005 SP1\n');
        fprintf('ERROR: - The Service Pack 1! Follow the link under the text "For VS 2005 SP1 vcredist_x86.exe:"\n');
        fprintf('ERROR: If you install the wrong runtime, it will still not work.\n\n');
        fprintf('ERROR: After fixing the problem, restart this installation/update routine.\n\n');

        if strcmp(computer,'PCWIN64')
            % 64 bit Matlab running on 64 bit Windows?!? That won't work.
            fprintf('ERROR:\n');
            fprintf('ERROR: It seems that you are running a 64-bit version of Matlab on your system.\n');
            fprintf('ERROR: That won''t work at all! Psychtoolbox currently only supports 32-bit versions\n');
            fprintf('ERROR: of Matlab.\n');
            fprintf('ERROR: You can try to exit Matlab and then restart it in 32-bit emulation mode to\n');
            fprintf('ERROR: make Psychtoolbox work on your 64 bit Windows. You do this by adding the\n');
            fprintf('ERROR: startup option -win32 to the matlab.exe start command, ie.\n');
            fprintf('ERROR: matlab.exe -win32\n');
            fprintf('ERROR: If you do not know how to do this, consult the Matlab help about startup\n');
            fprintf('ERROR: options for Windows.\n\n');
        end
        
        fprintf('\n\nInstallation aborted. Fix the reported problem and retry.\n\n');
        return;
    end
end

% Try to execute online registration routine: This should be fail-safe in case
% of no network connection.
% No registration yet
%fprintf('\n\n');
%PTBWrapperRegistration(isUpdate, flavor);
fprintf('\n\n\n');

% Some goodbye, copyright and getting started blurb...
fprintf('\nDone with post-installation. PTBWrapper is ready for use.\n\n\n');
fprintf('GENERAL LICENSING CONDITIONS:\n');
fprintf('-----------------------------\n\n');
fprintf('Almost all of the material contained in the PTBWrapper distribution\n');
fprintf('is free software. All material is covered by the GNU General Public license (GPL).\n');
fprintf('PTBWrapper is free software; you can redistribute it and/or modify\n');
fprintf('it under the terms of the GNU General Public License as published by\n');
fprintf('the Free Software Foundation; either version 2 of the License, or\n');
fprintf('(at your option) any later version. See the file ''License.txt'' in\n');
fprintf('the PTBWrapper root folder for exact licensing conditions.\n\n');

fprintf('\nEnjoy!\n\n');

% Clear out everything:
if ~IsOctave & IsWin
    clear all;
end
     
return;
