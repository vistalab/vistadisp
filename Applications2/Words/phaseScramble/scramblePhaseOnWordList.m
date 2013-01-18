%% Script to read in a word list and make phase scrambled bmp images out of
%% these words, at a scramble level of sc.  This script was modified from
%% the more complicated scramblePhase script written by Bob.
%
%  amr Feb 27, 2009
%

% Things you probably want to change:
scrambleLevel = 0.00; %0.15; % phase scramble level- 0=none, 1=max (try .60 to .75)
%condNames = {['PhaseScrambleWord_' num2str(sc)]};  % this determines the directory bmps are saved in, can be PhaseScrambleWord or PhaseScrambleNW
%condNames = {['PhaseScrambleWord_' num2str(sc)]};
%condNames = {'consonants'};
%wordListPath = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim/wordlist.txt';
wordListPath = mrvSelectFile('r','txt','Please choose word (stimulus) list.',pwd);
if isempty(wordListPath), return, end
[tmp,condNames,ext] = fileparts(wordListPath);
condNames = {condNames};

% Font parameters
%letterCachePath = '/Users/Shared/AndreasWordsMatlab/WordHierarchy/stim/letterCache.mat';
letterCachePath = '/Users/Shared/ScanData/MotionWords/EventRelated/stim/general/letters.mat';
if exist(letterCachePath,'file')
    load(letterCachePath)
    centerOnLetters = 0;
else
    fontName = 'Monospaced';  %SansSerif
    fontSize = 8; %18;
    sampsPerPt = 6; %2; % this should be 2 or 3- use fontSize to adjust character size
    antiAlias = 0; % don't change
    fractionalMetrics = 0; % don't change
    letters = 'abcdefghijklmnopqrstuvwxyz';
    maskChar = '#%&?*@$';
    allLetters = [letters maskChar];
    centerOnLetters = 0;
    save(letterCachePath,'fontName','fontSize','sampsPerPt','letters','allLetters','maskChar','antiAlias','fractionalMetrics');
    
    
    % Make character images
    clear im;
    maxWidth = 0;
    maxHeight = 0;
    for(ii=1:length(letters))
        im{ii} = renderText(letters(ii), fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);
        if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
        if(size(im{ii},1) > maxHeight) maxHeight = size(im{ii},1); end
        
        %         im{ii} = renderText(maskChar(floor(rand*length(maskChar))+1), fontName, fontSize-4, sampsPerPt, antiAlias, fractionalMetrics);
        %         if(size(im{ii},2) > maxWidth) maxWidth = size(im{ii},2); end
        %         if(size(im{ii},1) > maxHeight) maxHeight = size(im{ii},1); end
    end
    
    
    % %For masking characters
    % for(jj=1:length(maskChar))
    %     im{ii+jj-1} = renderText(maskChar(jj), fontName, fontSize-4, sampsPerPt, antiAlias, fractionalMetrics);
    %     if(size(im{ii+jj-1},2) > maxWidth) maxWidth = size(im{ii+jj-1},2); end
    %     if(size(im{ii+jj-1},1) > maxHeight) maxHeight = size(im{ii+jj-1},1); end
    % end
    
    % Normalize all character heights (widths will still vary, unless monospaced font used)
    for(ii=1:length(im))
        sz = size(im{ii});
        if(sz(1) < maxHeight)
            im{ii} = vertcat(zeros(ceil((maxHeight-sz(1))/2),sz(2)), im{ii}, zeros(floor((maxHeight-sz(1))/2) ,sz(2)));
        end
    end
    
end


%% Where the output will go
%outDirName = 'PhaseScrambledStims';
%outDirName = 'scramble';
outDirPath = uigetdir(pwd,'Choose output directory for bmp images.');
%outDirBasename = '/Users/Shared/AndreasWordsMatlab/EventRelatedCode/PhaseScrambleER/stim';
[outDirBasename,outDirName] = fileparts(outDirPath);
if(~exist(fullfile(outDirBasename,outDirName),'dir')) mkdir(outDirBasename,outDirName); end


%% Read in word list
fid=fopen(wordListPath);
tmp = textscan(fid,'%s');
tmp = tmp{1};
fclose(fid);
stimulusList = tmp;

d = loadDisplayParams('displayName', '3T_projector_800x600');

for xx = 1:length(stimulusList)
    curWordImg = wordGenerateImage(d,letters,stimulusList{xx});
    %scrImg = scrambleWord(stimulusList{xx},scrambleLevel);
    curWordImg(curWordImg==0) = 0.5;  % turn the black background gray
    curWordImg = curWordImg.* 255;
    scrImg = scrambleImage(curWordImg,scrambleLevel);
    imwrite(scrImg,fullfile(outDirPath,[stimulusList{xx} '.bmp']),'BMP');
end


return

%% OLDER CODE %%

condList = [6];  %number of characters in each word?
nchar = 6;  % set number of characters in each word here (short words get padded by maskChar)

%% Pad the shorter words
for(ii=1:length(tmp))
    len(ii) = length(tmp{ii});
end

wordList = cell(6,1);
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

%% Specify the stimulus bounding box, in pixels
imWidth = maxWidth*nchar+20;
% all letters should be the same exact height
imHeight = maxHeight+20;
pad = 2; % for zero-padding


%% Scramble each word

for condNum = 1:length(condList)
    for wordNum=1:length(stimulusList)
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
        %figure;image(scrambleIm); colormap(gray(256)); truesize;
        fname = [stimulusList{wordNum}];
        stimDirName = condNames{condNum};
        if(~exist(fullfile([outDirBasename '/' outDirName],stimDirName),'dir')), mkdir([outDirBasename '/' outDirName],stimDirName); end
        fname = fullfile(outDirBasename, outDirName, stimDirName, [fname '.bmp']);
        imwrite(scrambleIm, gray(256), fname);
        disp(fname);
    end
end