function LexDec_w_Prime_Experiment(subject, stim_list, practice_list, num_blocks, is_in_MEG, run_practice, ...
    run_experiment, randomize_practice_stims, randomize_experiment_stims, ...
    use_feedback, fixation_time, ISI, target_timeout, ITI_mean, ITI_std, ...
    text_font, text_size, text_color, background_color,...
    use_sound_response, sound_trigger_volume, sound_response_time, prime_time, prime_ISI, is_debugging)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: LexDec_Experiment.m
%
% Runs a simple lexical decision experiment. 
%
% Arguments
%	- subject: The subject id (can be any string)
%   - num_blocks: The number of blocks to split the stimuli into
%   - is_in_MEG: 1 if the subject is in the MEG, 0 otherwise
%   - run_practice: Set to 1 to run the practice.
%   - run_experiment: Set to 1 to run the experiment.
%   - randomize_practice_stims: Set to 1 to randomize the practice.
%   - randomize_experiment_stims: Set to 1 to randomize the experiment.
%   - use_feedback: Set to 1 to use feedback during the practice. 
%   - fixation_time: The time to show the cross for.
%   - ISI: The time in between the cross and word.
%   - target_timeout: The time to respond (set to -1 to disable).
%   - ITI_mean: The mean ITI time.
%   - ITI_std: The standard deviation for the ITI normal distribution.
%   - text_font: The font to use.
%   - text_size: The size of the text.
%   - text_color: The color for the text.
%   - background_color: The screen color 
%   - use_sound_response: Set to 1 to use sound as the response.
%   - sound_trigger_volume: The volume to trigger at when using sound.
%   - prime_time: The time for the prime.
%   - prime_ISI: The time between the prime and the target.
%   - is_debugging: Set to 1 to run in debug mode (Optional: Defaults to 0)
%
% Usage
%    LexDec_Experiment('Subj_Label',3,0)
%
% Stimulus Lists
%   -   Stimuli lists should be .txt files with the following columns,
%   separated by tabs. 
%    -   There should be no header row in the file
%   unique ID, condition name, item number, target stimulus, fixation trigger,
%   target trigger
%   -   Unique ID should be a number unique to each individual stimulus
%   (while item number might be shared by a set of matched stimuli)
%
%   e.g.:
%  1    word	1	this	1	8	
%  2     nonword	1	smurb	2	9	
%
%
% Author: Doug Bemis (adapted from code by Jon Brennan adapted from code
%   by Doug Bemis)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% PLEASE NOTE: If you are running this 
% using Run_LexDec_Experiment.m, you
% are not intended to modify this code.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%















% Global variable declarations
global GL_word_key;
global GL_nonword_key;
global GL_exit_key;
global GL_fixation_time;       
global GL_ISI;                      
global GL_target_timeout; 
global GL_ITI_mean; 
global GL_ITI_std; 
global GL_vertical_offset;
global GL_trigger_delay;
global GL_use_timeout;
global GL_prime_ISI;
global GL_prime_time;
global GL_response_time;



% Timing parameters. These control the structure of the trial and are in
% seconds. The structure of each trial is: fixation cross, blank screen,
% stimulus. The stimulus remains onscreen until either the subject responds
% or is deemed to have fallen asleep (i.e. the timeout is reached). If you
% don't like this structure, as always, you are free to write your own
% script.

% This is how long the initial fixation cross is on for. 
GL_fixation_time = fixation_time; 

% This is the length of the blank screen between the fixation cross and the word.
GL_ISI = ISI;

% For primes
GL_prime_time = prime_time;
GL_prime_ISI = prime_ISI;

% This is the time limit to respond. For no timeout, try setting this to
% eleventy billion.
if target_timeout < 0
    GL_use_timeout = 0;
else
    GL_use_timeout = 1;
end
GL_target_timeout = target_timeout;    

% This controls the time in between trials. It should be 
% random if you want your experiment to be any good at all. 
% This is the mean and standard deviation for the ITI. We're
% using a normal distribution below to sample from...
GL_ITI_mean = ITI_mean;
GL_ITI_std = ITI_std;




% Some instructions. While it's fun to throw subjects in the machine and
% watch them desparetly flail about trying to figure out what to do, it's
% probably not advisable until you're at least in your third year. Making
% these informative can help.

% This comes up before the practice.
 practice_instructions = {'The practice is about to begin.', ...
            'If the text forms a word', ... 
            'Respond with your index finger.',...
            'If the text does not form a word',...
            'Respond with your middle finger.', ' ',};

% This comes up before the experiment.
 main_instructions = {'The experiment is about to begin.', ...
            'If the text forms a word', ... 
            'Respond with your index finger.',...
            'If the text does not form a word',...
            'Respond with your middle finger.', 'Press any key to begin.',' ',};

% This fools the subject, who will probably miss the modifier 'main' and
% will think they're leaving soon.
if is_in_MEG
    end_comment = {'The main experiment is now over.',...
            'Please lie still as we save the data.', ...
            'The experimenter will be in shortly.'};
else
    end_comment = {'The main experiment is now over.'};    
end

% MEG settings. These exist in order to counteract the foibles of our MEG
% machine. 


% Despite the fact that everything should move around the system like
% well-oiled lightning, there's a screw loose somewhere, and so there's a
% small delay between when the trigger gets to the machine and when the
% subject sees a display. You can correct this with the parameter below.
% This is not quite as big a problem as you might fear, because, if you
% think a 6 ms delay is your biggest source of error in an MEG experiment,
% you're living in a dream world.
% NOTE: You can and should check this before your experiment. Ask Jeff
% (disclaimer - this solution only works at the NYU KIT lab)
GL_trigger_delay = 0.006;



% This will exit the program if used as a response. This probably shouldn't
% be the same as either of the response keys, but that's your choice.
GL_exit_key = 'q';


% Only send triggers if we're in the MEG
global GL_send_triggers;
if is_in_MEG
    GL_send_triggers = 1;
    GL_vertical_offset = -100; 
    PTBSetInputCollection('Char');
    GL_word_key = '2';
    GL_nonword_key = '1';
else
    GL_send_triggers = 0;
    GL_vertical_offset = 0; 
    PTBSetInputCollection('Queue');
    GL_word_key = '2';
    GL_nonword_key = '1';
end
GL_response_time = .1;

% Set this no matter what. Can't hurt.
if use_sound_response
    GL_word_key = 'sound';
    GL_nonword_key = 'sound';  
    GL_response_time = sound_response_time;
end

% Make sure we're up to date enough
PTBVersionCheck(1,1,14,'at least');

%   Set the background color & text color
PTBSetBackgroundColor(background_color); % default: grey
PTBSetTextColor(text_color); % default: white
PTBSetTextSize(text_size);
PTBSetTextFont(text_font);


%   Where to write out the logs. This will give
%   you all the information about what was displayed (log.txt)
%   and what the responses were (data.txt).
PTBSetLogFiles([subject '_log.txt'], [subject '_data.txt']);

%   If this is set to 1, the display will not take up the
%   whole screen. 
if exist('is_debugging','var') && is_debugging
    PTBSetIsDebugging(1);
    Screen('Preference', 'SkipSyncTests', 1);
end
    
%   Set the input option
%   NOTE: Only Char seems to work for the MEG right now.
%   NOTE: This collection response only records alphanumeric keys.
collection_type = 'Char';
PTBSetInputCollection(collection_type);

%   The inputs 
%   NOTE: Might need to switch these - depends on 
%   the USB ports, etc....
keyboard_id = 2;
button_box_id = 1;

% Set the exit key.
PTBSetExitKey(GL_exit_key);


% `These global variables may be useful
% `Uncomment as needed

global PTBLastKeyPressTime;				  % When the last response was given.
%global PTBScreenRes;                          % Has 'width' and 'height' of current display in pixels 
%global PTBLastKeyPress;                    % The last response given.
%global PTBLastPresentationTime;        % When the last display was presented.

feedback_time = 1;
start_block = 1;

% Use the start screen for now
PTBSetUseStartScreen(1);

% Set some headers for the output files
PTBSetLogHeaders({'block_type','stim_list','id','answer','prime','target'});

% Automatically split into blocks so the experimenter doesn't have to worry
% about it.
block_stims = blockStims(stim_list, num_blocks, randomize_experiment_stims);
practice_stims = blockStims(practice_list,1,randomize_practice_stims);

% Run the experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('LexDec_Experiment');
    
    % Set this up now, so it'll have an effect
    PTBSetSoundKeyLevel(sound_trigger_volume);
	
    % This gives time to get the program up and going
    PTBDisplayBlank({.3},'');
    	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do the practice first, if we have some
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if run_practice

        % Change the input, if necessary
        if is_in_MEG        
            PTBSetInputDevice(button_box_id);
        end

        % Give a screen
        paragraph = practice_instructions;
        if use_feedback
            paragraph{end+1} = 'You will receive feedback'; 
        else
            paragraph{end+1} = 'You will not receive feedback';
        end
        paragraph{end+1} = 'Press any key to begin.'; 
        PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});

        % Get the initial start time
        PTBDisplayBlank({.5},'');
        start_time = PTBLastKeyPressTime + .5;

        % Read through each trial
        for t = 1:length(practice_stims{1})
            PTBSetLogAppend(1,'clear',{'practice', practice_list, num2str(practice_stims{1}{t}{1}), practice_stims{1}{t}{2}, ...
                practice_stims{1}{t}{4}, practice_stims{1}{t}{5}});
            if use_sound_response
                PTBSetAudioTriggerFileName(practice_stims{1}{t}{5});
            end
            [response start_time] = performTrial(start_time, practice_stims{1}{t}{4}, practice_stims{1}{t}{5}, ...
                practice_stims{1}{t}{6}, practice_stims{1}{t}{7}, practice_stims{1}{t}{8});

            % Give some feedback, if we want
            if use_feedback
                if (strcmp(practice_stims{1}{t}{2},'word') && strcmpi(response, GL_word_key)) ||...
                        (strcmp(practice_stims{1}{t}{2},'nonword') && strcmpi(response, GL_nonword_key))
                    PTBDisplayText('Correct!', {'center',[0 GL_vertical_offset]},{feedback_time});
                else
                    PTBDisplayText('Incorrect.', {'center',[0 GL_vertical_offset]},{feedback_time});
                end
                PTBDisplayBlank({.5},'');
                start_time = start_time + feedback_time + 0.5;
            end
        end

        % Give a screen, if done.
        PTBDisplayParagraph({'The practice is now over.'}, {'center', 30}, {'any'});
        PTBDisplayBlank({.5},'');

        % Change the input, if necessary
        if is_in_MEG        
            PTBSetInputDevice(keyboard_id);
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do the experiment 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if run_experiment

        % Start the triggers
        if is_in_MEG
            PTBInitUSBBox;
            PTBDisplayParagraph({'Please lie still as we start the recording.'}, {'center', 30}, {'a'});
        end

        % Time to start the recording
            paragraph = main_instructions;
        PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});

        % Change the input, if necessary
        if is_in_MEG
            PTBSetInputDevice(button_box_id);
        end

        % Go through each block
        for i = start_block:num_blocks

            % Give a screen
            PTBDisplayParagraph({['Block number ' num2str(i) ' is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});

            % Get the initial start time
            PTBDisplayBlank({.5},'');
            start_time = PTBLastKeyPressTime + .5;

            % Go through each trial
            for t = 1:length(block_stims{i})
                PTBSetLogAppend(1,'clear',{'experiment', stim_list, num2str(block_stims{i}{t}{1}), block_stims{i}{t}{2}, ...
                    block_stims{i}{t}{4}, block_stims{i}{t}{5}});
                if use_sound_response
                    PTBSetAudioTriggerFileName(block_stims{i}{t}{5});
                end
                [response start_time] = performTrial(start_time, block_stims{i}{t}{4}, block_stims{i}{t}{5}, ...
                    block_stims{i}{t}{6}, block_stims{i}{t}{7}, block_stims{i}{t}{8}); %#ok<ASGLU>
            end

            % Give a screen
            PTBDisplayParagraph({['Block ' num2str(i)  ' of ' num2str(num_blocks) ' is now over.'], 'Press any key to continue.'}, {'center', 30}, {'any'});
            PTBDisplayBlank({.5},'');
        end

        % Change the input, if necessary
        if is_in_MEG
            PTBSetInputDevice(keyboard_id);
        end

        % The end screens 
        PTBDisplayParagraph(end_comment,...
            {'center', 30}, {'a'});

        % Quick blank to make sure the last screen stays on
        PTBDisplayBlank({.1},'');
    end
    
	% Have to have a final screen, to catch any last responses.
	PTBDisplayText('The end.',{'center'},{2});
	PTBDisplayBlank({.1},'Final Screen');
	
	% And finish up. This should always be the last call.
	% It closes the screen and sets everything back to how it was.
    PTBCleanupExperiment;

% This catch, plus PTBHandleError call allows matlab
% to recover when psychtoolbo crashes. Keep this
% in, with the try call above.

catch %#ok<CTCH>
	PTBHandleError;
end

end

%%%%%% END MAIN EXPERIMENT CODE %%%%%%%%%

%%%%%%%%% BEGIN HELPER FUNCTIONS %%%%%%%%
% Do not edit this code unless you know what you
% are doing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% performTrial: displays a single trial 
function [response end_time] = performTrial(start_time, prime_stim, target_stim, f_trig, p_trig, t_trig)

% Trial parameters

global GL_word_key;
global GL_nonword_key;
global GL_vertical_offset;
global GL_fixation_time;
global GL_prime_time;
global GL_ISI;
global GL_prime_ISI;
global GL_trigger_delay;
global GL_ITI_mean;
global GL_ITI_std;
global GL_target_timeout
global GL_send_triggers;
global GL_use_timeout;
global GL_exit_key;
global GL_response_time;

% set current ITI
this_iti = GL_ITI_std*randn+GL_ITI_mean;

% Show a cross first
end_time = start_time + GL_fixation_time;
if GL_send_triggers
    PTBDisplayText('+', {'center', [0 GL_vertical_offset]},{end_time}, f_trig, GL_trigger_delay);
else
    PTBDisplayText('+', {'center', [0 GL_vertical_offset]},{end_time});
end

% Then a blank
end_time = end_time + GL_ISI;
PTBDisplayBlank({end_time,'exit'},'ISI');

% Show the prime
end_time = end_time + GL_prime_time;
if GL_send_triggers
    PTBDisplayText(prime_stim, {'center', [0 GL_vertical_offset]},{end_time}, p_trig, GL_trigger_delay);
else
    PTBDisplayText(prime_stim, {'center', [0 GL_vertical_offset]},{end_time});
end

% Then a blank
end_time = end_time + GL_prime_ISI;
PTBDisplayBlank({end_time},'ISI');

% And the target
if GL_use_timeout
    if GL_send_triggers
        PTBDisplayText(target_stim, {'center', [0 GL_vertical_offset]}, ...
            {GL_word_key, GL_nonword_key, GL_target_timeout, GL_exit_key},t_trig, GL_trigger_delay);
    else
        PTBDisplayText(target_stim, {'center', [0 GL_vertical_offset]}, ...
            {GL_word_key, GL_nonword_key, GL_target_timeout, GL_exit_key});    
    end
else
    if GL_send_triggers
        PTBDisplayText(target_stim, {'center', [0 GL_vertical_offset]}, ...
            {GL_word_key, GL_nonword_key, GL_exit_key},t_trig, GL_trigger_delay);
    else
        PTBDisplayText(target_stim, {'center', [0 GL_vertical_offset]}, ...
            {GL_word_key, GL_nonword_key, GL_exit_key});    
    end    
end


% Quick screen to get the response time
PTBDisplayBlank({GL_response_time},'Response_Catcher');
global PTBLastKeyPressTime;
global PTBLastKeyPress;

% And the final blank
% set end_time based on key press time, if available

if strcmpi(PTBLastKeyPress, 'TIMEOUT')
    end_time = end_time + GL_target_timeout + GL_response_time + this_iti;
else    
    end_time = PTBLastKeyPressTime + GL_response_time + this_iti; % .1 is to prevent rounding errors
end

PTBDisplayBlank({end_time},'ITI');

% Record the response
response = PTBLastKeyPress;

end



% Helper to randomize and block the stims
function block_stims = blockStims(stim_list, num_blocks, randomize)

all_stims = {};
fid = fopen(stim_list);
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    [uniqueid condition item_num prime target f_trig p_trig t_trig] = ...
        strread(line,'%f%s%f%s%s%f%f%f','delimiter','\t'); %#ok<REMFF1>
    all_stims{end+1} = {uniqueid condition{1} item_num prime{1} target{1} f_trig p_trig t_trig}; %#ok<AGROW>
end
fclose(fid);

% Split into blocks and randomize
if randomize
    order = randperm(length(all_stims));
else
    order = 1:length(all_stims);
end
block_num = 0;
block_stims = {};
for i = 1:length(all_stims)
    if mod(i,ceil(length(all_stims)/num_blocks)) == 1
        block_num = block_num+1;
        block_stims{block_num} = {}; %#ok<AGROW>
    end
    block_stims{block_num}{end+1} = all_stims{order(i)}; %#ok<AGROW>
end

end



