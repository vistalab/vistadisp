function stim = facebehav_createTextures(stim, cleanUp);
% Special version of createTextures for the face behavioral experiments.
% While createTextures simply copys stim.images to stim.textures, this 
% function does several things:
%
%   * contrast-scales the images (RMS scaling for now)
%
%   * it places each image centered at the specified distance from the
%   fixation, based on stim.faceEcc, stim.faceAngle, and stim.fixPos;
%
%   * it creates a texture for each unique image position;
%
%   * it creates stim.seq to index the textures. To save on memory and
%   load times, the load process only loads each unique image once. But,
%   since that same image may occur at many screen positions, the value in 
%   in stim.seq will reflect the values in both stim.imgNum and stim.cond.
%
%
% ras, 06/23/09.
if notDefined('display'), display = stim.display;   end
if notDefined('cleanUp'), cleanUp = 1;              end

bgColor = 127;  % face image background color
X = stim.display.numPixels(1);
Y = stim.display.numPixels(2);
win = stim.display.windowPtr;

% compute row, column of fixation point: this will serve as the (0, 0)
% point for all stimulus locations specified in stim.faceEcc and
% stim.faceAngle.
cenX = round( X/2 + stim.fixPos(1) );
cenY = round( Y/2 + stim.fixPos(2) );

% how many unique stimuli are there? a unique stimulus is a combinaion of a
% particular image (indexed by stim.imgNum) and an image position (indexed by
% stim.cond).
condVals = [stim.cond(:) stim.imgNum(:)];
condVals = condVals(3:end,:);  % ignore first dummy events
condVals = unique(condVals, 'rows' );
nUniqueStimuli = size(condVals, 1);

% we'll initialize a vector for the new, re-indexed stimulus sequence. The
% indices in the new sequence will point to individual textures
% (combinations of image + position), rather than just the image alone
% (which is what's currently stim.imgNum). We'll swap in the new sequence
% after we finish the main loop.
stim.seq = repmat(-1, size(stim.imgNum));

%% main loop
for ii = 1:nUniqueStimuli
    %% get parameters for this stimulus:
    % which image #, which stim position?
    imgNum = condVals(ii,2);
    condNum = condVals(ii,1);
    [ysz xsz] = size(stim.images{imgNum}); % should == stim.faceSize(I)
    
    I = find(stim.imgNum==imgNum & stim.cond==condNum);
    r = stim.faceEcc(I);
    th = stim.faceAngle(I);
    
    %% initialize image: create a screen-size blank image
    img = repmat(bgColor, [Y X]);
    
    % for blank screens, this is all we need
    if strncmp(stim.image{I(1)}, 'blank', 5)
        stim.textures(ii) = Screen('MakeTexture', win, double(img));
        stim.seq(I) = ii;
        continue
    end
    
    
    %% place stimulus in screen-size image
    % there may be multiple trials with the same image and position. 
    % In this case, the index I will have several entries. This is fine, 
    % only check that the position (r, th) is represented by a single value, 
    % -- there really is only single unique position for this stimulus.
    if length(I) > 1  
        if condNum==0
            % it's okay, it's a blank trial
            r = r(1);
            th = th(1);
        else
            r = unique(r);
            th = unique(th);
            if length(r) > 1 | length(th) > 1
                keyboard
                %             error(['Mis-mapped stimuli: single stimulus expected at ' ...
                %                 'multiple positions.']);
            end
        end
    end
    
    % if requested, randomly left/right flip half the stimuli 
    % (this prevents all the trials being in a single visual hemifield)
    if stim.balanceLR==1
        doFlip = round(rand);
        if doFlip==1
           th = mod(th + pi, 2*pi); 
        end
    end
    
    % convert (r, th) values into image row and column
    [xx yy] = pol2cart(th, r);
    col = cenX + xx;
    row = cenY + yy;
    
    % intended x/y range subtended by whole face
    rows = round([1:ysz] - ysz/2 + row);
    cols = round([1:xsz] - xsz/2 + col);

    % allow for the stimulus to extend past the screen:
    % find only those 'ok' rows/cols within the screen bounds
    ok_rows = find(rows >= 1 & rows <= Y);
    ok_cols = find(cols >= 1 & cols <= X);
    
    if isempty(ok_rows) | isempty(ok_cols)
        warning('[%s]: Entire stimulus is offscreen.', mfilename);
        [r th col row X Y]
        continue;  % stimulus is entirely off screen
    end

    %% contrast scaling, final adjustments
    % TODO: add contrast scaling
    scaledImage = faceScaleContrast(stim.images{imgNum}, stim.contrast);
    
    % place the stimulus
    rows = rows(ok_rows);
    cols = cols(ok_cols);
    
    img(rows,cols) =  scaledImage(ok_rows,ok_cols);
   
    % reorient if specified by the display parameters
    if (isfield(display, 'flipLR') && stim.display.flipLR),
        img = fliplr(img);
    end
    if (isfield(display, 'flipUD') && stim.display.flipUD),
        img = flipud(img);
    end
    
    %% copy into an offscreen texture
    stim.textures(ii) = Screen('MakeTexture', win, double(img));  

    % the texture sequence should point to this texture
    stim.seq(I) = ii;
end;



% clean up
if cleanUp==1
    stim.images = {};
end

% call/load 'DrawTexture' prior to actual use (clears overhead)
Screen('DrawTexture', display.windowPtr, stim.textures(1));

return




