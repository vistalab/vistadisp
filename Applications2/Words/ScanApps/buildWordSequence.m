function sequence = buildWordSequence(sequenceFile,params,numStimuli)
%
% sequence = buildWordSequence(sequenceFile,params,numStimuli)
%
% Builds the stimulus sequence for running the word scan, based on a text
% file with the following format, where the first column is the condition and
% the second column is the number of seconds for that condition:
%
% wordM 12
% blank 4
% noiseM 8
% wordM 4
%
% Valid conditions are: 
% wordM, nonWordM, noiseM, wordL, nonWordL, noiseL, blank  
% (M and L stand for motion and luminance, respectively)
%
% Sequence will be a list of indexes specifying the order of stimuli to
% play.  e.g. [1 2 3 1 2 3 8 8 4 5 6 4]
% 
% written by amr 7/29/08
%


fid = fopen(sequenceFile);
cols = textscan(fid,'%s%f');
fclose(fid);

wordCount = 1;
nonwordCount = 1;
noiseMcount = 1;
noiseLcount = 1;

sequence =[];

% Right now, the first third of stimuli are nonwords, the second third are words, and the third
% third are noise. They are all params.duration seconds long.  With 9 stimuli, this means
% 1-3 are words,
% 4-6 are nonwords,
% 7-9 are noise.
% Last stimulus (10) is background colored blank. (Also params.duration
% seconds long)

for ii=1:length(cols{1})
    if strcmp(cols{1}(ii),'wordM')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence wordCount];
            wordCount=wordCount+1;
            if wordCount > 3
                wordCount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'nonWordM')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence nonwordCount+3];
            nonwordCount=nonwordCount+1;
            if nonwordCount > 3
                nonwordCount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'noiseM')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence noiseMcount+6];
            noiseMcount=noiseMcount+1;
            if noiseMcount > 3
                noiseMcount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'wordL')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence wordCount+9];
            wordCount=wordCount+1;
            if wordCount > 3
                wordCount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'nonWordL')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence nonwordCount+12];
            nonwordCount=nonwordCount+1;
            if nonwordCount > 3
                nonwordCount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'noiseL')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence noiseLcount+15];
            noiseLcount=noiseLcount+1;
            if noiseLcount > 3
                noiseLcount = 1;
            end
        end
    elseif strcmp(cols{1}(ii),'blank')
        for jj=1:(cols{2}(ii)/params.duration)
            sequence = [sequence numStimuli];  % numStimuli is the last stimulus, which is a blank
        end
    else
        sprintf('Bad sequence file. Condition not recognized: %s',char(cols{1}(ii)))
        return;
    end
end

return;