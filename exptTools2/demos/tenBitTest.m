
AssertOpenGL;
screens = Screen('Screens');
screenNumber = max(screens);

tenBit = [1 1]'*[1:255];
eightBit = floor(tenBit/4)*4 + 1;

oldTable = repmat(linspace(0,1,256)',1,3);

im = repmat([repmat(tenBit(:)', 32, 1); repmat(eightBit(:)', 32, 1)], 8, 1);
im = uint8(repmat(im,[1 1 3]));
%figure(1);
%image(im); axis tight off; truesize;

table = repmat(linspace(.5-.25/2,.5+.25/2,256)',1,3);

numFrames = 16;
inc = 0.25./numFrames;
offset = 0;
bgGamma = [.5 .5 .5];
linMap = repmat(linspace(0,.25,255)',1,3);
gt{1} = [bgGamma; linMap*0]; gt{numFrames} = gt{1};
for(ii=2:numFrames+1)
    gt{ii} = [bgGamma; offset+linMap];
    offset = offset+inc;
end

try
    tex = Screen('MakeTexture', screenNumber, im);
    w = Screen('OpenWindow', screenNumber, 0, [], 32, 2);
    Screen('LoadNormalizedGammaTable', screenNumber, gt{round(numFrames/2)});
    Screen('FillRect', w, 0);
    Screen('DrawTexture', w, tex);
    Screen('Flip', w);
    Screen('FillRect', w, 0);
    Screen('DrawTexture', w, tex);
    Screen('Flip', w);
    pause(5);

    % Run the movie animation for a fixed period.
    for(ii=1:numFrames)
        Screen('DrawTexture', w, tex);
        Screen('Flip', w);
        Screen('LoadNormalizedGammaTable', screenNumber, gt{ii});
        pause(1);
    end;
    Screen('LoadNormalizedGammaTable', screenNumber, oldTable);

    % Close onscreen and offscreen windows and textures.
    Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    Screen('LoadNormalizedGammaTable', screenNumber, oldTable);
    rethrow(lasterror);
end %try..catch..