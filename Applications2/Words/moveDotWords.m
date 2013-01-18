
%%
% Create the word mask by rendering a text string
%
fontName = 'SansSerif';
fontSize = 10;  %regular value 18
sampsPerPt = 12; %regular value 12
antiAlias = 0;
fractionalMetrics = 0;

str = 'Hello';
testText = renderText(str, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
sz = size(testText);


%%
% Create the movie
%
nFrames = 60;
stimParams.coherence = 1.0;
stimParams.dotDensity = 0.05;
stimParams.formDir = 270;
stimParams.backDir = 90;
testMov = makeMoveDotForm(testText, stimParams, nFrames);
sz = size(testMov);

%%
% Show the movie
%
mplay(testMov);

%%
% Save the movie
%

imwrite(testMov,['/tmp/' str '.gif'],'DelayTime',0.1,'LoopCount',65535);
% To save individual frames:
% for(ii=1:size(testMov,3))
%     imwrite(testMov(:,:,ii),cmap./255,sprintf('/tmp/f%02d.png',ii));
% end

%% Make a texture version
textureImg = zeros(sz(1:3),'uint8');
for(curFrame=1:nFrames)
    tmp = testMov(:,:,:,curFrame);
    curMask = repmat(any(tmp,3),[1 1 3]);
    textureImg(curMask) = tmp(curMask);
end
figure; image(textureImg); truesize; axis off;


%% Make random dot stereogram
figure;
stereoImg = stereogram(testText,'parallel-eyes');

%%
error('Stop here- code below is not finished.');

%
% More complex code to create more precise stimuli, e.g., with controlled
% letter spacing and bounding box. Also loads specified stimuli from a text
% file.
%
coherence = 1;
dotDensity = 0.25;
nFrames = 60;

fontName = 'SansSerif';
fontSize = 18;
sampsPerPt = 5;
antiAlias = 0;
fractionalMetrics = 0;
%letters = 'bcdfghjkmnpqrstvwxz';%BCDFGHJKLMNPQRSTVWXZ';
letters = 'abcdefghijklmnopqrstuvwxyz';
centerOnLetters = 0;
pad = 10;

numChar = length(letters);
clear im;
maxWidth = 0;
for(ii=1:numChar)
    im{ii} = renderText(letters(ii), fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
    if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
end

wordList = textread('/home/bob/matlab/fonts/n-letter_nouns.txt','%s%*[^\n]');
%wordList = [wordList; textread('/home/bob/matlab/fonts/words031704.txt','%s%*[^\n]')];
for(ii=1:length(wordList))
    len(ii) = length(wordList{ii});
end

imHeight = size(im{1},1);
imWidth = maxWidth*max(len);

outDirName = 'wordLen';
outDirBasename = '/silver/scr1/fonts';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end

clear wordWidth wordHeight M;
for(wordNum=1:length(wordList))
    strIndex = wordList{wordNum}-double(letters(1))+1;
    tmp = horzcat(im{strIndex});
    wordWidth(wordNum) = size(tmp,2);
    wordHeight = size(tmp,1);
    % zero-pad the edges
    str = zeros(wordHeight+pad*2, wordWidth+pad*2);
    if(centerOnLetters)
        xoffset = round(size(str,2)/2 - size([im{strIndex(1:2)}],2));
    else
        xoffset = round((size(str,2)-size(tmp,2))/2);
    end
    yoffset = round((size(str,1)-size(tmp,1))/2);
    str(yoffset+1:yoffset+size(tmp,1),xoffset+1:xoffset+size(tmp,2)) = tmp;
    [mov,cmap] = makeMoveDotForm(str, coherence, dotDensity, nFrames);
    for(ii=1:size(mov,3))
        M{wordNum}(ii) = im2frame(mov(:,:,ii),cmap./255);
    end
    %
    % *** WORK HERE
    %
    %str = uint8(round(str*255));
    %figure;image(str); colormap(gray(256)); truesize;
    %fname = fullfile(outDirBasename, outDirName, [wordList{wordNum} '.bmp']);
    %imwrite(str, gray(256), fname); disp(fname);
end 

ii = 30;
figure(86);
image(M{ii}(1).cdata);truesize;
colormap(M{ii}(1).colormap);
movie(M{ii},-1,60);

