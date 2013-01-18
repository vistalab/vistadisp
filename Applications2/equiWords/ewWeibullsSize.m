function data = ewWeibullsSize(subjNum,sessNums)

% Function to go through the dataSum after certain number of sessions
% (each of which contain numStaircases number of staircases) and plot a
% Weibull for each staircase.
%
% subjNum = vector of subject numbers you'd like processed
%
% sessNums = cell array of session numbers you'd like presented, cells are
% indexed by subject number, with each non-empty cell containing a vector
% of sessions one would like processed
%
practiceTrials = 10;
%close all % clean up the figures before plotting these
dataDir = '/Users/Shared/PsychophysData/equiWords/';
load(fullfile(dataDir,'ewSubjSess.mat'));

% Foolproof subjNum
if(exist('subjNum','var'))
    if(isempty('subjNum'))
       subjNum = 2:length(SubjList); % process all subjects when none are indicated (empty input)
    end
else
    subjNum = 2:length(SubjList); % process all subjects when none are indicated (no input at all)
end

% Foolproof sessNums
if(exist('sessNums','var'))
    if(isempty('sessNums'))
        for i=subjNum
            sessNums{i} = 1:SessList(i); % process all sessions when none are specified
        end
    else
        for i=subjNum
            if(isempty(sessNums{i}))
                sessNums{i} = 1:SessList(i); % process all sessions for empty cases when only some are specified
            end
        end
    end
else
    for i=subjNum
        sessNums{i} = 1:SessList(i); % process all sessions when none are specified
    end
end

for i=subjNum
    data{i} = [];
    for ii=sessNums{i}
        dataFile = sprintf('S%02ds%02d.mat',i,ii);
        load(fullfile(dataDir,dataFile));
        if ~isfield(dataSum(1).stairParams,'laps')
            dataSum(1).stairParams.laps = 1;
        end
        if(isempty(data{i}))
            for stairNum=1:dataSum(1).stairParams.nStairs % Initialization of all relevant fields
                data{i}(stairNum).history        = dataSum(stairNum).history;
                data{i}(stairNum).stimLevels     = dataSum(stairNum).stimLevels;
                data{i}(stairNum).wordRGB        = dataSum(stairNum).wordRGB(1);
                data{i}(stairNum).angle          = dataSum(stairNum).angle(1);
                data{i}(stairNum).distance       = dataSum(stairNum).distance(1);
                data{i}(stairNum).numCorrect     = zeros(size(data{i}(stairNum).stimLevels));
                data{i}(stairNum).numTrials      = zeros(size(data{i}(stairNum).stimLevels));
            end
        end
        for lap = 1:dataSum(1).stairParams.laps
            for stairNum = 1:dataSum(1).stairParams.nStairs
                stairRef = (dataSum(1).stairParams.nStairs*(lap-1))+stairNum ;
                for trial = 1:length(dataSum(stairRef).correct)
                    stimLevelInd = dataSum(stairRef).stimLevels == dataSum(stairRef).history(trial);
                    if dataSum(stairRef).trialCounts(trial)>practiceTrials
                        data{i}(stairNum).numCorrect(stimLevelInd==1) = data{i}(stairNum).numCorrect(stimLevelInd==1)+dataSum(stairRef).correct(trial);
                    end
                    data{i}(stairNum).numTrials(stimLevelInd==1) = data{i}(stairNum).numTrials(stimLevelInd==1)+1;
                end
            end
        end
    end
    
    % ANALYSIS CODE
    counter = 0;
    for stairNum=1:2:dataSum(1).stairParams.nStairs
        counter = counter + 1;
        data{i}(stairNum).numTrials = data{i}(stairNum+1).numTrials + data{i}(stairNum+1).numTrials;
        data{i}(stairNum).numCorrect = data{i}(stairNum+1).numCorrect + data{i}(stairNum+1).numCorrect;
        data{i}(stairNum).analysis = analyzeStaircase(data{i}(stairNum), 'threshErr',50);
        figure(i);
        subplot(1,3,counter);
        %subplot(dataSum(1).stairParams.measuredEcc,dataSum(1).stairParams.nStairs/dataSum(1).stairParams.measuredEcc,stairNum); % sizes x eccentricities subplot
        hold on; semilogx(data{i}(stairNum).analysis.x,data{i}(stairNum).analysis.y,'x');
        hold on; plot(data{i}(stairNum).analysis.wx,data{i}(stairNum).analysis.wy); hold on;
        %x = 10^-2:0.01:1;
        x = min(data{i}(stairNum).analysis.x):(max(data{i}(stairNum).analysis.x)-min(data{i}(stairNum).analysis.x))/10:max(data{i}(stairNum).analysis.x);
        y = .82*ones(size(x));
        plot(x,y,'.k','MarkerSize',2); 
        hold off; % plot line for 82%
        %set(gca,'xscale', 'log');
        %axis([10^-1 1 .5 1]);  % give them all the same scale
        axis([min(data{i}(stairNum).analysis.x) max(data{i}(stairNum).analysis.x) .5 1]);
        title(sprintf('%1.2f | %d | %1.1f',data{i}(stairNum).wordRGB,data{i}(stairNum).angle,data{i}(stairNum).distance),'FontSize',12);
    end
    %{
    %normed{i}.numCorrect = data{i}.numCorrect;
    %normed{i}.numTrials = data{i}.numTrials;
    normedSum{i}.history = [];
    normedSum{i}.stimLevels = [];
    normedSum{i}.numCorrect = [];
    normedSum{i}.numTrials = [];
    for stairNum=1:dataSum(1).stairParams.nStairs
        normed{i}(stairNum).numCorrect  = data{i}(stairNum).numCorrect;
        normed{i}(stairNum).numTrials   = data{i}(stairNum).numTrials;
        normed{i}(stairNum).history     = data{i}(stairNum).history/data{i}(stairNum).analysis.thresh;
        normed{i}(stairNum).stimLevels  = data{i}(stairNum).stimLevels/data{i}(stairNum).analysis.thresh;
        normed{i}(stairNum).analysis    = analyzeStaircase(normed{i}(stairNum));
        figure(100+i);
        subplot(dataSum(1).stairParams.measuredEcc,dataSum(1).stairParams.nStairs/dataSum(1).stairParams.measuredEcc,stairNum); % sizes x eccentricities subplot
        hold on; semilogx(normed{i}(stairNum).analysis.x,normed{i}(stairNum).analysis.y,'x');
        hold on; plot(normed{i}(stairNum).analysis.wx,normed{i}(stairNum).analysis.wy); hold on;
        x = 10^-2:0.01:1; 
        y = 0.82; 
        plot(x,y); 
        hold off; % plot line for 82%
        set(gca,'xscale', 'log');
        %axis([10^-1 1 .5 1]);  % give them all the same scale
        title(sprintf('%1.2f | %d | %1.1f',data{i}(stairNum).wordRGB,data{i}(stairNum).angle,data{i}(stairNum).distance),'FontSize',12);
        
        normedSum{i}.history = [normedSum{i}.history normed{i}(stairNum).history];
        normedSum{i}.stimLevels = [normedSum{i}.stimLevels normed{i}(stairNum).stimLevels];
        normedSum{i}.numCorrect = [normedSum{i}.numCorrect normed{i}(stairNum).numCorrect];
        normedSum{i}.numTrials = [normedSum{i}.numTrials normed{i}(stairNum).numTrials];
    end
    normedSum{i}.analysis = analyzeStaircase(normedSum{i});
    
    figure(200+i);
    hold on; semilogx(normedSum{i}.analysis.x,normedSum{i}.analysis.y,'x');
    hold on; plot(normedSum{i}.analysis.wx,normedSum{i}.analysis.wy); hold off;
    set(gca,'xscale', 'log');
    
    for stairNum=1:dataSum(1).stairParams.nStairs
        fixedSlope{i}(stairNum).analysis = analyzeStaircase(data{i}(stairNum),'fixSlope',normedSum{i}.analysis.slope,'threshErr',50);
        figure(300+i);
        subplot(dataSum(1).stairParams.measuredEcc,dataSum(1).stairParams.nStairs/dataSum(1).stairParams.measuredEcc,stairNum); % sizes x eccentricities subplot
        hold on; semilogx(fixedSlope{i}(stairNum).analysis.x,fixedSlope{i}(stairNum).analysis.y,'x');
        hold on; plot(fixedSlope{i}(stairNum).analysis.wx,fixedSlope{i}(stairNum).analysis.wy); hold on;
        x = 10^-2:0.01:1; 
        y = 0.82; 
        plot(x,y); 
        hold off; % plot line for 82%
        set(gca,'xscale', 'log');
        %axis([10^-1 1 .5 1]);  % give them all the same scale
        title(sprintf('%1.2f | %d | %1.1f',data{i}(stairNum).wordRGB,data{i}(stairNum).angle,data{i}(stairNum).distance),'FontSize',12);
    end
    % Sort of hacked this in, probably more elegant ways to do it that are
    % also more abstract and thus flexible, but for now it will do
    %}
    
    %{
    figure(100+i);
    xs = zeros(3,2);
    ys = zeros(3,2);
    xErrs = [];
    yErrs = [];
    
    for iEcc=1:3
        for iContrast=1:2
            iStair = iEcc+(3*(iContrast-1));
            y = data{i}(iStair).analysis.thresh;
            x = data{i}(iStair).distance;
            if data{i}(iStair).angle==270
                flag = -1;
            else
                flag = 1;
            end
            xs(iContrast,iEcc) = x*flag;
            ys(iContrast,iEcc) = y;
        end
    end
    
    xsFix(:,1) = xs(:,3); xsFix(:,2) = xs(:,1); xsFix(:,3) = xs(:,2);
    ysFix(:,1) = ys(:,3); ysFix(:,2) = ys(:,1); ysFix(:,3) = ys(:,2);
    
    hold on;
    plot(xsFix(1,:),ysFix(1,:),'-*b');
    plot(xsFix(2,:),ysFix(2,:),'-*g');
    
    for iEcc=1:3
        for iStair=iEcc:3:dataSum(1).stairParams.nStairs
            if data{i}(iStair).angle==270
                flag = -1;
            else
                flag = 1;
            end
            yP = data{i}(iStair).analysis.thresh + data{i}(iStair).analysis.threshErr;
            yN = data{i}(iStair).analysis.thresh - data{i}(iStair).analysis.threshErr;
            x = data{i}(iStair).distance*flag;
            plot([x x],[yN yP],'-+b');
        end
    end
    
    hold off;
    %}
end