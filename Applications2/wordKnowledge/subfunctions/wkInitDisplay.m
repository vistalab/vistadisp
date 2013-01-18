function display = wkInitDisplay

display = loadDisplayParams('displayName', 'HP LP2480zx.mat');
display = openScreen(display);
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames');
display.frameRate = 60;
display.distance = 40;
display.fixFirst = 1;
display.postTrialFix = 1;