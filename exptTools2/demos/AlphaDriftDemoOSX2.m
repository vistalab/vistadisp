function AlphaDriftDemoOSX2
%
% OS X: ___________________________________________________________________
%
% Display an animated grating using the new Screen('DrawTexture') command.
% In the OS X Psychtoolbox Screen('DrawTexture') replaces
% Screen('CopyWindow').     
%
% This illustrates an application of OpenGL Alpha blending by masking the moving
% grating with a gaussian transparency mask.
%
% In each frame, first the grating is drawn. Then a texture acting as a
% transparency mask is drawn "over" the grating, masking out selected
% parts of the grating.
%
% Please note that we only use two textures: One defining the static
% grating, the other defining the mask. We shift the grating below the
% mask to create the illusion of an endless grating. This is a nice
% "application" of the aperture problem in visual motion perception.
%
% See DriftDemoOSX for an illustration of the "old style" of doing this
% without OpenGL's Alpha-Blending.
%
% The old style would need *a lot* of system memory for precreating the
% whole animation in offscreen-windows or textures...
%
% OS 9 and WINDOWS : ______________________________________________________
%
% AlphaDriftDemoOSX does not exist on OS 9 and Windows.  See DriftDemo instead.
% _________________________________________________________________________
% 
% see also: PsychDemosOSX, MovieDemoOSX

% HISTORY
%  6/28/04    awi     Adapted from Denis Pelli's DriftDemo.m for OS 9 
%  7/18/04    awi     Added Priority call.  Fixed.
%  9/8/04     awi     Added Try/Catch, cosmetic changes to comments and see also.
%  1/4/05     mk      Adapted from awi's DriftDemoOSX.                 

try
	% This script calls Psychtoolbox commands available only in OpenGL-based 
	% versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
	% only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
	% an error message if someone tries to execute this script on a computer without
	% an OpenGL Psychtoolbox
	AssertOpenGL;
	
	% Get the list of screens and choose the one with the highest screen number.
	% Screen 0 is, by definition, the display with the menu bar. Often when 
	% two monitors are connected the one without the menu bar is used as 
	% the stimulus display.  Chosing the display with the highest dislay number is 
	% a best guess about where you want the stimulus displayed.  
	screens=Screen('Screens');
	screenNumber=max(screens);
	
	% Find the color values which correspond to white and black.  Though on OS
	% X we currently only support true color and thus, for scalar color
	% arguments,
	% black is always 0 and white 255, this rule is not true on other platforms will
	% not remain true on OS X after we add other color depth modes.  
	white=WhiteIndex(screenNumber);
	black=BlackIndex(screenNumber);
	gray=(white+black)/2;
	if round(gray)==white
		gray=black;
	end
	inc=white-gray;

    % Open a double buffered fullscreen window and draw a gray background 
	% and front and back buffers.
	w=Screen('OpenWindow',screenNumber, 0,[],32,2);
	Screen('FillRect',w, gray);
	Screen('Flip', w);
	Screen('FillRect',w, gray);
	
	% compute static grating and and convert it, stored in
	% MATLAB matrix, into a Psychtoolbox OpenGL texture using 'MakeTexture';
    s=200;
	[x,y]=meshgrid(-s:s, -s:s);
	angle=30*pi/180; % 30 deg orientation.
	f=0.05*2*pi; % cycles/pixel
    a=cos(angle)*f;
	b=sin(angle)*f;
    gratingtex=ones(2*s+1,2*s+1,1, 'uint8');
    m=sin(a*x+b*y);
    % We use a single layer luminance matrix of type uint8
    % just to illustrate the very fast MakeTexture path in this case.
    gratingtex=uint8(gray+inc*m);
    t1=GetSecs;
    % Build a single luminance grating texture:
    gratingtex=Screen('MakeTexture', w, gratingtex);
    t1=GetSecs - t1

    tavg=0;
    
    % We create a Luminance+Alpha matrix for use as transparency mask:

    % Layer 1 (Luminance) is filled with luminance value 'gray' of the
    % background.
    maskblob=ones(2*s+1, 2*s+1, 2, 'uint8') * gray;
    % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
    % mask.
    maskblob(:,:,2)=uint8(255 - exp(-((x/90).^2)-((y/90).^2))*255);

    % Build a single transparency mask texture:
    masktex=Screen('MakeTexture', w, maskblob);
    	
	% Run the movie animation for a fixed period.  
	movieDurationSecs=10;
	frameRate=Screen('FrameRate',screenNumber);
	if(frameRate==0)  %if MacOSX does not know the frame rate the 'FrameRate' will return 0. 
        frameRate=60;
    end

    movieDurationFrames=round(movieDurationSecs * frameRate);
	movieFrameIndices=mod(0:(movieDurationFrames-1), 100) + 1;

    priorityLevel=MaxPriority(w)
	Priority(priorityLevel)

    for i=1:movieDurationFrames
        t1=GetSecs;
        % Draw grating for current frame:
        xp=i-s;
        yp=0;
        Screen('DrawTexture', w, gratingtex, [], [xp yp xp+4*s yp+4*s]);

        % Overdraw -- and therefore alpha-blend -- with gaussian alpha
        % mask:
        Screen('DrawTexture', w, masktex, [], [s 0 4*s 3*s]);
        
        % Show result on screen:
        Screen('Flip', w);
        t1=GetSecs - t1;
        tavg=tavg+t1;
	end;
	Priority(0);

    tavg=tavg / movieDurationFrames
    
	%The same commands wich close onscreen and offscreen windows also close
	%textures.
	Screen('CloseAll');

catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..



    




