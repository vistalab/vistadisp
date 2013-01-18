function [params] = cocSetFixationParams(params)

params.display.fixType        = params.fixation;
params.display.fixSizePixels  = 6;
params.fix.task               = 'Detect fixation change';
params.fix.responseTime       = [.01 3]; % seconds

switch(lower(params.display.fixType))
    case 'none'
        %do nothing
        
    case {'dot', 'disk'}
        params.display.fixSizePixels  = 1;
       
        % for isoluminant fixation
        backColorRgb = params.display.backColorRgb;
        if length(backColorRgb) == 1, 
            backColorRgb = [backColorRgb backColorRgb backColorRgb 255];
        end
        params.display.fixColorRgb    = ...
                                [ 253 137 124 255;...
                                  1  117 130 255;...
                                  backColorRgb];
        
        %params.display.fixColorRgb    = [127 0 0 127; 0 127 0 127];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
%         ecc = params.stimulus.fixationEcc * params.stimulus.fixationSide;
%         ecc = angle2pix(params.display,ecc);
        
        params.display.fixY = round(dim.y./2);
        params.display.fixX = round(dim.x./2);
        params.fix.colorRgb = params.display.fixColorRgb; 

    otherwise,
        error('Unknown fixationType!');
end

return