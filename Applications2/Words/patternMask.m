%addpath /home/bob/matlab/fonts

letters = 'abcdefghijklmnopqrstuvwxyz';
centerOnLetters = 1;
numChar = length(letters);
wordList = textread('/Users/Shared/AndreasWordsMatlab/EventRelatedCode/MotionWordsER/stim/wordList_test.txt','%s%*[^\n]');
%wordList = textread('/home/bob/matlab/fonts/nouns4letter.txt','%s%*[^\n]');
% randomize list
wordList = wordList(randperm(length(wordList)));
% all letters should be the same exact height
imHeight = 85;
charWidePix = floor(.4*imHeight);
imWidth = charWidePix*length(wordList{1});
pad = 0;
thick = 2;

load myFont;
maskChars = logical(ones(size(myFont)));
% Remove single-spline letters (C, S, G)
maskChars([3,7,10,19]) = 0; 

clear im;
c = imHeight;
for(ii=1:length(myFont))
    tmp = renderSpline(scaleSpline(myFont(ii).spline, c*.1, c*.25, ...
                                   c*.45, c*.75), c, c, thick);
    im(:,:,ii) = tmp(:,1:charWidePix);
end
montage = makeMontage(im(:,:,:));
figure; imagesc(montage); truesize; axis off;

outDirName = 'patternWords_letterCenter3';
%outDirBasename = '/snarp/u1/bob/fonts';
outDirBasename = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end

snr = [.9 .7 .6 .5];
condNames = {'NoDist'}; %{'NoDist','LowDist','HiDist','vHiDist','TotDist'};
wordNum = 1;
for(condNum=1:length(snr))
    for(blockNum = 1:6)
        for(itemNum = 1:6)
            %strIndex = randperm(numChar); strIndex = strIndex(1:strLength);
            strIndex = wordList{wordNum}-double(letters(1))+1;
            wordNum = wordNum+1; 
            if(wordNum>length(wordList)) 
                % start over, randomizing order again
                wordNum = 1; 
                disp(['WORDNUM WRAPPED! ' num2str([blockNum itemNum condNum])]);
                %wordList = wordList(randperm(length(wordList)));
            end
            tmp = [];
            for(ii=strIndex)
                tmp = horzcat(tmp, im(:,:,ii));
            end
            % zero-pad the edges
            str = zeros(imHeight+pad*2, imWidth+pad*2);
            xoffset = round((size(str,2)-size(tmp,2))/2);
            yoffset = round((size(str,1)-size(tmp,1))/2);
            str(yoffset+1:yoffset+size(tmp,1),xoffset+1:xoffset+size(tmp,2)) = tmp;
            
            if(snr(condNum)>1)
                % special case- make a checkerboard
                nCyclesX = 6;
                xyRatio = size(str,2)./size(str,1);
                x = mod(round(linspace(-nCyclesX,nCyclesX,size(str,2))),2)*2-1;
                y = mod(round(linspace(-nCyclesX./xyRatio,nCyclesX./xyRatio,size(str,1))),2)*2-1;
                stimImg = y'*x.*.5;
            else
                mask = makeSplineMask(myFont(maskChars), imHeight, imWidth, thick);
                %mask = zeros(size(str));
                stimImg = snr(condNum).*str;
                indx = stimImg==0;
                stimImg(indx) = (1-snr(condNum)).*mask(indx);
                %stimImg = snr(condNum).*str + (1-snr(condNum)).*mask;
            end
            stimImg(stimImg>1) = 1;
            stimImg(stimImg<-1) = -1;
            stimImg = stimImg(pad+1:pad+imHeight, pad+1:pad+imWidth);
            stimImg = uint8(round(stimImg*127.5+127.5));
            %figure;image(stimImg); colormap(gray(256)); truesize;
            fname = [condNames{condNum} num2str(blockNum,'%01d') '-' num2str(itemNum,'%01d')];
            fname = fullfile(outDirBasename, outDirName, [fname '.bmp']);
            imwrite(stimImg, gray(256), fname);
            disp(fname);
        end
    end
end 



wordList = textread('/home/bob/matlab/fonts/nonwords031704.txt','%s%*[^\n]');
wordList = [wordList; textread('/home/bob/matlab/fonts/words031704.txt','%s%*[^\n]')];

outDirName = 'vwfaLocalizer_letterCenter';
outDirBasename = '/snarp/u1/bob/fonts';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end

clear wordWidth wordHeight;
for(wordNum=1:length(wordList))
    strIndex = wordList{wordNum}-double(letters(1))+1;
    tmp = horzcat(im{strIndex});
    wordWidth(wordNum) = size(tmp,2);
    wordHeight = size(tmp,1);
    % zero-pad the edges
    str = zeros(imHeight+pad*2, imWidth+pad*2);
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
