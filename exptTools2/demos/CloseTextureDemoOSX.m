function CloseTextureDemoOSX(numTex, texsize, fastpath)
% Benchmark the speed of creating many textures via MakeTexture and
% deleting them again via Screen('Close')...
%
% numTex = Number of textures to create and close afterwards.
% texsize = Size of textures: Creates luminance only textures of size
% texsize x texsize pixels.
% fastpath = 0 == Close textures via Matlab-loop, 1 == Close via fast
% Screen('Close') call.
%
% --> Although closing all textures via Screen('Close') is more convenient
% than doing it in a Matlab for-loop via multiple calls, it isn't much
% faster! The call-overhead and for-loop overhead of Matlab is usually
% negligible compared to the time it takes for PTB to release all texture
% memory.
%
% --> It's mostly texture size and amount of physical RAM that matters.
%

% History:
% 01/30/05  mk  wrote it.

try
    % Open up a window on the screen and clear it.
    s = max(Screen('Screens'));
    w = Screen('OpenWindow',s,0,[],[],2);
    t = magic(texsize);
    Screen('Flip',w);
    t1=GetSecs();
    for i=1:numTex
        tex(i)=Screen('MakeTexture', w, t);
    end;
    tcreate_secs=GetSecs() - t1
    tcreate_msecs_pertex= tcreate_secs / numTex * 1000
    
    % Destroy textures:
    t3=GetSecs();
    if (fastpath>0)
        Screen('Close');
    else
        for i=1:numTex
            Screen('Close', tex(i));
        end;
    end;
    
    tdestroy_secs=GetSecs() - t3
    tdestroy_msecs_pertex=tdestroy_secs / numTex * 1000
    
    Screen('CloseAll');
catch
    Screen('CloseAll');
    rethrow(lasterror);
end

