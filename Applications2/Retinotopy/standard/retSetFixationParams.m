function params = retSetFixationParams(params, expName)
% params = retSetFixationParams(params, expNme)
%
% Add parameters for the specified fixation type for a retinotopy
% experiment
%
%
% If called with no arguments, return a cell array listing all the
% fixation names that it is configured to do. This call is made from
% retMenu.m. It is a kind of hack, but it is useful to have the list of
% fixation names and the switch statement for fixation type in the same
% function, so that if we add a new fixation type, we need only modify this
% function: 
%
% If a new fixation type  is added, then the fixation name must be added
% both to the variable 'fixString' and to the switch / case statement below.
%
% April, 2010, JW: Split off from setRetinotopyParams.
%
% See also 
%       setRetinotopyParams.m  
%       retSetFixationParams.m
%       retSetExperimentParams.m
%       retSetDefaultParams.m
%
% note: this function doesn't have to be specific to retinotopy. could now
% be renamed and moved to, say, vistadisp/exptTools2/experimentControl
% except for last switch statement on bottom, which would need to be moved)

fixString  = {...
                'disk'...
                'dot'...
                'dot with grid'...
                'double disk'...
                'large cross'...
                'large cross x+'...
                'thin cross'...
                'left disk'...
                'right disk'...
                'upper left'...
                'lower left'...
                'upper right'...
                'lower right'...
                'left'...
                'right'...
                'upper'...
                'lower'...
                };

if ~exist('params', 'var'), params = fixString; return; end



% ***********************************************************
% Big switch! Set the parameters for the desired fixation type
% ***********************************************************

% common to many fixations (but can be overwritten)
dim.x = params.display.numPixels(1);
dim.y = params.display.numPixels(2);
sz    = params.display.fixSizePixels;
params.display.fixColorRgb    = [255 0 0 255; 0 255 0 255]; %R/G by default

switch(lower(params.display.fixType))
    case {'dot' 'smalldot'}
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        params.display.fixSizePixels = 3;
        
    case {'dot with grid' 'grid'}
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        params.display.fixSizePixels = 3;
        params.display.fixGrid = 1;
        
    case {'disk','double disk'}
%        params.display.fixColorRgb  = [255 255 255 255;...
%                                         255 255 255 255];
        params.display.fixX          = round(dim.x./2);
        params.display.fixY          = round(dim.y./2);
        params.display.fixSizePixels = 6;
        
    case {'large cross' , 'largecross'}        
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = 18;
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords = [dim.xcoord;dim.ycoord];

    case {'thin cross'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*1);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = params.display.numPixels(1);        
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];
        % prevent the cross from rotating by setting the 2 coor
        % configurations to be the same
        params.display.fixCoords{1} = [params.display.fixCoords{1} params.display.fixCoords{2}];
        params.display.fixCoords{2} = params.display.fixCoords{1};
        
    case {'double large cross' , 'doublelargecross'}
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels{1}= 12;
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
    case {'large cross x+' , 'largecrossx+'}
        params.display.fixColorRgb    = [0 0 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*12);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];

    case 'left disk'
 %       params.display.fixColorRgb    = [255 0 0 255;...
 %                                        128 0 0 255];
        params.display.fixX = round(dim.x./2) - floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);

    case 'right disk'
%        params.display.fixColorRgb    = [255 0 0 255;...
%                                         128 0 0 255];
        params.display.fixX = round(dim.x./2) + floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);

    case 'upper left'
        params.display.fixX = 1 + round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = 1 + round(max(.5*(dim.y - dim.x),sz));

    case 'lower left'
        params.display.fixX = 1 + round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = dim.y - round(max(.5*(dim.y - dim.x),sz));

    case 'upper right'
        params.display.fixX = dim.x - round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = 1 + round(max(.5*(dim.y - dim.x),sz));

    case 'lower right'
        params.display.fixX = dim.x - round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = dim.y - round(max(.5*(dim.y - dim.x),sz));

    case 'left'
        params.display.fixX = 1 + round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = round(dim.y./2);
        
    case 'right'
        params.display.fixX = dim.x - round(max(.5*(dim.x - dim.y),sz));
        params.display.fixY = round(dim.y./2);
        
    case 'upper'
        params.display.fixX = round(dim.x./2);
        params.display.fixY = 1 + round(max(.5*(dim.y - dim.x),sz));
        
    case 'lower'
        params.display.fixX = round(dim.x./2);
        params.display.fixY = dim.y - round(max(.5*(dim.y - dim.x),sz));

    otherwise,
        error('Unknown fixationType!');
end


% if red/green we make the fixation white so it can be seen in any
% condition
switch expName
    case {'full-field, red/green',...
          'full-field, red/green - red only',...
          'full-field, red/green - green only',...
          'full-field, red/green - red only with blanks',...
          'full-field, red/green - green only with blanks'}
      params.display.fixColorRgb    = [0 0 0 255;...
                                       0 0 0 255];
%     case {'8 bars','8 bars (slow)','8 bars with blanks','8 bars (sinewave)'}
%         params.display.fixColorRgb    = [  0   0   0 255;...
%                                          255 255 255 255];
%         params.display.fixSizePixels  = 3;
%     case {'8 bars (slow)'}
%         params.display.fixColorRgb    = [  0   0   0 255;...
%                                          255 255 255 255];
%         params.display.fixSizePixels  = 3;
    case {'8 bars (LMS)','8 bars (LMS) with blanks'}
        params.display.fixColorRgb    = [255 255 255 255;...
                                         255 255 255 255];
        params.display.fixSizePixels  = 3;

end;



