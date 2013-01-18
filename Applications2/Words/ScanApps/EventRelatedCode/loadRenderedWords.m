function [wStrImages,RenderedStimFile,fontParams] = loadRenderedWords(fontParams,stimOrder)
% This function will load the outlines (forms) for a list of stimuli from a
% mat file (RenderedStimFile).  If this mat file (which the user selects)
% does not already exist (i.e. user cancels), it will create such a file by
% rendering the stimuli.  It gives the user the option to save out this new
% list of rendered images.
%
% wStrImages: this output is a list of images in a cell array
% RenderedStimFile: full path to the saved mat file
% fontParams: set by initWordParams. Contains font information used in rendering
% stimOrder: a list of words (strings) that will be rendered
%
%   [wStrImages,RenderedStimFile,fontParams] = loadRenderedWords(fontParams,stimOrder)
%
%       written amr Dec 16, 2008


%% Create the rendered outline for all words/nonwords

% Load rendered images from a file
%RenderedStimFile = mrvSelectFile('r','mat','Do you have rendered stimuli saved?');
RenderedStimFile = [];

if isempty(RenderedStimFile)  % if the user pressed cancel, make new renderings
    % Create renderings of each of the stimuli--  note that if stimuli are
    % repeated, they will be rendered each time (i.e. multiple times)--
    % inefficient!
    fprintf('\n%s\n','Creating new renderings...');
    [images, fontParams] = wordCreateSaveTextOutline(fontParams, stimOrder);
    wStrImages = images.wStrImg; clear images;
    % figure; imagesc(wStrImages{1})   % to have a look at one of the images

    % Save the new renderings
    %RenderedStimFile = saveNewRenderings(wStrImages,stimOrder,fontParams);

else  % load the images from the file that the user selected
    % note that if you load a rendering that doesn't match up with
    % stimOrder, then we will force a re-rendering
    disp('Loading rendered stim file...');
    tmp = load(RenderedStimFile);

    % rendered text is in the stimulus variable e.g. images.wStrImg{1};
    wStrImages = tmp.wStrImages;
    LoadedStimOrder = tmp.stimOrder;
    fontParams = tmp.fontParams;

    if ~isequal(LoadedStimOrder,stimOrder)  % if the order of stimuli is not exactly the same as expected from stimOrder
        fprintf('\nLoaded rendered stimuli are in a different order than expected stimulus order.\nRecreating renderings.\n');
        [images, fontParams] = wordCreateSaveTextOutline(fontParams, stimOrder);  % redo renderings
        wStrImages = images.wStrImg; clear images;

        % Save the new renderings
        %RenderedStimFile = saveNewRenderings(wStrImages,stimOrder,fontParams);
    end
end

return


function RenderedStimFile = saveNewRenderings(wStrImages,stimOrder,fontParams)
% function saves rendered stimuli to RenderedStimFile

RenderedStimFile = mrvSelectFile('w','mat','Choose where to save rendered stimuli');
if   isempty(RenderedStimFile), disp('User canceled saving rendered text.');
else
    save(RenderedStimFile,'wStrImages','stimOrder','fontParams');
    fprintf('Saved rendered stimuli to file: %s\n\n',RenderedStimFile);
end
return