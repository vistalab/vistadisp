% Script to make parfiles for block-design scans that test coherence level
% effect.  There will be 4 types of blocks:  100% motion coherence
% (switching between leftward and rightward direction), 0% motion
% coherence, a rectangle form with 100% motion coherence, and words with
% 100% motion coherence
%
% Blocks will be 150 frames * 2 seconds = 300 seconds.  That allows 25
% blocks, so 13 blocks of fixation and 12 blocks of task (3 of each type).
% Each subject will probably do 3 of these blocks.
%

fname = '/Users/Shared/ScanData/MotionWords/EventRelated/parfiles/MW_coherenceBlockScan1';

% Coherent planes
condLabels{1} = 'MW_mot-100.lum-0.informdir-90.outformdir-90_Words';
condLabels{2} = 'MW_mot-100.lum-0.informdir-270.outformdir-270_Words';

% Incoherent motion
condLabels{3} = 'MW_mot-0.lum-0.informdir-90.outformdir-90_Words';
condLabels{4} = 'MW_mot-0.lum-0.informdir-270.outformdir-270_Words';

% Rectangles (uses the nonword list)
condLabels{5} = 'MW_mot-100.lum-0.rect';
condLabels{6} = 'MW_mot-100.lum-0.rect';

% Words
condLabels{7} = 'MW_mot-100.lum-0_Words';
condLabels{8} = 'MW_mot-100.lum-0_Words';



scantime = 300; % seconds
blocklength = 12; % seconds
stimLength = 2;
ISI = 0.4;
numStims = blocklength/(stimLength+ISI);

numBlocks = scantime/blocklength;
numFix = ceil(numBlocks/2);
numStimBlocks = numBlocks-numFix;

onset(1) = 0;
cond(1) = 0;
label(1) = 'Fix';
count = 1;

for blocknum = 1:numStimBlocks
    for stimNum = 1:numStims
        count = count+1;
        
        
    end
    
end
