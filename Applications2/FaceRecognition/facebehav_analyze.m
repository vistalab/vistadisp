function anal = facebehav_analyze(exptName, subjects, runs, varargin);
% Analyze face recognition behavioral data.
%
%   anal = facebehav_analyze(exptName, subjects, [runs, options]);
%
% INPUTS:
%   exptName: name of task and image set to analyze. Example: 'gender-1'.
%   For multiple-subject analysis, this can be a cell array with the name
%   of the task for each subject. Or, you can enter just the task name
%   ('gender', 'identify', 'categorize', etc): the code will look for all
%   available data files with that task name, provide you a dialog to
%   select which data sets to analyze.
%
%   subjects: name of subject or subjects to analyze. (Use a cell array for
%   multiple subjects; otherwise can be a string.)
%
%   runs: set of runs to analyze. For multiple subjects, enter a string
%   with the set of runs for each subject. [Default: analyze all runs found
%   in the data file.]
%
% OUTPUTS:
%   anal: analysis struct.
%
% ras, 07/02/09.
if notDefined('exptName'), 	exptName = 'identify';			end

if ismember( lower(exptName), {'gender' 'identify' 'detect' 'categorize'} )
	[exptName subjects] = selectDataDialog( lower(exptName) );
end

if ischar(exptName),	exptName = {exptName};			end
	
codeDir = fileparts(which(mfilename));
dataDir = fullfile(codeDir, 'Data');

if notDefined('subjects')
    % analyze all subjects for which data is found
    pattern = fullfile(dataDir, ['*_' exptName{1} '*.mat']);
    w = dir(pattern);
	for ii = 1:length(w)
        vals = explode('_', w(ii).name);
        allnames{ii} = vals{1};
    end
    subjects = unique(allnames);
end

if isempty(subjects)
    error('No subjects found or specified.')
end

if ischar(subjects),     subjects = {subjects};				end


if notDefined('runs')
    for ii = 1:length(subjects)
        runs{ii} = [];
    end
elseif isnumeric(runs), 
    runs = {runs};
end

%% params
plotFlag = 1; % flag to plot the results

% parse the options
for ii = 1:2:length(varargin)
    eval('%s = %s;', varargin{ii}, num2str(varargin{ii+1}));
end

%% loop across subjects
for s = 1:length(subjects)
    subjAnal{s} = facebehav_analyzeSubject(exptName{s}, subjects{s}, ...
                                            runs{s}, dataDir);
end

%% compile across subjects
anal = compileSubjectData(subjAnal);	

%% plot the results
if plotFlag==1
% 	anal = acrossSubjects_plotSizeFits(anal);
	anal = fitAcrossSubjectsData(anal);
	anal = facebehav_plotAnalysis_acrossSubjects(anal);
end

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function [exptName subjects] = selectDataDialog(task);
%% dialog to select which experiments and subject to analyze for a given
%% task.

% first, find all data files which could contain subject data for this
% task.
codeDir = fileparts(which(mfilename));
dataDir = fullfile(codeDir, 'Data');
pattern = fullfile(dataDir, ['*_' task '-*.mat']);
w = dir(pattern);

% I may want to add a filter which verifies that each of the files in w has
% proper face-behavior data. For now, I'll just take 'em all.

% prompt the user to select those files to analyze.
dlg.fieldName = 'whichFiles';
dlg.style = 'listbox';
dlg.list = {w.name};
dlg.string = ['Select behavioral data files to analyze'];
dlg.value = [];

[resp ok] = generalDialog(dlg, 'Analyze Eccentricity Experiment Data');
if ~ok | isempty(resp.whichFiles), error('User aborted.');  end

% decompose the user selection into experiment names and subject names.
for n = 1:length(resp.whichFiles)
	underscore = strfind(resp.whichFiles{n}, '_');
	dot = strfind(resp.whichFiles{n}, '.');
	
	subjects{n} = resp.whichFiles{n}(1:underscore(1)-1);
	exptName{n} = resp.whichFiles{n}(underscore(1)+1:dot(end)-1);
end

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function anal = facebehav_analyzeSubject(exptName, subj, runs, dataDir);
%% create an analysis structure for a single subject's data.

%% load the data
filePath = fullfile(dataDir, [subj '_' exptName '.mat']);
if ~exist(filePath, 'file')
    error('Data file %s not found.', filePath);
end

load(filePath, 'fullRecord');

% set default runs to be all runs in this data set
if notDefined('runs'), runs = 1:length(fullRecord); end

%% initialize the analysis struct
% get the set of sizes, eccentricities tested 
sizes = unique( [fullRecord.faceSize] );
ecc   = unique( [fullRecord.faceEcc] );
sizes = sizes(sizes > 0);
if any( fullRecord(1).faceEcc(3:2:end) == 0 )
	% check if 0deg eccentricity was actually used as a condition, or just
	% a filler for offset-events
	ecc = ecc( ecc >= 0 );
else
	ecc = ecc( ecc > 0 );
end

% initialize the struct
anal.subject = subj;
anal.experiment = exptName;
anal.dataFile = filePath;
anal.nRuns = length(runs);
anal.display = fullRecord(1).display;
[anal.faceEcc anal.faceSize] = meshgrid(ecc, sizes); % conditions
anal.pc = [];   % percent correct by condition
anal.dprime = [];  % d-prime by condition
anal.nTrials = []; % trials per condition
anal.hits = [];    % proportion hits by condition
anal.misses = [];  % proportion misses by condition
anal.falseAlarms = []; % false alarms by condition
anal.correctRejects = []; % correct rejections by condition
anal.responseBias = []; % response bias by condition (percent yes responses)
anal.allImageFiles = {}; % image files used for each trial
anal.allSizes = [];  % size for every trial across runs
anal.allEcc = []; % eccentricity for every trial across runs
anal.allUserResponses = []; % user response index for every trial
anal.allAnswers = []; % answer for every trial
anal.allRTs = []; % response time for every trial

% let's grab the display params, for plotting purposes
% (allows us to convert from pix -> visual angle)
anal.display = fullRecord(1).display;

%% concatenate the data across runs
for r = runs
    resp = fullRecord(r).responses;
    
    % check that the responses have had a preliminary analysis -- selecting
    % only the valid, stimulus-present trials. Sometimes the code was run
    % without computing this; if so, we have the subroutine to do the
    % analysis here.
%     if ~checkfields(resp, 'responseIndex')
        tmp = computeTaskPerformance(fullRecord(r));
        resp = tmp.responses;
%     end
    
    anal.allImageFiles = [anal.allImageFiles resp.image];
    anal.allSizes = [anal.allSizes resp.faceSize];
    anal.allEcc = [anal.allEcc resp.faceEcc];
    anal.allUserResponses = [anal.allUserResponses resp.responseIndex];
    anal.allAnswers = [anal.allAnswers resp.isMatch];
    anal.allRTs = [anal.allRTs resp.responseTimes];		
end

anal.allCorrect = (anal.allUserResponses==anal.allAnswers);

%% compute d-prime and percent correct for each condition
for s = 1:length(sizes)
    for e = 1:length(ecc)
        I = find( anal.allSizes==sizes(s) & anal.allEcc==ecc(e) );
        if isempty(I)
%             error('No trials found, size %i, ecc %i', sizes(s), ecc(e));
			continue
		end
		
        userResponses = anal.allUserResponses(I);
        answers = anal.allAnswers(I);
        correct = anal.allCorrect(I);
        RTs = anal.allRTs(I);
        
        anal.nTrials(s,e) = length(I);
        anal.rt(s,e) = nanmean(RTs);
        anal.pc(s,e) = 100 * mean(correct);
		
		anal.rt_std(s,e) = nanstd(RTs);
		anal.rt_sem(s,e) = nanstd(RTs) ./ sqrt(length(I)-1);
		anal.pc_std(s,e) = nanstd(correct);
		anal.pc_std(s,e) = nanstd(correct) ./ sqrt(length(I)-1);
        
        
        [dpr subAnal] = dprime(userResponses, answers, 'silent');
        anal.dprime(s,e) = dpr;
        anal.hits(s,e) = subAnal.hitsPercent;
        anal.misses(s,e) = subAnal.missesPercent;
        anal.falseAlarms(s,e) = subAnal.falseAlarmsPercent;
        anal.correctRejects(s,e) = subAnal.correctRejectsPercent;
        anal.responseBias(s,e) = subAnal.responseBias;
    end
end

% convert the eccentricity and size (in pixels) values to corresponding
% grids of eccentricity in degrees and face diameter in degrees:
[eccAngle sizeAngle] = facebehav_pix2angle(anal.faceEcc, anal.faceSize, ...
											anal.display.numPixels);
anal.eccAngle = eccAngle;
anal.sizeAngle = sizeAngle;

% fit performance-vs-size curves for each eccentricity; find the critical
% size value for each eccentricity
anal = fitSizeFunction(anal);

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function stim = computeTaskPerformance(stim);
%% compute performance on the face recognition task for the just-completed
%% run.

%% extract only the behaviorally relevant events
% (we ignore 'blank' image offsets and end-of-run events)
ok = 3:2:length(stim.cond);
stim.responses.cond = stim.cond(ok);
stim.responses.image = stim.image(ok);
stim.responses.faceSize = stim.faceSize(ok);
stim.responses.faceEcc = stim.faceEcc(ok);
stim.responses.faceAngle = stim.faceAngle(ok);
stim.responses.isMatch = stim.isMatch(ok);
stim.responses.whichKey = stim.responses.keyCode(ok)';

% emprically derived: we need to shift the key code; it is not in sync with
% the other fields
stim.responses.whichKey = circshift(stim.responses.whichKey(:), -1)';

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

% we've been including an unnecessary 'end-of-run' event in both the
% responseIndex and isMatch fields. Trim this last event.
stim.responses.isMatch = stim.responses.isMatch(1:end-1);
stim.responses.responseIndex = stim.responses.responseIndex(1:end-1);
responseIndex = responseIndex(1:end-1);
stim.responses.faceSize = stim.responses.faceSize(1:end-1);
stim.responses.faceEcc = stim.responses.faceEcc(1:end-1);
stim.responses.faceAngle = stim.responses.faceAngle(1:end-1);
stim.responses.whichKey = stim.responses.whichKey(1:end-1);
stim.responses.image = stim.responses.image(1:end-1);

%% compute whether each trial was correct.
stim.responses.isCorrect = (responseIndex==stim.responses.isMatch);
stim.responses.percentCorrect = 100 * mean(stim.responses.isCorrect);

%% compute RT for each trial
stim.responses.responseTimes = stim.responses.secs(5:2:end) - stim.onset(3:2:end-2);

% sometimes you miss a keypress -- if you don't correct this in the
% response times, it will register as negative response time (because the
% 'secs' field is zero in these cases):
missed = find(stim.responses.secs(5:2:end)==0);
stim.responses.responseTimes(missed) = NaN;


%% group percent correct and RTs by condition
% for now, I will hard-code a loop across size and eccentricity. If I also
% test other dimensions, such as polar angle, I will need to modify this
% code
sizes = unique(stim.responses.faceSize);
ecc  = unique(stim.responses.faceEcc);
sizes = sizes( sizes > 0 );
ecc   = ecc( ecc >= 0 );
for s = 1:length(sizes)
    for e = 1:length(ecc)
        I = find(stim.responses.faceSize==sizes(s) & ...
                 stim.responses.faceEcc==ecc(e));
        stim.responses.pc(s,e) = mean( stim.responses.isCorrect(I) );

        J = find(stim.responses.faceSize==sizes(s) & ...
                 stim.responses.faceEcc==ecc(e) & ...
                 stim.responses.isCorrect==1);        
        stim.responses.rt(s,e) = nanmean( stim.responses.responseTimes(J) );
        stim.responses.rt_std(s,e) = nanstd( stim.responses.responseTimes(J) );
        
        stim.responses.trialCount(s,e) = length(I);
    end
end

% fprintf('[%s]: %3.2f%% correct.\n', stim.scriptName, ...
%             stim.responses.percentCorrect);

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function anal = compileSubjectData(subjAnal);
% combine many subjects' analysis structures into a single combined
% analysis structure.

anal.subjAnal = subjAnal;
anal.display = subjAnal{1}.display;
nSubjs = length(subjAnal);
for n = 1:nSubjs
	anal.subjects{n} = subjAnal{n}.subject;
	anal.experiment{n} = subjAnal{n}.experiment;
	anal.nRuns(n) = subjAnal{n}.nRuns;
end

dash = strfind(subjAnal{1}.experiment, '-');
anal.task = subjAnal{1}.experiment(1:dash(1)-1);
anal.faceSize = subjAnal{1}.faceSize;
anal.faceEcc = subjAnal{1}.faceEcc;
anal.sizeAngle = subjAnal{1}.sizeAngle;
anal.eccAngle = subjAnal{1}.eccAngle;

for s = 1:nSubjs
	anal.pc(:,:,s) = subjAnal{s}.pc;
	anal.dprime(:,:,s) = subjAnal{s}.dprime;
	anal.rt(:,:,s) = subjAnal{s}.rt;
end

% deal w/ Inf d-primes
anal.dprime( isinf(anal.dprime) ) = NaN;

anal.pc_mean = nanmean(anal.pc, 3);
anal.pc_std  = nanstd(anal.pc, [], 3);
anal.pc_sem  = nanstd(anal.pc, [], 3) ./ sqrt(nSubjs - 1);

anal.dprime_mean = nanmean(anal.dprime, 3);
anal.dprime_std  = nanstd(anal.dprime, [], 3);
anal.dprime_sem  = nanstd(anal.dprime, [], 3) ./ sqrt(nSubjs - 1);

anal.rt_mean = nanmean(anal.rt, 3);
anal.rt_std  = nanstd(anal.rt, [], 3);
anal.rt_sem  = nanstd(anal.rt, [], 3) ./ sqrt(nSubjs - 1);

% compile the size-curve fitting parameters
for s = 1:nSubjs
	anal.sizeThresh(s,:) = anal.subjAnal{s}.sizeThresh;
	anal.ceiling_pc(s,:) = anal.subjAnal{s}.ceiling_pc;
	anal.critical_size(s,:) = anal.subjAnal{s}.critical_size;
	anal.exponent_p(s,:) = anal.subjAnal{s}.exponent_p;
	anal.exponent_n(s,:) = anal.subjAnal{s}.exponent_n;
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function anal = acrossSubjectsANOVA(anal);
%% perform ANOVAs on subjects' percent correct and response time data, with
%% face size and eccentricity as factors (and maybe subjects).

%% percent correct ANOVA
Y = anal.pc;
[ECC SZ SUBJ] = meshgrid( unique(anal.faceEcc(:)), unique(anal.faceSize(:)), ...
						  1:size(Y, 3) );
varnames = {'Eccentricity' 'Size' 'Subject'};

[p anal.anova_pc] = anovan(Y(:), {ECC(:) SZ(:) SUBJ(:)}, 'Random', 3, ...
								'Varnames', varnames, ...
								'Model', 'interaction');

%% response time ANOVA
Y = anal.rt;
[ECC SZ SUBJ] = meshgrid( unique(anal.faceEcc(:)), unique(anal.faceSize(:)), ...
						  1:size(Y, 3) );
varnames = {'Eccentricity' 'Size' 'Subject'};

[p anal.anova_rt] = anovan(Y(:), {ECC(:) SZ(:) SUBJ(:)}, 'Random', 3, ...
								'Varnames', varnames, ...
								'Model', 'interaction');
							
return
% /--------------------------------------------------------------/ %



% /--------------------------------------------------------------/ %
function [eccAngle sizeAngle] = facebehav_pix2angle(eccPixels, sizePixels, screenRes);
%% convert pixel sizes into visual angle, using hard-coded display parameters.
screenDims = [44 28];  % size [X Y] of experimental display in cm
% screenRes = [1680 1050]; % number of [X Y] of resolution to use
eyeDist = 43; % distance from subject eye -> screen in cm

% convert pixels to centimeters. I base the conversion on the X axis dimensions, 
% which is what we generally manipulate -- eccentricity along the horizontal
% meridian. But if the pixel aspect ratio is around 1, it doesn't matter.
eccCm = eccPixels .* screenDims(1) / screenRes(1);
sizeCm = sizePixels .* screenDims(1) / screenRes(1);

% take the opposite, adjacent triangle measures and compute the angles
eccAngle = atan( eccCm ./ eyeDist ) * (180/pi);
sizeAngle = atan( sizeCm ./ eyeDist ) * (180/pi);

% we round here (for most iterations of our data, I set the desired angles
% to be round numbers)
eccAngle = round(eccAngle);
sizeAngle = round(sizeAngle);

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function anal = fitSizeFunction(anal, threshPC);
%% fits an analog to the performance vs. size function described in 
%% Makela et al, Vis. Res. 2001:
%%
%%  S = Smax * [1 + (wo/w)^p] ^ n;       eq. (9)
%%
%% where S is the identification sensitivity (in their work, the inverse of
%% the contrast-detection threshold; in this analogy, proportion correct);
%% Smax is the saturating sensitivity for a given face eccentricity;
%% w0 is the critical size for that eccentricity;
%% w is the size of a given face stimulus;
%% p and n are fitted exponential values.
%% 
%% This function takes the performance data for a single subject as a
%% function of size, and uses fminsearch to find Smax, wo, p, and n. (I'm
%% not sure how underconstrained this is; I'll have to see and find out.)
%%
if notDefined('threshPC')
	% performance threshold (usually 82%, reduce for some data which never
	% reaches that level)
	threshPC = 82; 
end

for ecc = 1:size(anal.pc, 2)
	% get the sample points and observed performance for this eccentricity
	eccAngle = log2( anal.eccAngle(1,ecc) );
	w = anal.sizeAngle(:,ecc)';
	observed = anal.pc(:,ecc)';
	
	% fit the parameters for the size function to these data
	initParams(1) = max(observed);
	initParams(2) = max(1, eccAngle/2);  % critical size; guess
	initParams(3) = .5;  % makela 2001 data (for contrast sensitivity)
	initParams(4) = 1;   % these exponents taken from subj. RM data in
	
	options = optimset('MaxFunEvals', 500, 'MaxIter', 500);
	f = (@(params) sizeFunction(w, observed, params));
	params = fminsearch(f, initParams, options);
	
	% the "critical size" solved by the params gives the point for which
	% the function is 0. We actually want to extract the point at which this 
	% curve would reach 82% performance (the threshold used during the noise 
	% estimation step at the fovea), if it ever does. Do so here:
	Smax = params(1);
	wo = params(2);
	n =  params(3);
	p =  params(4);
	
	% a simpler, dumber way to find the 82% threshold, in which I have more
	% confidence:
	xi = linspace(.4, 100, 10000);
	yi = sizeFunctionPrediction(xi, [Smax wo n p]);
	delta = abs(yi - threshPC);
	if min(delta) > 2
		% if the function doesn't come within 2% of 82% performance, we
		% have no solution
		wthresh = NaN;
	else
		iMin = find( delta==min(delta) );
		wthresh = xi(iMin(1));
	end
	anal.sizeThresh(ecc) = wthresh;	
	
	% store the parameters
	anal.ceiling_pc(ecc) = Smax;
	anal.critical_size(ecc) = wo;
	anal.exponent_p(ecc) = p;
	anal.exponent_n(ecc) = n;
end

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function [rss prediction] = sizeFunction(w, observed, params);
%% main size function adapted from Makela et al 2001. This is used with
%% fminsearch, and provides a goodness-of-fit criterion (RSS error, which
%% fminsearch tries to minimize across parameters).
Smax = params(1);
wo   = repmat(params(2), [1 size(w, 2)]);
n    = 2; % params(3);
p    = 1; % params(4);

prediction = Smax .* [1 - (wo./w).^p] .^ n;
prediction(w < wo | prediction < 50) = 50;  % chance performance below threshold

rss = sqrt( sum((observed - prediction).^2) );

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function prediction = sizeFunctionPrediction(w, params);
%% just the prediction part of the size function, without comparing it to
%% data.
Smax = params(1);
wo   = repmat(params(2), [1 size(w, 2)]);
n    = params(3);
p    = 1; % params(4);

prediction = Smax .* [1 - (wo./w).^p] .^ n;
prediction(w < wo | prediction < 50) = 50;  % chance performance below threshold

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function anal = fitAcrossSubjectsData(anal);
%% Fits the performance-versus-size curves on the across-subject mean data.
%% We go ahead and plot the results here too (may break it off if it gets
%% too big).
%% Note that this over-writes the fields 'critical_size', 'celing_pc',
%% 'exponent_n' and 'exponent_p' which were computed in
%% 'compileSubjectData'. This is an alternative way of summarizing across
%% subjects data: compile subject data uses separate fits for each subject,
%% then averages the fit. Invoking this function shows what happens when
%% you average across subjects first, then fit the data. I wrote this
%% because the fitting process in individual subjects sometimes goes awry
%% (although the subject's data may look somewhat reasonable), and this can
%% cause outliers to throw the fitting. Also, for small eccentricities, the
%% fitting is very sensitive.

%% params
colors = {[0 0 1] [0 .3 1] [0 .6 .6] [.3 .6 .3] [.6 .6 0] [.6 .3 0]};
[sizes ecc] = getFaceSizesInDegrees(anal);
threshPC = 82;

%% open the plot figure
nm = [anal.task ' Task Across-Subjects Performance'];
hFig = figure('Color', 'w', 'Name', nm);

% remove the old fields
anal.ceiling_pc = [];
anal.critical_size = [];
anal.exponent_n = [];
anal.exponent_p = [];
anal.sizeThresh = [];

% do the fitting
anal = fitSizeFunction(anal, threshPC);

%% plot the performance data and fitted curves 
% hAx(1) = subplot(1, 3, 1);  hold on
set(gca, 'XScale', 'log');
for ii = 1:length(ecc)
	subplot(2, length(ecc), ii);  hold on
	
	% plot data
	x = sizes;
	y = anal.pc_mean(:,ii);
	e = anal.pc_sem(:,ii);
	errorbar(x, y, e, 'o', 'Color', colors{ii}, ...
			'LineWidth', 2);

	% compute size/performance curve
	Smax = anal.ceiling_pc(ii);
	wo = anal.critical_size(ii);
	n = anal.exponent_n(ii);
	p = anal.exponent_p(ii); 
	xi = linspace(wo, max(sizes), 100); 
	yi = sizeFunctionPrediction(xi, [Smax wo n p]);		

	% plot fitted size/performance curves
	plot(xi, yi, '--', 'Color', colors{ii}, 'LineWidth', 1);
	axis([0 max(sizes) 45 100]);		

	% mark the critical size
	wthresh = anal.sizeThresh(ii);
	line(minmax(xi), [threshPC threshPC], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1.5);
	line(minmax(xi), [50 50], 'Color', [.5 .5 .5], 'LineStyle', ':', 'LineWidth', 1);
	plot(wthresh, threshPC, 'kd', 'MarkerSize', 5);
	
	% set axes, labels
	set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 12);
	if ii==1
		xlabel(['Face Diameter (', char(176) ')'], 'FontSize', 12);
		ylabel('Percent Correct', 'FontSize', 12);	
	end
	ttl = sprintf('Ecc = %.1f%s', ecc(ii), char(176));
	title(ttl, 'FontSize', 14, 'Color', colors{ii});
end	


%% plot the critical threshold versus eccentricity
hAx(2) = subplot(2, 2, 3);  hold on;
plot(ecc, anal.sizeThresh, 'ko-', 'LineWidth', 3, 'MarkerSize', 5);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 12);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 14);
ylabel(['Critical Face Size (' char(176) ')'], 'FontSize', 14);	


%% show the performance matrix
hAx(3) = subplot(2, 2, 4);  hold on;
drawXCorrMatrix( mean(anal.pc, 3), [50 100], 0 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'Box', 'off', ...
    'FontSize', 12);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 14);
ylabel(['Face Diameter (', char(176) ')'], 'FontSize', 14);
title('Percent Correct', 'FontSize', 14);
axis square;  axis on;  colorbar;

return
% /---------------------------------------------------------------------/ %




% /---------------------------------------------------------------------/ %
function anal = facebehav_plotAnalysis(anal);
% plot the results of the analysis.

%% get some parameters which will be useful for the plots.
sizes = unique( anal.faceSize(:) );
ecc   = unique( anal.faceEcc(:) );

% convert these to degrees...
% the proper way to do this will be to set up a calibrated display file for
% use with the VISTADISP tools, including the subject's eye-display
% distance and the display dimensions. For now, I'll do a
% back-of-the-envelope calculation, based on measurements made 07/02/2009
% in room 454:
displayRadiusCm = 22;
displayRadiusPix = anal.display.numPixels(1) / 2;
eyeDistanceCm = 43;

maxEccDegrees = atan(displayRadiusCm / eyeDistanceCm) * (180/pi);

sizes = maxEccDegrees .* sizes ./ displayRadiusPix;
ecc   = maxEccDegrees .* ecc ./ displayRadiusPix;

%% plot the results of the main performance-by-condition matrices.
name = ['Face Recognition ' anal.experiment ' By Condition'];
anal.plotHandle(1) = figure('Color', 'w', 'Name', name, 'Units', 'norm', ...
                            'Position', [.2 .2 .6 .6]);

subplot(234); 
drawXCorrMatrix( anal.pc, [50 100], 0 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'Box', 'off', ...
    'FontSize', 12);
xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('Percent Correct', 'FontSize', 16, 'FontWeight', 'bold');
axis square;  axis on;  colorbar;

subplot(235); 
drawXCorrMatrix( anal.dprime, [0 2.5], 1 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'Box', 'off', ...
    'FontSize', 12);xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('d''', 'FontSize', 16, 'FontWeight', 'bold');
axis square;  axis on;  colorbar;

subplot(236); 
drawXCorrMatrix( anal.rt, minmax(anal.rt), 2 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'Box', 'off', ...
    'FontSize', 12);xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('Response Times (s)', 'FontSize', 16, 'FontWeight', 'bold');
axis square;  axis on;  colorbar;

colormap([0 0 0; jet(255)]);

% the next few plots show falloff in eccentricity for different face sizes
colors = {'k' [0 0 .6] [0 .4 1] [.4 1 .4] 'r'};
nSizes = length(sizes);

for n = 1:nSizes
	sizeLeg{n} = sprintf('%.1f%s', sizes(n), char(176));
end
for n = 1:length(ecc)
	eccLeg{n} = sprintf('%.1f%s', ecc(n), char(176));
end

subplot(231);
plot(ecc, anal.pc', 'o-', 'LineWidth', 2);
setLineColors(colors);
axis([0 max(ecc) min(anal.pc(:)) 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 10);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 12);
ylabel('Percent Correct', 'FontSize', 12);
legend(sizeLeg, -1, 'XColor', 'w', 'YColor', 'w');

subplot(232);
plot(sizes, anal.pc, 'o-', 'LineWidth', 2);
setLineColors(colors);
axis([0 max(ecc) min(anal.pc(:)) 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 10);
xlabel(['Size (', char(176) ')'], 'FontSize', 12);
ylabel('Percent Correct', 'FontSize', 12);
legend(eccLeg, -1, 'XColor', 'w', 'YColor', 'w');

subplot(233);
x = repmat(ecc, [1 nSizes]);
errorbar(x, anal.rt', anal.rt_sem', 'Marker', 'o', 'LineWidth', 2);
setLineColors(colors);
axis tight;
set(gca, 'Box', 'off', 'TickDir', 'out', 'FontSize', 10);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 12);
ylabel('Response Time (s)', 'FontSize', 12);
legend(sizeLeg, -1, 'XColor', 'w', 'YColor', 'w');

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function [sizes ecc] = getFaceSizesInDegrees(anal);
%% return the size and eccentricity conditions used in the data in units of
%% visual degrees.
sizes = unique( anal.faceSize(:) );
ecc   = unique( anal.faceEcc(:) );

% convert these to degrees...
% the proper way to do this will be to set up a calibrated display file for
% use with the VISTADISP tools, including the subject's eye-display
% distance and the display dimensions. For now, I'll do a
% back-of-the-envelope calculation, based on measurements made 07/02/2009
% in room 454:
displayRadiusCm = 22;
displayRadiusPix = anal.display.numPixels(1)/2;
eyeDistanceCm = 43;

maxEccDegrees = atan(displayRadiusCm / eyeDistanceCm) * (180/pi);

sizes = maxEccDegrees .* sizes ./ displayRadiusPix;
ecc   = maxEccDegrees .* ecc ./ displayRadiusPix;

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function anal = facebehav_plotAnalysis_acrossSubjects(anal);
%% plot the results of the across-subjects analysis.

%% get some parameters which will be useful for the plots.
[sizes ecc] = getFaceSizesInDegrees(anal);

%% plot the results of the main performance-by-condition matrices.
dash = strfind(anal.experiment{1}, '-');
expString = anal.experiment{1}(1:dash-1);
name = ['Face Recognition ' expString ' By Condition'];
anal.plotHandle(1) = figure('Color', 'w', 'Name', name, 'Units', 'norm', ...
                            'Position', [.2 .2 .6 .6]);

subplot(234); 
drawXCorrMatrix( anal.dprime_mean, [0 2.5], 1 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'YDir', 'normal', 'Box', 'off', ...
    'FontSize', 12);
xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('d''', 'FontSize', 16);
axis square;  axis on;  colorbar;

subplot(235); 
drawXCorrMatrix( anal.pc_mean, [50 100], 0 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'Box', 'off', 'YDir', 'normal', ...
    'FontSize', 12);
xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('Percent Correct', 'FontSize', 16);
axis square;  axis on;  colorbar;

subplot(236); 
drawXCorrMatrix( anal.rt_mean, minmax(anal.rt_mean), 2 );
set(gca, 'TickDir', 'out', 'LineWidth', 2, 'XTick', 1:length(ecc), ...
    'XTickLabel', round(10*ecc)/10, 'YTick', 1:length(sizes), ...
    'YTickLabel', round(10*sizes)/10, 'YDir', 'normal', 'Box', 'off', ...
    'FontSize', 12);
xlabel('Eccentricity, deg', 'FontSize', 14);  
ylabel('Size, deg', 'FontSize', 14);
title('Response Times (s)', 'FontSize', 16);
axis square;  axis on;  colorbar;

% colormap([0 0 0; jet(255)]);

% the next few plots show falloff in eccentricity for different face sizes
colors = {'k' [0 0 .6] [0 .4 1] [.4 1 .4] 'r'};
nSizes = length(sizes);

for n = 1:nSizes
	sizeLeg{n} = sprintf('%.1f%s', sizes(n), char(176));
end
for n = 1:length(ecc)
	eccLeg{n} = sprintf('%.1f%s', ecc(n), char(176));
end

subplot(231);  hold on;
setLineColors(colors);
x = repmat(ecc, [1 nSizes]);
errorbar(x, anal.pc_mean', anal.pc_sem', 'Marker', 'o', 'LineWidth', 2);
axis([0 max(ecc) min(anal.pc(:)) 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 10);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 14);
ylabel('Percent Correct', 'FontSize', 14);
legend(sizeLeg, -1, 'XColor', 'w', 'YColor', 'w');
text(17, 102, 'Face Size', 'HorizontalAlignment', 'center', 'FontSize', 12);
line([0 max(ecc)], [50 50], 'Color', [.3 .3 .3], 'LineWidth', 2, 'LineStyle', ':');

subplot(232);  hold on;
setLineColors(colors);
x = repmat(sizes, [1 length(ecc)]);
errorbar(x, anal.pc_mean, anal.pc_sem, 'Marker', 'o', 'LineWidth', 2);
axis([0 max(sizes) min(anal.pc(:)) 100]);
set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 10);
xlabel(['Size (', char(176) ')'], 'FontSize', 14);
ylabel('Percent Correct', 'FontSize', 14);
legend(eccLeg, -1, 'XColor', 'w', 'YColor', 'w');
text(32, 102, 'Face Ecc', 'HorizontalAlignment', 'center', 'FontSize', 12);
line([0 max(sizes)], [50 50], 'Color', [.3 .3 .3], 'LineWidth', 2, 'LineStyle', ':');

subplot(233);  hold on;
x = repmat(ecc, [1 nSizes]);
setLineColors(colors);
errorbar(x, anal.rt_mean', anal.rt_sem', 'Marker', 'o', 'LineWidth', 2);
axis tight;
set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 10);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 14);
ylabel('Response Time (s)', 'FontSize', 14);
legend(sizeLeg, -1, 'XColor', 'w', 'YColor', 'w');
text(34, .98, 'Face Size', 'HorizontalAlignment', 'center', 'FontSize', 12);

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function anal = acrossSubjects_plotSizeFits(anal);
%% plot each subject's performance as a function of size, for each
%% eccentricity. Then plot the critical size across subjects as a function
%% of eccentricity.
threshPC = 82; % threshold performance level 
colors = {'k' [0 0 .6] [0 .4 1] [.4 1 .4] 'r' [.5 .2 0] [.1 1 .1]};
nSubjs = length(anal.subjAnal);

%% figure w/ individual subject size curves
anal.fitFig(1) = figure('Color', 'w', 'Position', [680 87 847 1011], ...
					    'Name', 'Individual Subject Performance');
for s = 1:nSubjs
	% get data
	sizes = unique( anal.subjAnal{s}.sizeAngle(:) );
	ecc   = unique( anal.subjAnal{s}.eccAngle(:) );
	x = repmat(sizes, [1 length(ecc)]);
	y = anal.subjAnal{s}.pc;
% 	err = anal.subjAnal{s}.pc_sem;
	
	for ii = 1:length(ecc)
		% plot data
		subplot(nSubjs, length(ecc), (s-1)*length(ecc) + ii);
		plot(x(:,ii), y(:,ii), 'o', 'LineWidth', 2, 'Color', colors{ii});

		% compute size/performance curve
		Smax = anal.subjAnal{s}.ceiling_pc(ii);
		wo = anal.subjAnal{s}.critical_size(ii);
		n = anal.subjAnal{s}.exponent_n(ii);
		p = anal.subjAnal{s}.exponent_p(ii); 
		xi = linspace(min(x(:,ii)), max(x(:,ii)), 100); 
		yi = sizeFunctionPrediction(xi, [Smax wo n p]);		

		% plot fitted size/performance curves
		hold on
		plot(xi, yi, '--', 'Color', colors{ii}, 'LineWidth', 2);
		axis([0 max(sizes) 45 100]);		
		
		% mark the critical size
		wthresh = anal.sizeThresh(s,ii);
% 		line([wthresh wthresh], [50 100], 'Color', 'k', 'LineStyle', '--', 'LineWidth', 1);
		line(minmax(xi), [threshPC threshPC], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1);
		line(minmax(xi), [50 50], 'Color', 'k', 'LineStyle', ':', 'LineWidth', 1);
		plot(wthresh, threshPC, 'rd');
		
		% set axes, labels
		set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 10);
		if s==nSubjs & ii==1
			xlabel(['Face Diameter (', char(176) ')'], 'FontSize', 14);
			ylabel('Percent Correct', 'FontSize', 14);	
		end
		ttl = sprintf('%s: \nEcc = %.1f%s', anal.subjAnal{s}.subject, ...
					  ecc(ii), char(176));
		title(ttl, 'FontSize', 10);
	end	
end

%% figure showing critical size vs. eccentricity summary
anal.fitFig(2) = figure('Color', 'w', 'Name', 'Face Size vs. Eccentricity');
Y = nanmean(anal.sizeThresh);
E = nanstd(anal.sizeThresh) ./ sqrt(nSubjs - 1);
errorbar(ecc, Y, E, 'Marker', 'o', 'Color', 'k', 'LineWidth', 2.5);
x = repmat(ecc, [1 nSubjs]);
hold on, plot(x, anal.sizeThresh', 'd:', 'LineWidth', 1.5);
set(gca, 'Box', 'off', 'TickDir', 'out', 'XScale', 'linear', 'FontSize', 12);
xlabel(['Eccentricity (', char(176) ')'], 'FontSize', 14);
ylabel(['Size Threshold (', char(176) ')'], 'FontSize', 14);
legendPanel(anal.subjects);

return







    
