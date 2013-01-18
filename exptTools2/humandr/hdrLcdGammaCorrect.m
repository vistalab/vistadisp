function lcdLevel = hdrLcdGammaCorrect(lcdLumin,lcdGamma,lcdMax)

lcdLevel = round(lcdLumin^(1/lcdGamma) * lcdMax);