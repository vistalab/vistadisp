function [waitTime, nextFlipTime] = getWaitTime(stimulus, response, frame, t0, timeFromT0)
% [waitTime, nextFlipTime] = getWaitTime(stimulus, response, frame, t0, timeFromT0)
%
% If timeFromT0 we wait until the current time minus the initial time is
% equal to the desired presentation time, and then flip the screen.
% If timeFromT0 is false, then we wait until the current time minus the
% last screen flip time is equal to the desired difference in the
% presentation time of the current flip and the prior flip.


if timeFromT0
    nextFlipTime = t0 + stimulus.seqtiming(frame); 
    waitTime     =  GetSecs-nextFlipTime;
    
else
    if frame > 1,
        lastFlip = response.flip(frame-1);
        desiredWaitTime = stimulus.seqtiming(frame) - stimulus.seqtiming(frame-1);
    else
        lastFlip = t0+1;
        desiredWaitTime = stimulus.seqtiming(frame);
    end
    % we add 10 ms of slop time, otherwise we might be a frame late.
    % This should NOT cause us to be 10 ms early, because PTB waits
    % until the next screen flip. However, if the refresh rate of the
    % monitor is greater than 100 Hz, this might make you a frame
    % early. [So consider going to down to 5 ms? What is the minimum we
    % need to ensure that we are not a frame late?]
    slopTime = .015; % maybe should be expressed as a fraction of one refresh duration
    nextFlipTime = lastFlip + desiredWaitTime - slopTime;
    waitTime     = GetSecs - nextFlipTime;
end

