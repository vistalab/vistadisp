function params = locMakeParFile(params)
% Make parameter file for fMRI localizer experiment
%
% params = locMakeParFile(params)
%
% The par file is a text file with three columns:
% OnsetTime     ConditionNumber     ConditionName

parFileName = ['Localizer_'  params.scan.subjInitials '_' ...
    datestr(now,'ddmmyyyy_HH-MM') '.par'];

params.parFilePath = fullfile(params.stim.baseDir,'parfiles',parFileName);
if ~exist(fullfile(params.stim.baseDir, 'parfiles'), 'dir'), 
    mkdir(fullfile(params.stim.baseDir, 'parfiles')); 
end

%% MAKE PARFILE VARIABLE
% should make it possible to read in a parfile as well

for parIndex = 1:2:(2*length(params.stim.blockOrder))         
    % go by 2s because block is always paired with fixation
    
    % Fixation block
    if parIndex == 1, 
        % t = 0 for first  onset
        par.onset = 0; 
    else
        % add the block length to the start of the previous block
        par.onset(parIndex) =  par.onset(parIndex-1) + params.stim.blockLength;
    end
    
    % fixations are always labeled as condition = 0, name = 'Fix'
    par.cond(parIndex)  = 0;
    par.label{parIndex} = 'Fix';
    
    % Stimulus block - onset time is onset of previous fix + fixation length
    par.onset(parIndex+1) = par.onset(parIndex) + params.stim.fixLength((parIndex+1)/2);
    
    % figure out which stimulus is shown, indexed as 'thisstim', we divide
    % parIndex by 2 because blockOrder does not store fixations. could
    % change this....
    thisstim =  params.stim.blockOrder(ceil(parIndex/2));
    par.cond(parIndex+1)  = thisstim;
    par.label{parIndex+1} = params.stim.condNames{thisstim};
end

% add fixation to end
par.onset(end+1) = par.onset(end)+params.stim.blockLength;
par.cond(end+1)  = 0;
par.label{end+1} = 'Fix';

params.par = par;
return

