function gp = gp_params;
% gp_params - initiate Goldmann perimetry parameters

% 08/2005 sod wrote it

movefix = [0 0];%[-14 -7];
fixsize = 0.25;

% stuff to ask.
gp.subject         = input(sprintf('[%s]:Enter subjects initials : ',mfilename),'s');
if isempty(gp.subject),
    gp.subject = 'test';
end;
gp.screenHeightDeg = input(sprintf('[%s]:What is the screen diameter in degrees [default = 28deg]? : ',mfilename));
if isempty(gp.screenHeightDeg),
    gp.screenHeightDeg = 28;
end;
% standard size V dot is 64mm2 at 33cm distance
gp.dot.sizeInDeg   = input(sprintf('[%s]:Enter dot size in degrees [default = 0.78deg]: ',mfilename));
if isempty(gp.dot.sizeInDeg),
    gp.dot.sizeInDeg = 0.78;
end;

% set response device
gp.devices = getDevices;
if isempty(gp.devices.keyInputExternal),
    gp.devices.keyInputExternal = gp.devices.keyInputInternal;
end;
disp(sprintf('[%s]:Getting subjects responses from device #%d',mfilename,gp.devices.keyInputExternal));
disp(sprintf('[%s]:Getting experimentor''s responses from device #%d',mfilename,gp.devices.keyInputInternal));


% display params
gp.display = loadDisplayParams('displayName','3T_projector_800x600');
gp.display.quitProgKey    = KbName('q');
gp.display.yesKey    = 'm';
gp.display.noKey     = 'x';
disp(sprintf('[%s]:When stimulus is detected press %s otherwise press %s',...
    mfilename,gp.display.yesKey,gp.display.noKey));
gp.display.screenNumber   = max(Screen('screens'));
gp.display.backColorRgb   = [0 0 0 255];
gp.screenRect    = Screen('Rect', gp.display.screenNumber);
gp.screenSize    = gp.screenRect([3 4]);


gp.dot.size         = round((gp.screenSize(2)./gp.screenHeightDeg)).*gp.dot.sizeInDeg; % 1 deg
gp.dot.coordAxis    = 'polar'; % polar or cartesian coordinate system
gp.dot.coordCenter  = round(gp.screenSize./2); % center coordinates
gp.dot.coordNLines  = 4; % per quadrant
gp.dot.timePerPixel = 0.001; % sec 
gp.dot.colorRgb     = [255 255 255 255];

% display params
gp.display = loadDisplayParams('displayName','builtin');
gp.display.quitProgKey    = KbName('q');
gp.display.screenNumber   = max(Screen('screens'));
gp.display.backColorRgb   = [80 80 80 255]; % 0.5 log units apart
%--- make fixation cross
gp.display.fixType          = 'disk'; %'largeCross'
switch(gp.display.fixType)
    case 'disk',
        gp.display.fixColorRgb    = [255 0 0 255];
        gp.display.fixSizePixels  = ceil((gp.screenSize(2)./gp.screenHeightDeg).*fixsize);%./4 %0.25 deg
        % place fixation in center
        gp.display.fixY = round(gp.screenSize(2)./2); % assume ydim is smallest
        gp.display.fixX = round(gp.screenSize(1)./2);
        % move fixation
        gp.display.fixationOffsetInDegX = movefix(1); % minus is left
        gp.display.fixationOffsetInDegY = movefix(2);  % minus is down
        gp.display.fixationOffsetInPixelsX = gp.display.fixationOffsetInDegX./gp.screenHeightDeg.*gp.screenSize(2); 
        gp.display.fixationOffsetInPixelsY = gp.display.fixationOffsetInDegY./gp.screenHeightDeg.*gp.screenSize(2); 
        gp.display.fixX = round(gp.screenSize(1)./2 + gp.display.fixationOffsetInPixelsX);
        gp.display.fixY = round(gp.screenSize(2)./2 - gp.display.fixationOffsetInPixelsY); % assume ydim is smallest

    case 'largeCross'
        gp.display.fixColorRgb    = [255 0 0 255];
        gp.display.fixSizePixels  = 12;
        dim.ycoord = [1:gp.screenSize(2) gp.screenSize(2):-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:gp.screenSize(2) 1:gp.screenSize(2)] + round(-gp.screenSize(2)/2+gp.screenSize(1)/2);
        gp.display.fixCoords = [dim.xcoord;dim.ycoord];
    otherwise,
        error('Unknown fixationType!');
end

 
%--- make trajectories
switch(gp.dot.coordAxis)
    case 'cartesian'
        ydim  = [1:gp.screenSize(2)];
        xstep = gp.screenSize(1)/(gp.dot.coordNLines*2+1);
        xdim  = round([0:gp.dot.coordNLines*2-1].*xstep+xstep/2);
        ydim  = ydim(:)*ones(1,length(xdim));
        xdim  = xdim(:)*ones(1,length(ydim));j jjjj;l
        xdim  = xdim';
        
        for n=1:size(xdim,2),
            gp.dot.coord(n).coords = [xdim(:,n)';ydim(:,n)']; % coords
        end;
        
    case 'polar'
        slopes = tan([0:gp.dot.coordNLines+1]/(gp.dot.coordNLines*2-2)*pi);
        for n=1:length(slopes),
            slope = slopes(n);
            if slope <1,
                xdim  = [1:gp.screenSize(1)];
                x     = xdim-gp.dot.coordCenter(1);
                ydim  = round(slope*x);
                ydim  = ydim + gp.dot.coordCenter(2);
            else,
                ydim  = [1:gp.screenSize(2)];
                y     = ydim-gp.dot.coordCenter(2);
                xdim  = round((1/slope)*y);
                xdim  = xdim + gp.dot.coordCenter(1);
            end;
            inScreen = find(xdim>0 & xdim<gp.screenSize(1) & ydim>0 & ydim<gp.screenSize(2));
            xdim     = xdim(inScreen);
            ydim     = ydim(inScreen);
            % store coordinates
            gp.dot.coord(n).coords = [xdim;ydim]; 
        end;
        
    otherwise
        error('Unknown coordinate system');
end
   
% make space for responses
gp.response.coordDetected = zeros(gp.screenSize(2),gp.screenSize(1));
gp.response.coordShown    = zeros(gp.screenSize(2),gp.screenSize(1));
gp.response.field         = zeros(gp.screenSize(2),gp.screenSize(1)).*NaN;



