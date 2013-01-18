load('cocParams07.02.2008.mat');

sHi  = params;
sMed  = params;
sLo = params;
uHi = params;
uMed = params;
uLo = params;
LOC = params;

sHi.experiment = 'SquareWave';
sMed.experiment = 'SquareWave';
sLo.experiment = 'SquareWave';
uHi.experiment = 'Uniform';
uMed.experiment = 'Uniform';
uLo.experiment = 'Uniform';
LOC.experiment = 'localizer';

sHi.stimulus.edgeAmplitdue = 1;
sMed.stimulus.edgeAmplitdue = .5;
sLo.stimulus.edgeAmplitdue = .2;

uHi.stimulus.edgeAmplitdue = 1;
uMed.stimulus.edgeAmplitdue = .5;
uLo.stimulus.edgeAmplitdue = .1;


% Scan 07/02/2008

coc(LOC)

coc(uMed)
coc(uHi)
coc(sLo)
coc(sMed) 
coc(uLo)

coc(LOC)

coc(uLo)
coc(sMed)
coc(sLo)
coc(uMed)
coc(uHi)
coc(sHi) 

coc(LOC)

coc(sHi) 

coc(uMed)
coc(uHi)
coc(sLo)
coc(sMed)
coc(uLo)
coc(sHi) 


% 15 scans - we should stop here -

coc(sHi) 
coc(sMed) 
coc(sLo)
coc(uHi)
coc(uMed)
coc(uLo)

