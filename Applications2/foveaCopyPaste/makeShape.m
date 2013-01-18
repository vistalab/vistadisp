function [sm in] = makeShape(level, pair, stimsize, x, y, targetX, targetY)
% function that generates a shape
% 2 inputs: (1) 'pair' = integer from 1 to 16, specifying a pair of prototypes
%           (2) 'level' = number from 1 to 1000, specifying morph level between
%                       the first (1) and second (1000) prototypes
% output: 'sm' = "smooth" polygon that defines the shape (1901 x 2)
%          'g' = getframe
% Example:
%     level = 500;
%     pair = 1;
%     stimsize = 500;
%     [x, y] = meshgrid(1:stimsize, 1:stimsize);
%     targetX = stimsize/2;
%     targetY = stimsize/2;
%     [sm in] = makeShape(level, pair, stimsize, x, y, targetX, targetY);
% 
%     figure; imshow(in)


pairs = [1 2; 3 7; 4 8; 6 9; 10 11; 5 12; 13 14; 15 16;  ...
    18 19; 20 24; 21 26; 22 25; 23 28; 27 30; 34 29; 31 36];
nlevels = 1000;

%load and display shapes
prototype_coords;   %defines "prototypes" [20 x 2 x 36]

%prototypes = prototypes * npix/max(prototypes(:)); %#ok<NODEF>

prot1 = pairs(pair,1);
prot2 = pairs(pair,2);

coords1 = prototypes(:,:,prot1);
coords2 = prototypes(:,:,prot2);

r1 = 1 - (level-1)/(nlevels-1);
r2 = 1 - r1;
coords = r1*coords1 + r2*coords2;
sm = test_spline(coords);

%reorient and shrink to [0 1 0 1]
sm(:,2) = -sm(:,2)+400; sm = sm/450;
sm(:,2) = 1 - sm(:,2);

% expand to correct size
sm = sm * stimsize;

% shift to correct location
sm(:,1) = sm(:,1) + targetY - stimsize/2;
sm(:,2) = sm(:,2) + targetX - stimsize/2;

% find the points
in = InPolygon(x,y,sm(:,1),sm(:,2));

return
