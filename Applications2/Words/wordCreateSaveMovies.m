function [stim,data,numRefreshesPerFrame] = wordCreateSaveMovies(params,data)

fprintf('Assembling movies: \n')
% Memory for params values to set back
old.outFormDir = params.outFormDir;
old.inFormDir = params.inFormDir;
old.coherence = params.coherence;
old.inFormRGB = params.inFormRGB;
old.outFormRGB = params.outFormRGB;

numRefreshesPerFrame = round(params.frameDuration * params.display.frameRate);
numFrames = round((params.display.frameRate * params.duration)/numRefreshesPerFrame);

% Motion movies (word and nonword)
fprintf(' (1/4) motion\n')
for ii=1:length(data.wStrImg)
    data.wMovies{ii} = makeMoveDotForm(data.wStrImg{ii}, params, numFrames);
end

for ii=1:length(data.nwStrImg)
    data.nwMovies{ii} = makeMoveDotForm(data.nwStrImg{ii}, params, numFrames);
end

% Luminance movies (word and nonword)
fprintf(' (2/4) luminance\n')
params.outFormRGB = [0 0 0];

for ii=1:length(data.wStrImg)
    data.wLumMovies{ii} = makeLuminanceDotForm(data.wStrImg{ii}, params, numFrames);
end

for ii=1:length(data.nwStrImg)
    data.nwLumMovies{ii} = makeLuminanceDotForm(data.nwStrImg{ii}, params, numFrames);
end

params.outFormRGB = old.outFormRGB; % set it back for noise movies

% Noise motion movies -- may want to think about what "noise" stimulus
% should be
fprintf(' (3/4) noise motion\n')
params.coherence = 1;  %set coherence to 0 for noise stimuli?
params.inFormDir = -params.inFormDir;
params.outFormDir = params.inFormDir; %make a uniformly moving background
for ii=1:length(data.wStrImg)
    data.noiseMovies{ii} = makeMoveDotForm(data.wStrImg{ii}, params, numFrames); 
end

% Noise luminance movies -- again, should noise be random luminance values
% or should it be a uniform field?
fprintf(' (4/4) noise luminance\n')
params.coherence = 0;  %set coherence to 0 for noise stimuli
for ii=1:length(data.wStrImg)
    data.noiseLumMovies{ii} = makeLuminanceDotForm(data.wStrImg{ii}, params, numFrames); 
end


% reset old params values
params.coherence = old.coherence;
params.inFormDir = old.inFormDir;
params.outFormDir = old.outFormDir;
params.inFormRGB = old.inFormRGB;
params.outFormRGB = old.outFormRGB;

fprintf('Finished creating movies.\n')

% ii = 2;
% tmp = data.nwMovies{ii};
% mplay(tmp)

%% Combining individual movies into one

fprintf('Combining movies...  ')
lastFrame = 0;
% Motion movies
for ii=1:length(data.wMovies)
    mov = data.wMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end

for ii=1:length(data.nwMovies)
    mov = data.nwMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end

for ii=1:length(data.noiseMovies)
    mov = data.noiseMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end

% Luminance movies
for ii=1:length(data.wLumMovies)
    mov = data.wLumMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end

for ii=1:length(data.nwLumMovies)
    mov = data.nwLumMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end

for ii=1:length(data.noiseLumMovies)
    mov = data.noiseLumMovies{ii};
    % Put the movie into stim.images cells
    nFrames = size(mov,4);
    for jj=1:nFrames, stim.images{jj + lastFrame} = mov(:,:,:,jj); end
    lastFrame = length(stim.images);
end


% Tack on a movie of nFrames length that is a blank screen
blankFrame = zeros(size(stim.images{1}),'uint8');
blankFrame(:) = params.backRGB(1);
for ii=1:nFrames
    stim.images{ii + lastFrame}=blankFrame;
end

% 
% figure(1); for ii=1:length(stim.images); imagesc(stim.images{ii}); pause(0.05); end
clear mov

% See createStimulusStruct for required fields for stim
stim.imSize = size(stim.images{1});
stim.imSize = stim.imSize([2 1 3]);
stim.cmap = [];


% Not sure what this is about.
stim.srcRect = [];

% Center the output display rectangle
c = params.display.numPixels/2;
tl = round([c(1)-stim.imSize(1)/2 c(2)-stim.imSize(2)/2]);
stim.destRect = [tl tl+stim.imSize(1:2)];

fprintf('finished.\n\n')

return;