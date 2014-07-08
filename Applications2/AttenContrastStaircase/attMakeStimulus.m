function im  = attMakeStimulus(stimParams, display)
% Construct image sequence for one trial of MEG attention experiment
% im = attMakeStimulus(stimulus, display)

%% Attention stimulus

% Load in images from the precomputed image matrices

% To do: Create images by script rather than loading stored images
stored_images = load('vistadisp/Applications2/Retinotopy/standard/storedImagesMatrices/onOffLeftRight_params1.mat');
imageA    = double(stored_images.stimulus.images(:,:,1));
imageB    = double(stored_images.stimulus.images(:,:,2));

% Derive the stimulus size and background value from the images themselves
stimsize  = length(stored_images.stimulus.images(:,:,1));
% bkg       = mode(double(imageA(:)));
% bkg = round(mode(double(imageA(:)))/2);
col_values = unique(imageA(:));
bkg = median(col_values);

% Check that background value in stored image is the same as the background
% value in the display struct
assert(bkg == display.backColorIndex);

% Check that stimulus size matches screen size
assert(stimsize == min(display.numPixels));

% Change value of images to be centered at 0 so that we can modulate
% contrast by multiplying by a mask ranging from [0 1]
imageA    = imageA - bkg;
imageB    = imageB - bkg;

% Make meshgrid for gaussian contrast decrement
[x,y]         = meshgrid((-stimsize/2:stimsize/2-1)/stimsize/2, (-stimsize/2:stimsize/2-1)/stimsize/2);


%% Gaussian contrast decremention mask

% The test probe will be windowed within a one-second period
n_time_points = stimParams.nTimePoints;

% attend to which side?
probe_side = stimParams.probe_side;
if probe_side == 0, probe_side = 1; end 
distractor_side = 3 - probe_side;

% target is upper or lower?
upper_or_lower_target = stimParams.upper_or_lower;

% distractor is upper or lower?
upper_or_lower_distractor = stimParams.upper_or_lower_distractor; % 1 is upper, 2 is lower

row_target = stimParams.RowCoords(upper_or_lower_target) * stimsize;
col_target = stimParams.ColCoords(probe_side) * stimsize;

row_distractor = stimParams.RowCoords(upper_or_lower_distractor) * stimsize;
col_distractor = stimParams.ColCoords(distractor_side) * stimsize;

stdrow = stimParams.gaussianSigma;
stdcol = stimParams.gaussianSigma;

G = makegaussian2d(stimsize,row_target,col_target,stdrow,stdcol, x, y);
% G = G + makegaussian2d(stimsize,row_distractor,col_distractor,stdrow,stdcol, x, y);
contrast_decrement = stimParams.contrast_decrement;

% Make envelope for contrast decrement
envelope = hann(n_time_points);


% Add images to mask_frames

% TODO: pre-allocate mask_frames

% Define mask_frame matrix
mask_frames = zeros(stimsize,stimsize,length(envelope)+2);

% Pre-decrement
mask_frames(:,:,1) = imageA;
mask_frames(:,:,2) = imageB;

% Add contrast decrement to images for target
n = 1;

for ii = 3:n_time_points+2;
    if ii == 3;
        F = G * contrast_decrement * envelope(n);
        F = 1 - F;
        if mod(stimParams.start_frame,2) == 1 % If start frame is even, we need ImageA
            mask_frames(:,:,ii) = double(imageA) .* F ;
            n = n+1;
        else % If not, than we need ImageB
            mask_frames(:,:,ii) = double(imageB) .* F ;
            n = n+1;
        end
        
    elseif mod(ii,2) == 0;
        F = G * contrast_decrement * envelope(n);
        F = 1 - F;
        mask_frames(:,:,ii) = double(imageA) .* F ;
        n = n+1;
    elseif mod(ii,2) == 1;
        F = G * contrast_decrement * envelope(n);
        F = 1 - F;
        mask_frames(:,:,ii) = double(imageB)  .* F ;
        n = n+1;
    end
    
end


%% Show images
% figure(1); colormap gray
% subplot(1,2,1); imagesc(G); axis image off;
% subplot(1,2,2);
% mask_frames = uint8(mask_frames + 128);
% a = size(mask_frames); for ii = 1:a(3); imagesc(mask_frames(:,:,ii), [0 255]); axis image off; pause(0.1); end


% Adjust the image according to the experiment type, when more 'cases'
im = uint8(mask_frames + bkg);

return
