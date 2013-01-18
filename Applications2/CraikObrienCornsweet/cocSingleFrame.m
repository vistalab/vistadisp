function [im x y] = cocSingleFrame(stimulus, display) 
% function [im] = cocSingleFrame(stimulus, display)

stimsize    = stimulus.radius;
m           = round(angle2pix(display,stimsize)*2); %(width in pixels)
n           = round(angle2pix(display,stimsize)*2*2); %(height in pixels)
[x,y]       = meshgrid(linspace(-stimsize*2,stimsize*2,n),linspace(stimsize,-stimsize,m));
curvature   = stimulus.curvatureAmp;

%edgeShift   = curvature - ones(n,1) * abs(sin((1:n) *pi/n))*curvature + stimulus.fixationEcc;
edgeShift   = curvature -  abs(sin((1:m)' * ones(1, n) *pi/m))*curvature + stimulus.fixationEcc;
edgeShift   = edgeShift * stimulus.fixationSide;
edgeAmp     = stimulus.edgeAmplitdue;

im = ((x + edgeShift) < 0) * 2 - 1;
im = im*edgeAmp;

%construct a band-passed filter
sigmaH = 50;%4.3
sigmaL = 0.5;%.17
freq = (0:(n-1)) /(stimsize*2);
freq(n:-1:n/2+1) = -freq(2:n/2+1);
theFilter = exp(-freq.^2/(2*sigmaH^2))-exp(-freq.^2/(2*sigmaL^2));
theFilter = ones(m,1) * theFilter;

        
% Adjust the image according to the experiment type
switch lower(stimulus.type)
    case {'coc'}        
        %filter the edge
        Y = fft(im')';
        im = (ifft((Y .* theFilter)'))';

    case('edgeonly')
        %um, how to make this one?
        %filter the edge
        Y = fft(im')';
        im = (ifft((Y .* theFilter)'))';
        im = abs(im);
    
    case{'square'}
        %already done!

    case('uniform')
        im = ones(size(im)) * edgeAmp;

    
    case('localizer')
        %how ?
        


end

im = im(:, n/4+1: n*3/4);
x  = x(:, n/4+1: n*3/4);
y  = y(:, n/4+1: n*3/4);
return
