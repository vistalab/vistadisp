function h = noiseTest(imgs, noiseType, noiseLevel);
% Simple GUI allowing you to play with adding different types of noise to
% images.
% 
%   h = noiseTest([imgs=test faces], [noiseType=1], [noiseLevel=0.5]);
%
% The GUI will show an iamge with noise on top, and have sliders for
% setting the level of noise and selecting the image, and a popup for
% setting the noise type.
% 
% INPUTS:
%   imgs: 3D array of images, or cell array of images. [default: load a set
%   of 10 face images of size 300 x 300]
%
%   noiseType: initial type of noise to choose. Options are:
%       -1: partial Fourier phase scrambling
%       0: white (uniform) noise
%       1: pink (1/f) noise
%       2: Brownian (1/f^2) noise
%       3: "Clouds" (1/f^3) noise
%
%   noiseLevel: initial noise level (from 0-1). [default: 0.5]
%
%
% ras, 07/09/09.
if notDefined('imgs')
    imgs = loadFaces( zeros(1, 10), 'b', 300 );
end

if notDefined('noiseType'), noiseType = 1;      end
if notDefined('noiseLevel'), noiseLevel = 0.5;  end

%% make sure imgs is a cell of images
if isequal(imgs, 'update')
    % callback from uicontrols
    noiseTestUpdate;
    return
elseif isnumeric(imgs)
    tmp = {};
    for ii = 1:size(imgs, 3)
        tmp{ii} = imgs(:,:,ii);
    end
    imgs = tmp;
end

%% open the figure
h = figure('Color', [.9 .9 .9], 'Name', 'Noise Test', 'UserData', imgs);
colormap gray

%% add the axes for the image
axes('Units', 'norm', 'Position', [.1 .3 .8 .6], 'Tag', 'NoiseImageAxes');

%% add slice slider
sliceSlider = mrvSlider([.1 .1 .25 .08], 'Image #', 'Value', 1, ...
                        'Range', [1 length(imgs)], 'IntFlag', 1, ...
                        'Callback', 'noiseTest(''update''); ');
set(sliceSlider.sliderHandle, 'Tag', 'ImageSlider');                    

%% add noise level slider
sliceSlider = mrvSlider([.7 .1 .25 .08], 'Noise level', 'Value', noiseLevel, ...
                        'Range', [0 1], 'IntFlag', 0, ...
                        'Callback', 'noiseTest(''update''); ');
set(sliceSlider.sliderHandle, 'Tag', 'NoiseLevel');       

%% add noise order slider
orderSlider = mrvSlider([.4 .1 .2 .08], 'Noise Order (N)', 'Value', noiseLevel, ...
                        'Range', [0 3], 'IntFlag', 0, 'FlexFlag', 1, ...
                        'Callback', 'noiseTest(''update''); ');
set(orderSlider.sliderHandle, 'Tag', 'NoiseOrder');                    
set(orderSlider.labelHandle, 'Tag', 'NoiseOrder');                    
set(orderSlider.editHandle, 'Tag', 'NoiseOrder');                    

%% add popup to select the noise type
% noiseList = {'Phase-scramble' 'White' 'Pink (1/f) Noise ' ...
%              'Brownian (1/f^2) Noise' ...
%              '1/f^3 noise'};
noiseList = {'Partial Phase-Scramble' '1/f^N Noise'};
uicontrol('Units', 'norm', 'Position', [.5 .2 .2 .06], ...
          'Style', 'popup', 'String', noiseList, ...
          'Tag', 'NoiseType', 'Callback', 'noiseTest(''update'');');
      
noiseTestUpdate;

return
% /--------------------------------------------------------/ %




% /--------------------------------------------------------/ %
function noiseTestUpdate;
% update function for the controls
imgs = get(gcf, 'UserData');

% find the current image I
I = get( findobj('Tag', 'ImageSlider'), 'Value' );

% get the noise type and noise level
noiseType = get( findobj('Tag', 'NoiseType'), 'Value' );
noiseLevel = get( findobj('Tag', 'NoiseLevel'), 'Value' );

% add noise to the image
if noiseType==1
    % partial phase scramble
    imgs{I} = phaseScramble(imgs{I}, noiseLevel);
	
	set( findobj('Tag', 'NoiseOrder'), 'Visible', 'off')
else
	orderSlider = findobj('Style', 'slider', 'Tag', 'NoiseOrder');
	noiseOrder = get(orderSlider, 'Value');
    imgs(I) = addNoiseToMany(imgs(I), noiseOrder, noiseLevel);
	
	set( findobj('Tag', 'NoiseOrder'), 'Visible', 'on')	
end

% display the image
axes( findobj('Tag', 'NoiseImageAxes') );  cla;
imagesc(imgs{I});
axis image; axis equal;  axis off;
set(gca, 'Tag', 'NoiseImageAxes');

return




