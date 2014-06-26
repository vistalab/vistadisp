%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: SpecModHead
%
% Runs the SpecModHead experiment
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%	- is_outside: Set to 1 if outside the MEG. This will just run the
%		first practice with and without feedback. 0 will run both tasks
%		with a practice run and no feedback at the beginning and
%		two practice runs for the second task.
%   - use_eyetracker : Set to 1 if using eyetracker, else 0.
%
% Usage: SpecModHead('R0001',1,0)
%
% Author: Paul + LinMin
% Date: 6/3/13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SpecModHead(subject,is_outside, use_eyetracker)

% Parse the arguments

if nargin < 3
    
    use_eyetracker = 0;
end

if nargin < 2
    is_outside = 0;
end

subject_dir = [subject '_logs'];

if not(exist(subject_dir, 'dir'))
    mkdir(subject_dir)
end


% The inputs
% NOTE: Might need to switch these - depends on
% the USB ports, etc....
keyboard_id = 2;
button_box_id = 1;

% Make sure we're compatible
PTBVersionCheck(1,1,6,'at least');

% % NOTE: Might need this, if you run from the
% % debugger (i.e. Fn+F5)
% Screen('Preference', 'SkipSyncTests', 1);

% Set to debug, if we want to.
%PTBSetIsDebugging('1');

% Only Char seems to work for
% the MEG right now.
collection_type = 'Char';
PTBSetInputCollection(collection_type);

% Set the exit key.
if strcmp(collection_type, 'Char')
    PTBSetExitKey('0');
else
    PTBSetExitKey('ESCAPE');
end

% Where to write out the logs.
% NOTE: Set the keyfile name in order to log all the TRs
PTBSetLogFiles([subject_dir filesep subject '_log.txt'], [subject_dir filesep subject '_data.txt']);


% Experiment parameters


% The tasks and conditions.
% The conditions have the condition labels, followed
% by the fixation, initial, and target triggers.
% Lastly, there are the task (99 if there is, 0 if there isn't)
%
% conditions = {'spec_one', 'spec_two', 'basic_one', 'basic_two'};
%
% triggers = {2,4,8,16};
%
% blink_trigger = 20;

%create new stimulus files for this subject

% Number of blink trials at end
num_blinks = 0;


% Number of blocks to split the stimuli into
start_block = 1;
num_blocks = 12;

%   Set the response keys
%   NOTE: if you are NOT using this script with MEG, see below for more
%   response collection options


% Display timing
global GL_word_time;
global GL_question_timeout;
global GL_ISI_time;
global GL_fixation_time;
feedback_time = 1;


GL_word_time = .300;        % display duration for each word
GL_fixation_time = 0.300;   % display duration for fixation
GL_question_timeout = [];       % display duration for questions, in seconds ([] means no timeout)
GL_ISI_time = .300;

% Picture placement parameters.
global GL_vertical_offset;
GL_vertical_offset = -100;

% Response keys
global GL_same_key;
global GL_different_key;
if strcmp(collection_type, 'Char')
    GL_same_key = '2';
    GL_different_key = '1';
else
    GL_same_key = '2@';
    GL_different_key = '1!';
end

% TODO: Test the trigger delays
global GL_trigger_delay;
GL_trigger_delay = 0.006;

% Don't use the start screen for now
PTBSetUseStartScreen(1);

% Use gray
PTBSetBackgroundColor([128 128 128]);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
% Screen('Preference', 'SkipSyncTests', 1);


% Set the appropriate parameters
if is_outside
    give_feedback = 1;
    use_eyetracker =0;
    % How much practice
    num_practice_trials = 12;
    
else
    
    give_feedback = 0;
    num_practice_trials = 10;
end

%key press information
global PTBScreenRes;
global PTBTheWindowPtr;
global PTBLastKeyPressTime;
global GL_picture_position;
global GL_square_position;
% Let's try our experiment

try
    
    % First, prepare everything to go
    PTBSetupExperiment('SpecModHead');
    
    if use_eyetracker
        PTBInitEyeTracker();
        paragraph = {'Eyetracker initialized.','Get ready to calibrate.'};
        PTBDisplayParagraph(paragraph, {'center',30}, {'a'});
        PTBCalibrateEyeTracker;
        
        % actually starts the recording
        % name correponding to MEG file (can only be 8 characters!!, no extension)
        PTBStartEyeTrackerRecording('eyelink');
        
    end
    
    
    
    
    GL_picture_position = [PTBScreenRes.width/2, PTBScreenRes.height/2 + GL_vertical_offset];
    GL_square_position =   [75, PTBScreenRes.height/3*2];
    
    
    % This gives time to get the program up and going
    init_blank_time = 1;
    PTBDisplayBlank({init_blank_time},'');
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do the practice first
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if num_practice_trials > 0 && is_outside
        trial_number = 1;
        
        
        % Might be giving feedback
        for feedback = give_feedback
            
            %to randomize
            
            practice_fname = randomizeStims('practice', subject);
            
            % Change the input, if necessary
            if ~is_outside
                PTBSetInputDevice(button_box_id);
            end
            
            % Give a screen
            paragraph = {'The practice is about to begin.', ...
                'You will read words or 2-word phrases on the screen.',...
                'Sometimes a phrase will follow,', ...
                'If the following phrase matches the preceding phrases,',...
                'respond with your index finger.',...
                'If it is not,',...
                'respond with your middle finger.', ' ',};
            if feedback
                paragraph{end+1} = 'You will receive feedback';
            else
                paragraph{end+1} = 'You will not receive feedback';
            end
            paragraph{end+1} = 'Press any key to begin.';
            PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});
            
            % Get the initial start time
            PTBDisplayBlank({.5},'Response_Catcher');
            start_time = PTBLastKeyPressTime + .1 + GL_ISI_time;
            
            % Read through each trial
            fid = fopen([practice_fname '.txt']);
            
            while 1
                line = fgetl(fid);
                if ~ischar(line)
                    break;
                end
                
                
                % Parse the next one
                
                
                [condition item_num modifier headw question mod_trig headw_trig answer] = ...
                    strread(line,'%s%f%s%s%s%f%f%s','delimiter',';');
                PTBSetLogAppend(1,'clear',{'practice', condition{1}, num2str(item_num), modifier{1}, headw{1}, ...
                    question{1}, num2str(mod_trig),num2str(headw_trig),answer{1}});
                [response start_time] = performTrial(start_time, modifier{1},...
                    headw{1}, mod_trig, headw_trig, question{1},trial_number);
                trial_number = trial_number + 1;
                
                % Give some feedback, if we want
                if feedback
                    if (strcmp(answer{1},'Y') && strcmpi(response, GL_same_key)) ||...
                            (strcmp(answer{1},'N') && strcmpi(response, GL_different_key))
                        PTBDisplayText('Correct!', {'center',[0 GL_vertical_offset]},{feedback_time});
                    elseif strcmp(answer{1},'_')
                        PTBDisplayBlank({.5},'');
                    else
                        PTBDisplayText('Incorrect.', {'center',[0 GL_vertical_offset]},{feedback_time});
                    end
                    PTBDisplayBlank({.5},'');
                    start_time = start_time + feedback_time + 0.5;
                end
            end
            fclose(fid);
            
            
            % Give a screen, if done.
            if feedback == 0
                PTBDisplayParagraph({'The practice is now over.', 'Press any key to continue'}, {'center', 30}, {'any'});
            end
            PTBDisplayBlank({.5},'');
        end
        
        % Change the input, if necessary
        if ~is_outside
            PTBSetInputDevice(keyboard_id);
        end
    end
    
    % End here, if outside
    if is_outside
        PTBCleanupExperiment;
        return;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do the experiment
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Start the triggers
    % 		PTBInitUSBBox;
    PTBInitStimTracker;
    
    % Time to start the recording
    PTBDisplayParagraph({'Please lie still as we start the recording.'}, {'center', 30}, {'a'});
    paragraph = {'The experiment is about to begin.', ...
        'You will read words or 2-word phrases on the screen',...
        'sometimes a phrase will follow',...
        'If the following phrase matches the preceding phrases,',...
        'respond with your index finger.',...
        'If it does not,',...
        'respond with your middle finger.', ' ', 'Press any key to continue' };
    PTBDisplayParagraph(paragraph, {'center', 30}, {'any'});
    
    
    % Change the input, if necessary
    if ~is_outside
        PTBSetInputDevice(button_box_id);
    end
    
    
    %randomize block order
    
    block_random_order = randperm(num_blocks);
    
    %write block presentation order to file for future reference
    
    new_filename = [subject '_' 'rand_block_order'];
    fid = fopen([new_filename '.txt'], 'w+');
    fprintf(fid, '%f\n', block_random_order);
    trial_number = 1;
    
    % Go through each block
    for i = start_block:num_blocks
        
        
        %to randomize
        
        list_fname = randomizeStims(['block_' num2str(block_random_order(i))], subject);
        
        % Give a screen
        PTBDisplayParagraph({['Block number' num2str(i) ' is about to begin.'], 'Press any key to begin.'}, {'center', 30}, {'any'});
        
        % Get the initial start time
        PTBDisplayBlank({.5},'');
        start_time = PTBLastKeyPressTime + .5;
        
        % Read through each trial
        fid = fopen([list_fname '.txt']);
        while 1
            line = fgetl(fid);
            if ~ischar(line)
                break;
            end
            
            % Parse the next one
            [condition item_num modifier headw question mod_trig headw_trig answer] = ...
                strread(line,'%s%f%s%s%s%f%f%s','delimiter',';');
            PTBSetLogAppend(1,'clear',{'practice', condition{1}, num2str(item_num), modifier{1}, headw{1}, ...
                question{1}, num2str(mod_trig),num2str(headw_trig),answer{1}});
            [response start_time] = performTrial(start_time, modifier{1},...
                headw{1}, mod_trig, headw_trig, question{1},trial_number);
            trial_number = trial_number + 1;
        end
        fclose(fid);
        
        % Give a screen
        PTBDisplayParagraph({['Block ' num2str(i)  ' of ' num2str(num_blocks) ' is now over.'], 'Press any key to continue.'}, {'center', 30}, {'any'});
        PTBDisplayBlank({.5},'');
    end
    
    % Change the input, if necessary
    if ~is_outside
        PTBSetInputDevice(keyboard_id);
    end
    
    % The end screens
    PTBDisplayParagraph({'The task is now over.','Please lie still as we save the data.'},...
        {'center', 30}, {'a'});
    
    % Quick blank to make sure the last screen stays on
    PTBDisplayBlank({.1},'');
    
    
    %%%%%%%%
    %Blink Block
    %%%%%%%%%%%
    
    
    %     % Time to start the recording
    % 	paragraph = {'A quick blink block is about to begin.','Just blink naturally when the cross disappears.'};
    % 	PTBDisplayParagraph(paragraph, {'center', 30}, {'a'});
    %
    % 	% Do the blink block
    % 	for i = 1:num_blinks
    % 		performBlinkTrial(blink_trigger);
    % 	end
    %
    % 	% And done
    %
    % 	% Quick blank to make sure the last screen stays on
    % 	PTBDisplayBlank({.1},'');
    %
    
    if use_eyetracker
        
        % retrieve the file
        PTBDisplayParagraph({'The experiment is now over.','Please lie still while we save the data.'}, {'center', 30}, {.1});
        PTBStopEyeTrackerRecording; % <----------- (can take a while)
        
        % move the file to the logs directory
        destination = [subject_dir filesep subject '_eyelink_'];
        i = 0;
        while exist([destination num2str(i) '.edf'], 'file')
            i = i + 1;
        end
        movefile('eyelink.edf', [destination num2str(i) '.edf'])
        
    end
    
    
    PTBDisplayParagraph({'The experiment is now over.','We will be in shortly.'}, {'center', 30}, {'a'});
    
    % And finish up
    PTBCleanupExperiment;
    
catch
    PTBHandleError;
end


% Helper Functions

% Show one trial
function [response end_time] = performTrial(start_time,modifier,...
    headw, mod_trig, headw_trig, question, trial_number)

% Trial parameters
global GL_fixation_time;
global GL_vertical_offset;
global GL_trigger_delay;
global GL_iti_time;
global GL_word_time;
global GL_same_key;
global GL_different_key;
global PTBLastKeyPressTime;
global PTBLastKeyPress;
global GL_ISI_time;
global GL_picture_position;
global GL_square_position;
global PTBScreenRes;
global PTBTheWindowPtr;


timing_check_size = 30; % size of the square displayed for the phoho-diode
timing_check_ypos = round(PTBScreenRes.height / 4 * 3);
timing_check_pos = [0, ...
    timing_check_ypos - timing_check_size, ...
    timing_check_size, ...
    timing_check_ypos];

%set iti time to be normally distributed around .4 with s.d of .1


    

end_time = start_time;

modulus = mod(trial_number,3);
if  modulus == 2
    end_time = end_time + .75;
    PTBDisplayText('BLINK',{'center',[0 GL_vertical_offset]},{end_time});
    end_time = end_time + GL_ISI_time;
    PTBDisplayBlank({end_time},'ISI');
end


% blink_option = randi(3);
% 
% if blink_option ==1
%     end_time = end_time + .75;
%     PTBDisplayText('BLINK',{'center',[0 GL_vertical_offset]},{end_time});
% end


GL_iti_time = .4 + .1*randn;

% % Show a fixation cross first
end_time = end_time + GL_fixation_time;
%
% PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {end_time});
% PTBDisplayText('+++',{'center',[0 GL_vertical_offset]},{end_time});
% 
% end_time = end_time + GL_ISI_time;
% 
% PTBDisplayBlank({end_time},'ISI');
% 
% end_time = end_time + GL_fixation_time;

%
% PTBDisplayPictures({'Photo_Square.jpg'},{timing_check_pos},{.5},{-1},'Photo');
% % % Screen('DrawTexture', PTBTheWindowPtr, timing_check_ID, ...
% % %       [], timing_check_pos, [], [], [], [255,255,255]);
PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {end_time});


% Then a blank
end_time = end_time + GL_ISI_time;
%
PTBDisplayBlank({end_time},'ISI');
% PTBDisplayBlank({GL_ISI_time},'ISI');

%show the words
end_time = end_time + GL_word_time;

PTBDisplayText(modifier,{'center', [0 GL_vertical_offset]}, {end_time},mod_trig,GL_trigger_delay);
%PTBDisplayPictures({'Photo_Square.jpg'},{timing_check_pos},{.5},{-1},'Photo');
% Screen('DrawTexture', PTBTheWindowPtr, timing_check_ID, ...
%       [], timing_check_pos, [], [], [], [255,255,255]);
%PTBDisplayText(first_stim,{'center', [0 GL_vertical_offset]}, {end_time});

end_time = end_time + GL_ISI_time;

PTBDisplayBlank({end_time},'ISI');

% PTBDisplayBlank({GL_ISI_time},'ISI');

end_time = end_time + GL_word_time;

% PTBDisplayText(target_stim,{'center', [0 GL_vertical_offset]}, {end_time},...
%     t_trig, GL_trigger_delay);
%PTBDisplayPictures({'Photo_Square.jpg'},{timing_check_pos},{.5},{-1},'Photo');
% Screen('DrawTexture', PTBTheWindowPtr, timing_check_ID, ...
%       [], timing_check_pos, [], [], [], [255,255,255]);
PTBDisplayText(headw,{'center', [0 GL_vertical_offset]}, {end_time},...
    headw_trig, GL_trigger_delay);

%ISI
%
end_time = end_time + GL_ISI_time;

PTBDisplayBlank({end_time},'ISI');
%
%         PTBDisplayBlank({GL_ISI_time},'ISI');

% PTBDisplayText(first_stim,{'center', [0 GL_vertical_offset]}, {.3},...
%     f_trig, GL_trigger_delay);
% PTBDisplayBlank({.3},'ISI');
%
% PTBDisplayText(target_stim,{'center', [0 GL_vertical_offset]}, {.3},...
%     t_trig, GL_trigger_delay);
% PTBDisplayBlank({.3},'ISI');
response = 'NA';

% Set 'response' to a sensible default

if ~strcmp(question,'_')
    question = [upper(question) '?'];
    PTBDisplayText(question,{'center',[0 GL_vertical_offset]}, {GL_same_key, GL_different_key});
    PTBDisplayBlank({.4},'Response_Catcher');
    response = PTBLastKeyPress;
    end_time = PTBLastKeyPressTime + .1 + GL_iti_time;
    PTBDisplayBlank({end_time},'ITI');
else
    end_time = end_time + GL_iti_time;
    PTBDisplayBlank({end_time},'ITI');
     response = 'NA';
end




%
%         %play image
%
%         PTBDisplayPictures({'Photo_Square.jpg'},{timing_check_pos},{.5},{-1},'Photo');
% % Screen('DrawTexture', PTBTheWindowPtr, timing_check_ID, ...
% %       [], timing_check_pos, [], [], [], [255,255,255]);
%     PTBDisplayPictures({image},{GL_picture_position},...
%         {[150 150]},{GL_same_key, GL_different_key}, 'image',task_trig, GL_trigger_delay);
%

% Quick screen to get the response time


% end_time = PTBLastKeyPressTime + .4;
%

% And the final blank

% end_time = end_time + GL_iti_time;

% PTBDisplayBlank({end_time},'ITI');
% PTBDisplayBlank({GL_iti_time},'ITI');



% Make people blink
function performBlinkTrial(b_trigger)

% Put the cross on and off
global GL_vertical_offset;
PTBDisplayText('+',{'center', [0 GL_vertical_offset]}, {1});
PTBDisplayBlank({1}, 'Blink_Break', b_trigger);




%%%%%%%
% randomizeStims: reads the stims for the current block and writes out a new
%   textfile with the stims in a randomized order
%   returns the filename of the new file (minus extension)
%


function [new_filename] = randomizeStims(fname, subject)

randstims = cell(1);
stimnum = 0;
fid = fopen([fname '.txt']);
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    stimnum = stimnum + 1;
    randstims{stimnum} = line;
end

fclose(fid);
order = randperm(stimnum);
new_filename = [subject '_' fname '_rand'];
fid = fopen([new_filename '.txt'], 'w+');
for i = 1:stimnum
    fprintf(fid, '%s\n', randstims{order(i)});
end







