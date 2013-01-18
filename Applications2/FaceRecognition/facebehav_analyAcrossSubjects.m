function facebehav_analyAcrossSubjects(fullRecord,stimSet)

%This function will compute the standard deviations and means of the
%Reaction Times and percent correct across runs and subjects.

subjectNames=input('Which subject(s) would you like to analyze?');
stimSet=input('Which stimulus set(s) would you like to analyze?');
taskSet=input('Which task set(s) would you like to analyze?');

for z=1:length(taskSet)
    for y=1:length(subjectNames)
        for x=1:length(stimSet)
        fileName=strcat(subjectNames(y), '-', taskSet(z), '_', stimSet(x), '.mat');
        load fileName;
        
        
        
        
        fullRecord.zAnalysis.stDevReactionTime
        end
    end
end