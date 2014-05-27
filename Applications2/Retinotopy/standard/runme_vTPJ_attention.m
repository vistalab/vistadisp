function fname_stim = runme_vTPJ_attention(run_num, subj)
% function to make structure for vTPJ detection experiment, run it, and
% plot it
%

% key presses for main task (vowel detection) and secondary task (gabor)
key_rsvp = 4;
key_gabor = 3;

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
tr = 2;

% isi (fixed or random?)
ISI = [2 3 4];

% experiment duration (seconds)
num_trs = 135;

% noise level
noise_amp = 0.2; % [0 1]

% Gabor parameters
gabor.amplitudes = [0 .04 .08 .12 .2 .4]; % contrast (max is 1)
gabor.cpfov      = 10;    % cycles per field of view
gabor.bandwidth  = 2;     % number of cycles per 4 std dev of the Gaussian envelope
gabor.ecc        = 0.8;   % eccentricity of g center relative to screen radius
num_positions    = 2;
gabor.angles     = (0:num_positions-1)/num_positions * 2*pi - pi/2;

% *******************************
% **** Derived parameters *******
% *******************************
T                = num_trs * tr; % experiment length (seconds)
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
envelope = hann(round(images_per_trial));
envelope_onset = find(envelope,1);

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
    
end



%% Store variables in struct and save
stimulus.images     = images;
stimulus.seq        = seq(:);
stimulus.seqtiming  = (0:length(stimulus.seq)-1)' * dt;
stimulus.cmap       = (0:255)'*[1 1 1];
stimulus.fixSeq     = randi(68,size(stimulus.seq));
stimulus.srcRect    = [0 0 sz sz];
stimulus.destRect   = [0 0 sz sz];
stimulus.trial_info = trial;

% change fixation sequence every n images
fix_dur = 2;
for ii = 2:fix_dur
    stimulus.fixSeq(ii:fix_dur:end) = stimulus.fixSeq(1:fix_dur:end);
end
% save
pth = '~/matlab/git/vistadisp/Applications2/Retinotopy/standard/storedImagesMatrices/';
fname_stim = sprintf('tpjAtt_params_wl_subj%02d_run_%02d.mat', subj, run_num);

save(fullfile(pth, fname_stim), 'stimulus');


%%


params = retCreateDefaultGUIParams;
params.experiment      = 'experiment from file';
params.calibration     = 'CBI_NYU_projector';
params.loadMatrix      = fname_stim;
params.tr              = tr;
params.period          = T;
params.triggerKey      = '`';
params.prescanDuration = 0;
params.fixation        = 'rsvp letters';

ret(params);

%% check accuracy and plot psychometric function



d = dir('~/Desktop/*.mat');
S = [d(:).datenum];
[~,S] = sort(S);
results = load(fullfile('~/Desktop', d(S(end)).name));
tmp = load(fullfile(pth, fname_stim));
trial_data = tmp.stimulus.trial_info; clear tmp;

% get the unique response keys
inds     = find(results.response.keyCode);
keycodes = unique(results.response.keyCode(inds));
chars    = KbName(keycodes);
numeric  = cellfun(@(x) sscanf(x, '%d'), chars, 'UniformOutput', false);
resp(1)  = keycodes(cellfind(numeric, key_rsvp));
resp(2)  = keycodes(cellfind(numeric, key_gabor));

responses(1,:) = results.response.keyCode == resp(1);
responses(2,:) = results.response.keyCode == resp(2);

%
f(1) = figure(787);
set(gca, 'Color', 'k'); hold on

gabor_onsets = (trial_data.tr-1) * images_per_trial+1;
set(gca, 'XTick', gabor_onsets, 'XGrid', 'on')

contrasts = unique(trial_data.amplitudes);
colors    = jet(length(contrasts));

gabor_detections = find(responses(2,:));
accuracy = NaN(length(contrasts), 100);

for ii = 1:length(contrasts)
    indices = find(trial_data.amplitudes == contrasts(ii));
    for jj = 1:length(indices)
        x = (trial_data.tr(indices(jj))-1) * images_per_trial+envelope_onset;
        plot([x x], [0 1], '-', 'Color', colors(ii,:), 'LineWidth', ii);
        
        accuracy(ii,jj) = any(gabor_detections - x > 0 & gabor_detections - x < 1.5/dt);
    end
    
end



plot(responses(2,:), 'g--');

psychometric_function = nanmean(accuracy,2);
psychometric_sem      = sqrt(psychometric_function .* (1-psychometric_function) ./ sum(isfinite(accuracy),2));


%%

f(2) = figure(234); clf; set(gcf, 'Color', 'w')
set(gca, 'FontSize', 20)
errorbar(contrasts, psychometric_function, psychometric_sem, 'r-o', 'LineWidth', 2, 'MarkerSize', 12)
axis tight
xlabel('Contrast')
ylabel('Accuracy')

im_pth = fullfile('~', 'Desktop', 'tpj_images', sprintf('wl_subj%03d', subj));

if ~exist(im_pth, 'dir'), mkdir(im_pth); end
hgexport(f(1), fullfile(im_pth, sprintf('responses_%02d.eps', run_num)));
hgexport(f(2), fullfile(im_pth, sprintf('psychometric_%02d.eps', run_num)));

end