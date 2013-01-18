function stimLoc = computePosition(display,percCenter,angle,distance)
% return stimloc [percx percy pixx pixy]

% Adjust for angles equal to or greater than 360
divides         = floor(angle/360);
angle           = angle - (360*divides);
screenDims      = [pix2angle(display,display.numPixels(1)) pix2angle(display,display.numPixels(2))];

if angle<90 && angle>0
    quad = 1;
elseif angle<180 && angle>90
    angle = 180 - angle;
    quad = 2;
elseif angle<270 && angle>180
    angle = 270 - angle;
    quad = 3;
elseif angle<360 && angle>270
    angle = 360 - angle;
    quad = 4;
end

if(exist('quad','var'))
    yDist = screenDims(2)/2; %display.degHeight/2;
    xDist = yDist/tand(angle);

    hypDist = sqrt((xDist^2)+(yDist^2));
    scaleFactor = distance/hypDist;

    xDist = xDist*scaleFactor;
    yDist = yDist*scaleFactor;

    xPercDist = xDist/screenDims(1); %display.degWidth;
    yPercDist = yDist/screenDims(2); %display.degHeight;

    if quad==1
        stimLoc(1) = percCenter(1)+xPercDist;
        stimLoc(2) = percCenter(2)-yPercDist;
    elseif quad==2
        stimLoc(1) = percCenter(1)-xPercDist;
        stimLoc(2) = percCenter(2)-yPercDist;
    elseif quad==3
        stimLoc(1) = percCenter(1)-xPercDist;
        stimLoc(2) = percCenter(2)+yPercDist;
    elseif quad==4
        stimLoc(1) = percCenter(1)+xPercDist;
        stimLoc(2) = percCenter(2)+yPercDist;
    end
else
    if angle==0 || angle==360
        stimLoc(1) = percCenter(1)+(distance/screenDims(1)); %display.degWidth);
        stimLoc(2) = percCenter(2);
    elseif angle==90
        stimLoc(1) = percCenter(1);
        stimLoc(2) = percCenter(2)-(distance/screenDims(2)); %display.degHeight);
    elseif angle==180
        stimLoc(1) = percCenter(1)-(distance/screenDims(1)); %display.degWidth);
        stimLoc(2) = percCenter(2);
    elseif angle==270
        stimLoc(1) = percCenter(1);
        stimLoc(2) = percCenter(2)+(distance/screenDims(2)); %display.degHeight);
    end
end

stimLoc(3) = stimLoc(1)*display.numPixels(1);
stimLoc(4) = stimLoc(2)*display.numPixels(2);