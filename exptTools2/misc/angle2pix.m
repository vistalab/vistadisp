function n=angle2pix(display,ang)%ANGLE2PIX%n=angle2pix(display,ang)%returns width of square in pixels for visual angle angn=2*display.distance*tan(ang*pi/360)/display.pixelSize;