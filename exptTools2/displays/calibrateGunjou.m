clear all; close all

global g_useIOPort
g_useIOPort = 0;
PR650Init(1)

% check it
CMCheckInit

% load stored file
cal = LoadCalFile('3T_Back_Bore_800x600_4_23_08');

% do it
whichMeterType    = 1; 
blankOtherScreen  = 0; 
UserPrompt        = [];
cal = CalibrateMonDrvr(cal, UserPrompt, whichMeterType, blankOtherScreen);
save  3T_Back_Bore_800x600_7_7_2010.mat cal
