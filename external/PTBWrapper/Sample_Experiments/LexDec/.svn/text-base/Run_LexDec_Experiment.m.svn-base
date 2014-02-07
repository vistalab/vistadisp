%% Run_LexDec_Experiment: A file to run a lexical decision experiment

% Please read this file before running the experiment.

% This file is setup as a code cell. That means that you can run the code 
% by selecting 'Evaluate Current Cell' from the Cell menu. Once your
% stimulus files are setup, and the below arguments are set appropriately,
% running this code will run the experiment. Make sure your matlab current
% folder has this file in it, along with the stimuli .txt files and the
% LexDec_Experiment.m file.

% NOTE: The response keys are the '1' (nonword) and '2' (word) keys for 
%   the keyboard and the blue (nonword) and yellow (word) keys in the MEG.
%   If you want to exit the experiment at any point, hit 'q'. This will
%   cause matlab to report an error, but don't worry, that's fine. 


% PLEASE NOTE: You are not intended to modify the code in LexDec_Experiment.
% Unless you are fairly adapt at matlab and programming, there is a high
% likelyhood that the code there will not make very much sense to you.
% If you need further functionality, let the lab manager know, and
% hopefully it can be added to a future version of this file. Otherwise,
% there are several experiment files that might suit your needs better.
% Also, there is a PTBWrapper tutorial of sorts (named Stimuli_Tutorial.m), 
% that you can use to get acquainted with the PTBWrapper functions. This 
% file lays out the basic commands for displaying stimuli to the screen. 

% Stimulus file setup. To run the experiment, you need to create a file
% called Stim_List.txt that holds your stimuli. It should have one row per
% trials, each with six columns, in this order:
% 
% 	* ID_# (this should be unique)
% 	* Condition ('word' or 'nonword')
% 	* Item_# (relative to the condition of the item)
% 	* stim (the stimulus item)
% 	* fixation trigger (the trigger sent to the MEG when the fixation cross appears)
% 	* target trigger (the trigger sent to the MEG with the stimulus appears)
%
% * A quick note on triggers: you can use any number 1-255. The triggers
%       are sent out over eight binary lines, so it's easiest to use powers 
%       of 2 (1,2,4,8, etc.) until you run out.
%
% Please see the (hopefully) included Stim_List.txt file for an example. 
%
% Also, if you intend to run a practice, create a file called
% Practice_List.txt to hold the practice items.

% Finally, if you need to debug the experiment for some reason, you can
%   add the argument 1 to the end of the last line of this file.



% NOTE: You can replace these files with those of your own, as long as they
%   have the same structure. If you do, put the name of those files in
%   these variables.
stim_list = 'Stim_List.txt';
practice_list = 'Practice_List.txt';

% Below are the parameters for the experiment. Please make sure they are
% set correctly before running the code. Once they are, run the code using
% Evaluate Current Cell from the Cell menu and your experiment should run.


%  This is the name of the subject. It will be prepended to the data and 
%   log files that record what happened during the experiment. These are 
%   the _data.txt and _log.txt files that are made by the program during 
%   the experiment. The _log.txt file keeps a record of every stimulus 
%   that appears on the screen during the experiment and what and when it was. 

subject_name = 'Subject';


% This is the number of blocks to split your experiment into. Between each
%   block the subject will be prompted with a screen to take a break.

num_blocks = 4;


% Set this argument to 1 when the subject is in the MEG machine. It will
%    send triggers along with your stimuli, as designated in the stimulus files. 
% * NOTE: If you set this to 1 and are not connected to the MEG
%    machine, you will receive a warning that no triggers are sent, but
%    the experiment should still run.
% * NOTE: To get past this warning, as well as the "prepare to start the
%    recording screen, hit 'a'.

is_in_MEG = 0;


% Set this to 1 to run a practice. This will run at the beginning of the
%   experiment and will not send any triggers to the MEG.

run_practice = 0;

% Set to 1 in order to give the subject feedback during the practice.

use_feedback = 0;


% Set this to 1 to run the experiment. This will run after the practice.
%   Set this to 0 and run_practice to 1 if you only want to run the practice.

run_experiment = 1;


% Set this to 1 to randomize the practice stimuli.

randomize_practice_stims = 0;


% Set this to 1 to randomize the experimental stimuli.

randomize_experiment_stims = 1;




%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Timing parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%%


% This is how long the initial fixation cross is on for. 

fixation_time = 0.300; 


% This is the length of the blank screen between the fixation cross and the word.

ISI = 0.300;


% This is the time limit to respond. For no timeout, set this to -1.

target_timeout = -1;


% This is the mean and standard deviation for the ITI. The ITI per trial
%   will be drawn from a normal distribution with these parameters

ITI_mean = .500;
ITI_std = .150;



%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Display parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%


% This is the font to use. 

text_font = 'Courier';


% The font size to use.

text_size = 30;


% These control the color of the words and the background. It's probably
%   best to make them different. The format is [R G B] with each ranging from
%   0 (black) to 255 (white). Note, using white as the background tends to
%   be too bright for subjects.

text_color = [255 255 255];
background_color = [128 128 128];



%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Response parameters
%
%%%%%%%%%%%%%%%%%%%%%%%%


% Set this to one to use sound as the response trigger
use_sound_response = 1;

% When using sound, this controls the volume to trigger at
sound_trigger_volume = .02;

% This controls how long the response is recorded for
sound_response_time = .7;



% This line runs the experiment
LexDec_Experiment(subject_name, stim_list, practice_list, num_blocks, is_in_MEG, run_practice, ...
    run_experiment, randomize_practice_stims, randomize_experiment_stims,...
    use_feedback, fixation_time, ISI, target_timeout, ITI_mean, ITI_std, ...
    text_font, text_size, text_color, background_color,...
    use_sound_response, sound_trigger_volume, sound_response_time)






