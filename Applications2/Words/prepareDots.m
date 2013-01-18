function [dp] = prepareDots(sp, dp, formInd)

%% Dot lifetimes
% Start dots off with random ages
dp.dotLife = sp.dotLife;
if(dp.dotLife>0)
    dp.dotAge = ceil(rand(dp.numDots,1)*dp.dotLife)-1;
else
    % Make it infinite
    dp.dotAge = [];
end

%% Compute the x and y direction displacements
% There is a single signal direction.   We create a vector of random directions that
% we will sample later
% xDir =  sin(2*pi*(1:sp.numDir)/sp.numDir)*sp.dotDisplacement;
% yDir = -cos(2*pi*(1:sp.numDir)/sp.numDir)*sp.dotDisplacement;
% Flipped so it chooses left or right instead of up or down when numDir=2
xDir = -cos(2*pi*(1:sp.numDir)/sp.numDir)*sp.dotDisplacement;
yDir =  sin(2*pi*(1:sp.numDir)/sp.numDir)*sp.dotDisplacement;
xDir = xDir';
yDir = yDir';

% These are the displacements of the dots
% pi/180 converts degrees into radians
dp.xDisp = sin(pi*(sp.dotDir(formInd+1)/180))*sp.dotDisplacement;
dp.yDisp = -cos(pi*(sp.dotDir(formInd+1)/180))*sp.dotDisplacement;

% Randomly select (x,y) positions of the dots for the form
dp.xPos = ceil(rand(dp.numDots,1)*dp.stimWide)-1;
dp.yPos = ceil(rand(dp.numDots,1)*dp.stimHigh)-1;

% vector of indices specifying the noise dot velocities
dp.index = ceil(rand(dp.motNumNoise,1)*sp.numDir);
dp.randX = xDir(dp.index);
dp.randY = yDir(dp.index);