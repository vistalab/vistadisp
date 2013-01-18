function stim = facebehav_readscript(scriptPath, stim);
%
%  stim = facebehav_readscript(scriptPath, stim);
%
% Reads in a script for the face recognition behavior experiments,
% returning a stimulus struct.
%
% ras, 06/22/2009.
if notDefined('scriptPath')
    [scriptPath ok] = mrvSelectFile('r', 'txt', 'Select a script...', 'Scripts');
    if ~ok, error('User Aborted.');  end
end

%% check that file exists
if ~exist(scriptPath, 'file')
    % chceck if the file is specified relative to the Scripts/ directory of
    % the code dir
    codeDir = fileparts( which(mfilename) );
    scriptDir = fullfile(codeDir, 'Scripts');
    [p f ext] = fileparts(scriptPath);
    
    altName = fullfile(scriptDir, [f '.txt']);
    if exist(altName, 'file')
        scriptPath = altName;
    else
        error('File %s not found, nor a similar file in %s.', scriptPath, ...
                scriptDir);
    end
end

%% init empty stim fields
stim.bgColor = 165;  % background color for faces
stim.trialNum = [];
stim.onset = [];
stim.cond = [];
stim.faceSize = [];
stim.faceEcc = [];
stim.faceAngle = [];
stim.isMatch = [];
stim.image = {};

[p f ext] = fileparts(scriptPath);
dash = find(f=='-');
stim.task = f(1:dash(1)-1);

%% open the file
fid = fopen(scriptPath, 'r');

%% read the header
% skip the first line
fgetl(fid);

% get the noise level and expected run length
vals = explode(sprintf('\t'), fgetl(fid));
if length(vals)==1
    % older script, can only get run length
    stim.runLength = sscanf(vals{1}, 'Run length: %f seconds\n');
else
    % newer script, can get both noise level and run length
    openparen = strfind(vals{1}, '(');
    stim.noiseLevel = str2num( vals{1}(1:openparen(1)-1) );
    stim.noiseType = vals{1}(openparen(1)+1:end-1);
    stim.runLength = sscanf(vals{2}, 'Run length: %f seconds\n');
end    

% get the task question
ln = fgetl(fid);
vals = explode(':', ln);
stim.taskStr = vals{2}(2:end);

% skip the column-header line
fgetl(fid);

%% read in the main lines
while ~feof(fid)
	ln = fgetl(fid);
	
	vals = explode( sprintf('\t'), ln );
	
	if length(vals) < 5
		if findstr(ln, '***')    % end of run indicator
			break
		else
			error( sprintf('Improperly formed line. %s', ln) );
		end
	end
	
	stim.trialNum(end+1) = str2num(vals{1});
	stim.onset(end+1) = str2num(vals{2});
	stim.cond(end+1) = str2num(vals{3});
	stim.faceSize(end+1) = str2num(vals{4});
    stim.faceEcc(end+1) = str2num(vals{5});
	stim.faceAngle(end+1) = str2num(vals{6});
	stim.isMatch(end+1) = str2num(vals{7});
	stim.image{end+1} = parseImagePath(vals{8}, 'FaceBehavImages');
end

% done with the file
fclose(fid);

return
% /--------------------------------------------------------------------/ %




% /--------------------------------------------------------------------/ %
function imgPath = parseImagePath(imgPath, imageDir);
% make an image path relative to the specified images directory for the current 
% machine. This allows for scripts to be more portable; the images specified in the 
% script only need to be relative to the string specified in 'imageDir'.
% (In practice, for the face behavior experiments, I'm guessing it will be
% more convenient to simply regenerate the scripts and images anew for each
% computer. But this step has proven useful in the past, for instance with
% the face bar retinotopy, so I preserve the practice of portability.)
if ~strncmp(imgPath, 'blank', 5)
    % figure out the file separator: depends on what system generated
    % the script
    if ~isempty( findstr(imgPath, '/') )
        sep = '/';
    else
        sep = '\';
    end
    
    % break up into subdirectory strings
    pth = explode(sep, imgPath);
    
    % find the entry for 'FaceBehavImages'
    iStart = strmatch(imageDir, pth);
    if isempty(iStart)
        error('Invalid path.')
    end
    
    % set up the updated image path
    imgPath = fileparts(which(mfilename));
    for ii = iStart:length(pth)
        imgPath = fullfile(imgPath, pth{ii});
    end
    
    % (there will be a space character at the end, added by explode;
    % ignore this)
    imgPath = imgPath(1:end-1);
end

return

    