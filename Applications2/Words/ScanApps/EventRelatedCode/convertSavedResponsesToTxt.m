% Simple script to read in the saved variables to get out number of trials
% per condition across any number of runs

%cd /Users/Shared/AndreasWordsMatlab/EventRelatedCode/ResponseSorting/savedTrials/

% Initialize all trial counters
numResponse1Tot = 0;
numResponse2Tot = 0;

numCorrectRespTot = 0;
numIncorrectRespTot = 0;

numHitsTot = 0;
numMissesTot = 0;
numCorRejsTot = 0;
numFalseAlarmsTot = 0;

% mean RT measurements across conditions (initialize)
RTresp1Tot = 0;
RTresp2Tot = 0;
RTcorRespTot = 0;
RTincorRespTot = 0;
RThitsTot = 0;
RTmissesTot = 0;
RTcorRejTot = 0;
RTfalseAlarmsTot = 0;

count = 0;

% Have the user keep picking files to add up trials per cond
while 1
    behFile = mrvSelectFile('r','mat','Please select a behavior file. (Saved responses per condition)');
    if isempty(behFile)
        break
    end
    count = count+1;
    load(behFile)

    numResponse1Tot = numResponse1Tot+numResponse1;
    if ~(numResponse1==0)  % otherwise RT is NaN
        RTresp1Tot = RTresp1Tot+(Response1RT*numResponse1);
    end

    numResponse2Tot = numResponse2Tot+numResponse2;
    if ~(numResponse2==0)  % otherwise RT is NaN
        RTresp2Tot = RTresp2Tot+(Response2RT*numResponse2);
    end

    numCorrectRespTot = numCorrectRespTot+numCorrectResp;
    if ~(numCorrectResp==0)  % otherwise RT is NaN
        RTcorRespTot = RTcorRespTot+(CorrectRespRT*numCorrectResp);
    end

    numIncorrectRespTot = numIncorrectRespTot+numIncorrectResp;
    if ~(numIncorrectResp==0)  % otherwise RT is NaN
        RTincorRespTot = RTincorRespTot+(IncorrectRespRT*numIncorrectResp);
    end

    numHitsTot = numHitsTot+numHits;
    if ~(numHits==0)  % otherwise RT is NaN
        RThitsTot = RThitsTot+(HitsRT*numHits);
    end

    numMissesTot = numMissesTot+numMisses;
    if ~(numMisses==0)  % otherwise RT is NaN
        RTmissesTot = RTmissesTot+(MissesRT*numMisses);
    end

    numCorRejsTot = numCorRejsTot+numCorRejs;
    if ~(numCorRejs==0)  % otherwise RT is NaN
        RTcorRejTot = RTcorRejTot+(CorRejsRT*numCorRejs);
    end

    numFalseAlarmsTot = numFalseAlarmsTot+numFalseAlarms;
    if ~(numFalseAlarms==0)  % otherwise RT is NaN
        RTfalseAlarmsTot = RTfalseAlarmsTot+(FalseAlarmsRT*numFalseAlarms);
    end
end



% calculate mean RTs across all trials per condition
meanRTresp1 = RTresp1Tot/numResponse1Tot;
meanRTresp2 = RTresp2Tot/numResponse2Tot;
meanRTcorrectResp = RTcorRespTot/numCorrectRespTot;
meanRTincorrectResp = RTincorRespTot/numIncorrectRespTot;
meanRThits = RThitsTot/numHitsTot;
meanRTmisses = RTmissesTot/numMissesTot;
meanRTcorRej = RTcorRejTot/numCorRejsTot;
meanRTfalseAlarms = RTfalseAlarmsTot/numFalseAlarmsTot;

fid = fopen('TrialsPerConditionTotals.txt','wt');
fprintf(fid,'%s\t%0.0f\n','numResponse1:  ',numResponse1Tot);
fprintf(fid,'%s\t%0.0f\n\n','numResponse2:  ',numResponse2Tot);
fprintf(fid,'%s\t%0.0f\n','numCorrectResp:  ',numCorrectRespTot);
fprintf(fid,'%s\t%0.0f\n\n','numIncorrectResp:  ',numIncorrectRespTot);
fprintf(fid,'%s\t%0.0f\n','numHits:  ',numHitsTot);
fprintf(fid,'%s\t%0.0f\n','numMisses:  ',numMissesTot);
fprintf(fid,'%s\t%0.0f\n','numCorRejs:  ',numCorRejsTot);
fprintf(fid,'%s\t%0.0f\n\n\n','numFalseAlarms:  ',numFalseAlarmsTot);
fprintf(fid,'%s\t%0.3f\n','meanRT Resp 1:  ',meanRTresp1);
fprintf(fid,'%s\t%0.3f\n\n','meanRT Resp 2:  ',meanRTresp2);
fprintf(fid,'%s\t%0.3f\n','meanRT CorrectResp:  ',meanRTcorrectResp);
fprintf(fid,'%s\t%0.3f\n\n','meanRT IncorrectResp:  ',meanRTincorrectResp);
fprintf(fid,'%s\t%0.3f\n','meanRT Hits:  ',meanRThits);
fprintf(fid,'%s\t%0.3f\n','meanRT Misses:  ',meanRTmisses);
fprintf(fid,'%s\t%0.3f\n','meanRT CorRej:  ',meanRTcorRej);
fprintf(fid,'%s\t%0.3f\n\n\n','meanRT FalseAlarms:  ',meanRTfalseAlarms);

fprintf(fid,'%s%0.0f\n','Total number files counted:  ',count);

fclose(fid);