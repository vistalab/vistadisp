function vistaCalibrateMonitor(firstcalib,do10bittest)
% vistaCalibrateMonitor(firstcalib,do10bittest)
%
% this is a derivation of CalibrateMonSpd.m customized for the vista lab
% local use on a Mac OSX machines.
% 
% this function:
% (1) performs some basics tests to check the serial-port communication
%     with the PR650
% (2) calibrates a monitor
% (3) performs a 1-bit test to determine if your video card can control the 
%     display at 10-bit contrast 
% (4) the user has the option to performs either a 'long' (~ 3-4 hours) 
%     accurate calibration or a 'short' less accurate (< 2 hours calibration)
% (5) handles whether the current is the first calibration for a monitor or
%     whether a previous calibration file was already created and the
%     current calibration is and addition.
%
% this function requires both the PsychToolbox and the vistadisp repository.
%
% N.B. three psychtoolbox functions are replicated and slightly modified
% locally: calibrateMonSpd.m and CMCheckInit.m and CalibrateMonDrv.m
%
% 2011/06/09 fp adapted the original psychTooolbox file for the visatdisp
%               environmnet. added 10-bit test and re-load previous
%               calibration.

tic
global g_useIOPort

% set to use the SerialComm toolbox instead fo the default IOPort toolbox
g_useIOPort = 0;

% make sure the PR650 is connected, on and waiting for input under CONTROL
% mode.
pr650ready = 0;
while ~pr650ready
 disp('% --------------- VISTA MONITOR CALIBRATION: TEST SERIAL CONNECTION ----------------- %')
 disp(sprintf('Turn on the PR650. Is the PR650 display lit? Does it look something like this?\n'));
 disp('% -------------------------------------------------------------------- %\n')
 disp(sprintf('PR-650 REMOTE MODE\n(CTRL) s/w V1.19\n\nCMD b\n'));
 disp('% -------------------------------------------------------------------- %')
 pr650ready = input('Press "1" if YES, turn off and back on the PR650 until you see that screen otherwise. ');
end

% now try to initialize the PR650, if it works go ahead otherwise stop by typing <apple period>
disp(sprintf('OK. Next, I am going to initialize the serial communication with the PR650.\nYou should see something like the following screen:\n'));
disp('% -------------------------------------------------------------------- %')
disp(sprintf('Opened device: ''/dev/cu.PL2303-0000101D''\nOpened device: ''/dev/cu.PL2303-0000101D''\n\n'));
disp('% -------------------------------------------------------------------- %')
disp(sprintf('\nTrying now ...'))
disp(sprintf('If you do not see the correct text or if matlab hangs, press <COMMAND .> and clear all and start over the calibration after turning the PR650 off/on.'));
disp(sprintf('If this does not work for more than a couple of attempts. Try restarting the computer.\n'));

% initialize the PR650
PR650init(1);

disp(sprintf('\nOK DONE initializing the PR650!\n\nNext I am going to make a couple of test measurments To make sure that things work.\n'))

% trying  short measurment:

disp(sprintf('Attempting one measurement. If this works, you should hear two clicks coming from the photometer.\n'))

% get some measurements
xyz = PR650measxyz;

if ~isempty(xyz)
 disp(sprintf('OK this test passed too!\n\n'))
else
 disp(sprintf('Something went wrong in the communication with the PR650.\nI did not get any reading. Exiting. Restart matlab and/or the PR650 and/or the computer.\n'))
 clear all
 return
end
disp('% ---------------- VISTA MONITOR CALIBRATION: STARTING CALIBRATION ------------------ %')

% switch calls depending on whether this is the first time this monitor is
% being calibrated or not:
if notDefined('firstcalib')
 firstcalib = 1; 
 firstcalib = input(sprintf('Is it the first time that you calibrate this monitor?\n[1=yes, 0=no]\n'));
end

% selecte the calibration to perform
if firstcalib
 
 % chose the type of calibration long but accurate or fast but inaccurate:
 calibrationType = 'long';
 calibrationType = input(sprintf('Do you want to perform a quick basic calibration (~1h 20 mins) or the default slow but accurate one (~4h)?\n[s,short,fast,f, OR l,long,slow,w]\n'),'s');
 
 % this does the actual calibration
 cal = calibrateMonSpd(calibrationType);
 
else % calibrate a file with a previous calibration
 % load the previous calibration file:
 dispList = getDisplaysList;
 disp(sprintf('The following are the available displays. Which one do you want to calibrate?\n\n'));
 for id =1:length(dispList)
  disp(sprintf('(%i) %s\n',id,dispList{id}));
 end
 dispNum = input(sprintf('Please type in the display number (1:%i): ',length(dispList)));
 cal = load(sprintf('%s.mat',fullfile(getDisplayPath,'PsychCalLocalData',dispList{dispNum})));
 cal = cal.cals; % should i add the new cal as newCal = cal(end+1)? does psychtoolbox load the last one automatically?
 
 % do the calibration
 whichMeterType    = 1;
 blankOtherScreen  = 0;
 UserPrompt        = [];
 
 % calibrate the monitor
 cal = CalibrateMonDrvr(cal, UserPrompt, whichMeterType, blankOtherScreen); 
 
 % Calibrate ambient
 USERPROMPT = 0;
 cal = CalibrateAmbDrvr(cal, USERPROMPT, whichMeterType, blankOtherScreen);

end

% add display parameters to the calibration
cal  = addDisplayParams(cal);

% save the calibration file
% Save the structure
fprintf(1, '\nSaving to %s.mat\n', cal.describe.calibrationfilename);
SaveCalFile(cal, sprintf('%s.mat',cal.describe.calibrationfilename));

disp('% ---------------- VISTA MONITOR CALIBRATION: DONE CALIBRATION ------------------ %');

if do10bittest == 1
 disp('% ---------------- VISTA MONITOR CALIBRATION: PERFORMING 10-bit TEST ------------------ %')
 %%%%% 10-bit test
 rec = [];
 for rep=1:100
  t = ones(256,3) * (1000/1023);
  screen('LoadNormalizedGammaTable',1,t);
  rec(:,rep,1) = PR650measxyz;
  
  t = ones(256,3) * (1001/1023);
  screen('LoadNormalizedGammaTable',1,t);
  rec(:,rep,2) = PR650measxyz;
  
  t = ones(256,3) * (1002/1023);
  screen('LoadNormalizedGammaTable',1,t);
  rec(:,rep,3) = PR650measxyz;
 
  t = ones(256,3) * (1003/1023);
  screen('LoadNormalizedGammaTable',1,t);
  rec(:,rep,4) = PR650measxyz;

 end
 
 save(fullfile(getDisplayPath,[cal.describe.calibrationfilename,'_10bittest_data.mat']),'rec');
  
 % show the ten-bit test results and save a figure
 mn = mean(rec,2);
 se = std(rec,[],2)/sqrt(size(rec,2));
 h = figure;
 titles = {'X' 'Y' 'Z'};
 for p=1:3
  subplot(1,3,p); hold on;
  plot(squeeze(mn(p,:,:)),'r-');
  errorbar2(1:4,squeeze(mn(p,:,:)),squeeze(se(p,:,:)),'v','r-');
  ax = axis; axis([0 5 ax(3:4)]);
  xlabel('voltage'); ylabel(titles{p});
  set(gca,'XTick',1:4,'XTickLabel',{'1000' '1001' '1002' '1003'});
 end
 
 % save the figure
 figName = fullfile(getDisplayPath,[cal.describe.calibrationfilename,'_10bittest_figure.mat']);
 printCommand = sprintf('print(%s, ''-cmyk'', ''-painters'',''-depsc2'',''-tiff'',''-r500'' , ''-noui'', ''%s'')', num2str(h),figName);
 disp(sprintf('[%s] saving 10-bit test figure %s/%s\nUsing command: %s',mfilename,figDir,figName,printCommand));
 eval(printCommand);

 disp('% ---------------- VISTA MONITOR CALIBRATION: DONE PERFORMING 10-bit TEST ------------------ %') 
end

donotes = input(sprintf('\n do you want to add notes to the calibration?\n'));
if donotes
 edit(fullfile(getDisplayPath,[cal.describe.calibrationfilename,'_notes.m']));
end

toc


%%%%%%%%%%%%%%%%%%%%
% addDisplayParams %
%%%%%%%%%%%%%%%%%%%%
function cal = addDisplayParams(cal)
% software used for calibration
cal.thisfunction = mfilename;

% hardware specs:
cal.monitor.model.info  = sprintf('Please enter the model of the monitor, e.g., ''DELL 3007WFP'': ');
cal.monitor.model.value = input(cal.monitor.model.info,'s');

cal.monitor.native.info   = sprintf('Please enter the monitor native resolution, e.g., ''[2560, 1600]'': ');
cal.monitor.native.value  = input(cal.monitor.native.info);

cal.monitor.interface.info = sprintf('Please enter the interface used to connect the monitor to the computer, e.g., ''DVI, or VGA'': ');
cal.monitor.interface.value = input(cal.monitor.interface.info,'s');

% hardware settings:
cal.monitor.resolution.info = sprintf('Please enter the monitor resolution used in this calibration, e.g., ''[1880, 1660]'': ');
cal.monitor.esolution.value = input(calibrationResolution.info);

% monitor field or view and distance
cal.monitor.dimensions.info       = sprintf('Please enter the monitor''s dimensions in cm (Width x Height), e.g., ''[64.3, 40.2]'': ');
cal.monitor.dimensions.value      = input(cal.monitor.dimensions.info);

cal.monitor.viewingdistance.info  = sprintf('Please enter the distance between the monitor the subject''s eyes (in cm), e.g., ''[240]'': ');
cal.monitor.viewingdistance.value = input(cal.monitor.viewingdistance.info);

% computer used for calibratinsg
cal.computer.info     = sprintf('Please enter the computer being used for calibrating, e.g., ''Franco''s Mac Laptop OSX 10.5'': ');
cal.computer.value    = input(cal.computer.info);


%%%%%%%%%%%%%%%%%%%
% calibrateMonSpd %
%%%%%%%%%%%%%%%%%%%
function cal = calibrateMonSpd(calibrationType)
% this function is a local version of the psychToolbox one. It contains
% some ad-hoc changes that are necessary for things to work smoothly.
%
% NOTE for vist:
% i copied this function here so that we can change the parameters of the
% calibration. the psychotoolbox option is to hack into the script
%
% franco 2011/04/12

% Create calibration structure;
cal = [];

% Blank other screens?
blankOtherScreen = 1;

% Script parameters
whichScreen = max(Screen('Screens'));
whichMeterType = 1;

% swithc which calibration we are doing.
% a fast but inaccurate one or a slow but accurate one
switch calibrationType
 case {'short', 's', 'fast', 'f'}
  cal.describe.leaveRoomTime = 15;
  cal.describe.nAverage      = 2;
  cal.describe.nMeas         = 30 ;
  cal.describe.boxSize       = 400;
  cal.nDevices               = 3;
  cal.nPrimaryBases          = 1;
  
 case {'long', 'l', 'slow', 'w'}
  cal.describe.leaveRoomTime = 15;
  cal.describe.nAverage      = 5;
  cal.describe.nMeas         = 85;
  cal.describe.boxSize       = 900;
  cal.nDevices               = 3;
  cal.nPrimaryBases          = 1;
  
 otherwise
  keyboard
end


switch whichMeterType
 case {0,1}
  cal.describe.S = [380 4 101];
 case 2
  cal.describe.S = [380 1 401];
 otherwise
  cal.describe.S = [380 4 101];
end
cal.manual.use = 0;

% Enter screen
defaultScreen = whichScreen;
whichScreen = input(sprintf('Which screen to calibrate [%g]: ', defaultScreen));
if isempty(whichScreen)
 whichScreen = defaultScreen;
end
cal.describe.whichScreen = whichScreen;

% Blank screen
defaultBlankOtherScreen = 0;
blankOtherScreen = input(sprintf('Do you want to blank another screen? (1 for yes, 0 for no) [%g]: ', defaultBlankOtherScreen));
if isempty(blankOtherScreen)
 blankOtherScreen = defaultBlankOtherScreen;
end
if blankOtherScreen
 defaultBlankScreen = 2;
 whichBlankScreen = input(sprintf('Which screen to blank [%g]: ', defaultBlankScreen));
 if isempty(whichBlankScreen)
  whichBlankScreen = defaultBlankScreen;
 end
 cal.describe.whichBlankScreen = whichBlankScreen;
end

% Find out about screen
cal.describe.dacsize = ScreenDacBits(whichScreen);
nLevels = 2^cal.describe.dacsize;

% Prompt for background values.  The default is a guess as to what
% produces one-half of maximum output for a typical CRT.
defBgColor = [190 190 190]'/255;
thePrompt = sprintf('Enter RGB values for background (range 0-1) as a row vector [%0.3f %0.3f %0.3f]: ',...
 defBgColor(1), defBgColor(2), defBgColor(3));
while 1
 cal.bgColor = input(thePrompt)';
 if isempty(cal.bgColor)
  cal.bgColor = defBgColor;
 end
 [m, n] = size(cal.bgColor);
 if m ~= 3 || n ~= 1
  fprintf('\nMust enter values as a row vector (in brackets).  Try again.\n');
 elseif (any(defBgColor > 1) || any(defBgColor < 0))
  fprintf('\nValues must be in range (0-1) inclusive.  Try again.\n');
 else
  break;
 end
end

% Get distance from meter to screen.
defDistance = .80;
theDataPrompt = sprintf('Enter distance from meter to screen (in meters): [%g]: ', defDistance);
cal.describe.meterDistance = input(theDataPrompt);
if isempty(cal.describe.meterDistance)
 cal.describe.meterDistance = defDistance;
end

% Fill in descriptive information
computerInfo = Screen('Computer');
hz = Screen('NominalFrameRate', cal.describe.whichScreen);
cal.describe.caltype = 'monitor';
cal.describe.computer = sprintf('%s''s %s, %s', computerInfo.consoleUserName, computerInfo.machineName, computerInfo.system);
cal.describe.monitor = input('Enter monitor name: ','s');
cal.describe.driver = sprintf('%s %s','unknown_driver','unknown_driver_version');
cal.describe.hz = hz;
cal.describe.who = input('Enter your name: ','s');
cal.describe.date = sprintf('%s %s',date,datestr(now,14));
cal.describe.program = sprintf('vistaCalibrateMonitor, background set to [%g,%g,%g]',...
 cal.bgColor(1), cal.bgColor(2), cal.bgColor(3));
cal.describe.comment = input('Describe the calibration: ','s');

% Get name
defaultFileName = 'monitor';
thePrompt = sprintf('Enter calibration filename [%s]: ',defaultFileName);
newFileName = input(thePrompt,'s');
if isempty(newFileName)
 newFileName = defaultFileName;
end
cal.describe.calibrationfilename = newFileName; 

% Fitting parameters
cal.describe.gamma.fitType = 'crtPolyLinear';
cal.describe.gamma.contrastThresh = 0.001;
cal.describe.gamma.fitBreakThresh = 0.02;

% Initialize
switch whichMeterType
 case 0
 case 1
  CMCheckInit;
 case 2
  CVIOpen;
 otherwise
  error('Invalid meter type');
end
ClockRandSeed;
%ScreenSaver(0);

% Calibrate monitor
USERPROMPT = 1;
cal = CalibrateMonDrvr(cal, USERPROMPT, whichMeterType, blankOtherScreen);

% Calibrate ambient
USERPROMPT = 0;
cal = CalibrateAmbDrvr(cal, USERPROMPT, whichMeterType, blankOtherScreen);

% Signal end
Snd('Play', sin(0:10000)); WaitSecs(.75); Snd('Play', sin(0:10000)); WaitSecs(.75); Snd('Play', sin(0:20000));

% Save the structure
fprintf(1, '\nSaving to %s.mat\n', newFileName);
SaveCalFile(cal, newFileName);

% Put up a plot of the essential data
figure(1); clf;
plot(SToWls(cal.S_device), cal.P_device);
xlabel('Wavelength (nm)', 'Fontweight', 'bold');
ylabel('Power', 'Fontweight', 'bold');
title('Phosphor spectra', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
axis([380, 780, -Inf, Inf]);

figure(2); clf;
plot(cal.rawdata.rawGammaInput, cal.rawdata.rawGammaTable, '+');
xlabel('Input value', 'Fontweight', 'bold');
ylabel('Normalized output', 'Fontweight', 'bold');
title('Gamma functions', 'Fontsize', 13, 'Fontname', 'helvetica', 'Fontweight', 'bold');
hold on
plot(cal.gammaInput, cal.gammaTable);
hold off
figure(gcf);
drawnow;

% Reenable screen saver.
%ScreenSaver(1);

% Close down meter
switch whichMeterType
 case 0
  
 case 1
  CMClose;
 case 2
  CVIClose;
 otherwise
  error('Invalid meter type');
end


%%%%%%%%%%%%%%%
% CMCheckInit %
%%%%%%%%%%%%%%%
function CMCheckInit(meterType, PortString)
% THis is a local version of the same function in the psychTOoolbox
% i made a local copy because the original function crashed on Mac OSX
% unless edited.
%
% the only change to the function is on this line at the beginning:
%
% % If g_useIOPort == 1 the IOPort driver shall be used instead of SerialComm:
% g_useIOPort = 1;
%
% g_useIOPort is set to 0 here. So NOT to use the IOPort toolbox whioch
% seem to crash.
%
% CMCheckInit([meterType], [PortString])
%
% Initialize the color meter.  The routine calls the
% lower level routines for given 'meterType'. If the low level routine
% fails, this routine retries, then prompts the user to take appropriate
% action.  If the low level routine succeeds, this
% routine  is silent.
%
% The following colormeters are supported:
%
% meterType 1 is the PR650 (default)
% meterType 2 is the CVI (need CVIToolbox) - Not yet implemented!
% meterType 3 is the CRS Colorimeter
% meterType 4 is the PR655
%
% For the PR-series colorimeters, 'PortString' is the optional name of a
% device string for the serial port or Serial-over-USB port to which the
% device is connected. If none is given, the routine uses different files
% and built-in defaults to try to find the proper port: If there is a file
% 'CMPreferredPort.txt' in the search path of Matlab/Octave, it will parse
% that file for a PortString to use. Else it will use a hard-coded default
% inside this routine. If a calibration file with name 'PR650Ports' for the
% PR-650 colorimeter or 'PR655Ports' for the PR-655 colorimeter exists
% inside the PsychCalData folder, it will use the portname from that file.
%
% Other Colorimeters, e.g., CRS ColorCal, have their own specific setup
% methods and this routine just calls their setup code with default
% settings.
%

%
% 9/15/93 dhb		Modified to use new CMInit properly.
% 1/18/94 jms		Added gHardware switch
% 1/24/94 dhb		Changed sign of gHardware switch.
% 2/20/94 dhb		Call through CMETER rather than CM... routines.
% 4/4/00  dhb       Optional port name, only used on SERIAL version.
% 9/11/00 dhb       Added meterType.
% 1/4/02  dhb, ly   Try to get OS9 version to work with Megawolf board and SERIAL.
% 1/10/02 dhb, ly   Change calling convention.  Remove passing of port, but read
%                   port from a "calibration" file in PsychCalLocalData if it's there.
% 4/13/02 dgp		Cosmetic.
% 2/26/03 dhb       Add CRS Colorimeter, change meter type of PR-650 to 1.
% 10/05/06 dhb, cgb OSX version.
% 11/27/07 mpr      replaced hard coded portNameIn with FindSerialPort for OS X, and
%                   attempted to make this more robust and user-friendly.
%                   modifications tested only on Mac OS 10.5.1, Matlab 2007b, on
%                   a Mac Pro.  Other systems may require more tinkering...
% 2/07/09  mk, tbc  Add PR-655 support.
% 2/07/09  mk       Add experimental setup code for use of IOPort instead of SerialComm.
% 2/11/09  cgb,mk   Small fixes: Now we use IOPort instead of SerialComm --
%                   by default. Verified to work for both PR650 and PR655 toolboxes.

global g_serialPort g_useIOPort;

% If g_useIOPort == 1 the IOPort driver shall be used instead of SerialComm:
g_useIOPort = 0;

% Number of retries before giving up:
DefaultNumberOfTries = 5;

% Read the local preferred serial port file if it exists.
if exist(which('CMPreferredPort.txt'), 'file')
 t = textread(which('CMPreferredPort.txt'), '%s');
 defPortString = t{1};
else
 if IsOSX
  defPortString = 'usbserial';
 end
 
 if IsLinux
  defPortString = 'USB0';
 end
 
 if IsWin
  defPortString = 'COM5';
 end
end

% Set default the defaults.
switch nargin
 case 0
  meterType = 1;
  PortString = defPortString;
 case 1
  if isempty(meterType)
   meterType = 1;
  end
  PortString = defPortString;
 case 2
  if isempty(meterType)
   meterType = 1;
  end
  if isempty(PortString)
   PortString = defPortString;
  end
end

% I wrote the function FindSerialPort before I discovered CMCheckInit had
% been ported to OS X.  It may generally require less of users than relying
% on what amounts to a preference in the calibration files.  The default
% for portNameIn was 2, but on my machine it was 1 when I wrote my
% function.  Someone in the Brainard lab may want to generalize
% "FindSerialPort" to work with OSs other than Mac OS X and then use that
% function in lieu of meterports=LoadCalFile.  I am not intrepid enough to
% take that step.  -- MPR 11/21/07


switch meterType
 case 1,
  % PR-650
  % Look for port information in "calibration" file.  If
  % no special information present, then use defaults.
  meterports = LoadCalFile('PR650Ports');
  if isempty(meterports)
   if IsWin || IsOSX || IsLinux
    portNameIn = FindSerialPort(PortString, g_useIOPort);
   else
    error(['Unsupported OS ' computer]);
   end
  else
   portNameIn = meterports.in;
  end
  
  if IsWin || IsOSX || IsLinux
   stat = PR650init(portNameIn);
   status = sscanf(stat,'%f');
   if (isempty(status) || status == -1)
    disp('Failed initial attempt to make contact.');
    disp('If colorimeter is off, turn it on; if it is on, turn it off and then on.');
   end
   NumTries = 0;
   
   while (isempty(status) || status == -1) & NumTries < DefaultNumberOfTries %#ok<AND2>
    stat = PR650init(portNameIn);
    status = sscanf(stat,'%f');
    NumTries = NumTries+1;
    if (isempty(status) || status == -1) & NumTries >= 3 %#ok<AND2>
     if IsOSX
      if ~g_useIOPort
       evalc(['SerialComm(''close'',' int2str(portNameIn) ');']);
       evalc('clear SerialComm');
      else
       IOPort('Close', g_serialPort);
      end
     end
     % Release global port handle:
     %                     clear global g_serialPort;
     
     fprintf('\n');
     if ~rem(NumTries,4)
      fprintf('\nHave tried making contact %d times.  Will try %d more...',NumTries,DefaultNumberOfTries-NumTries);
     end
    end
   end
   fprintf('\n');
   if isempty(status) || status == -1
    disp('Failed to make contact.  If device is connected, try turning it off and re-trying CMCheckInit.');
   else
    disp('Successfully connected to PR-650!');
   end
  else
   error(['Unsupported OS ' computer]);
  end
 case 2,
  error('Support for CVI colormeter not yet implemented in PTB-3, sorry!');
 case 3,
  % CRS-Colorimeter:
  if exist('CRSColorInit') %#ok<EXIST>
   CRSColorInit;
  else
   error('CRSColorInit command is missing on your path. Is the CRS color calibration toolbox set up properly?');
  end
 case 4,
  % PR-655:
  % Look for port information in "calibration" file.  If
  % no special information present, then use defaults.
  meterports = LoadCalFile('PR655Ports');
  if isempty(meterports)
   if IsWin || IsOSX || IsLinux
    portNameIn = FindSerialPort(PortString, g_useIOPort);
   else
    error(['Unsupported OS ' computer]);
   end
  else
   portNameIn = meterports.in;
  end
  
  if IsWin || IsOSX || IsLinux
   stat = PR655init(portNameIn);
   status = sscanf(stat,'%f');
   if (isempty(status) || status == -1)
    disp('Failed to make contact.  If device is connected, try turning it off and re-trying CMCheckInit.');
   else
    disp('Successfully connected to PR-655!');
   end
  else
   error(['Unsupported OS ' computer]);
  end
  
 otherwise,
  error('Unknown meter type');
end


function cal = CalibrateMonDrvr(cal, USERPROMPT, whichMeterType, blankOtherScreen)
% cal = CalibrateMonDrvr(cal,USERPROMPT,whichMeterType,blankOtherScreen)
%
% Main script for monitor calibration.  May be called
% once parameters are set up.
%
% Each monitor input channel is calibrated.
% A summary spectrum is computed.
% Gamma curves are computed.

% 10/26/93	dhb		Wrote it based on CalibrateProj.
% 11/3/93	dhb		Added filename entry with default.
% 2/28/94	dhb		Updated SetMon call to SetColor call.
% 3/12/94	dhb		Created version for monitor 0.
% 					User interface is a little wild.
% 4/3/94	dhb		Save the darkAmbient variable.
% 					User interface improvements
% 9/4/94	dhb		Incorporate gamma fitting
%					improvements from CalibrateMonRoom.
%			dhb		Add whichScreen variable. 
%			dhb		Add sync mode variable.
% 10/20/94	dhb		Add bgColor variable.
% 11/18/94  ccc     Change the range of LUT from (0,255) to 
%                   (0, InputLevels-step) with step=nInputLevels/255 
% 11/21/94	dhb, ccc	Further nine-bit modifications.
% 1/23/95	dhb		Pulled parameter setting out into a calling script,
%					made user prompting conditional.
% 4/12/97	dhb		Update for new toolbox.
% 8/21/97	dhb		Don't save data here.
% 			dhb		Get rid of option not to measure.
% 4/7/99    dhb     NINEBIT -> NBITS.
%           dhb     Handle noMeterAvail, RADIUS switches.
%           dhb     Check for empty indexLin.
% 9/22/99   dhb, mdr  Make boxRect depend on boxSize, defined up one level.
% 10/1/99   dhb, mdr  Pull out nMonBases, defined up one level.
% 12/2/99   dhb     Put background on after white box for aiming.
% 8/14/00   dhb     Call to CMETER('Frequency') only for OS9.
% 8/20/00   dhb     Remove bits arg to SetColor and most RADIUS conditionals.
% 9/11/00   dhb     Remove syncMode code, any direct refs to CMETER.
% 9/14/00   dhb     Use OpenWindow to open.
% 3/8/02    dhb, ly  Call CalibrateManualDrvr if desired.
% 7/9/02    dhb     Get rid of OpenWindow, CloseWindow.
% 9/23/02   dhb, jmh  Force background to zero when box is up for aiming.
% 2/26/03   dhb     Tidy comments.
% 2/3/06	dhb		Allow passing of cal.describe.boxRect
% 10/23/06  cgb     OS/X, etc.
% 11/08/06  dhb, cgb Living in the 0-1 world ....
% 11/10/06  dhb     Get rid of round() around production of input levels.
% 9/26/08   cgb, dhb Fix dacsize when Bits++ is used.  Fit gamma with full number of levels. 

global g_usebitspp;

% If the global flag for using Bits++ is empty, then it hasn't been
% initialized and default it to 0.
if isempty(g_usebitspp)
    g_usebitspp = 0;
end

% Measurement parameters
monWls = SToWls(cal.describe.S);

% Define input settings for the measurements
mGammaInputRaw = linspace(0, 1, cal.describe.nMeas+1)';
mGammaInputRaw = mGammaInputRaw(2:end);

% Make manual measurements here if desired.  This needs to come first.
if cal.manual.use
    error('Manual measurements not yet converted to PTB-3.  Fix CalibrateManualDrvr if you need this.');
    CalibrateManualDrvr;
end

% User prompt
if USERPROMPT
	if cal.describe.whichScreen == 0
		fprintf('Hit any key to proceed past this message and display a box.\n');
		fprintf('Focus radiometer on the displayed box.\n');
		fprintf('Once meter is set up, hit any key - you will get %g seconds\n',...
                cal.describe.leaveRoomTime);
		fprintf('to leave room.\n');
		GetChar;
	else
		fprintf('Focus radiometer on the displayed box.\n');
		fprintf('Once meter is set up, hit any key - you will get %g seconds\n',...
                cal.describe.leaveRoomTime);
		fprintf('to leave room.\n');
	end
end

% Blank other screen
if blankOtherScreen
	[window1, screenRect1] = Screen('OpenWindow', cal.describe.whichBlankScreen, 0);
    if g_usebitspp
        Screen('LoadNormalizedGammaTable', window1, linspace(0, 1, 256)' * [1 1 1]);
        BitsPlusSetClut(window1, zeros(256, 3));
    else
        Screen('LoadNormalizedGammaTable', window1, zeros(256,3));
    end
end

% Blank screen to be measured
[window, screenRect] = Screen('OpenWindow', cal.describe.whichScreen, 0);
if (cal.describe.whichScreen == 0)
	HideCursor;
else
	%Screen('MatlabToFront');
end
theClut = zeros(256, 3);
if g_usebitspp
    Screen('LoadNormalizedGammaTable', window, linspace(0, 1, 256)' * [1 1 1]);
    BitsPlusSetClut(window, theClut);
else
    Screen('LoadNormalizedGammaTable', window, theClut);
end

% Draw a box in the center of the screen
if ~isfield(cal.describe, 'boxRect')
	boxRect = [0 0 cal.describe.boxSize cal.describe.boxSize];
	boxRect = CenterRect(boxRect,screenRect);
else
	boxRect = cal.describe.boxRect;
end
theClut(2,:) = [1 1 1];
Screen('FillRect', window, 1, boxRect);
if g_usebitspp
    BitsPlusSetClut(window, theClut .* (2^16 - 1));
else
	Screen('Flip', window);
    Screen('LoadNormalizedGammaTable', window, theClut);
end

% Wait for user
if USERPROMPT == 1
    FlushEvents;
%%%    fprintf('Set up radiometer and hit any key when ready\n');
%%%    GetChar;  % perhaps comment this out and replace with pause(3)  ! 

    fprintf('Pausing for %d seconds ...', cal.describe.leaveRoomTime);
    %WaitSecs(cal.describe.leaveRoomTime);

pause(3);

    fprintf(' done\n');
end

% Put correct surround for measurements.
theClut(1,:) = cal.bgColor';
if g_usebitspp
    Screen('FillRect', window, 1, boxRect);
    BitsPlusSetClut(window, theClut .* (2^16 - 1));
else
    Screen('LoadNormalizedGammaTable', window, theClut);
end

% Start timing
t0 = clock;

mon = zeros(cal.describe.S(3)*cal.describe.nMeas,cal.nDevices);

  %%% KK added 2011/07/18:
monindividual = zeros(cal.describe.S(3)*cal.describe.nMeas,cal.nDevices,cal.describe.nAverage);
  %%%
  
for a = 1:cal.describe.nAverage
    for i = 1:cal.nDevices
        disp(sprintf('Monitor device %g',i));
        Screen('FillRect', window, 1, boxRect);
        Screen('Flip', window, 0, double(g_usebitspp));

        % Measure ambient
        darkAmbient1 = MeasMonSpd(window, [0 0 0]', cal.describe.S, 0, whichMeterType, theClut);

        % Measure full gamma in random order
        mGammaInput = zeros(cal.nDevices, cal.describe.nMeas);
        mGammaInput(i,:) = mGammaInputRaw';
        sortVals = rand(cal.describe.nMeas,1);
        [null, sortIndex] = sort(sortVals);
        %fprintf(1,'MeasMonSpd run %g, device %g\n',a,i);
        [tempMon, cal.describe.S] = MeasMonSpd(window, mGammaInput(:,sortIndex), ...
            cal.describe.S, [], whichMeterType, theClut);
        tempMon(:, sortIndex) = tempMon;

        % Take another ambient reading and average
        darkAmbient2 = MeasMonSpd(window, [0 0 0]', cal.describe.S, 0, whichMeterType, theClut);
        darkAmbient = ((darkAmbient1+darkAmbient2)/2)*ones(1, cal.describe.nMeas);

        % Subtract ambient
        tempMon = tempMon - darkAmbient;

        % Store data
        mon(:, i) = mon(:, i) + reshape(tempMon,cal.describe.S(3)*cal.describe.nMeas,1);

          %%% KK added 2011/07/18:
        monindividual(:,i,a) = reshape(tempMon,cal.describe.S(3)*cal.describe.nMeas,1);
        cal.rawdata.monindividual = EnforcePos(monindividual);
        save('~/tempcalibration.mat');  % in case we crash, don't lose all our data!
          %%%

    end
end
mon = mon / cal.describe.nAverage;

% Close the screen
Screen(window, 'Close');
ShowCursor;

% Report time
t1 = clock;
fprintf('CalibrateMonDrvr measurements took %g minutes\n', etime(t1, t0)/60);

% Pre-process data to get rid of negative values.
mon = EnforcePos(mon);
cal.rawdata.mon = mon;

% Use data to compute best spectra according to desired
% linear model.  We use SVD to find the best linear model,
% then scale to best approximate maximum
disp('Computing linear models');
cal = CalibrateFitLinMod(cal);

% Fit gamma functions.
cal.rawdata.rawGammaInput = mGammaInputRaw;
cal = CalibrateFitGamma(cal, 2^cal.describe.dacsize);

% Blank other screen
if blankOtherScreen
	Screen('Close', window1);
end

