function [pc,rc,nn] = getFixationPerformance(fixParams,stimulus,response)
%
%
% [percentCorrect,reactionTime] = getFixationPerformance(fixParams,stimulusSeq,responseSeq);
%
%
% 06.2005 SOD wrote it

if ~isfield(fixParams,'responseTime'),
    fixParams.responseTime = [0.01 3];  % look for responses between .01 and 3 seconds after
                                        % stimulus change
end;

pc = 0;  % percent correct
rc = 0;  % reaction time

switch fixParams.task,
    case 'Detect fixation change',
        stim     = abs(diff(stimulus.fixSeq));
        target   = find(stim>0);                       % change in stimulus
        resp     = find(diff(response.keyCode)>0);     % any response?
        resptime = response.secs(resp+1);   % + 1 to correct for diff operation
        
        count = [0 0];
        % loop over stimulus changes
        for n=1:numel(target),
            tmp=find(resptime >= stimulus.seqtiming(target(n)) + fixParams.responseTime(1) & ...
                     resptime <= stimulus.seqtiming(target(n)) + fixParams.responseTime(2));
        	if ~isempty(tmp),
                count(1) = count(1)+1;
                count(2) = count(2)+resptime(tmp(1))-stimulus.seqtiming(target(n));
            end;
        end;
        % calculate percent correct and reaction time (when correct)
        pc = count(1)/length(target).*100;
        if count(1)>0,
            rc = count(2)/count(1);
        end;
        nn = numel(target);
        
    otherwise,
        disp(sprintf('[%s]:Unknow fixation task',mfilename));
end;


