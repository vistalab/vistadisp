function varargout = launch(varargin)
% Launch is a GUI-based application that interacts with an experimenter to
%  select a subject-session combination to run, enrolling new subjects as
%  necessary. The enrollment process can, optionally, also collect
%  demographic information. Other versions of this call allow the user to
%  initially create the subjec-session database and obtain a history of
%  subject-sessions run.
% So that an experiment can be run simultaneously by mutliple, networked
%  computers, launch uses a (primitive, since Matlab provides no tools for
%  doing better) file-locking mechanism to ensure that only a single
%  instance of the program is updating the subject-session data at any
%  time.
% Calls:
% launch('Initialize', SubjSessFile, optDemoSex, optDemoEthnic, optDemoAge)
%   This call creates the data stores used by launch and, optionally, sets
%   options determining which of three demographic variables to collect and
%   save. It should be called only ONCE for an experiment, because
%   subsequent calls will irretriveably wipe out any information stored.
%   Arguments:
%   SubjSessFile -- Specification of a .mat file that will be used to store
%       the data used by launch. Three or four objects will be created:
%       SubjList -      a 1-D cell vector of subject identifiers
%       SessList -   a 1-D numeric vector, parallel to SubjList,
%           containing the session number of the most recent sesion run.
%       DateList -      a 1-D structure vector of session history
%       Demographics -  an optional 1-D structure vector, parallel to
%           SubjList, containing demographic data.
%   optDemoSex -    True/False: collect the sex of the participant
%   optDemoEthnic - True/False: collect ethnicity of the participant
%   optDemoAge -    True/False: colelct age of the participant
%
% [subjNum sessNum] = launch('GetSubjSess', SubjSessFile, optNoSessUpdate)
%   This call uses a specified, existing database of subject session
%     information to identify, for the calling program, the subject-session
%     combination to be run. As part of this process, new subjects may be
%     enrolled (and demographic information elicited), if necessary. So
%     that an experiment can be run simultaneously by mutliple, networked
%     computers, file-locking is used during this call.
%   Arguments:
%   SubjSessFile -- Specification of a .mat file  used to guide subject
%       and session selection. Variables in this file are also updated to
%       enroll new subjects and to record sessions.
%   optNoSessUpdate -- True/False (default flase) By default information
%       indicating that a session has been run is saved by this call. In
%       some cases, however, this may create problems if the session is not
%       completed. An alternative is to set this option to true and to call
%       launch('SaveSubjSess'), when the session is complete, to save the
%       information indicating that a session has been run.
%
% launch('SaveSubjSess')
%   This call is used, when launch('GetSubjSess') was called with the
%     optional argument optNoSessUpdate equal true to save the information
%     indicating that a session has been run. So that an experiment can be
%     run simultaneously by mutliple, networked computers, file-locking is
%     used during this call.
%
% launch('Summary', SubjSessFile, optOutputFile)
%   For each enrolled subject, this lists their name, sessions completed,
%   and any demographic information available.
%   Arguments:
%   SubjSessFile -- Specification of a .mat file created by launch.
%   optOutputFile -- (optional) Specification of a file to which the
%       summary information will be written using a tab-separated format in
%       which information for a participant is written on one line. By
%       default the output is written to the screen.
%
% launch('SessionHistory', SubjSessFile, optSubject)
%   Lists a chronological history of the sessions run.
%   Arguments:
%   SubjSessFile -- Specification of a .mat file created by launch.
%   optSubject -- Optionally limit the history to sessions for the
%       specified subject.  This can either be the subject's name or the
%       index of the subject in SubjList.

global LAUNCHsaveSessInfo LAUNCHfpath
if nargin == 0 
    error('Called with with no operation code');
end
if strcmp(varargin{1}, 'Initialize')==1
    % Create subject-session data files
    if nargin < 2
        error('Initialize requires at least the specification of SubjSessFile');
    end
    [pathstr, name, ext] = fileparts(varargin{2});
    if isempty(pathstr)
        pathstr = '.';
    elseif exist(pathstr, 'dir') ~= 7
        error('%s does not identify a valid directory', pathstr);
    end
    if ~isempty(ext) && strcmp(ext, '.mat') ~= 1
        error('Subject-session file (%s) must be a .mat file', name);
    end
    LAUNCHfpath = [pathstr '/' name '.mat'];
    % Check whether file already exists
    fileExists = 0;
    if exist(LAUNCHfpath, 'file') == 2
        fileExists = 1;
        fprintf('File %s already exists\n', LAUNCHfpath);
        fprintf('Continuing with this operation will destroy all subject-session information\n');
        fprintf('Once taken, this operation is not reversible\n');
        if ~getYN('Continue with initialization?')
            fprintf('Initialization Aborted\n')
            return
        end
    end
    % Create components of the new subject-session file
    SubjList = {};      % Cell array
    SessList = [];
    DateList = struct('Subject', [], 'Session', [], 'DateTime', []);
    Demographics = [];
    if nargin > 2 && varargin{3}
        Demographics.Sex = [];
    end
    if nargin > 3 && varargin{4}
        Demographics.Ethnicity = [];
    end
    if nargin > 4 && varargin{5}
        Demographics.Age = [];
    end
    if fileExists
        % Use append in case file has other uses
        save(LAUNCHfpath, 'SubjList', 'SessList', 'DateList', ...
            'Demographics', '-append');
    else
        save(LAUNCHfpath, 'SubjList', 'SessList', 'DateList', ...
            'Demographics');
    end
    varargout = {};

elseif strcmp(varargin{1}, 'GetSubjSess')==1
    % Check the subject-session file specification
    if nargin < 2
        error('GetSubjSess requires at least the specification of SubjSessFile');
    end
    [pathstr, name, ext] = fileparts(varargin{2});
    if isempty(pathstr)
        pathstr = '.';
    end
    if ~isempty(ext) && strcmp(ext, '.mat') ~= 1
        error('Subject-session file (%s) must be a .mat file', name);
    end
    LAUNCHfpath = [pathstr '/' name '.mat'];
%     while lockFile('Check', [pathstr '/Launch'])
%         fprintf('A lock file already exists in %s\n', pathstr);
%         if ~getYN('Do you want to continue checking?')
%             error('Could not get the Subject-Session because of a lock file problem');
%         end
%     end
%     ret= lockFile('Set', [pathstr '/Launch']);
%     if ret
%         error('Problem %d setting lockfile', ret);
%     end
    loadRet = load (LAUNCHfpath);
    % Check for our strings
    fn = fieldnames(loadRet);
    if isempty(strmatch('SubjList', fn)) || ...
            isempty(strmatch('SessList', fn)) || ...
            isempty(strmatch('DateList', fn)) || ...
            isempty(strmatch('Demographics', fn))
        error('File %s is missing needed variables', LAUNCHfpath)
    end
    
    % Actually do the interaction with the experimenter
    ret = GetSubjSessGui('Initialize', loadRet.SubjList, ...
        loadRet.SessList, loadRet.Demographics(1));
    if ~ret.GotGood
%        lockFile('Clear');
        varargout = {0, 0}; % return 0s if subject exits the subj-sess selection GUI
        return;
    end
    
    % Save the results
    doSave = false;
    if ret.NewSubj
        loadRet.SubjList{ret.SubjNum} = ret.SubjName;
        loadRet.Demographics(ret.SubjNum) = ret.Demographics;
        doSave = true;
    end
    if nargin == 3 && varargin{3}
        LAUNCHsaveSessInfo = struct('Subject', ret.SubjNum, ...
            'Session', ret.SessNum, 'DateTime', datestr(now));
    else
        % optNoSessUpdate was not specified or was false
        loadRet.SessList(ret.SubjNum) = ret.SessNum;
        if isempty(loadRet.DateList(1).Subject)
            n = 1;
        else
            n = length(loadRet.DateList)+1;
        end
        loadRet.DateList(n) = struct('Subject', ret.SubjNum, ...
            'Session', ret.SessNum, 'DateTime', datestr(now));
        doSave = true;
    end
    if doSave
        save(LAUNCHfpath, '-struct', 'loadRet');
    end
    
    % Clear the lockfile and return to user
%     lockFile('Clear');
    varargout = {ret.SubjNum, ret.SessNum};
    
elseif strcmp(varargin{1}, 'SaveSubjSess') == 1
    pathstr = fileparts(LAUNCHfpath);
%     while lockFile('Check', pathstr)
%         fprintf('A lock file already exists in %s\n', pathstr);
%         if ~getYN('Do you want to continue checking?')
%             error('Could not get the Subject-Session because of a lock file problem');
%         end
%     end
%     ret=lockFile('Set', pathstr);
%     if ret
%         error('Problem %d setting lockfile', ret);
%     end
    loadRet = load(LAUNCHfpath);
    loadRet.SessList(LAUNCHsaveSessInfo.Subject) = ...
        LAUNCHsaveSessInfo.Session;
    if isempty(loadRet.DateList(1).Subject)
        n = 1;
    else
        n = length(loadRet.DateList)+1;
    end
    loadRet.DateList(n) = LAUNCHsaveSessInfo;
    save(LAUNCHfpath, '-struct', 'loadRet');
    % Clear the lockfile and return to user
%     lockFile('Clear');
%     varargout = {};

elseif strcmp(varargin{1}, 'Summary') == 1
    if nargin == 1 || nargin > 3
        error('Summary expects 2 or 3 arguments: the Subject-Session file and the optional output file');
    end
    ret = load(varargin{2});
    ns = length(ret.SubjList);
    if nargin == 3
        [fid, message] = fopen(varargin{3}, 'w');
        if fid == -1
            error(message);
        end
    else
        fid = 1;
    end
    if fid == 1
        fprintf(fid, ...
            'Subject Name        Last Sess   Sex     Ethnicity            Age\n');
    end
    for s = 1:ns
        if fid == 1
            fprintf(fid, '%-20s    %2d      %-8s%-20s%3d\n', ret.SubjList{s}, ...
                ret.SessList(s), ret.Demographics(s).Sex, ...
                ret.Demographics(s).Ethnicity, ret.Demographics(s).Age);
        else
            fprintf(fid, '%s\t%d\t%s\t%s\t%d\n', ret.SubjList{s}, ...
                ret.SessList(s), ret.Demographics(s).Sex, ...
                ret.Demographics(s).Ethnicity, ret.Demographics(s).Age);
        end
    end

elseif strcmp(varargin{1}, 'SessionHistory') == 1
    if nargin == 1 || nargin > 3
        error('SessionHistory expects 2 or 3 arguments: the Subject-Session file and the optional Subject');
    end
    ret = load(varargin{2});
    if nargin == 3
        subj = varargin{3};
        if ischar(subj)
            subj = strmatch(subj, ret.SubjList, 'exact');
            if isempty(subj)
                error('Could not match Subject Name %s', varargin{3});
            end
        end
    else
        subj = 0;
    end
    fprintf('Subj# Sess# Date/Time\n');
    for i=1:length(ret.DateList)
        if subj == 0 || subj == ret.DateList(i).Subject
            fprintf('%3d%6d   %s\n', ret.DateList(i).Subject, ...
                ret.DateList(i).Session, ret.DateList(i).DateTime);
        end
    end
    
else
    error('%s is an unknown operation', varargin{1});
end
end