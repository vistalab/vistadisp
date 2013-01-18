% Script for getting percent correct in each condition averaged across runs
% for MotionWordsER scans.
%
% Run from the directory with the _savedResponses.mat files!
%
% note: assuming conds 1-4 are words, 5-8 are nonwords, and equal trials in
% both!



% Initialize all trial counters
% numResponse1Tot = 0;
% numResponse2Tot = 0;
% 
% numCorrectRespTot = 0;
% numIncorrectRespTot = 0;
% 
% numHitsTot = 0;
% numMissesTot = 0;
% numCorRejsTot = 0;
% numFalseAlarmsTot = 0;
PCsum.byCond = [0 0 0 0 0 0 0 0];

% % mean RT measurements across conditions (initialize)
% RTresp1Tot = 0;
% RTresp2Tot = 0;
% RTcorRespTot = 0;
% RTincorRespTot = 0;
% RThitsTot = 0;
% RTmissesTot = 0;
% RTcorRejTot = 0;
% RTfalseAlarmsTot = 0;

count = 0;

fid = fopen('PC-byConditionAveraged.txt','wt');

allMatFiles = dir('*savedResponses.mat');

if isempty(allMatFiles)
    fprintf('\n\nNo savedResponses.mat files found.  Pick manually.')
    % Have the user keep picking files to add up trials per cond
    while 1
        behFile = mrvSelectFile('r','mat','Please select a behavior file. (Saved responses per condition)');
        if isempty(behFile)
            break
        end
        count = count+1;
        load(behFile)

        PCsum.byCond = PCsum.byCond + PC.byCond;
        fprintf(fid,'%3.3f\t',PC.byCond)
        fprintf(fid,'%s\n',' ')
    end
    
else   % you did find the files in the current directory, so process them
    for curFile = 1:length(allMatFiles)
        behFile = allMatFiles(curFile).name;
        count = count+1;
        load(behFile)

        PCsum.byCond = PCsum.byCond + PC.byCond;
        fprintf(fid,'%3.3f\t',PC.byCond)
        fprintf(fid,'%s\n',' ')
    end

end
    

% Average across runs
PCavg.byCond = PCsum.byCond./count;
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n','Averaged across runs:')
fprintf(fid,'%3.3f\t',PCavg.byCond)
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n',' ')


% Average across word and nonword conditions
% note: assuming conds 1-4 are words, 5-8 are nonwords, and equal trials in both!
PCavg.WordsNWCombined(1)=(PCavg.byCond(1)+PCavg.byCond(5))/2;
PCavg.WordsNWCombined(2)=(PCavg.byCond(2)+PCavg.byCond(6))/2;
PCavg.WordsNWCombined(3)=(PCavg.byCond(3)+PCavg.byCond(7))/2;
PCavg.WordsNWCombined(4)=(PCavg.byCond(4)+PCavg.byCond(8))/2;
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n','Averaged across words and nonwords:')
fprintf(fid,'%3.3f\t',PCavg.WordsNWCombined)
fprintf(fid,'%s\n',' ')
fprintf(fid,'%s\n',' ')


fprintf(fid,'%s%0.0f\n','Total number files counted:  ',count);

fclose(fid);