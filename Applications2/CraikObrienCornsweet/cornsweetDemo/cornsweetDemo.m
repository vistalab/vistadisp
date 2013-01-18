function params = cornsweetDemo(params)

if notDefined('params'), params = []; end

% define parameters via a simple GUI
[params, stim, ok] = cornsweetParamsGUI(params);  
if ~ok, params = get(gcf, 'UserData'); return; end

% make the filter
stim           = cornsweetFilter(params, stim);

% make 1D luminance profiles
stim           = cornsweet1D(params, stim);

% 1D => 2D
stim           = cornsweet1Dto2D(params, stim);

% straight edge => curved edge
stim           = cornsweetAddCurvature(params, stim);

% circular mask
stim           = cornsweetCicrularMask(params, stim);


% loop through images
for ii = 1:params.framesPerCycle * params.numRepetitions;

    starttime = cputime;
    
    % add fixation square
    % stim = cocAddFixation(params, stim);
       
    stim = cornsweetPlotImages(params, stim, ii);

    cornsweetPlotLuminanceProfiles(params, stim, ii);
    
    
    drawnow();
    
    timeelapsed = cputime - starttime;
    
    pause(1/params.framePerSecond - timeelapsed)
    
end

if params.loop, cornsweetDemo(params); end

end
