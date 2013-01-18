function [realEdge cocEdge mixture] = cocAddFixation(realEdge, cocEdge, mixture, screenHeight, screenWidth, fixationLoc)

fixationY = screenWidth/2 + fixationLoc + (-1:1);
fixationX = screenHeight/2  + (-1:1);

if mod(t, 2*pi) < fixationDutyCycle*2*pi,
    cocEdge(fixationX, fixationY) = 0;
    realEdge(fixationX, fixationY) = 0;
    mixture(fixationX, fixationY) = 0;
end

end