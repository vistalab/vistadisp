function images = addNoiseToMany(images, N, w);
% for a cell array of images, scale back the contrast to 50%, and 
% add (1 / f^N) noise.
% if N==0, it adds white noise;
% if N==1, it adds pink noise;
% if N==2, it adds Brownian noise.
% See http://www.csse.uwa.edu.au/~pk/Research/MatlabFns/Misc/noiseonf.m

% get a mask for the background
sz = min( size(images{1}) );
[X Y] = meshgrid( [1:sz] - sz/2);
R = sqrt(X.^2 + Y.^2);
mask = (R > sz/2 + 8);

for ii = 1:length(images)
   signalImage = double( faceScaleContrast(images{ii}, .5) );
   
   noiseImage = double( noiseonf( size(signalImage), N ) );
   rng = minmax(signalImage);
   noiseImage = normalize(noiseImage, rng(1), rng(2));
   
   noiseImage(mask) = signalImage(mask);
   
   images{ii} = (1-w) * signalImage  +  w * noiseImage;
   images{ii} = uint8( rescale2(images{ii}, [], [0 255]) );
end

return
