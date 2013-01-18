wordInput = 'A_blue_jay_was_perched_on_a_limb_looking_for_water';

%% get display params
params.display = loadDisplayParams('displayName', 'NEC485words.mat');
screens=Screen('Screens'); % find the number of screens
params.display.screenNumber = max(screens); % put this on the highest number screen

%% load letters
lettersFname = fullfile('/Users','Shared','ScanData','MotionWords','EventRelated','stim','general','letters-4ptfont.mat');
params.font.fontSize = 4;
if exist(lettersFname,'file')
   load(lettersFname);
else  % render the letters first
    fprintf('\nCreating letters with default parameters and saving in:  \n%s\n',lettersFname)
    letters = wordGenLetterVar(lettersFname,params.font);  % use font params from initWordParams to create rendered letters if they don't already exist
end
params.letters = letters;

%% make an image
[img outputparams] = wordGenerateImage(params.display,params.letters,wordInput);

%% invert black and white (if you want) -- why isn't the background turning gray???
newImg = img;
inds=(img==1);  % find white regions (in-form)
newImg(newImg==0)=0.5;  % turn the black regions (out-form) gray
newImg(inds)=0;  % turn in-form black

% hack to turn background gray

newImg(1,1)=1; % make max color 256 so that background is gray


%% Make a frame of luminance dot word
[params.font,params.movie] = initWordParams('mr');
params.movie.display = params.display;
params.movie.frameRate = 60;
params.movie.noiseRGB = [128 128 128];
%trialInfo.conditionName = 'MW_mot-0.lum-100_Words';
trialInfo.conditionName = 'MW_mot-0.lum-100.in-0.out-128_Words';
[movieFrames,nFrames] = makeMovingWordTrial2(img,params.movie,[],trialInfo,[]);
exFrame = movieFrames{1};
exFrame = exFrame./255;
figure; imagesc(exFrame); colormap gray; truesize; axis off; title('Luminance-defined')


%% Make a frame of motion dot words
trialInfo.conditionName = 'MW_mot-100.lum-100.in-0.out-128.noise-128_Words';
[movieFrames,nFrames] = makeMovingWordTrial2(img,params.movie,[],trialInfo,[]);
exFrame = movieFrames{1};
exFrame = exFrame./255;
%exFrame(exFrame==255)=1;  % why can't i show an image from 0 to 255????
%exFrame(exFrame==128)=0.5;
figure; imagesc(exFrame); colormap gray; truesize; axis off; title('Motion-defined')


%% Make a movie out of it and show the movie
for frameNum = 1:nFrames
    img = (movieFrames{frameNum}./255);
    M(frameNum) = im2frame(img);
end
% for frameNum = 1:nFrames
%     img = (movieFrames{frameNum}./255);
%     M(frameNum+nFrames) = im2frame(img);
% end
% for frameNum = 1:nFrames
%     img = (movieFrames{frameNum}./255);
%     M(frameNum+2*nFrames) = im2frame(img);
% end

movie(M,15,30)   % show it twice at 60 frames per second

fprintf('Saving movie example to: %s\n',[pwd '/wordExampleMovie.avi'])
movie2avi(M,'wordExampleMovie.avi','FPS',30)