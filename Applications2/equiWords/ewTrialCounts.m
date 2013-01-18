function [countDat newDataSum] = ewTrialCounts(subjNum)

fileName = sprintf('S%02d.log',subjNum);
fid = fopen(fileName);
C = textscan(fid,'%s%s%s%s%s%s%s%s%s','Delimiter','\t');
otherFileName = sprintf('S%02ds01.mat',subjNum);
load(otherFileName);
round = 0;
stimSizes = zeros(1,20); eccDists = zeros(1,20); eccAngles = zeros(1,20);
stimSizes1   = dataSum(1).stimParams.stimSizes;
eccDists1    = dataSum(1).stimParams.eccDists;
eccAngles1   = dataSum(1).stimParams.eccAngles;
stimSizes1   = str2num(num2str(stimSizes1));
eccDists1    = str2num(num2str(eccDists1));
eccAngles1   = str2num(num2str(eccAngles1));
for i=1:4
    start = ((i-1)*5)+1;
    endstart = start+4;
    stimSizes(start:endstart) = stimSizes1(i:4:20);
    eccDists(start:endstart) = eccDists1(i:4:20);
    eccAngles(start:endstart) = eccAngles1(i:4:20);
end
for i=1:20
    stimSizes(i) = str2num(sprintf('%1.4f',stimSizes(i)));
end

for i=1:size(C{1},1)
    if ~isempty(cell2mat(strfind(C{1}(i),'curStair')));
        round = round + 1;
        if round==1 || round==13
            tally = 1;
        end
    end
    if ~isempty(cell2mat(strfind(C{1}(i),'width')))
        continue
    elseif ~isempty(cell2mat(strfind(C{1}(i),'2009')))
        continue
    elseif ~isempty(cell2mat(strfind(C{1}(i),'curStair')))
        continue
    end
    
    if round==1
        run=1;
        session = 1;
    elseif round==5
        run=2;
    elseif round==9
        run=3;
    elseif round==13
        session = 2;
        run=1;
    elseif round==17
        run=2;
    elseif round==21
        run=3;
    end
  
    trialInStair    = str2num(str2mat(C{2}(i)));
    width           = str2num(str2mat(C{7}(i)));
    distance        = str2num(str2mat(C{8}(i)));
    angle           = str2num(str2mat(C{9}(i)));
    stairInd        = stimSizes==width & ...
                      eccDists==distance & ...
                      eccAngles==angle;
    stairInd        = ((run-1)*20)+(find(stairInd==1));
    countDat{session}(stairInd).trialCount(trialInStair) = tally;
    countDat{session}(stairInd).width = width;
    countDat{session}(stairInd).distance = distance;
    countDat{session}(stairInd).angle = angle;
    
    tally = tally + 1;
end
    
for i = 1:2
    fileName = sprintf('S%02ds%02d.mat',subjNum,i);
    load(fileName);
    for ii = 1:60
        if str2num(sprintf('%1.4f',dataSum(ii).width(1)))==countDat{i}(ii).width && ...
           dataSum(ii).angle(1)==countDat{i}(ii).angle && ...
           dataSum(ii).distance(1)==countDat{i}(ii).distance
            dataSum(ii).trialCounts = countDat{i}(ii).trialCount;
        end
    end
    newDataSum{i} = dataSum;
    save(fileName,'dataSum');
end
    