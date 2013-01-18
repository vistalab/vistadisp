function scrambledWordImage = scrambleWord(word,scrambleLevel,centerOnLetters)
% This function will phase-scramble a word at a given scrambleLevel.
% Theoretically, this function could be used for phase scrambling any
% image, not just words.  However, there are some special things we do with
% words (like padding the edges with other characters).  Note that right
% now, this script expects 4 character words.  Shorter words will be padded
% by other characters.  Longer words currently crash this code.
%
%   scrambledWordImage = scrambleWord(word,scrambleLevel,[centerOnLetters=0])
%
% Inputs
%   word:  text of a word that you want to create an image for an scramble
%
%   scrambleLevel:  between 0 and 1, with full scrambling at 1
%
%   centerOnLetters:  center on letters flag, default=0
%
% Output
%   scrambledWordImage:  image of word scrambled by a certain level
%   (scrambleLevel)
%
% written by amr June 23, 2009
%

%% Default Parameters
if notDefined('centerOnLetters')
    centerOnLetters = 0;
end


%% First get the letters
letterCache = '/Users/Shared/PsychophysData/PhaseScrambleStaircase/letterCache.mat';
if exist(letterCache,'file')
    tmp = load(letterCache);
    im = tmp.im;
    maxHeight = tmp.maxHeight;
    maxWidth = tmp.maxWidth;
    letters = tmp.letters;
    maskChar = tmp.maskChar;
    clear tmp
else
    % Get stimulus parameters (size of letters and font) from Phase Scramble Params
    stimParams = initPhaseScrambleParams('detect');  % stim params should be equivalent for detect and lexical
    fontName = stimParams.fontName;
    fontSize = stimParams.fontSize;
    sampsPerPt = stimParams.sampsPerPt;
    clear stimParams;
    % Make the letter stimuli
    fprintf('\nRendering letter images...please be patient.\n');
    clear im;
    antiAlias = 0; % don't change
    fractionalMetrics = 0; % don't change
    letters = 'abcdefghijklmnopqrstuvwxyz';
    maskChar = '#%&?*@$';
    allLetters = [letters maskChar];
    centerOnLetters = 0;
    maxWidth = 0;
    maxHeight = 0;
    for(ii=1:length(letters))
        im{ii} = renderText(letters(ii), fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
        if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
        if(size(im{ii},1) > maxHeight) maxHeight = size(im{ii},1); end
        
%             im{ii} = renderText(maskChar(floor(rand*length(maskChar))+1), fontName, fontSize-4, sampsPerPt, antiAlias, fractionalMetrics);
%             if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
%             if(size(im{ii},1) > maxHeight) maxHeight = size(im{ii},1); end
    end
    
    %For masking characters
    for(jj=1:length(maskChar))
        im{ii+jj} = renderText(maskChar(jj), fontName, fontSize-4, sampsPerPt, antiAlias, fractionalMetrics);
        if(size(im{ii+jj-1},2) > maxWidth) maxWidth = size(im{ii+jj-1},2); end
        if(size(im{ii+jj-1},1) > maxHeight) maxHeight = size(im{ii+jj-1},1); end
    end
    
    % Normalize all character heights (widths will still vary, unless monospaced font used)
    for(ii=1:length(im))
        sz = size(im{ii});
        if(sz(1) < maxHeight)
            im{ii} = vertcat(zeros(ceil((maxHeight-sz(1))/2),sz(2)), im{ii}, zeros(floor((maxHeight-sz(1))/2) ,sz(2)));
        end
    end
    
    % Save out the letters
    try
        save(letterCache,'im','letters','maskChar','maxWidth','maxHeight');
        fprintf('\nSaved letter cache in:  %s\n\n',letterCache)
    catch
        letterCache = mrvSelectFile('w','mat','Save letter cache file.',pwd')
        if ~isempty(letterCache)
        save(letterCache,'im','letters','maskChar','maxWidth','maxHeight');
            fprintf('\nSaved letter cache in:  %s\n\n',letterCache)
        end
    end
end


% Pad short words
len = length(word);

nchar = 4;
nmask = max(nchar-len,0);
nleft = floor(nmask/2);
lm = maskChar(round(rand(1,nleft)*(length(maskChar)-1)+1));
rm = maskChar(round(rand(1,nmask-nleft)*(length(maskChar)-1)+1));
word = [lm word rm];

%% Specify the stimulus bounding box, in pixels
imWidth = maxWidth*nchar+20;
% all letters should be the same exact height
imHeight = maxHeight+20;
pad = 2; % for zero-padding


%% Scramble each word

strIndex = word-double(letters(1))+1;
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
newPh = angle(fftIm) + scrambleLevel*(rand(size(str))-.5)*pi*2;
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
scrambledWordImage = uint8(round(scrambleIm*127.5+127.5));
%figure;image(scrambleIm); colormap(gray(256)); truesize;



return

% older code below -- works but words look different

%% Then pad the words, etc.

for(ii=1:length(unscrambledWordImage))
    len(ii) = length(unscrambledWordImage(ii));
end

wordList = cell(6,1);
% Number of characters in each string (short words get padded by maskChar)
nchar = 4;
% lengthList = [];
% for(ii=1:length(unscrambledWordImage))
%     nmask = max(nchar-len(ii),0);
%     nleft = floor(nmask/2);
%     curCond = len(ii)-min(len)+1;
%     lm = maskChar(round(rand(1,nleft)*(length(maskChar)-1)+1));
%     rm = maskChar(round(rand(1,nmask-nleft)*(length(maskChar)-1)+1));
%     wordList{curCond} = [wordList{curCond}; [lm unscrambledWordImage(ii) rm]];
%     lengthList(len(ii)) = curCond;
% end

%% Specify the stimulus bounding box, in pixels
imWidth = size(unscrambledWordImage,2); %maxWidth*nchar+20;
% all letters should be the same exact height
imHeight = size(unscrambledWordImage,1);  %maxHeight+20;
pad = 2; % for zero-padding


%% Scramble the word image
%curCond = condList(condNum)-min(len)+1;
%strIndex = wordList{curCond}(wordNum,:)-double(letters(1))+1;
% for(ii=1:length(maskChar))
%     strIndex(strIndex==maskChar(ii)-double(letters(1))+1) = ii+length(letters)-1;
% end
% unscrambledWordImage = horzcat(im{strIndex});

% zero-pad the edges
str = zeros(imHeight+pad*2, imWidth+pad*2);
if(centerOnLetters)
    xoffset = round(size(str,2)/2 - size([im{strIndex(1:2)}],2));
else
    xoffset = round((size(str,2)-size(unscrambledWordImage,2))/2);
end
yoffset = round((size(str,1)-size(unscrambledWordImage,1))/2);
str(yoffset+1:yoffset+size(unscrambledWordImage,1),xoffset+1:xoffset+size(unscrambledWordImage,2)) = unscrambledWordImage;

fftIm = fft2(str);
newPh = angle(fftIm) + scrambleLevel*(rand(size(str))-.5)*pi*2;
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
scrambledWordImage = uint8(round(scrambleIm*127.5+127.5));

% for looking at the new image:
%figure;image(scrambleIm); colormap(gray(256)); truesize;

return


%% For testing this function:

word = 'word';
scrambleLevel = 0.7;

stimParams.fontName = 'Monospaced'; %'SansSerif';
stimParams.fontSize = 10;  %regular value 10
stimParams.sampsPerPt = 8; %regular value 8
stimParams.antiAlias = 0;
stimParams.fractionalMetrics = 0;
stimParams.boldFlag = true;
stimParams.stimSizePix = [108 244];  %[180 600]; % in pixels, [y,x]
stimParams.spread = stimParams.stimSizePix/5; %4.5

curStrImg = renderText(word, stimParams.fontName, stimParams.fontSize,...
    stimParams.sampsPerPt, stimParams.antiAlias, stimParams.fractionalMetrics, stimParams.boldFlag);
scrWordImg = scrambleWord(curStrImg,scrambleLevel);
figure; imagesc(scrWordImg); axis equal; colormap gray;


%% Maybe a different way to scramble without using whole letters? --probably need to modify
curStrImg = renderText(word, stimParams.fontName, stimParams.fontSize,...
    stimParams.sampsPerPt, stimParams.antiAlias, stimParams.fractionalMetrics, stimParams.boldFlag);
fftIm = fft2(curStrImg);
newPh = angle(fftIm)+scrambleLevel*(rand(size(curStrImg))-0.5)*pi*2;

k = [1,1];
sz = size(newPh);
keep = sub2ind(sz, k(:,1), k(:,2));
newPh(keep) = angle(fftIm(keep));
scrambleIm = real(ifft2(abs(fftIm) .* exp(i*newPh)));
scrambleIm(scrambleIm>1) = 1;
scrambleIm(scrambleIm<-1) = -1;
scrambledWordImage = uint8(round(scrambleIm*127.5+127.5));
figure; imagesc(scrambledWordImage); axis equal; colormap gray;
