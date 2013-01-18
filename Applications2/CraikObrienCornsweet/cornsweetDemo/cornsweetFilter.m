function stim = cornsweetFilter(params, stim)
% from some COC paper (look this up!)

% screen parameters
screenWidth         = params.screenWidth;
imageWidthInDegrees = params.imageWidthInDegrees;

% freqeuncy cutoffs for the c-o-c filter
sigmaH              = 20; %4.3; % high frequency cutoff?
sigmaL              = 0.17;% low frequency cutoff?

% make the spatial frequencies  
freq                = (0:(screenWidth-1)) / imageWidthInDegrees;
indsR               = screenWidth:-1:screenWidth/2+1;
indsL               = 2:screenWidth/2+1;
freq(indsR)         = -freq(indsL);

% the filter
stim.theFilter      = exp(-freq.^2/(2*sigmaH^2))-exp(-freq.^2/(2*sigmaL^2));

end