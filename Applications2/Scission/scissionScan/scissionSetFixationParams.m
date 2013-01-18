function [params] = scissionSetFixationParams(params)

params.display.fixType        = params.fixation;
params.display.fixSizePixels  = 6;
params.fix.task               = 'Detect fixation change';
params.fix.responseTime       = [.01 3]; % seconds

% 
% switch(lower(params.display.fixType))
%     case 'none'
%         %do nothing
%         
%     case {'dot', 'disk'}
%         params.display.fixSizePixels  = 1;
%         params.display.fixColorRgb    = [127 0 0 127;...
%             0 127 0 127];
%         dim.x = params.display.numPixels(1);
%         dim.y = params.display.numPixels(2);
% %         ecc = params.stimulus.fixationEcc * params.stimulus.fixationSide;
% %         ecc = angle2pix(params.display,ecc);
%         
%         params.display.fixY = round(dim.y./2);
%         params.display.fixX = round(dim.x./2);
%         params.fix.colorRgb  = params.display.fixColorRgb; 
% 
%     otherwise,
%         error('Unknown fixationType!');
% end
% 
% return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%																	%
% Fixation parameters												%
%																	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% params.display.fixType        = params.fixation; % disk or largeCross
% params.display.fixSizePixels  = 6;%3;%6;12

switch(lower(params.display.fixType))
    case 'none'
        %do nothing
        
    case {'dot' 'smalldot'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        params.display.fixSizePixels = 3;
    case {'dot with grid' 'grid'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        params.display.fixSizePixels = 3;
        params.display.fixGrid = 1;
    case {'disk','double disk'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
%        params.display.fixColorRgb    = [255 255 255 255;...
%                                         255 255 255 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
    case {'large cross' , 'largecross'},
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = 18;
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords = [dim.xcoord;dim.ycoord];

    case {'thin cross'},
        params.display.fixColorRgb    = [255 0 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*1);
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];
        % prevent the cross from rotating by setting the 2 coor
        % configurations to be the same
        params.display.fixCoords{1} = [params.display.fixCoords{1} params.display.fixCoords{2}];
        params.display.fixCoords{2} = params.display.fixCoords{1};

        
    case {'double large cross' , 'doublelargecross'},
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels{1}= 12;
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
    case {'large cross x+' , 'largecrossx+'},
        params.display.fixColorRgb    = [0 0 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*12);
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y [1:dim.y].*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [[1:dim.y].*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];

    case 'left disk',
        params.display.fixColorRgb    = [255 0 0 255;...
                                         128 0 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) - floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
    case 'right disk',
        params.display.fixColorRgb    = [255 0 0 255;...
                                         128 0 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) + floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
    otherwise,
        error('Unknown fixationType!');
end