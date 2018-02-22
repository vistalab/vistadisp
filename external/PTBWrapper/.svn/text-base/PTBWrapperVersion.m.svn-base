%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: PTBWrapperVersion.m
%
% Return a string identifying this release of the PTBWrapper.
% The first three numbers identify the base version of PTBWrapper:
%
% « Leftmost: increments indicate a significant change in the feature
% set, either through accumulated progress over time or abrupt introduction
% of significant new features.
%
% « Middle: Even numbers designate a "stable" release. The objective for
% even number releases is that the software should run stably, as opposed
% to introduction of new features. An even number is not a guarantee of
% stability, but an expression of intent.  Odd numbers indicate a
% "developer" release.  Odd number releases are incomplete, the software is
% made available for the purpose of public collaboration in development.
%
% « Rightmost: A counter to distinguish multiple releases having the same
% leftmost and middle version numbers.
%
% Numeric values of the three integer fields contained in versionString are
% available in fields of the second return argument, "versionStructure".
%
% The field 'Flavor' defines the subtype of PTBWrapper being used:
% * beta: An experimental release that is already tested by the developers,
% but not yet sufficiently tested or proven in the field. Beta releases
% contain lots of new and experimental features that may be useful to you
% but that may change slightly in behaviour or syntax in the final release,
% making it necessary for you to adapt your code after a software update.
% Beta releases are known to be imperfect and fixing bugs in them is not a
% high priority.  The term 'current' is a synonym for 'beta'.
%
% * stable: A release with the intention of being well-tested and reliable.
% Fixing bugs found in stable releases has a high priority and syntax or
% behaviour of features in a stable release is not likely to change. Code
% written against a stable release should work after an update without the
% need for you to modify anything.
%
% The revision number and the provided URL allows you to visit the developer
% website in the Internet and get direct access to all development logs
% regarding your working copy of PTBWrapper.
%
% Be aware that execution of the PTBWrapperVersion command can take a
% lot of time (in the order of multiple seconds to 1 minute).
%
% Author: Doug Bemis (Really, the psychtoolbox team)
% Date: 2/5/10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PTBWrapper = PTBWrapperVersion

% Hmm... Doesn''t work yet. But, neither does the Psychtoolbox version...
global PTBWrapper
fid = fopen([PTBWrapperRoot 'Contents.m']);
fgetl(fid);
line = fgetl(fid);
[x y version day month year] = strread(line, '%s%s%s%f%s%f');
version = version{1};
delim = findstr('.',version);
PTBWrapper.major = str2num(version(1:delim(1)-1));
PTBWrapper.minor = str2num(version(delim(1)+1:delim(2)-1));
PTBWrapper.point = str2num(version(delim(2)+1:end));
PTBWrapper.date = [num2str(day) ' ' month{1} ' ' num2str(year)];

% Get past versions
line = fgetl(fid);
line = fgetl(fid);
PTBWrapper.past_versions = {};
if isempty(findstr('Past versions:', line))
	error('Bad contents file. Exiting...');
end
while 1
	line = fgetl(fid);
	[perc line] = strtok(line);
	[v line] = strtok(line);
	if isempty(v) || ~isnumeric(str2num(v))
		break;
	end
	PTBWrapper.past_versions{end+1} = {};
	PTBWrapper.past_versions{end}{1} = strtok(v);
	PTBWrapper.past_versions{end}{2} = strtok(line);
end

fclose(fid);
return;

if IsOS9
	if ~isfield(PTBWrapper,'version')
		% Get version and date of PTBWrapper from PTBWrapper:Contents.m
		PTBWrapper.version=0;
		file=fullfile(PTBWrapper,'Contents.m');
		f=fopen(file,'r');
		fgetl(f);
		s=fgetl(f);
		fclose(f);
		[PTBWrapper.version,count,errmsg,n]=sscanf(s,'%% Version %f',1);
		ss=s(n:end);
		PTBWrapper.date=ss(min(find(ss-' ')):end);
	end
	v=PTBWrapper.version;
elseif IsOSX | IsLinux | IsWin
    if ~isfield(PTBWrapper,'version')
        PTBWrapper.version.major=0;
        PTBWrapper.version.minor=0;
        PTBWrapper.version.point=0;
        PTBWrapper.version.string='';
        PTBWrapper.version.flavor='';
        PTBWrapper.version.revision=0;
        PTBWrapper.version.revstring='';
        PTBWrapper.version.websvn='';
        
        file=fullfile(PTBWrapper,'Contents.m');
		f=fopen(file,'r');
		fgetl(f);
		s=fgetl(f);
		fclose(f);
        [cvv,count,errmsg,n]=sscanf(s,'%% Version %d.%d.%d',3);
        PTBWrapper.version.major=cvv(1);
        PTBWrapper.version.minor=cvv(2);
        PTBWrapper.version.point=cvv(3);

        % Additional parser code for SVN information. This is slooow!
        svncmdpath = GetSubversionPath;
        
        % Find revision string for PTBWrapper that defines the SVN revision
        % to which this working copy corresponds:
        if ~IsWin
           [status , result] = system([svncmdpath 'svnversion -c ' PTBWrapper]);
        else
           [status , result] = dos([svncmdpath 'svnversion -c ' PTBWrapper]);
        end
        
        if status==0
            % Parse output of svnversion: Find revision number of the working copy.
            colpos=findstr(result, ':');
            if isempty(colpos)
                PTBWrapper.version.revision=sscanf(result, '%d',1);
            else
                cvv = sscanf(result, '%d:%d',2);
                PTBWrapper.version.revision=cvv(2);
            end
            if isempty(findstr(result, 'M'))
                PTBWrapper.version.revstring = sprintf('Corresponds to SVN Revision %d', PTBWrapper.version.revision);
            else
                PTBWrapper.version.revstring = sprintf('Corresponds to SVN Revision %d but is *locally modified* !', PTBWrapper.version.revision);
            end
            
            % Ok, now find the flavor and such... This is super expensive - needs network access...
            %[status , result] = system([svncmdpath 'svn info --xml -r ' num2str(Psychtoolbox.version.revision) '  ' PsychtoolboxRoot]);
            status=-1;
            if status<0 | status>0
                % Fallback path:
                if ~IsWin
                   [status , result] = system([svncmdpath 'svn info --xml ' PTBWrapper]);
                else
                   [status , result] = dos([svncmdpath 'svn info --xml ' PTBWrapper]);
                end
            end
            
            startdel = findstr(result, '/ptbwrapper/') + length('/ptbwrapper/');
            
            if isempty(startdel)
                if ~IsWin
                   [status , result] = system([svncmdpath 'svn info ' PTBWrapper]);
                else
                   [status , result] = dos([svncmdpath 'svn info ' PTBWrapper]);
                end
                startdel = findstr(result, '/ptbwrapper/') + length('/ptbwrapper/');
            end
            
            findel = min(findstr(result(startdel:length(result)), '/PTBWrapper')) + startdel - 2;
            PTBWrapper.version.flavor = result(startdel:findel);
            
            % And the date of last commit:
            startdel = findstr(result, '<date>') + length('<date>');
            findel = findstr(result, 'T') - 1;
            PTBWrapper.date = result(startdel:findel);            
            % Build final SVN URL: This is the location where one can find detailled info about this working copy:
            PTBWrapper.version.websvn = sprintf('http://svn.berlios.de/wsvn/ptbwrapper/?rev=%d&sc=0', PTBWrapper.version.revision);
            % Build final version string:
            PTBWrapper.version.string = sprintf('%d.%d.%d - Flavor: %s - %s\nFor more info visit:\n%s', PTBWrapper.version.major, PTBWrapper.version.minor, PTBWrapper.version.point, ...
                                                  PTBWrapper.version.flavor, PTBWrapper.version.revstring, PTBWrapper.version.websvn);
        else        
            % Fallback path if svn commands fail for some reason. Output as much as we can.
            fprintf('PTBWrapperVersion: WARNING - Could not query additional version information from SVN -- svn tools not properly installed?!?\n');
            PTBWrapper.version.string=sprintf('%d.%d.%d', PTBWrapper.version.major, PTBWrapper.version.minor, PTBWrapper.version.point);
            ss=s(n:end);
            PTBWrapper.date=ss(min(find(ss-' ')):end);
        end    
    end
    versionString=PTBWrapper.version.string;
    versionStructure=PTBWrapper.version;
else
    error('Unrecognized PTBWrapper platform');
end
