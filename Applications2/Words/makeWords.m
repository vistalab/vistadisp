% This script does not run. It produces many errors. 
% Jw 4.10.2012

% Serif, SansSerif, Monospaced, Dialog, DialogInput
fontName = 'SansSerif';
fontSize = 18;
sampsPerPt = 3;
strLength = 4;
antiAlias = 0;
fractionalMetrics = 0;
%letters = 'bcdfghjkmnpqrstvwxz';%BCDFGHJKLMNPQRSTVWXZ';
letters = 'abcdefghijklmnopqrstuvwxyz';
centerOnLetters = 1;

numChar = length(letters);
clear im;
maxWidth = 0;
for(ii=1:numChar)
    im{ii} = renderText(letters(ii), fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
    if(size(im{ii},2) > maxWidth), maxWidth = size(im{ii},2); end
end

wordList = textread('/Users/Shared/AndreasWordsMatlab/EventRelatedCode/MotionWordsER/stim/wordList_test.txt','%s%*[^\n]'); %'/home/bob/matlab/fonts/n-letter_nouns.txt','%s%*[^\n]');
%wordList = [wordList; textread('/home/bob/matlab/fonts/words031704.txt','%s%*[^\n]')];
for(ii=1:length(wordList))
    len(ii) = length(wordList{ii});
end

outDirName = 'wordLen';
outDirBasename = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/MotionWordsER/stim';  %/snarp/u1/bob/fonts';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end

clear wordWidth wordHeight;
for(wordNum=1:length(wordList))
    strIndex = wordList{wordNum}-double(letters(1))+1;
    tmp = horzcat(im{strIndex});
    wordWidth(wordNum) = size(tmp,2);
    wordHeight = size(tmp,1);
    % zero-pad the edges
    str = zeros(imHeight+pad*2, imWidth+pad*2);
    %str = zeros(wordHeight+pad*2, wordWidth+pad*2);
    if(centerOnLetters)
        xoffset = round(size(str,2)/2 - size([im{strIndex(1:2)}],2));
    else
        xoffset = round((size(str,2)-size(tmp,2))/2);
    end
    yoffset = round((size(str,1)-size(tmp,1))/2);
    str(yoffset+1:yoffset+size(tmp,1),xoffset+1:xoffset+size(tmp,2)) = tmp;
    str = 1-str;
    str(str==1) = .5;
    k = gausswin(3)*gausswin(3)'; k = k./sum(k(:));
    str = conv2(str, k, 'same');
    str = str(pad+1:pad+imHeight, pad+1:pad+imWidth);
    str = uint8(round(str*255));
    %figure;image(str); colormap(gray(256)); truesize;
    fname = fullfile(outDirBasename, outDirName, [wordList{wordNum} '.bmp']);
    imwrite(str, gray(256), fname);
    disp(fname);
end 

% Make a checkerboard
h = ceil(mean(wordHeight)./1.6);
w = ceil(mean(wordWidth));
nCyclesY = 3;
yxRatio = h./w;
y = mod(round(linspace(-nCyclesY, nCyclesY, h)),2)*2-1;
x = mod(round(linspace(-nCyclesY./yxRatio, nCyclesY./yxRatio, w)),2)*2-1;
im = y'*x.*.5;
im = uint8(round(im*127.5+127.5));
figure;image(im); colormap(gray(256)); truesize;
fname = fullfile(outDirBasename, outDirName, ['CHECKS.bmp']);
imwrite(im, gray(256), fname); disp(fname);
