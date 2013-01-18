function gp = hp_params;
% gp_params - initiate Goldmann perimetry parameters

% 08/2005 sod wrote it

movefix = [0 0];%[-7 -7];
fixsize = 0.5;

% stuff to ask.
gp.subject         = input(sprintf('[%s]:Enter subjects initials : ',mfilename),'s');
if isempty(gp.subject),
    gp.subject = 'test';
end;
gp.screenHeightDeg = input(sprintf('[%s]:What is the screen diameter in degrees [default = 28deg]? : ',mfilename));
if isempty(gp.screenHeightDeg),
    gp.screenHeightDeg = 28;
end;

% standard Goldman is 64mm2 from 33cm distance:
% actual distance is 30cm...
gp.dot.sizeInDeg   = input(sprintf('[%s]:Enter dot radius in degrees [default = 0.86deg]: ',mfilename));
if isempty(gp.dot.sizeInDeg),
    gp.dot.sizeInDeg = 0.86;% old value was 0.78 using wrong distance
end;


% set response device
gp.devices = getDevices;
if isempty(gp.devices.keyInputExternal),
    gp.devices.keyInputExternal = gp.devices.keyInputInternal;
end;
disp(sprintf('[%s]:Getting subjects responses from device #%d',mfilename,gp.devices.keyInputExternal));
disp(sprintf('[%s]:Getting experimentor''s responses from device #%d',mfilename,gp.devices.keyInputInternal));

% screen init
gp.screen        = max(Screen('Screens'));
gp.screenRect    = Screen('Rect', gp.screen);
gp.screenSize    = gp.screenRect([3 4]);


gp.dot.size         = round((gp.screenSize(2)./gp.screenHeightDeg)).*gp.dot.sizeInDeg; % 1 deg
gp.dot.coordAxis    = 'cartesian'; % polar or cartesian coordinate system
gp.dot.coordCenter  = round(gp.screenSize./2); % center coordinates
gp.dot.coordNLines  = 4; % per quadrant
gp.dot.timePerPixel = 0.05; % sec 
gp.dot.timeToRespond = 2.5; % sec 
gp.dot.colorRgb     = [255 255 255 255];
gp.dot.ndots        = 12^2;%14^2;
disp(sprintf('[%s]:Dot grid spacing: %.1fdeg; Dot size: %.1fdeg',...
    mfilename,gp.screenHeightDeg./sqrt(gp.dot.ndots),gp.dot.sizeInDeg));
gp.dot.percentageBlank = .3; % no stim
gp.dot.measurementsPerDot = 4;

% display params
gp.display = loadDisplayParams('displayName','3T_projector_800x600');
gp.display.quitProgKey    = KbName('q');
gp.display.yesKey    = 'm';
gp.display.noKey     = 'x';
disp(sprintf('[%s]:When stimulus is detected press %s otherwise press %s',...
    mfilename,gp.display.yesKey,gp.display.noKey));
gp.display.screenNumber   = max(Screen('screens'));
% In Golman perimetry ratio of max vs mean is typically 0.5 log units
% (log10(255/80), assuming proper calibration...
gp.display.backColorRgb   = [80 80 80 255];

%--- make fixation cross
gp.display.fixType          = 'disk';%'large Cross x+'; %'largeCross'
switch lower(gp.display.fixType)
    case 'disk',
        gp.display.fixColorRgb    = [255 255 0 255; 255 255 0 255];
        gp.display.fixSizePixels  = ceil((gp.screenSize(2)./gp.screenHeightDeg).*fixsize); %0.25 deg radius
        % place fixation in center
        gp.display.fixY = round(gp.screenSize(2)./2); % assume ydim is smallest
        gp.display.fixX = round(gp.screenSize(1)./2);
        % do not place fixation in center so we can acquire data from
        % blind spot. This correction will be specific for each patient (we
        % assume the center of scotoma is the fovea. Also, these
        % coordinates are in screen pixel units but we want degrees of
        % visual angle, ie HACK
        % for HW we estimate his fovea at 5,5
        % move fixation
        gp.display.fixationOffsetInDegX = movefix(1); % minus is left
        gp.display.fixationOffsetInDegY = movefix(2);  % minus is down
        gp.display.fixationOffsetInPixelsX = gp.display.fixationOffsetInDegX./gp.screenHeightDeg.*gp.screenSize(2); 
        gp.display.fixationOffsetInPixelsY = gp.display.fixationOffsetInDegY./gp.screenHeightDeg.*gp.screenSize(2); 
        gp.display.fixX = round(gp.screenSize(1)./2 + gp.display.fixationOffsetInPixelsX);
        gp.display.fixY = round(gp.screenSize(2)./2 - gp.display.fixationOffsetInPixelsY); % assume ydim is smallest

        
        
    case 'largeCross'
        gp.display.fixColorRgb    = [255 255 0 255];
        gp.display.fixSizePixels  = ceil(gp.screenSize(2)./gp.screenHeightDeg./4); %0.25 deg
        dim.ycoord = [1:gp.screenSize(2) gp.screenSize(2):-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:gp.screenSize(2) 1:gp.screenSize(2)] + round(-gp.screenSize(2)/2+gp.screenSize(1)/2);
        gp.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
    case {'large cross x+' , 'largecrossx+'},
        gp.display.fixColorRgb    = [255 255 0 255;...
                                     255 255 0 255];
        gp.display.fixSizePixels  = ceil([1 sqrt(2)].*(gp.screenSize(2)./gp.screenHeightDeg./4)); %0.25 deg;
        dim.x = gp.screenSize(1);
        dim.y = gp.screenSize(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        gp.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = gp.screenSize(1);
        dim.y = gp.screenSize(2);
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        gp.display.fixCoords{2} = [dim.xcoord;dim.ycoord];

    otherwise,
        error('Unknown fixationType!');
end

 
nDot = sqrt(gp.dot.ndots);
%--- make trajectories
switch(gp.dot.coordAxis)
    case 'cartesian'
        lin = linspace(-0.9,0.9,nDot);
        [xdim,ydim]=meshgrid(lin);
        gp.grid.x = round(xdim.*gp.screenSize(2)./2+gp.dot.coordCenter(1));
        gp.grid.y = round(ydim.*gp.screenSize(2)./2+gp.dot.coordCenter(2));
        xdim=xdim(:);
        ydim=ydim(:);
        keep = find(sqrt(xdim.^2+ydim.^2)<=1);
        gp.grid.shown = keep;
        gp.grid.z = NaN(size(gp.grid.x));
        
        xdim = round(xdim(keep).*gp.screenSize(2)./2+gp.dot.coordCenter(1));
        ydim = round(ydim(keep).*gp.screenSize(2)./2+gp.dot.coordCenter(2));
       
        nBlanks = round(numel(xdim).*gp.dot.percentageBlank);
        gp.dot.coord(1).coords = [xdim'; ydim']; % coords
        xdim = [xdim; NaN(nBlanks,1)];
        ydim = [ydim; NaN(nBlanks,1)];
        gp.dot.coord(1).coords_wBlanks = [xdim'; ydim']; % coords with blanks (NaNs)
        
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
   


return;


