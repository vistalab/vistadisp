%addpath /home/bob/matlab/fonts
maskChar = ' '; %'#%&?*';

%
% Specify font characteristics.
%
% Serif, SansSerif, Monospaced, Dialog, DialogInput
fontName = 'SansSerif';
fontSize = 10; %18;
sampsPerPt = 8; %2; % this should be 2 or 3- use fontSize to adjust character size
antiAlias = 0; % don't change
fractionalMetrics = 0; % don't change
letters = 'abcdefghijklmnopqrstuvwxyz';
allLetters = [letters maskChar];
centerOnLetters = 0;

%
% Render each character
% (shouldn't need to change this code)
%
clear im;
maxWidth = 0;
maxHeight = 0;
for(ii=1:length(letters))
    im{ii} = renderText(letters(ii), fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
    if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
    if(size(im{ii},1) > maxHeight) maxHeight = size(im{ii},1); end
end
for(jj=1:length(maskChar))
    im{ii+jj-1} = renderText(maskChar(jj), fontName, fontSize-4, sampsPerPt, antiAlias, fractionalMetrics);
    if(size(im{ii+jj-1},2) > maxWidth) maxWidth = size(im{ii+jj-1},2); end
    if(size(im{ii+jj-1},1) > maxHeight) maxHeight = size(im{ii+jj-1},1); end
end
% Normalize all character heights (widths will still vary)
for(ii=1:length(im))
    sz = size(im{ii});
    if(sz(1) < maxHeight) 
        im{ii} = vertcat(zeros(ceil((maxHeight-sz(1))/2),sz(2)), im{ii}, zeros(floor((maxHeight-sz(1))/2) ,sz(2)));  
    end
end

%
% Read in word list
%
%tmp = textread('/home/bob/matlab/fonts/n-letter_nouns.txt','%s%*[^\n]');
wordListPath = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/MotionWordsER/stim/wordList_test.txt';
fid=fopen(wordListPath);
tmp = textscan(fid,'%s');
tmp = tmp{1};
fclose(fid);

% OR

%tmp = textread('/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim/n-letter_nouns.txt','%s%*[^\n]');
%wordList = [wordList; textread('/home/bob/matlab/fonts/words031704.txt','%s%*[^\n]')];
for(ii=1:length(tmp))
    len(ii) = length(tmp{ii});
end
wordList = cell(6,1);
% Number of characters in each string (short words get padded by maskChar)
nchar = 8;
lengthList = [];
for(ii=1:length(tmp))
    nmask = max(nchar-len(ii),0);
    nleft = floor(nmask/2);
    curCond = len(ii)-min(len)+1;
    lm = maskChar(round(rand(1,nleft)*(length(maskChar)-1)+1));
    rm = maskChar(round(rand(1,nmask-nleft)*(length(maskChar)-1)+1));
    wordList{curCond} = [wordList{curCond}; [lm tmp{ii} rm]];
    lengthList(len(ii)) = curCond;
end
   
% randomize the entire list
for(ii=1:length(wordList))
    r = randperm(size(wordList{ii},1));
    wordList{ii} = wordList{ii}(r,:);
end
% Specify the stimulus bounding box, in pixels
imWidth = maxWidth*nchar+20;
% all letters should be the same exact height
imHeight = maxHeight+20;
pad = 2; % for zero-padding

% Where the output will go
outDirName = 'test';
%outDirBasename = '/snarp/u1/bob/fonts';
outDirBasename = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim';
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end

sc = .70; % phase scramble level- 0=none, 1=max (try .60 to .75)
condList = [4 5 6];
condNames = {'NoDist','LowDist','HiDist','vHiDist','TotDist'};
for(condNum=1:length(condList))
    wordNum = 0;
    for(blockNum = 1)%:6)
        for(itemNum = 1)%:6)
            wordNum = wordNum+1; 
            if(wordNum>size(wordList{curCond},1)) 
                % start over, randomizing order again
                wordNum = 1;
                disp(['WORDNUM WRAPPED! ' num2str([blockNum itemNum condNum])]);
            end
            curCond = condList(condNum)-min(len)+1;
            strIndex = wordList{curCond}(wordNum,:)-double(letters(1))+1;
            for(ii=1:length(maskChar))
                strIndex(strIndex==maskChar(ii)-double(letters(1))+1) = ii+length(letters)-1;
            end
            tmp = horzcat(im{strIndex});
            % zero-pad the edges
            str = zeros(imHeight+pad*2, imWidth+pad*2);
            if(centerOnLetters)
                xoffset = round(size(str,2)/2 - size([im{strIndex(1:2)}],2));
            else
                xoffset = round((size(str,2)-size(tmp,2))/2);
            end
            yoffset = round((size(str,1)-size(tmp,1))/2);
            str(yoffset+1:yoffset+size(tmp,1),xoffset+1:xoffset+size(tmp,2)) = tmp;
            
            fftIm = fft2(str);
            newPh = angle(fftIm) + sc*(rand(size(str))-.5)*pi*2;
            % We want to preserve some phases (DC level- but that shouldn't
            % matter?)
            k = [1,1];
            sz = size(newPh);
            keep = sub2ind(sz, k(:,1), k(:,2));
            newPh(keep) = angle(fftIm(keep));
            scrambleIm = real(ifft2(abs(fftIm) .* exp(i*newPh)));
            
            scrambleIm(scrambleIm>1) = 1;
            scrambleIm(scrambleIm<-1) = -1;
            scrambleIm = scrambleIm(pad+1:pad+imHeight, pad+1:pad+imWidth);
            scrambleIm = uint8(round(scrambleIm*127.5+127.5));
            figure;image(scrambleIm); colormap(gray(256)); truesize;
            fname = [condNames{condNum} num2str(blockNum,'%01d') '-' num2str(itemNum,'%01d')];
            fname = fullfile(outDirBasename, outDirName, [fname '.bmp']);
            %imwrite(scrambleIm, gray(256), fname);
            disp(fname);
        end
    end
end 

