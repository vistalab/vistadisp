%% Set the params for various localizer/block type experiments


%%%%%%%%%%%%%%%%%%%%%%   doRotatingWordLoc   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 0 to 90
clear all

params.blockLength = 6;                         
params.fixLength = 0;  % between stimulus blocks
params.stimLength = 0.150;  % doesn't include ISItime
params.ISItime = 0.100;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 6;  % number of times to repeat sequence of blocks
params.initFix = 6;  % first fixation length
params.postFix = 0;

conds.A = '0';
conds.B = '22';
conds.C = '45';
conds.D = '67';
conds.E = '90';

params.blockOrder = 'ABCDE';  % basic block order, will be repeated n times; predictable
params.blockOrder = repmat(params.blockOrder,1,params.nRepeats);
numBlocks = length(params.blockOrder);

scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix
nFrames = scanLength/2

sprintf('\ndoRotatingWordLoc(params,conds)')



%% Words V Upside-Down
clear all

params.blockLength = 12;                         
params.fixLength = 12;  % between stimulus blocks
params.stimLength = 0.150; %0.400;  % doesn't include ISItime
params.ISItime = 0.100;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 1;

conds.A = '0';
conds.B = '180';
conds.C = 'checkerboard';
conds.D = '0_phaseScramble';
conds.E = '180_phaseScramble';

sessNum = input('Which session?  (1,2,3):  ');
% if sessNum==1, params.blockOrder = 'ABCABC';  params.stimChooseAlgorithm = 'list_stimOrder_WvUD_run1'; end  % basic block order, will be repeated n times; predictable
% if sessNum==2, params.blockOrder = 'CBACBA';  params.stimChooseAlgorithm = 'list_stimOrder_WvUD_run2'; end
% if sessNum==3, params.blockOrder = 'BACCAB';  params.stimChooseAlgorithm = 'list_stimOrder_WvUD_run3'; end
if sessNum==1, params.blockOrder = 'ABCDEABCDE';  end  % basic block order, will be repeated n times; predictable
if sessNum==2, params.blockOrder = 'CADBEEBDAC';  end
if sessNum==3, params.blockOrder = 'EDCBAEDCBA';  end
params.stimChooseAlgorithm = 'list_stimOrder_WvUD';
params.dummyBlockType = 'A';
numBlocks = length(params.blockOrder);

scanLength = (params.blockLength+params.fixLength)*(numBlocks+1)+params.fixLength  % +1 for dummy, params.fixLength for extra fixation at end
nFrames = scanLength/2

numStimsPerBlock = params.blockLength / (params.stimLength+params.ISItime);

sprintf('\ndoRotatingWordLoc(params,conds)')

% % To make stimOrder txt file, run this:
% checkerFlag = 1;  % C condition is checkerboard
% [stimList stimOrderPath] = makeStimOrderTextFile(params.blockOrder,numStimsPerBlock,checkerFlag,params.dummyBlockType);



%% Full Circle
clear all

params.blockLength = 4;                           
params.fixLength = 0;  % between stimulus blocks
params.stimLength = 0.150;  % doesn't include ISItime
params.ISItime = 0.100;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 6;  % number of times to repeat sequence of blocks
params.initFix = 6;  % first fixation length
params.postFix = 0;

conds.A = '0';
conds.B = '45';
conds.C = '90';
conds.D = '135';
conds.E = '180';
conds.F = '225';
conds.G = '270';
conds.H = '315';

params.blockOrder = 'EFGHABCD';  % basic block order, will be repeated n times; predictable
params.blockOrder = repmat(params.blockOrder,1,params.nRepeats);
numBlocks = length(params.blockOrder);

params.dummyBlockType = 'D';
params.stimChooseAlgorithm = 'list_stimOrder_fullCircle';  % txt files should be called stimOrder_fullCircle1, stimOrder_fullCircle2, etc

scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix
nFrames = scanLength/2

numStimsPerBlock = params.blockLength / (params.stimLength+params.ISItime);

sprintf('\ndoRotatingWordLoc(params,conds)')

% % To make stimOrder txt file, run this:
% checkerFlag = 0;  % C condition is checkerboard
% [stimList stimOrderPath] = makeStimOrderTextFile(params.blockOrder,numStimsPerBlock,checkerFlag,params.dummyBlockType);



%% Horiz/Vertical Circle
clear all

params.blockLength = 6;                          
params.fixLength = 0;  % between stimulus blocks
params.stimLength = 0.150;  %0.170;   % doesn't include ISItime
params.ISItime = 0.100;  %0.130; 
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 6;  % number of times to repeat sequence of blocks
params.initFix = 6;  % first fixation length
params.postFix = 0;

conds.A = '0';
conds.B = '90';
conds.C = '180';
conds.D = '270';

params.blockOrder = 'DABC';  % basic block order, will be repeated n times; predictable
params.dummyBlockType = 'C';
params.blockOrder = repmat(params.blockOrder,1,params.nRepeats);
numBlocks = length(params.blockOrder);

params.stimChooseAlgorithm = 'random';

scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix
nFrames = scanLength/2

sprintf('\ndoRotatingWordLoc(params,conds)')



%%%%%%%%%%%%%%%%%%%%%%  doWordHierarchy  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%doWordHierarchy

clear all

params.blockLength = 6;                           % usually 12
params.fixLength = 0;  % between stimulus blocks  % usually 12
params.stimLength = 0.100;  % doesn't include ISItime
params.ISItime = 0.200;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 6;  % number of times to repeat sequence of blocks
params.initFix = 6;  % first fixation length
params.postFix = 0;

% Older condition types
% conds.A = 'consonants';
% conds.B = 'unigrams';
% conds.C = 'bigrams';
% conds.D = 'trigrams';
% conds.E = 'words';

conds.A = 'checkerboard';
conds.B = 'consonants';
conds.C = 'bigrams';
conds.D = 'trigrams';
conds.E = 'words';

params.blockOrder = 'ABCDE';  % basic block order, will be repeated n times; predictable
params.blockOrder = repmat(params.blockOrder,1,params.nRepeats);
numBlocks = length(params.blockOrder);

scanLength = params.blockLength*(numBlocks+1)+params.initFix+params.postFix
nFrames = scanLength/2

sprintf('\ndoWordHierarchy(params,conds)')



%% doWordHierarchy with fixation

clear all

params.blockLength = 6;                           
params.fixLength = 6;  % between stimulus blocks
params.stimLength = 0.100;  % doesn't include ISItime
params.ISItime = 0.200;
params.blankColor = 128;  % ISI uniform color e.g. 128 for gray
params.nRepeats = 4;  % number of times to repeat sequence of blocks
params.initFix = 6;  % first fixation length
params.postFix = 0;

conds.A = 'checkerboard';
conds.B = 'consonants';
conds.C = 'bigrams';
conds.D = 'trigrams';
conds.E = 'words';

params.blockOrder = 'ABCDE';  % basic block order, will be repeated n times; predictable
params.blockOrder = repmat(params.blockOrder,1,params.nRepeats);
numBlocks = length(params.blockOrder);

scanLength = (params.blockLength+params.fixLength)*(numBlocks+1)+params.initFix+params.postFix
nFrames = scanLength/2

sprintf('\ndoWordHierarchy(params,conds)')
