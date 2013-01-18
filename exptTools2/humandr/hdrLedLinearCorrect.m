function ledLevel = hdrLedLinearCorrect(ledLumin,ledSlope,ledMax)

ledLevel = round(ledLumin/ledSlope * ledMax);