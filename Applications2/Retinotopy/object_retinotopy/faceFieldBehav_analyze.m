function anal = faceFieldBehav_analyze(subjects, dts, varargin);
% Analyze face field behavioral control experiment across subjects.
%
%   anal = faceFieldBehav_analyze(subjects, dts, options);
%
% subjects: cell array of subject names. You should have data files in the
% code/Data directory with these subject names as prefixes (within the
% vistadisp repository). [Default: dialog.]
%
% dts: data types to analyze. [Default: {'NoScaling' 'ScaleFactor2'
% 'FullFaces'}].
%
%
% ras, 12/07/2009.
if notDefined('subjects')
	subjects = getSubjectsDialog;
elseif isequal( lower(subjects), 'all' )
	subjects = getAllSubjects;
end

if notDefined('dts')
	dts = {'no_scaling' 'scale_factor_2' 'full_faces'};
end

%% params
anal.dts = dts;
anal.subjects = subjects;
anal.allStim = [];		% struct with the 'fullRecord' entries from all data files
anal.dtNames = {'Unscaled' 'Scaled' 'FullField'};
anal.colors = {'k' 'r' 'b'};
anal.styles = {'2o-' '2d-' '2s-'};
anal.doPlot = 1;

%% parse options
for ii = 2:2:length(varargin)
	param = varargin{ii-1};
	val = varargin{ii};
	anal.(param) = val;
end


%% gather data from each subject
for s = 1:length(subjects)
	[anal.subjData(s) anal.allStim] = analyzeSubjectData(anal.subjects{s}, ...
														dts, anal.allStim);
end

%% compute across-subjects performance
anal = acrossSubjectsPerformance(anal);

%% plot
if anal.doPlot==1
	anal = plotFaceFieldBehavData(anal);
end


return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function subjects = getSubjectsDialog;
%% put up a dialog to select the subjects to analyze, based on the data
%% files available.
dlg.fieldName = 'subjects';
dlg.style = 'listbox';
dlg.string = 'Analyze which subjects?';
dlg.list = getAllSubjects;
dlg.value = 1;

[resp ok] = generalDialog(dlg, 'Analyze Face Field Behav Data');
if ~ok
	error('User aborted')
end

subjects = resp.subjects;

return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function allSubjects = getAllSubjects;
%% find a list of all subjects for which we have data files.
codeDir = fileparts(which(mfilename));
pattern = fullfile(codeDir, 'Data', '*_no_scaling_behav.mat');
w = dir(pattern);
if isempty(w)
	error('No data files found in %s\Data.', codeDir);
end

allFiles = {w.name};
for f = 1:length(allFiles)
	vals = explode('_', allFiles{f});
	allSubjects{f} = vals{1};
end

return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function [A allStim] = analyzeSubjectData(subj, dts, allStim);
%% analyze all runs from one subject, returning the data structure A.
codeDir = fileparts(which(mfilename));
dataDir = fullfile(codeDir, 'Data');

for d = 1:length(dts)
	% find and load the data file for this data type
	dataFile = fullfile(dataDir, [subj '_' dts{d} '_behav.mat']);
	if ~exist(dataFile, 'file')
		error('Required data file %s not found.', dataFile);
	end

	load(dataFile, 'fullRecord');
	allStim = [allStim fullRecord];
	
	% recompute the task performance for each run; this corrects for some
	% updates to the task performance code since the data were collected
	for r = 1:length(fullRecord)
		fullRecord(r) = computeTaskPerformance(fullRecord(r));
	end
	
	% get all responses across runs
	allresp = [fullRecord.responses];
	fields = {'cond' 'image' 'orientation' 'position' 'gender' ...
			  'isMatch' 'whichKey' 'responseIndex' 'isCorrect' ...
			  'responseTime'};
	for f = 1:length(fields)
		fld = fields{f};
		A.(fld) = [allresp.(fld)];
	end
	
	% compute mean percent correct and response time for each position
	% (I'm going to hard code the position #s for now; if we try different
	% designs, this will need to be more complex. But maybe we're ok.)
	for p = 1:12
		I = find(A.position==p);
		A.pc(p,d) = 100 * nanmean( A.isCorrect(I) );
		A.rt(p,d) = nanmean( A.responseTime(I) );
		A.rt_sem(p,d) = nanstd( A.responseTime(I) ) ./ sqrt(length(I)-1);		
	end
	
	% also compute an estimate of performance based on distance of each bar
	% position from the fixation point
	% again, I'm using a manual indexing, based on the design with 12 vertical 
	% bar positions.
	condOrder = {[6 7] [5 8] [4 9] [3 10] [2 11] [1 12]};
	for c = 1:6
		I = find( ismember(A.position, condOrder{c}) );
		A.pcByEcc(c,d) = 100 * nanmean( A.isCorrect(I) );
		A.rtByEcc(c,d) = nanmean( A.responseTime(I) );
		A.rtByEcc_sem(c,d) = nanstd( A.responseTime(I) ) ./ sqrt(length(I)-1);		
	end
end


return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function stim = computeTaskPerformance(stim);
%% compute performance on the face recognition task for the just-completed
%% run.

%% extract only the behaviorally relevant events
% (we ignore 'blank' image offsets and end-of-run events)
ok = 2:2:length(stim.cond);
stim.responses.cond = stim.cond(ok);
stim.responses.image = stim.image(ok);
stim.responses.orientation = stim.orientation(ok);
stim.responses.position = stim.position(ok);
stim.responses.gender = stim.gender(ok);
stim.responses.isMatch = stim.isMatch(ok);
stim.responses.whichKey = stim.responses.keyCode(ok)';
stim.responses.responseTime = stim.responses.secs(ok) - stim.seqtiming(ok-1);

% sometimes the response time is screwed up and is zero or negative -- set
% these to NaNs
stim.responses.responseTime( stim.responses.responseTime < 0.3 ) = NaN;

% empirically derived: the 'isMatch' field is shifted by 1 event for some
% reason. We'll correct it here:
stim.responses.isMatch = circshift(stim.responses.isMatch(:), 1)';

%% for the 'whichKey' field, map from the key code for each guess to the
%% 'response index': that is, whether the pressed key indicated the subject
%% thought it was a match (1) or nonmatch (2).
responseIndex = zeros( size(stim.responses.cond) );
responseIndex( stim.responses.whichKey==stim.responseKeys(1) ) = 1;
responseIndex( stim.responses.whichKey==stim.responseKeys(2) ) = 2;

% let's also map keypresses for invalid keys: whichKey will be nonzero, but
% not be a member of either of the response keys:
invalid = find( stim.responses.whichKey > 0 & ...
                ~ismember(stim.responses.whichKey, stim.responseKeys) );
responseIndex(invalid) = -1;
if length(invalid) > 10
    warning('Subject pressed invalid key for >10 trials.')
end
    
stim.responses.responseIndex = responseIndex;

%% compute whether each trial was correct.
stim.responses.isCorrect = (responseIndex==stim.responses.isMatch);
stim.responses.percentCorrect = 100 * mean(stim.responses.isCorrect);

% for now, I will hard-code a loop across size and eccentricity. If I also
% test other dimensions, such as polar angle, I will need to modify this
% code
ori = unique(stim.responses.orientation);
pos  = unique(stim.responses.position);
ori = ori( ori > 0 );
pos   = pos( pos > 0 );
for p = 1:length(pos)
    for o = 1:length(ori)
        currOri = ori(o);
        I = find(stim.responses.orientation==currOri & ...
                 stim.responses.position==pos(p));
        stim.responses.pc(p,o) = 100 * nanmean( stim.responses.isCorrect(I) );
		stim.responses.rt(p,o) = nanmean( stim.responses.responseTime(I) );
    end
end

return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function anal = acrossSubjectsPerformance(anal);
%% compute the performance for each stimulus position and data type across
%% subjects.
nSubjects = length(anal.subjects);

for s = 1:nSubjects
	anal.pc(:,:,s) = anal.subjData(s).pc;
	anal.rt(:,:,s) = anal.subjData(s).rt;
	
	anal.pcByEcc(:,:,s) = anal.subjData(s).pcByEcc;
	anal.rtByEcc(:,:,s) = anal.subjData(s).rtByEcc;	
end

anal.meanPC = nanmean(anal.pc, 3);
anal.semPC = nanstd(anal.pc, [], 3) ./ sqrt(nSubjects - 1);

anal.meanRT = nanmean(anal.rt, 3);
anal.semRT = nanstd(anal.rt, [], 3) ./ sqrt(nSubjects - 1);

anal.meanPCByEcc = nanmean(anal.pcByEcc, 3);
anal.semPCByEcc = nanstd(anal.pcByEcc, [], 3) ./ sqrt(nSubjects - 1);

anal.meanRTByEcc = nanmean(anal.rtByEcc, 3);
anal.semRTByEcc = nanstd(anal.rtByEcc, [], 3) ./ sqrt(nSubjects - 1);


% we'll also want to grab an example display struct for easy access
% (this should be the same for all data files)
anal.display = anal.allStim(1).display;

return
% /-------------------------------------------------------------/ %



% /-------------------------------------------------------------/ %
function anal = plotFaceFieldBehavData(anal);
%% plot the results of the across-subjects analysis.

% reminder: this is how I figure out the eccentricity of the bar centers.
anal.distance = 64; % post-hoc correction for the actual distance of the display
radiusDeg = pix2angle(anal.display, 600); % max ecc of image=600 pixels
xPos = linspace(-radiusDeg, radiusDeg, 14);
xPos = repmat( xPos(8:13)', [1 3] );

% open the figure
name = ['Face Field Behav Results: '];
for s = 1:length(anal.subjects)
	name = [name ' ' anal.subjects{s}];
end
	
anal.fig = figure('Color', 'w', 'Units', 'norm', 'Position', [.2 .2 .5 .5], ...
				  'Name', name);
			  
% mean percent correct by condition
anal.hAx(1) = subplot(2, 2, 1);
errorbar(anal.meanPC, anal.semPC);
setLineColors(anal.colors);
setLineStyles(anal.styles);
axis([0 13 50 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 2, ...
	'XTick', 1:12);
xlabel('Bar Position', 'FontSize', 16);
ylabel('Percent Correct', 'Fontsize', 16);

% mean percent correct by eccentricity
anal.hAx(2) = subplot(2, 2, 2);
errorbar(xPos, anal.meanPCByEcc, anal.semPCByEcc);
setLineColors(anal.colors);
setLineStyles(anal.styles);
axis([0 13 50 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 2, ...
	'XTick', 1:12);
xlabel('Eccentricity (°)', 'FontSize', 16);
ylabel('Percent Correct', 'Fontsize', 16);

% mean response time by condition
anal.hAx(3) = subplot(2, 2, 3);
errorbar(anal.meanRT, anal.semRT);
setLineColors(anal.colors);
setLineStyles(anal.styles);
axis auto
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 2, ...
	'XTick', 1:12);
xlabel('Bar Position', 'FontSize', 16);
ylabel('Response Time (s)', 'Fontsize', 16);

% mean response time by eccentricity
anal.hAx(4) = subplot(2, 2, 4);
errorbar(xPos, anal.meanRTByEcc, anal.semRTByEcc);
setLineColors(anal.colors);
setLineStyles(anal.styles);
axis auto
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 12, 'LineWidth', 2, ...
	'XTick', 1:12);
xlabel('Eccentricity (°)', 'FontSize', 16);
ylabel('Response Time (s)', 'Fontsize', 16);

legendPanel(anal.dtNames, anal.colors);

return
