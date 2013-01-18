function display = ewInitDisplay

display = loadDisplayParams('displayName', 'HP LP2480zx.mat');%('builtin');%'tenbit');
display.devices = getDevices;
display = openScreen(display);

display.fixFirst = 0;
display.postTrialFix = 1;

return;

%linLength = 4;
%cirRadius = 1.2;
%display.CpixWidth = angle2pix(display,cirRadius); %(cirWidth/pix2angle(display,display.numPixels(1)))*display.numPixels(1);
%display.LpixWidth = angle2pix(display,linLength); %(degWidth/pix2angle(display,display.numPixels(1)))*display.numPixels(1);