function facebehav_meanAndStd(fullRecord,loadFile)

%This function will compute the mean and standard deviation of Reaction
%Time and Percent correct across runs and save them within the fullRecord
%struct in the same file.

while exist(loadFile)==0
    loadFile=input('What is the name of the file you would like to load?');
    cd(fileparts(which(loadFile)));
    load loadFile;
end

%Calculate the possibilities within the condition matrix and store a matrix
%with each of these possibilities
conditionOptions=fullRecord(1).cond;
conditionOptions=sort(conditionOptions);
repConditionOptions=sum(conditionOptions(2)==conditionOptions);
conditionOptions=conditionOptions(2:length(conditionOptions)/repConditionOptions:end)

nconditionOptions=length(conditionOptions)

nRuns=size(fullRecord,2);
for runNum=1:nRuns
    
    %This converts the conditions in each trial of a single run into a
    %matrix.
    condition=[];
    isCorrect=[];
    for n=1:length(fullRecord(runNum.cond)
        condition(n)=fullRecord(runNum).cond;
        isCorrect(n)=fullRecord(runNum).reponses.isCorrect;
    end
    
    %Calculate the Reaction Time for all conditions.
    reactionTime=[];
    for n=5:2:length(fullRecord(runNum).responses.secs)
        reactionTime(n)=(fullRecord(runNum).responses.secs(n))-(fullRecord.onset(n-1));
    end
    
    %Calculate the Percent Correct for each condition in a matrix with a
    %separate row for each condition.  
    indexCondition=ones(length(conditionOptions),length(condition)/length(conditionOptions));
    for x=1:length(conditionOptions)
        indexCondition(x,:,runNum)=find(condition==conditionOptions(x));
        catIsCorrect(x,:,runNum)=isCorrect(indexCondition(x,:,runNum));
        catReactionTime(x,:,runNum)=reactionTime(indexCondition(x,:,runNum));
    end
end

for x=1:length(conditionOptions)
    percentCorrect(x)=mean(catIsCorrect(x,:,:));
    meanReactionTime(x)=mean(catReactionTime(x,:,:));
    stDevReactionTime(x)=std(catReactionTime(x,:,:));
end

for cond=conditionOptions
analy.percentCorrect.(cond)=percentCorrect(condition
analy.meanReactionTime.(cond)


saveFile=strcat('analy_', loadFile)
save saveFile fullRecord
