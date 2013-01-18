function [wordData] = wordCreateSaveTextOutline(params,wStr)
%This function has changed quite a bit and is now in a state where it is
%more or less just a loop around the newer wordGenerateImage function.
%Params must include display and letters, as well as stimSizePix.  Letters
%is the images of letters created by wordGenLetterVar (or
%wordGenLetterGUI).
%
% wStr is a list of words (in a cell array) that you want to create images
% for.
%
%   [wordData] = wordCreateSaveTextOutline(stimParams,wStr,[nwStr])
%
%
% wStr = {'arch',  'boss'};
% nwStr = {'twon', 'ceap'};
% stimParams = initWordParams('mr');

%if notDefined('nwStr'), nwStr = {}; end  % in case you only want to make images from one list (wStr)
%%
% Initialize stimulus text parameters
fontName   = params.font.fontName;
fontSize   = params.font.fontSize;
sampsPerPt = params.font.sampsPerPt;
antiAlias  = params.font.antiAlias;
fractionalMetrics = params.font.fractionalMetrics;

% Not used by renderText ... should figure out
boldFlag = params.font.boldFlag;  %#ok<NASGU>

wordData = [];

%% Process word and then non-word strings
%for jj=1:2
%    if  jj == 1, str = wStr;
%    else         str = nwStr;
%    end
    
    % Create renderings for the word strings
for ii=1:length(wStr)
    if ~(strcmp(wStr{ii},'Fix'))  % special condition
        fprintf('Rendering text: %s\n',wStr{ii});
        tmp = wordGenerateImage(params.movie.display,params.movie.letters,wStr{ii},'adjustImSize',params.font.stimSizePix);
        %tmp = renderText(str{ii}, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics);

        % Check if the text is too large a stimulus
        %sz = size(tmp);
        %if(any(sz>stimParams.stimSizePix))
        %    r = stimParams.stimSizePix(1);
        %    c = stimParams.stimSizePix(2);
        %    error('Largest stimulus exceeds specificed stimulus size (%d %d).',r,c);
        %end
        % imtool(tmp)

        % rect is [left,top,right,bottom]. Matlab array is usually y,x
        % CenterRect is a PTB function
        %r = CenterRect([1 1 sz(1) sz(2)], [1 1 stimParams.stimSizePix]);
        %if jj == 1
            %wordData.wStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
            %wordData.wStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
        wordData{ii} = uint8(tmp);
        %else
            %wordData.nwStrImg{ii} = zeros(stimParams.stimSizePix, 'uint8');
            %wordData.nwStrImg{ii}(r(1):r(3),r(2):r(4)) = uint8(tmp);
            %wordData.nwStrImg{ii} = uint8(tmp);
        %end
    end
end
%end


return;

