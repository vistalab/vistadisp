function [PC,meanRT] = TMSmotionWordsAnalyzeBehavior(PC,meanRT,suppressFigures)
%
%    [PC,meanRT] = TMSmotionWordsAnalyzeBehavior(PC,meanRT,[suppressFigures=0])
%
%  PC input must contain PC.numCorrectTrials and PC.numTotalTrials (one entry per condition)
%  meanRT input must contain meanRT.byCond, meanRT.correctTrials, and
%  meanRT.allTrials
%
%  standard dev and SEM are taken across rows of these variable.  Rows are
%  different instances (e.g. trials or subjects).  Columns are different
%  conditions, which are specified below.
%
%  if suppressFigures = 1, then no figures will be plotted
%
%  The output is for words and nonwords combined.
%

if ~exist('suppressFigures','var'), suppressFigures = 0; end


% Specify which conditions are which (comes from TMSmakeMotionWordsRun)
motConds = [1 2 7 8 13 14 19 20 25 26 31 32];  % all conditions with words defined by motion
lumConds = [3 4 9 10 15 16 21 22 27 28 33 34]; % all conditions with words defined by luminance
PSconds =  [5 6 11 12 17 18 23 24 29 30 35 36];% all conditions with words defined by contours (phase-scrambling)

wordConds = [1:2:36];  % all the odd conditions are words
NWconds = [2:2:36];  % all the even conditions are nonwords

latencies = [-95 5 87 165 264 885];
% TMS latencies are neg100, 0, 80, 160, 260, 880ms (but measured latencies
% are slightly different.  We are taking the median of the measured
% latencies to be true)
% 3 different conditions (motion, luminance, phase scrambled)


%% Get mean PC and mean RT (and STDs/SEMs) for motion, luminance, and PS
PC.motionTrials = sum(sum(PC.numCorrectTrials(:,motConds))) / sum(sum(PC.numTotalTrials(:,motConds))); %mean(PC.byCond(motConds));
PC.luminanceTrials = sum(sum(PC.numCorrectTrials(:,lumConds))) / sum(sum(PC.numTotalTrials(:,lumConds))); %mean(PC.byCond(lumConds));
PC.phasescrambleTrials = sum(sum(PC.numCorrectTrials(:,PSconds))) / sum(sum(PC.numTotalTrials(:,PSconds))); %mean(PC.byCond(PSconds));

% don't include NaNs for meanRT, which are incorrect responses
motInds = motConds(~isnan(meanRT.byCond(motConds)));
meanRT.motionTrials = mean(meanRT.byCond(motInds));

lumInds = lumConds(~isnan(meanRT.byCond(lumConds)));
meanRT.luminanceTrials = mean(meanRT.byCond(lumInds));

PSinds = PSconds(~isnan(meanRT.byCond(PSconds)));
meanRT.phasescrambleTrials = mean(meanRT.byCond(PSinds));

meanRT.allTrials(meanRT.allTrials==0) = NaN;  % these trials are not counted, e.g. if subject didn't respond at all or if trials were excluded by experimenter


%% Make plots for words and nonwords separately
% Words
for latencyCount = 1:length(latencies)
    % Motion
    curConds = motConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,wordConds);
    PC.mot(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.mot(latencyCount), PC.motSTD(latencyCount), PC.motSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.mot(latencyCount), meanRT.motSTD(latencyCount), meanRT.motSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.motCorIncor(latencyCount), meanRT.motCorIncorSTD(latencyCount), meanRT.motCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Luminance
    curConds = lumConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,wordConds);
    PC.lum(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.lum(latencyCount), PC.lumSTD(latencyCount), PC.lumSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.lum(latencyCount), meanRT.lumSTD(latencyCount), meanRT.lumSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.lumCorIncor(latencyCount), meanRT.lumCorIncorSTD(latencyCount), meanRT.lumCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Phase-Scramble
    curConds = PSconds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,wordConds);
    PC.ps(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.ps(latencyCount), PC.psSTD(latencyCount), PC.psSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.ps(latencyCount), meanRT.psSTD(latencyCount), meanRT.psSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.psCorIncor(latencyCount), meanRT.psCorIncorSTD(latencyCount), meanRT.psCorIncorSEM(latencyCount)] = getStats(curVals);
    
end

if ~suppressFigures
    figure('Name','Words only'); hold on
    plotAllStats(latencies,meanRT,PC)
end

% Non-words
for latencyCount = 1:length(latencies)
    % Motion
    curConds = motConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,NWconds);
    PC.mot(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.mot(latencyCount), PC.motSTD(latencyCount), PC.motSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.mot(latencyCount), meanRT.motSTD(latencyCount), meanRT.motSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.motCorIncor(latencyCount), meanRT.motCorIncorSTD(latencyCount), meanRT.motCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Luminance
    curConds = lumConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,NWconds);
    PC.lum(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.lum(latencyCount), PC.lumSTD(latencyCount), PC.lumSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.lum(latencyCount), meanRT.lumSTD(latencyCount), meanRT.lumSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.lumCorIncor(latencyCount), meanRT.lumCorIncorSTD(latencyCount), meanRT.lumCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Phase-Scramble
    curConds = PSconds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    curConds = intersect(curConds,NWconds);
    PC.ps(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        [PC.ps(latencyCount), PC.psSTD(latencyCount), PC.psSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.ps(latencyCount), meanRT.psSTD(latencyCount), meanRT.psSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.psCorIncor(latencyCount), meanRT.psCorIncorSTD(latencyCount), meanRT.psCorIncorSEM(latencyCount)] = getStats(curVals);
    
end

if ~suppressFigures
    figure('Name','Non-words only'); hold on
    plotAllStats(latencies,meanRT,PC)
end


%% Combine words and nonwords for each latency and each stimulus type (this will the output of the function)
for latencyCount = 1:length(latencies)
    
    % Motion
    curConds = motConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    PC.mot(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        curVals = mean(curVals,2); % take the mean across words and nonwords first (don't include in STD)
        perc = mean(curVals(:));
        %PC.motSTD(latencyCount) = sqrt( (perc*(1-perc)) / length(curVals(:)));  % standard error of the proportion is sqrt[p*(1-p) / n]
        [PC.mot(latencyCount), PC.motSTD(latencyCount), PC.motSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.mot(latencyCount), meanRT.motSTD(latencyCount), meanRT.motSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.motCorIncor(latencyCount), meanRT.motCorIncorSTD(latencyCount), meanRT.motCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Luminance
    curConds = lumConds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    PC.lum(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        curVals = mean(curVals,2); % take the mean across words and nonwords first (don't include in STD)
        perc = mean(curVals(:));
        %PC.lumSTD(latencyCount) = sqrt( (perc*(1-perc)) / length(curVals(:)));
        [PC.lum(latencyCount), PC.lumSTD(latencyCount), PC.lumSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.lum(latencyCount), meanRT.lumSTD(latencyCount), meanRT.lumSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.lumCorIncor(latencyCount), meanRT.lumCorIncorSTD(latencyCount), meanRT.lumCorIncorSEM(latencyCount)] = getStats(curVals);
    
    
    % Phase-Scramble
    curConds = PSconds((latencyCount-1)*2+1 : (latencyCount-1)*2+2);
    PC.ps(latencyCount) = sum(sum(PC.numCorrectTrials(:,curConds))) / sum(sum(PC.numTotalTrials(:,curConds)));
    if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
        PC.percCor = PC.numCorrectTrials ./ PC.numTotalTrials;
        curVals = PC.percCor(:,curConds);
        curVals = mean(curVals,2); % take the mean across words and nonwords first (don't include in STD)
        perc = mean(curVals(:));
        %PC.psSTD(latencyCount) = sqrt( (perc*(1-perc)) / length(curVals(:)));
        [PC.ps(latencyCount), PC.psSTD(latencyCount), PC.psSEM(latencyCount)] = getStats(curVals);
    end
    curVals = meanRT.correctTrials(:,curConds);
    [meanRT.ps(latencyCount), meanRT.psSTD(latencyCount), meanRT.psSEM(latencyCount)] = getStats(curVals);
    
    curVals = meanRT.allTrials(:,curConds);
    [meanRT.psCorIncor(latencyCount), meanRT.psCorIncorSTD(latencyCount), meanRT.psCorIncorSEM(latencyCount)] = getStats(curVals);
end

if ~suppressFigures
    figure('Name','Words and Nonwords combined'); hold on
    plotAllStats(latencies,meanRT,PC)
end


return


function plotAllStats(latencies,meanRT,PC)
%% Plot
% Make 3 separate plots (1 per condition), 1 point per latency, averaged
% across words and nonwords

fontsz = 18;  % font size for axis labels (not tick labels)

subplot(3,3,1)
hE = errorbar(latencies,meanRT.mot,meanRT.motSEM,'*-');
formatPlot(hE,'*');
%plot(latencies,meanRT.mot,'*-')
setRTaxes(latencies)
ylabel('RT - correct trials (sec)','fontsize',fontsz)
title('Motion-Defined','fontsize',fontsz)

subplot(3,3,4)
hE = errorbar(latencies,meanRT.motCorIncor,meanRT.motCorIncorSEM,'*-');
formatPlot(hE,'*');
%plot(latencies,meanRT.motCorIncor,'*-')
setRTaxes(latencies)
ylabel('RT - all trials (sec)','fontsize',fontsz)

subplot(3,3,7)
if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
    hE = errorbar(latencies,PC.mot,PC.motSTD,'o-');
else
    hE = plot(latencies,PC.mot,'o-');
end
hold on
chanceLev = ones(1,length(latencies))*0.5;  % chance level of 0.5
lev82 = ones(1,length(latencies))*0.82;
plot(latencies,chanceLev,'--k','LineWidth',1)
plot(latencies,lev82,'--k','LineWidth',1)
setPCaxes(latencies)
formatPlot(hE,'o');
ylabel('Percent Correct','fontsize',fontsz)

subplot(3,3,2)
hE = errorbar(latencies,meanRT.lum,meanRT.lumSEM,'*-');
%plot(latencies,meanRT.lum,'*-')
setRTaxes(latencies)
formatPlot(hE,'*');
title('Luminance-Defined','fontsize',fontsz)

subplot(3,3,5)
hE = errorbar(latencies,meanRT.lumCorIncor,meanRT.lumCorIncorSEM,'*-');
%plot(latencies,meanRT.lumCorIncor,'*-')
setRTaxes(latencies)
formatPlot(hE,'*');


subplot(3,3,8)
if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
    hE = errorbar(latencies,PC.lum,PC.lumSTD,'o-');
else
    hE = plot(latencies,PC.lum,'o-');
end
hold on
plot(latencies,chanceLev,'--k','LineWidth',1)
plot(latencies,lev82,'--k','LineWidth',1)
setPCaxes(latencies)
formatPlot(hE,'o');
xlabel('SOA (ms)','fontsize',fontsz)


subplot(3,3,3)
hE = errorbar(latencies,meanRT.ps,meanRT.psSEM,'*-');
%plot(latencies,meanRT.ps,'*-')
setRTaxes(latencies)
title('Contour-Defined','fontsize',fontsz)
formatPlot(hE,'*');

subplot(3,3,6)
hE = errorbar(latencies,meanRT.psCorIncor,meanRT.psCorIncorSEM,'*-');
%plot(latencies,meanRT.psCorIncor,'*-')
setRTaxes(latencies)
formatPlot(hE,'*');


subplot(3,3,9)
if size(PC.numCorrectTrials,1) > 1  % more than one row (e.g. multiple subjects), so get STD and SEM
    hE = errorbar(latencies,PC.ps,PC.psSTD,'o-');
else
    hE = plot(latencies,PC.ps,'o-');
end
hold on
plot(latencies,chanceLev,'--k','LineWidth',1)
plot(latencies,lev82,'--k','LineWidth',1)
setPCaxes(latencies)
formatPlot(hE,'o');


return


function formatPlot(hE,markStyle)
if ~exist('markStyle'), markStyle = 'o'; end
set(hE                , ...
    'LineStyle'       , '-'       , ...
    'Marker'          , '.'          , ...
    'Color'           , [.1 .1 .1]   );
set(hE                , ...
    'LineWidth'       , 2            , ...
    'Marker'          , markStyle    , ...
    'MarkerSize'      , 5            , ...
    'MarkerEdgeColor' , [0.1 0.1 0.1], ...
    'MarkerFaceColor' , [.7 0 0]     );
return



function setRTaxes(latencies)
set(gca,'xlim',[-150 900])
set(gca,'XTick',latencies)
set(gca,'XTickLabel',{'-95','5','87','165','264','885'},'fontsize',12)
set(gca,'ylim',[0.8 3])
return

function setPCaxes(latencies)
set(gca,'xlim',[-150 900])
set(gca,'XTick',latencies)
set(gca,'XTickLabel',{'-95','5','87','165','264','885'},'fontsize',14)
% set(gca,'ylim',[0 1])
% set(gca,'YTick',[0 0.25 0.5 0.75 1])
% set(gca,'YTickLabel',{'0','25','50','75','100'})
set(gca,'ylim',[0.4 1])
set(gca,'YTick',[0.5 0.75 1])
set(gca,'YTickLabel',{'50','75','100'})
return

function [curMean,stanDev,stanErr] = getStats(curVals)
curMean = nanmean(curVals(:)); % ignore NaNs, which are incorrect responses
stanDev = nanstd(curVals(:));
stanErr = nanstd(curVals(:)) / sqrt((length(curVals(:))-length(find(isnan(curVals(:))))));
return

