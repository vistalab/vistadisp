function [analysis] = WordWeibulls(fileName,days)

% Function to go through the dataSum after certain number of sessions
% (each of which contain numStaircases number of staircases) and plot a
% Weibull for each staircase.
%
%  written by amr Feb 10, 2009
%  some small edits by rfb Feb 10, 2009

processData = 1;
if notDefined('numStaircases'), numStaircases = 6; end
%if notDefined('numSessions'), numSessions = 6; end
processedFile = sprintf('/Users/Shared/PsychophysData/WordStaircase/%sPROCESSED.mat',fileName);
loadFile = sprintf('/Users/Shared/PsychophysData/WordStaircase/%ssum.mat',fileName);
if ~exist('/Users/Shared/PsychophysData/WordStaircase/Plots/','dir')
    mkdir('/Users/Shared/PsychophysData/WordStaircase/Plots/');
end
if exist(processedFile,'file')
    display('Data Already Processed - Loading Analysis...');
    load(processedFile);
    processData = 0;
end

if processData
    load(loadFile);

    % Lame hack to make it easy to select days of subjects running
    d1 = []; d2 = []; d3 = []; d4 = [];
    count = 0;
    if find(days==1)
        d1 = dataSum(1:18);
        count = count+1;
    end
    if find(days==2)
        d2 = dataSum(19:36);
        count = count+1;
    end
    if find(days==3)
        d3 = dataSum(37:54);
        count = count+1;
    end
    if find(days==4)
        d4 = dataSum(55:72);
        count = count+1;
    end
    dataSum = [d1 d2 d3 d4];
    numSessions = count*3;


    for stairNum = 1:numStaircases
           d(stairNum).history      = dataSum(stairNum).history; % for now let's just take the first history, the median of which acts as starting guess
           d(stairNum).stimLevels   = dataSum(stairNum).stimLevels;
           d(stairNum).numCorrect   = zeros(size(d(stairNum).stimLevels));  % initalize
           d(stairNum).numTrials    = zeros(size(d(stairNum).stimLevels)); % initialize
       for datasumnum = stairNum:numStaircases:(numSessions*numStaircases)  % add up numCorrect and numTrials for each session of that staircase
           d(stairNum).numCorrect   = d(stairNum).numCorrect + dataSum(datasumnum).numCorrect;
           d(stairNum).numTrials    = d(stairNum).numTrials + dataSum(datasumnum).numTrials;
       end
       dnorm(stairNum).numCorrect   = d(stairNum).numCorrect;
       dnorm(stairNum).numTrials    = d(stairNum).numTrials;
       analysis.numTrials(stairNum,:) = d(stairNum).numTrials;
    end

    % Initialize variables for normalized data set
    dnormSum.history = [];
    dnormSum.stimLevels = [];
    dnormSum.numCorrect = [];
    dnormSum.numTrials = [];

    for stairNum = 1:numStaircases
        % Standard fits
        analysis.fitData(stairNum) = analyzeStaircase(d(stairNum));

        % Normalize by threshold
        dnorm(stairNum).history = d(stairNum).history/analysis.fitData(stairNum).thresh;
        dnorm(stairNum).stimLevels = d(stairNum).stimLevels/analysis.fitData(stairNum).thresh;

        % Fit Weibull to each set of data normalized
        analysis.fitNormData(stairNum) = analyzeStaircase(dnorm(stairNum));

        % Combine normalized data set
        dnormSum.history = [dnormSum.history dnorm(stairNum).history];
        dnormSum.stimLevels = [dnormSum.stimLevels dnorm(stairNum).stimLevels];
        dnormSum.numCorrect = [dnormSum.numCorrect dnorm(stairNum).numCorrect];
        dnormSum.numTrials = [dnormSum.numTrials dnorm(stairNum).numTrials];
    end

    % Store this normalized data for use later
    analysis.dnormSum = dnormSum;

    % Fit Weibull to all data normalized
    analysis.fitAllNormData = analyzeStaircase(dnormSum);

    color = {'m' 'r' 'g' 'b' 'c' 'k'}; 
    for stairNum=1:numStaircases
        analysis.fitSlopeFix(stairNum) = analyzeStaircase(d(stairNum),'fixSlope',analysis.fitAllNormData.slope,'threshErr',1000);

        % THIS DOESN'T WORK
        %analysis.normFixSlope(stairNum) =
        %analyzeStaircase(dnorm(stairNum),'fixSlope',analysis.fitAllNormData.slope,'threshErr',100);
    end
    
    save(processedFile,'analysis');
end

%COMMENTED OUT ONE OF THE FIGURES
%{
% figure(3);
% hold on; semilogx(analysis.fitAllNormData.x,analysis.fitAllNormData.y,'x');
% hold on; plot(analysis.fitAllNormData.wx,analysis.fitAllNormData.wy); hold off;
% set(gca,'xscale', 'log');
%}

for stairNum=1:numStaircases
    %COMMENTED OUT ONE OF THE FIGURES
    %{
    %     figure(1);
    %     subplot(3,2,stairNum);
    %     hold on; semilogx(analysis.fitData(stairNum).x,analysis.fitData(stairNum).y,'x');
    % 	  hold on; plot(analysis.fitData(stairNum).wx,analysis.fitData(stairNum).wy); hold on;
    %     x = 10^-2:0.01:1; y = 0.82; plot(x,y); hold off; % plot line for 82%
    %     set(gca,'xscale', 'log');
    %     axis([10^-1 1 0 1]);  % give them all the same scale
    %}
    
    %COMMENTED OUT ONE OF THE FIGURES
    %{
    %     figure(2);
    %     subplot(3,2,stairNum);
    %     hold on; semilogx(analysis.fitNormData(stairNum).x,analysis.fitNormData(stairNum).y,'x');
    % 	hold on; plot(analysis.fitNormData(stairNum).wx,analysis.fitNormData(stairNum).wy); hold on;
    %     x = [1 1]; y = [0 1]; plot(x,y); hold off;
    %     set(gca,'xscale', 'log');
    %     XLIM([.25 3])
    %}
    
    %COMMENTED OUT ONE OF THE FIGURES
    %{
    %     figure(4);
    %     subplot(3,2,stairNum);
    %     hold on; semilogx(analysis.fitSlopeFix(stairNum).x,analysis.fitSlopeFix(stairNum).y,'x');
    % 	hold on; plot(analysis.fitSlopeFix(stairNum).wx,analysis.fitSlopeFix(stairNum).wy); hold on;
    %     x = 10^-2:0.01:1; y = 0.82; plot(x,y); hold off; % plot line for 82%
    %     set(gca,'xscale', 'log');
    %     axis([10^-1 1 0 1])  % give them all the same scale
    %     
    %     figure(5);
    %     semilogx(analysis.fitSlopeFix(stairNum).wx,analysis.fitSlopeFix(stairNum).wy,color{stairNum}); hold on;
    %}
end

% FINAL PLOT
% Getting ready for a normalized plot to get everything on one plot

% Initialize threshold variables
thresh = zeros(1,6);
threshErr = zeros(1,6);

% Store thresholds & errors for each staircase into variables
for stairs=1:6
    thresh(stairs) = analysis.fitSlopeFix(stairs).thresh;
    threshErr(stairs) = analysis.fitSlopeFix(stairs).threshErr;
end

% Compute some variables for plotting later
analysis.savThreshErr = threshErr;
beta = analysis.fitAllNormData.slope;
alpha1 = analysis.fitSlopeFix(1).thresh;
alpha2 = analysis.fitSlopeFix(6).thresh;

%makeANormPlot(thresh); hold on;
makeAPlot(thresh, threshErr);

% Compute performance threshold
perfThresh = 1-.5*(1/exp(1));

% Plotting error bars for prediction
% Threshold Line
x=0:.00001:alpha1;
y=nthroot(((alpha2^beta)*(-(log(2-(2*perfThresh)))-((x/alpha1).^beta))),beta);
plot(x,y,'--'); hold on;
y=alpha2*(nthroot(-log(2-(2*perfThresh)),beta) - x/alpha1);
plot(x,y,'r--'); hold on;

% + Error Line
alpha1 = analysis.fitSlopeFix(1).thresh+threshErr(1);
alpha2 = analysis.fitSlopeFix(6).thresh+threshErr(6);
x=0:.00001:alpha1;
y=nthroot(((alpha2^beta)*(-(log(2-(2*perfThresh)))-((x/alpha1).^beta))),beta);
plot(x,y,'-'); hold on;
y=alpha2*(nthroot(-log(2-(2*perfThresh)),beta) - x/alpha1);
plot(x,y,'r-'); hold on;

% - Error Line
alpha1 = analysis.fitSlopeFix(1).thresh-threshErr(1);
alpha2 = analysis.fitSlopeFix(6).thresh-threshErr(6);
x=0:.00001:alpha1;
y=nthroot(((alpha2^beta)*(-(log(2-(2*perfThresh)))-((x/alpha1).^beta))),beta);
plot(x,y,'-'); hold on;
y=alpha2*(nthroot(-log(2-(2*perfThresh)),beta) - x/alpha1);
plot(x,y,'r-'); hold on;

dString = sprintf('%d',days);
gTitle = sprintf('/Users/Shared/PsychophysData/WordStaircase/Plots/%s',fileName); 
%title(gTitle);
leave = input('Leave as is? (0 = No, 1 = Yes) \n');
if ~leave
    axischange = input('Change x axis? (0 = No, 1 = Yes) \n');
    if axischange
        changeto = input('Change max to what? \n');
        set(gca,'XTick',0:(changeto/5):changeto,'fontSize', 20);
        xlim([0 changeto]);
    end
    removeaxis = input('Remove any axes? (0 = X, 1 = Y, 2 = X & Y) \n');
    if removeaxis==0
        set(gca,'XTickLabel',{''});
    elseif removeaxis==1
        set(gca,'YTickLabel',{''});
    elseif removeaxis==2
        set(gca,'XTickLabel',{''});
        set(gca,'YTickLabel',{''});
    end
end
saveas(gcf,gTitle,'epsc2');
