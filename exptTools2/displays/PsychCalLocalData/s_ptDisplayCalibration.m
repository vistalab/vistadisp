% s_ptDisplayCalibration
%
% Script for Psychtoolbox (pt) display calibration.
%
% Once you collect data using the Psychtoolbox mechanism, it is convenient
% to be able to convert the data into ISET format.  In this format we make
% various analyses of the display, and we can use the display as part of
% the ISET processing package.  For example, we can calculate the estimated
% cone absorptions for the RGB image on the calibrated monitor.
%
% To use this code, you must have ISET-4.0 on your path.
%
% Copyright Stanford Vista Team 2011

%% Create the ISET display file
%
% directory = 'C:\Users\Wandell\Documents\MATLAB\svn\vistadisp\trunk\exptTools2\displays\PsychCalLocalData';
% fname = fullfile(directory,'cni_lcd.mat');
% newDisplay = load(fname);

fname = fullfile(isetRootPath,'data','displays','CNI_LCD_2011_03_13.mat');
% oldDisplay = load(fname)

d = displayPT2ISET(fname);


% We save it in the ISET display directory.  This is not placed in the SVN
% repository until somebody checks it in.
% cniDisplay = sprintf('CNI-LCD-%s.mat',date);
% oname = fullfile(isetRootPath,'data','displays',cniDisplay);
% save(oname,'d');

%% Check the white point properties

% Here is the white point spectral power distribution in units of energy
whtSPD = displayGet(d,'white spd');
vcNewGraphWin; plot(wave,whtSPD);
ylabel('Watts/sr/nm/m2'); xlabel('Wavelength (nm)');

% Here are the spearate primary distributions
vcNewGraphWin; plot(wave,displayGet(d,'spd'));
ylabel('Watts/sr/nm/m2'); xlabel('Wavelength (nm)');

% Here are the XYZ values of the white point
whiteXYZ = ieXYZFromEnergy(whtSPD',wave);
whiteXYZ



%   whtSPD = displayGet(d,'white spd');
%   chromaticity(ieXYZFromEnergy(whtSPD',wave))
%   photons = Energy2Quanta(wave,whtSPD);

%   vcNewGraphWin; plot(wave,photons);
%   ylabel('Quanta/sec/nm/m2/sr'); xlabel('Wavelength (nm)');


% Plot the energy
wave = displayGet(d,'wave');
vcNewGraphWin; plot(wave,displayGet(d,'spd'));




chromaticity(ieXYZFromEnergy(whtSPD',wave))
photons = Energy2Quanta(wave,whtSPD);
vcNewGraphWin; plot(wave,photons);
ylabel('Quanta/sec/nm/m2/sr'); xlabel('Wavelength (nm)');
