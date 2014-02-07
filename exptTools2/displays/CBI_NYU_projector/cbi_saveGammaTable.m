
load('~/matlab/git/vistadisp/exptTools2/displays/CBI_NYU_projector/cbi_calibration_file_100209.mat');
gamma = calib.table*[1 1 1];
gammaTable = gamma*255;
save('~/matlab/git/vistadisp/exptTools2/displays/CBI_NYU_projector/gamma.mat', 'gamma', 'gammaTable')