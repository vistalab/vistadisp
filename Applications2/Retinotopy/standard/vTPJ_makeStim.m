% Script to make structure for vTPJ detection experiment

% Create a structure for 'Experiment from file'. Populating this structure
%   is the main purpose of the script
stimulus = struct('images', [], 'cmap', [], 'seq', [], ...
    'seqtiming', [], 'fixSeq', [], 'scrRect', [], 'destRect', []);

% *******************************
% **** Settable parameters ******
% *******************************

% screen diameter (pixels)
sz = 768;

% refresh rate (seconds)
dt = 1/60 * 6; 

% scanner tr, also duration of trial
tr = 1.5;

% isi (fixed or random?)
ISI = [3 4 5];

% experiment duration (seconds)
num_trs = 180;

% noise level
noise_amp = 0.2; % [0 1]

% Gabor parameters
gabor.amplitudes = [0 .025 .05 .1 .2 .4]; % contrast (max is 1)

gabor.cpfov      = 10;    % cycles per field of view
gabor.bandwidth  = 2;     % number of cycles per 4 std dev of the Gaussian envelope
gabor.ecc        = 0.8;   % eccentricity of g center relative to screen radius
gabor.angles     = (1:8)/8 * 2*pi;

% *******************************
% **** Derived parameters *******
% *******************************
T                = num_trs * tr; % experiment length (seconds)
num_images       =  T / dt;      % for whole experiment
images_per_trial = tr / dt;      % for one trial

%   grid for Gabors
[xx, yy]    = meshgrid((-sz/2+.5:sz/2-.5)/(sz/2), (-sz/2+.5:sz/2-.5)/(sz/2));  % x,y grid

% Gabor row and column centers
[r, c] = pol2cart(gabor.angles, gabor.ecc * sz);
gabor.rows = r + sz/2;
gabor.cols = c + sz/2;
% figure; plot(gabor.cols([1:end 1]),gabor.rows([1:end 1]), 'o-', [sz/2 sz/2], [0 sz], 'k-', [0 sz],[sz/2 sz/2],  'k-'); axis([0 sz 0 sz])

% *******************************
% **** Make images *******
% *******************************

% to conserve space, limit the number of noise images. 
num_noise_images = 100;

% Background images 
noise_images = uint8(randn(sz, sz, num_noise_images)*128*noise_amp+128);

% For bookkeeping, make iniital stimulus sequence a matrix of images x
% trials
seq = zeros(images_per_trial, num_trs);

% Random noise patterns for each image. Afterward we will replace trial
% images with combination of noise and target
for ii = 1:num_trs, seq(:,ii) = randperm(num_noise_images, images_per_trial);  end

% designate time points for trials, leaving 12 s of blank at start and end
this_tr = ceil(13/tr); ii = 1;
ISIs = ISI(randintrange(1,length(ISI),[1 1000]));
trial = [];
while this_tr < num_trs - ceil(12/tr)
    trial.tr(ii) = this_tr;
    ii = ii+1;
    this_tr = this_tr + ISIs(ii);
end
num_trials = ii-1;

% for each trial, assign parameters
rand_assign = @(x, n) x(randintrange(1,length(x), [1 n]));

%   rows and cols of gabor center
position_ind = rand_assign(1:length(gabor.rows), num_trials);
trial.row = gabor.rows(position_ind);
trial.col = gabor.cols(position_ind);

%   phase and angle of gabor sinusoid
trial.ang = rand(1, num_trials) * 2 * pi;
trial.ph  = rand(1, num_trials) * 2 * pi;
trial.amplitudes = rand_assign(gabor.amplitudes, num_trials);


% Make the images for each trial
%   temporal envelope - this is the same for every trial
%   envelope = hann(images_per_trial);
envelope = hann(round(images_per_trial/2));
envelope = padarray(envelope, round(images_per_trial/4), 'pre');
envelope = padarray(envelope, images_per_trial-length(envelope), 'post');
images = noise_images;
for ii = 1:num_trials
    % make the gabor for this trial
    G = makegabor2d(sz,trial.row(ii),trial.col(ii),gabor.cpfov,trial.ang(ii),trial.ph(ii),gabor.bandwidth,xx,yy) ;
    
    % precompute images
    these_images = double(noise_images(:,:, randperm(num_noise_images, images_per_trial)));
    for jj = 1:images_per_trial
        
        these_images(:,:,jj) = these_images(:,:,jj) + envelope(jj) * G * trial.amplitudes(ii) * 128;
        
    end
    
    these_images = uint8(these_images);
    seq(:,trial.tr(ii)) = (1:images_per_trial) + size(images,3);
    images = cat(3, images, these_images);
        
%     figure(1); for jj = 1:images_per_trial; imshow(images(:,:,jj)); title(sprintf('Trial %d\tImage %d', ii, jj)); pause(.01); end
%     waitforbuttonpress
end



%% Store variables in struct and save
stimulus.images     = images;
stimulus.seq        = seq(:);
stimulus.seqtiming  = (0:length(stimulus.seq)-1)' * dt;
stimulus.cmap       = (0:255)'*[1 1 1];
stimulus.fixSeq     = randi(10,size(stimulus.seq));
stimulus.srcRect    = [0 0 sz sz];
stimulus.destRect   = [0 0 sz sz];
stimulus.trial_info = trial;

% change fixation sequence every n images
fix_dur = 3;
for ii = 2:fix_dur
    stimulus.fixSeq(ii:fix_dur:end) = stimulus.fixSeq(1:fix_dur:end);
end
% save
pth = '~/matlab/git/vistadisp/Applications2/Retinotopy/standard/storedImagesMatrices/';
save(fullfile(pth, 'tpj_attention_params01'), 'stimulus');


%%


params = retCreateDefaultGUIParams;
params.experiment      = 'experiment from file';
params.calibration     = 'CBI_NYU_projector';
params.loadMatrix      = 'tpj_attention_params01.mat';
params.tr              = tr;
params.period          = T;
params.triggerKey      = '`';
params.prescanDuration = 0;
params.fixation        = 'rsvp letters';

%PsychDebugWindowConfiguration
p = ret(params);

%% check accuracy
d = dir('~/Desktop/*.mat');
S = [d(:).datenum]; 
[~,S] = sort(S);
results = load(fullfile('~/Desktop', d(S(end)).name));
tmp = load(fullfile(pth, 'tpj_attention_params01'));
trial_data = tmp.stimulus.trial_info; clear tmp;
% get the unique response keys
inds     = find(results.response.keyCode);
keycodes = unique(results.response.keyCode(inds));
chars    = KbName(keycodes);
numeric  = cellfun(@(x) sscanf(x, '%d'), chars, 'UniformOutput', false);
resp(1)   = keycodes(cellfind(numeric, 1));
resp(2)   = keycodes(cellfind(numeric, 8));



responses(1,:) = results.response.keyCode == resp(1);
responses(2,:) = results.response.keyCode == resp(2);

%%
figure(1); clf
set(gca, 'Color', 'k'); hold on
%plot(responses(1,:), 'r-'); hold on
plot(responses(2,:), 'g--');hold on

gabor_onsets = (trial_data.tr-1) * images_per_trial+1;
set(gca, 'XTick', gabor_onsets, 'XGrid', 'on')

contrasts = unique(trial_data.amplitudes);
colors = jet(length(contrasts));
for ii = 1:length(contrasts)
   indices = find(trial_data.amplitudes == contrasts(ii));
   for jj = 1:length(indices)
       x = (trial_data.tr(indices(jj))-1) * images_per_trial+1;
       plot([x x], [0 1], '-', 'Color', colors(ii,:), 'LineWidth', ii);
   end
    
end
