% Generate example word images
% Input your example word below.  This will create a contrast-edge defined
% word, a luminance-dot-defined word (1 frame), and a frame of the
% motion-defined word (with 0% luminance coherence).  It will also save out
% an example movie in pwd.
%

wordInput = 'lion';
scrambleLevel = 1; %between 0 and 1

%% get display params
params.display = loadDisplayParams('displayName', 'NEC485words.mat');

%% load letters
lettersFname = fullfile('/Users','Shared','ScanData','MotionWords','EventRelated','stim','general','letters.mat');
if exist(lettersFname,'file')
    load(lettersFname);
else  % render the letters first
    fprintf('\nCreating letters with default parameters and saving in:  \n%s\n',lettersFname)
    letters = wordGenLetterVar(lettersFname,params.font);  % use font params from initWordParams to create rendered letters if they don't already exist
end
params.letters = letters;

%% make an image
[img outputparams] = wordGenerateImage(params.display,params.letters,wordInput);

% %% Make contrast edge stimulus with other colors using makeMovingWordTrial2
% [params.font,params.movie] = initWordParams('mr');
% params.movie.display = params.display;
% params.movie.frameRate = 60;
% params.movie.inFormRGB = [0 0 0];  % Dark shade of blue
% % trialInfo.conditionName = 'MW_mot-0.lum-100.static_Words';  %Dots with colors
% trialInfo.conditionName = 'CE_out-128_Words';
% [movieFrames,nFrames] = makeMovingWordTrial2(img,params.movie,[],trialInfo,[]);
% exFrame = movieFrames{1};
% exFrame = exFrame./255;
% figure; imagesc(exFrame); %colormap gray; 
% truesize; axis off; title('Contrast Edge With Color')
% 
% % Scrambled Version
% scrColored = scrambleImage(exFrame,1);
% figure; imagesc(scrColored); %colormap gray; 
% truesize; axis off; title('Scrambled Contrast Edge With Color')


%% invert black and white (if you want) -- why isn't the background turning gray???
newImg = img;
inds=(img==1);  % find white regions (in-form)
newImg(newImg==0)=0.5;  % turn the black regions (out-form) gray
newImg(inds)=0;  % turn in-form black

% hack to turn background gray

newImg(1,1)=1; % make max color 256 so that background is gray

% produce figure
figure; imagesc(newImg); colormap gray; truesize; axis off; title('Contrast-Edge')

%% Make some phase-scrambled images
imgToScramble = newImg.*255;
for scrambleLevel = [0.2 0.5 0.7 1]
    phImage = scrambleImage(imgToScramble,scrambleLevel);
    figure; imagesc(phImage); colormap gray; truesize; axis off; %title('Phase-Scrambled')
end

% add some dark blue color
%phImage(phImage == 0) = 


%% Make a frame of luminance dot word
[params.font,params.movie] = initWordParams('mr');
params.movie.display = params.display;
params.movie.frameRate = 60;
%for lumCoherence = [0 15 30 45 65 75 90 100]  % put different luminanance coherence values here
for lumCoherence = 100
    trialInfo.conditionName = sprintf('MW_mot-0.lum-%d_Words',lumCoherence);
    [movieFrames,nFrames] = makeMovingWordTrial2(img,params.movie,[],trialInfo,[]);
    exFrame = movieFrames{1};
    exFrame(exFrame==255)=1;  % why can't i show an image from 0 to 255????
    exFrame(exFrame==128)=0.5;
    figure; imagesc(exFrame); colormap gray; truesize; axis off; %title('Luminance-defined')
end


%% Make a frame of motion dot words (random luminance)
% trialInfo.conditionName = 'MW_mot-100.lum-0_Words';
% [movieFrames,nFrames] = makeMovingWordTrial2(img,params.movie,[],trialInfo,[]);
% exFrame = movieFrames{1};
% exFrame(exFrame==255)=1;  % why can't i show an image from 0 to 255????
% exFrame(exFrame==128)=0.5;
% figure; imagesc(exFrame); colormap gray; truesize; axis off; title('Motion-defined')

%% Make example movie and save it out as avi
for frameNum = 1:nFrames
    img = (movieFrames{frameNum}./255);
    M(frameNum) = im2frame(img);
end
for frameNum = 1:nFrames
    img = (movieFrames{frameNum}./255);
    M(frameNum+nFrames) = im2frame(img);
end
for frameNum = 1:nFrames
    img = (movieFrames{frameNum}./255);
    M(frameNum+2*nFrames) = im2frame(img);
end
fprintf('Saving movie example to: %s\n',[pwd '/wordExampleMovie.avi'])
movie2avi(M,'wordExampleMovie.avi','FPS',30)
