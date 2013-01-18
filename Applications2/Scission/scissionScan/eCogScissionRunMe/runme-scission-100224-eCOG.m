clear all; close all;

mydir = fileparts(which('scissionMenu.m'));
cd (fullfile(mydir, 'eCogScissionRunMe'));
pwd


load('Scission-eCog-Params.mat')
params.display = selectDisplay;
params.period = 48;
params.numCycles = 2;
params.loadMatrix = 'Scission-eCog-Images.mat'; 


sci(params)
sci(params)
sci(params)



%'Im1-An0502GrayGaus15Hz.mat';

