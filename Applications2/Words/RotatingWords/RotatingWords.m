% rotating words reading task based on Cohen et al 2008
% adds necessary paths and starts the expt
% created by amr 10/20/08
%
% Task instructions:
% In this task, words will flash on the screen.  You must keep your
% eyes in the center of the screen (where the cross is) and to try to read
% the words.  The task is to respond whether the word refers to an animal
% or not.  (Press one button for animal, another for not an animal.)
%
% One prediction might be that parietal cortex will respond more for words
% rotated past ~50 degrees.
%

pwd
thePath.main = pwd; % Make sure you are starting from the RotatingWords directory!

[pathstr,curr_dir,ext,versn] = fileparts(pwd);
if ~strcmp(curr_dir,'RotatingWords')
    fprintf('You must start the experiment from the RotatingWords directory. Go there and try again.\n');
else
    stimDir = input('Which list (0-7) to run? (0 is practice)  ');
    thePath.scripts = fullfile(thePath.main, 'scripts');
    stimDirFolder = ['stim' num2str(stimDir)];
    thePath.stim = fullfile(thePath.main,stimDirFolder);
    thePath.util = fullfile(thePath.main, 'util');
    thePath.data = fullfile(thePath.main, 'data');
    thePath.lists = fullfile(thePath.main, 'lists');
    % add more dirs above

%     % Add relevant paths for this experiment -- not required if using SVN?
%     names = fieldnames(thePath);
%     for f = 1:length(names)
%         eval(['addpath(thePath.' names{f} ')']);
%         fprintf(['added ' names{f} '\n']);
%     end

    fprintf('Welcome to the Rotating Words Experiment\n');
    subID = input('What is the subject ID? ','s');
    theData = runRotatingWords(thePath,subID);
    
%     % Clean up paths after done
%     for f = 1:length(names)
%         eval(['rmpath(thePath.' names{f} ')']);
%         fprintf(['removed ' names{f} '\n']);
%     end
end