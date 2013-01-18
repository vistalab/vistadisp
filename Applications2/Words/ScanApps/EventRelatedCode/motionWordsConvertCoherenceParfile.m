function newParPaths = motionWordsConvertCoherenceParfile(savedResponsesFile,oldParPath)
%
% Written specifically for the motion-coherence block scans, this function
% converts a parfile from its original state into two new types:
%
% 1) Event-related parfile with the times corrected to the actual onset of
% the trials as measured by PTB.
%
% 2) Block-design parfile, treating a block of 2 sec stimuli as a block
% (and having 1 entry in the parfile per block)
%
% The reason this was necessary is that the stimuli aren't loaded up in the
% 400ms ISI, so the stimuli get delayed with respect to the parfile that we
% use to build the stimuli (oldParPath)
%
%

if notDefined('savedResponsesFile')
    savedResponsesFile = mrvSelectFile('r','mat','Please pick a file that has trialstarttime (usually savedResponses.mat)',...
        '/Users/Shared/ScanData/MotionWords/MotionCoherenceBlocks/stim/savedScans');
end

if notDefined('oldParPath')
    oldParPath = mrvSelectFile('r','par','Please pick the original parfile used to build scans',...
        '/Users/Shared/ScanData/MotionWords/MotionCoherenceBlocks/parfiles');
end

[onsets, conds, labels] = readParFile(oldParPath);

load(savedResponsesFile); % should include trialstarttime variable, which does not include fixation conditions


% Parfile with real onsets (from saved data)
realOnsets = onsets;
nonFixConds = find(conds~=0);
realOnsets(nonFixConds) = trialstarttime-6;  % these might have to be rounded?  first fixation block is 18 instead of 12 (b/c dummy), so subtract 6
realOnsets(nonFixConds+1) = realOnsets(nonFixConds)+2;  % 2 second stimuli
fixBlockInds = find(diff(conds)==0);  % anywhere this is 0, there is a fixation block (which actually kind of starts right after the last stimulus)
realOnsets(fixBlockInds+1) = realOnsets(fixBlockInds)+0.01; % set it to happening a hundreth of a second later

[foo,fn]=fileparts(oldParPath);
newParPaths{1} = fullfile(fileparts(savedResponsesFile),sprintf('%s_realOnsets_%s.par',fn,datestr(now,'ddmmyyyy-HH-MM')));

par.onset = realOnsets;
par.cond = conds;
par.label = labels;
writeParfile(par,newParPaths{1});

% Parfile as a block design
newBlockInds = [0 diff(conds)];  % new blocks characteristically have 2 fixations in a row (an ISI and then an inter-block interval)
fixOnsets = onsets(find(newBlockInds==0));
fixLength = 12; % assume 12 second fixation blocks
parBlock.onset = sort([fixOnsets fixOnsets+fixLength]);  % add in all the block onsets
parBlock.onset = parBlock.onset(1:end-1); % last onset is not a real block (end with fixation)
for xx = 1:length(parBlock.onset)
    parBlock.cond(xx) = conds(find(parBlock.onset(xx)==onsets));
    parBlock.label(xx) = labels(find(parBlock.onset(xx)==onsets));
end
newParPaths{2} = fullfile(fileparts(savedResponsesFile),sprintf('%s_block_%s.par',fn,datestr(now,'ddmmyyyy-HH-MM')));
writeParfile(parBlock,newParPaths{2});


return




