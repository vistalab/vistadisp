function img = renderText(someText, fontName, fontSize, sampsPerPt, antiAlias, fractionalMetrics)
% Use Matlab-Java to create a text outline
%
%  img = renderText(someText, fontName, fontSize, sampsPerPt, [antiAlias], [fractionalMetrics])
%
% Makes Java calls to render text into a 2d image. Make sure you launch
% matlab with the JVM enabled!
%
% Example:
%  img = renderText('HELLO World!','Sans',18,2);
%  figure; imagesc(img); axis equal tight off; colormap gray;
%
% HISTORY:
% 2003.??.?? Bob Dougherty (RFD) wrote it.
% 2005.10.31 RFD: added some comments and added it to exptTools2.
% BW read, edited, and a few comments
%

%
% TODO
%   boldFlag went away - why?  Should we figure it out again?
%   We should learn how to control the aliasing and other features
if notDefined('fontName'),   fontName = 'Courier'; end
if notDefined('fontSize'),   fontSize = 24; end
if notDefined('sampsPerPt'), sampsPerPt = 2; end
if notDefined('antiAlias'),  antiAlias= 0;   end
if notDefined('fractionalMetrics'), fractionalMetrics = 0; end

% Needed to run JAVA code below
import java.awt.*;

% Many of these are JAVA calls.
f = Font(fontName, Font.PLAIN, fontSize);

idXform = geom.AffineTransform;

% Render the font in java, save key parameters
frc        = font.FontRenderContext(idXform, antiAlias, fractionalMetrics);
glyphVec   = f.createGlyphVector(frc, someText);
lBnds      = glyphVec.getLogicalBounds;
glyphShape = glyphVec.getOutline;

%r = glyphShape.getBounds;

% This will be the output image of the rendered text
img = zeros(floor(lBnds.height*sampsPerPt),floor(lBnds.width*sampsPerPt));

% I couldn't figure out how to avoid this loop. Matlab doesn't seem to
% allow me to use more efficient Java calls (see dead code below).
% RFD
xVals = linspace(lBnds.x, lBnds.x+lBnds.width, (lBnds.width+1)*sampsPerPt);
yVals = linspace(lBnds.y, lBnds.y+lBnds.height, (lBnds.height+1)*sampsPerPt);
for x= xVals
    for y = yVals
        img(floor((y-lBnds.y+1)*sampsPerPt),floor((x-lBnds.x+1)*sampsPerPt)) = glyphShape.contains(x,y);
    end
end

return

% % DOESN'T WORK- no way to convince matlab to allow the currentSegment method
% % to return a double array.
% pi = glyphShape.getPathIterator(idXform);
%
% %tmpCoords = javaArray('java.lang.Double', 6)
% tmpCoords = zeros(6,1);
% ii = 1;
% clear shape;
% while(~pi.isDone)
%     shape(ii).segType = pi.currentSegment(tmpCoords);
%     shape(ii).coords = tmpCoords;
%     pi.next;
%     ii = ii+1;
% end
