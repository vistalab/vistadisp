function stim = cornsweet1D(params, stim)

% *************
% Square wave
% *************
y = stim.edge*params.amplitude;

% *************
% COC edge
% *************
Y = fft(y);
yFiltered = fliplr(ifft(Y .* stim.theFilter));

% flip COC to align with square wave (instead of l-r reversed)
yFiltered = fliplr(yFiltered);

% Scale
y = y/ params.realToCornAmpRatio;
% yFiltered = (yFiltered + 1)/2;

% Crop
inds        = params.screenWidth/4+1:params.screenWidth*3/4;
y           = y(inds);
yFiltered   = yFiltered(inds);


% *************
% Mixture
% *************
%yMixture = (y+ yFiltered)/2;

[mi indmin]         = min(yFiltered);
[ma indmax]         = max(yFiltered);

yMixture            = fliplr(yFiltered) - mi;

indsL               = 1:indmax;
indsR               = length(y):-1:indmin;

yMixture(indsL)     = yMixture(indsL)*(1 + 1/params.realToCornAmpRatio);
yMixture(indsR)     = max(yMixture) - yMixture(indsL);
yMixture            = yMixture + mi;

% ??
yMixture                    = fliplr(yMixture);


stim.y          = y;
stim.yFiltered  = yFiltered;
stim.yMixture   = yMixture;

end