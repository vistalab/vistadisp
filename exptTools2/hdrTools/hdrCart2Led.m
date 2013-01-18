function imageByLED = hdrCart2Led(image)
% 
% Usage: imageByLED = cart2led(image)
% 
% Convert the specified image (a 2D or 3D matrix) into a 1 x 1280 vector
% using the mapping information provided by Greg Ward.
% 
% Inputs:
% 1. image - a 2D or 3D matrix
% 
% Outputs:
% 1. imagebyLED - a 1 x 1280 vector, in which 759 of the elements are used
% to specified the LED values.
% 
% History:
% 03/14/06 shc (shcheung@stanford.edu) wrote it.

% TODO: better scheme for locating the led position mapping file
load ../displays/hdr1/ledord.dat -ascii
ledord = ledord(1:759);

% fit image into the led grid
scaledImage = imresize(image,[46,17]);

origIND = [1:(46*17)];
squeezedIND = mod(origIND,34);
numDim = ndims(scaledImage);
if(numDim==3)
    scaledImage = mean(scaledImage,3);
end
scaledImage = reshape(scaledImage',46*17,1);
squeezedImage = scaledImage(find(squeezedIND));

imageByLED = zeros(1,1280);
imageByLED(ledord+2) = squeezedImage;