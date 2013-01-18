function singleBarTest_makescript(N, varargin);
% Generates and saves a series of scripts for use in the single-bar experiment.
%
%  singleBarTest_makescript([N=1], [options]);
%
% This experiment is designed to test predictions from our scaled-faces pRF
% mapping experiment. The objective is to place a single bar aperture at a
% fixed location of the visual field, and have different sizes of faces
% behind the aperture. If the pRF results hold, we would predict that
% larger face images will produce a wider spatial extent of responses in 
% ventral cortex, extending into regions (like the ipsilateral cortical 
% hemisphere) which under other conditions would not represent the retinal
% position of the bar aperture. For instance, if the single bar is
% distinctly in the left visual field, we would not expect strong responses
% in left ventral cortex, since the contralateral visual field is never
% stimulated. But if the pRFs in these regions reflect the perceived extent
% of the object, then we may see some response to large faces, which are
% perceived as behind an aperture, but extending into the right visual
% field.
%
% N refers to the image set to use. [default 1]  Script names will be saved
% as 'single_bar_test_[N]_[run#].txt' in the code/Scripts folder.
%
% ras, 04/2009.
if notDefined('N'),		N = 1;						end

%% script params
sizes = [150];  % sizes (diameter) of faces in each condition
nImagesPerTrial = 9;   % # images for each position
secsPerTrial = 3;	  % seconds for each 'trial' where faces of the same size
					  % and gender are shown
trialsPerBlock = 5;	  % # of face-bar trials per block
ISI	= 15;			  % seconds in inter-block interval
nBlocksPerCond = 6;   % for each size, how many blocks? 
prestimSecs = 12;     % seconds before stimuli are presented in each run
poststimSecs = 12;     % seconds after stimuli are presented in each run
nRuns = 6;			  % # runs to make w/ the same face images
saveName = 'foveal_bar_localizer';   % prefix for scripts

for ii = 1:2:length(varargin)
	eval( sprintf('%s = %s;', varargin{ii}, varargin{ii+1}) );
end

% derived params
nConds = length(sizes);
secsPerBlock = (secsPerTrial * trialsPerBlock) + ISI;
nBlocks = nBlocksPerCond * nConds;
secsPerRun = secsPerBlock * nBlocks + prestimSecs + poststimSecs;

% name of image set, script

%% get path of directory in which to save scripts
codeDir = fileparts(which(mfilename));
imageDir = fullfile(codeDir, 'SingleBarImages');
ensureDirExists(imageDir);
saveDir = fullfile(imageDir, [saveName '_' num2str(N)]);

for r = 1:nRuns
	%% set up the script
	% first we set up the no-blanks script, then the blanks one
	stim.onset = 0;  % onset in seconds since run start: initialize 
	stim.image = {'blank'}; 
	stim.blockNum = 0; 
	stim.trialNum = 0;
	stim.cond = 0;  % 0 for blank 1-nConds for the different sizes
	stim.gender = 'b'; % 'b' for blank, 'm' for male, 'f' for female
	stim.size = 0; % 0 for blank, otherwise the image size in 'sizes'

	startTime = prestimSecs;

	%% create a block order
	blockOrder = shuffle( repmat(1:nConds, [1 nBlocksPerCond]) );
	repNum = nVals(blockOrder) - 1; % how many times each size has come up

	%% populate each block with trials
	mf = 'mf';  % gender codes
	for n = 1:nBlocks
		% first create event entries for the bar images
		for ii = 1:trialsPerBlock
			% flip a virtual coin to determine the gender of faces to show for
			% this trial
			gender = mf( round(rand) + 1 ); 

			% the size is determined by the block order
			sz = sizes( blockOrder(n) );

			% we also need a linear 'trial num' across all blocks, for indexing
			% the face images, as well as across all blocks of the given
			% size:
			trialNum = (n-1)*trialsPerBlock + ii;
			t = repNum(n) * trialsPerBlock + ii;
			
			% get the set of images for this trial
			imlist = {};
			for j = 1:nImagesPerTrial
				imgName = sprintf('%s%i-%i-%i.png', gender, blockOrder(n), t, j);
				imlist{j} = fullfile(saveDir, imgName);
			end

			% set the timing for each frame in imlist
			onset = linspace(0, secsPerTrial, nImagesPerTrial+1) + startTime;
			onset = onset(1:end-1);  % last onset is start of next trial	
			startTime = startTime + secsPerTrial;		

			% add to the stimulus struct
			repSize = [1 length(onset)];
			stim.onset = [stim.onset onset];
			stim.cond = [stim.cond repmat(blockOrder(n), repSize)];
			stim.size = [stim.size repmat(sz, repSize)];	
			stim.gender = [stim.gender repmat(gender, repSize)];
			stim.trialNum = [stim.trialNum repmat(trialNum, repSize)];		
			stim.blockNum = [stim.blockNum repmat(n, repSize)];
			stim.image = [stim.image imlist];		
		end

		% add events for 'blank' ISI trials.
		stim.onset = [stim.onset startTime];
		stim.cond = [stim.cond 0];
		stim.size = [stim.size 0];	
		stim.gender = [stim.gender 'b'];
		stim.trialNum = [stim.trialNum trialNum];		
		stim.blockNum = [stim.blockNum n];
		stim.image = [stim.image {'blank'}];		
		startTime = startTime + ISI;		
	end

	% add post-stim events, end of run
    stim.onset(end+1) = startTime;
	stim.cond = [stim.cond 0];
	stim.size = [stim.size 0];	
	stim.gender = [stim.gender 'b'];
	stim.trialNum = [stim.trialNum trialNum+1];		
	stim.blockNum = [stim.blockNum n+1];
	stim.image = [stim.image {'blank'}];		

    if poststimSecs > 1
        stim.onset(end+1) = stim.onset(end) + poststimSecs;
        stim.cond = [stim.cond 0];
        stim.size = [stim.size 0];	
        stim.gender = [stim.gender 'b'];
        stim.trialNum = [stim.trialNum trialNum+1];		
        stim.blockNum = [stim.blockNum n+1];
        stim.image = [stim.image {'blank'}];		
    end
    
	% write the scripts
	% make sure the script directory exists
	scriptDir = fullfile(codeDir, 'Scripts');
	ensureDirExists(scriptDir);

	[p f ext] = fileparts(saveDir);
	scriptPath = fullfile(scriptDir, sprintf('%s-%i.txt', f, r));
	writeScript(stim, scriptPath);
end

return
% /--------------------------------------------------------------/ %


% /--------------------------------------------------------------/ %
function writeScript(stim, pth);
% write out a script file
fid = fopen(pth, 'w');

% write the header
fprintf(fid, 'Script for single face bar experiment\n');
fprintf(fid, 'Run length: %3.2f seconds, %3.2f frames (if TR=2)\n', ...
            stim.onset(end), stim.onset(end)/2);
fprintf(fid, '\n'); 

% column headers
fprintf(fid, ['Block # \tOnset Time, sec \tTrial # \t' ...
			  'Condition # \tFace Size \tFace Gender \tImage File \n']);

% write the main body of the script
for i = 1:length(stim.blockNum)
    fprintf(fid, '%i \t%3.2f \t', stim.blockNum(i), stim.onset(i));
    fprintf(fid, '%i \t%i \t', stim.trialNum(i), stim.cond(i));	
    fprintf(fid, '%i \t%s \t',  stim.size(i), stim.gender(i));
    fprintf(fid, '%s \n', stim.image{i});
end

% finish up
fprintf(fid, '*** END OF SCRIPT ***\n');
fclose(fid);

fprintf('Wrote %s.\n', pth);

return