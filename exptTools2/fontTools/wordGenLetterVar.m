function letters = wordGenLetterVar(fileName,stimParams)
% img = wordPlaceLetters(wordLetters,params)
% [NOTE: Function related to wordGenerateImage.m]
%
% Purpose
%   Generate a properly formatted list of letters for use in the
%   wordGenerateImage function.
%
% Input
%   stimParams - Structure containing font properties as follows...
%       .fontName
%       .fontSize
%       .sampsPerPt
%       .antiAlias
%       .fractionalMetrics
%       .boldFlag
%
% Output - See wordGenerateImage.m
%   letters - 2xn cell array composed of n matrices in row 1, each
%             containing a letter image corresponding to one of the n letter strings
%             contained in row 2 (letter images of the format 0 =
%             background, 1 = body of letter) 
%
% RFB 2009 [renobowen@gmail.com]

if nargin==0 || nargin==1
    fontName = 'Monospaced';
    fontSize = 20;
    sampsPerPt = 8;
    antiAlias = 0;
    fractionalMetrics = 0;
    boldFlag = true;
else
    fontName                 = stimParams.fontName; 
    fontSize                 = stimParams.fontSize; %regular value 10
    sampsPerPt               = stimParams.sampsPerPt; %regular value 8
    antiAlias                = stimParams.antiAlias;
    fractionalMetrics        = stimParams.fractionalMetrics;
    boldFlag                 = stimParams.boldFlag;
end

letterVector = '0':1:'z';
numLetters = length(letterVector);
genLetters = cell(1,numLetters);
for i=letterVector
    genLetters{letterVector==i} = i;
end
    
letters = cell(2,numLetters);
for i = 1:numLetters
    percDone = (i/numLetters)*100;
    fprintf('[%%%03.0f] Rendering %s...\n',percDone,genLetters{i});
    letters{1,i} = renderText(...
        genLetters{i}, fontName, fontSize, sampsPerPt, ...
        antiAlias, fractionalMetrics, boldFlag);
    letters{2,i} = genLetters{i};
end

save(fileName, 'letters', 'fontName', 'fontSize', 'sampsPerPt', 'antiAlias', 'fractionalMetrics', 'boldFlag');