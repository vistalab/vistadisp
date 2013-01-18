
% Make sure the vistadisp exptTools2 are in our path
addpath(genpath('~/svn/vistadisp/exptTools2'));


% Compute the rgb2lms transform
load stockman
sensors = stockman;
% Load the raw RGB spectra (should load vars spectraRawRed,
% spectraRawGreen, spectraRawBLue).
load('../python/spec.txt');
spec = reshape(spec,[3,101])';
spectra(:,1)           = interpPR650(spec(:,1));
spectra(:,2)           = interpPR650(spec(:,2));
[spectra(:,3), lambda] = interpPR650(spec(:,3));
figure; plot(lambda,spectra(:,1),'r',lambda,spectra(:,2),'g',lambda,spectra(:,3),'b')

rgb2lms = sensors'*spectra;
% Normalize rgb2lms to fit into a short int:
rgb2lms = round(rgb2lms./max(rgb2lms(:)).*32767);
%lms2rgb = inv(rgb2lms);
backRGB.dir = [1 1 1]';
backRGB.scale = 0.5;
  
stimLMS.dir = [0 0 1];
stimLMS.scale = 1;
[stimLMS, stimRGB] = findMaxConeScale(rgb2lms,stimLMS,backRGB);

stimLMS.scale = stimLMS.maxScale*sin(linspace(0,2*pi*3,100));
stimRGB = cone2RGB(rgb2lms, stimLMS, backRGB);
rgb = stimRGB.dir*stimRGB.scale;
figure;plot(rgb');

stimLMS.scale = stimLMS.maxScale;%*sin(linspace(0,2*pi*3,100));
stimRGB = cone2RGB(rgb2lms, stimLMS, backRGB);

% Everything is linear, so computing the sine in RGB space is equivalent to
% computing it in cone space and then converting to rgb. (And much faster!)
t = linspace(0,2*pi*3,100);
rgb = (stimRGB.dir*stimRGB.scale)*2*sin(t);

figure;plot(t,rgb(1,:),'r', t,rgb(2,:), 'g', t,rgb(3,:),'b');


[lmsContrast lmsBack]= RGB2ConeContrast(rgb2lms,stimRGB,backRGB);
