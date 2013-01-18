function imgForm = labelDots(dp, numFrames, form, formInd)

imgForm = ones(dp.stimHigh,dp.stimWide,numFrames,'uint8'); % 15 ms
aFrame = ones(dp.stimHigh,dp.stimWide,'uint8'); % .5 ms

for ii=1:numFrames
    % This section takes ~15 ms, done 67 times, therefore ~1005 ms in total
    dp.dotAge = dp.dotAge + 1;
    deadDots = find(dp.dotAge>dp.dotLife);
    dp.dotAge(deadDots) = 1;
    dp.xPos(deadDots) = ceil(rand(length(deadDots),1)*dp.stimWide)-1;
    dp.yPos(deadDots) = ceil(rand(length(deadDots),1)*dp.stimHigh)-1;

    % Second, find the signal dots and move them
    dp.xPos(dp.motSigDots) = dp.xPos(dp.motSigDots)+dp.xDisp;
    dp.yPos(dp.motSigDots) = dp.yPos(dp.motSigDots)+dp.yDisp;

    % Third, move the noise dots
    dp.xPos(dp.motNoiseDots) = dp.xPos(dp.motNoiseDots)+dp.randX;
    dp.yPos(dp.motNoiseDots) = dp.yPos(dp.motNoiseDots)+dp.randY;
    
    % Fourth, check for x-axis wrap-around
    dp.index = find(dp.xPos>dp.stimWide-1);
    dp.xPos(dp.index) = dp.xPos(dp.index)-dp.stimWide+1;
    dp.index = find(dp.xPos<0);
    dp.xPos(dp.index) = dp.xPos(dp.index)+dp.stimWide-1;

    % Fifth, check for y-axis wrap-around
    dp.index = find(dp.yPos>dp.stimHigh-1);
    dp.yPos(dp.index) = dp.yPos(dp.index)-dp.stimHigh+1;
    dp.index = find(dp.yPos<0);
    dp.yPos(dp.index) = dp.yPos(dp.index)+dp.stimHigh-1;
    
    % Sixth, convert xPos & yPos to a vector index, dotPos
    dotPos = sub2ind(size(aFrame),floor(dp.yPos)+1,floor(dp.xPos)+1);
    
    % Lastly, we assign the labels
    aFrame(:) = dp.backCol; % .1 ms
    %aFrame(form==1) = 3;  % this could be a good place to change the color of the form (not the dots in the form)
    aFrame(dotPos) = dp.inFormCol(formInd+1); %  1 ms - Luminance Signal Dots
    n = length(dp.lumNoiseDots); % .1 ms

    for i=0:(n-1) % .2 ms
        aFrame(dotPos(dp.lumNoiseDots{i+1})) = dp.noiseCol+i;
    end

    aFrame(form~=formInd) = 0; % 1.5 ms
    imgForm(:,:,ii) = aFrame; % .1 ms
end