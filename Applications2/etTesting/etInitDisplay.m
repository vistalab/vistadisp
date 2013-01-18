function display = etInitDisplay

display = loadDisplayParams('displayName', 'NEC485words.mat');
display.devices = getDevices; % needs to be run before openScreen, since it closes the screen
display = openScreen(display);

