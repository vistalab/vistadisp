#!/usr/bin/env python

# ledFlicker calibration script
# Copyright 2010 Bob Dougherty (bobd@stanford.edu)

# To install necessary modules on Fedora, run "sudo yum install pyserial scipy python-matplotlib".
# You may need to change premissions on the serial ports (look in /dev/tty*).

# standard modules
import os, serial, time, pylab, scipy, scipy.io
from numpy import *
# our own pr650 module
from pr650 import *

calDir = "calData/"

# Make sure that the two devices are writable by the user (e.g., sudo chmod a+rw /dev/ttyUSB*)
# you can figure out the devices on linux with something like:
# dmesg | tail
# then, look for 
#    "FTDI USB Serial Device converter now attached to ttyUSB2" (that's the arduino device)
#    "pl2303 converter now attached to ttyUSB3" (that's the PR650)
arduinoDev = '/dev/ttyUSB0'
pr650Dev   = '/dev/ttyUSB1'

# You must run this command within a few seconds after turning the PR650 on. 
# Otherwise, it will reset itself to command mode.
pr650 = PR650(pr650Dev)
pr650.measure()

ledSer = serial.Serial(arduinoDev, 57600, timeout=1)
# Get the arduino serial number
# (ONLY WORKS ON LINUX!)
#out = subprocess.Popen("/sbin/udevadm info -a -n "+arduinoDev+" | grep '{serial}' | head -n1", shell=True, stdout=subprocess.PIPE).communicate()[0]
# or, use the usb module (sudo yum install pyusb): import usb

# default serial params: 8 bits, parity none, stopbits 1
time.sleep(1)
# Display the ledFlicker greeting
out = ledSer.readlines()
for l in out: print(l),
# display help
#ledSer.write('[?]\n');
#out = ledSer.readlines()
#for l in out: print(l),

# Get pylab ready for interactive figure plotting (allows us to plot data as we go).
pylab.ion()
col = ['m','g','r','b','c','y']
fig = pylab.figure(figsize=(14,6))
# initialize the spectra subplot
spectAx = fig.add_subplot(1,2,1,title='Spectra',xlabel='Wavelength (nm)',ylabel='Power (watts/sr/m^2/nm)')
spectAx.grid(True)
# initialize the gamma figure
gammaAx = fig.add_subplot(1,2,2,title='Luminance',xlabel='time',ylabel='Luminance (cd/m^2)')
gammaAx.grid(True)
pylab.draw()

# Initialze the calibration params
nChannels = 6
meanLevel = 2047
pwmLevels = array((1023, meanLevel, meanLevel+1023))
nLevels = pwmLevels.shape[0]
timePts = array(range(0,125*60,5*60))
nTimes = timePts.shape[0]

offCmd = "[m,0]\n"
meanCmd = "[m,%d]\n" % meanLevel

# Start with all LEDs off (if they weren't off until now, add a sleep here)
ledSer.write(offCmd)

for i in range(5,0,-1):
    print "Starting %d measurements on %d channels in %d sec..." % (nLevels,nChannels,i)
    time.sleep(1)

# measure gamma/spectra
gamma = zeros((nChannels,nLevels,nTimes));
specPow = zeros((101,nChannels,nLevels,nTimes))
curTime = zeros((nChannels,nLevels,nTimes));
startTime = time.time()
for t,timePt in enumerate(timePts):
    # Sleep for the target time (timePt) minus the elapsed time (time.time()-startTime)
    sleepTime = max((timePt - (time.time() - startTime), 0.0))
    print "Time point measurement %d of %d (sleeping %0.1f minutes)..." % (t+1,nTimes,sleepTime/60.0)
    if t>0:
        ledSer.write(meanCmd)
    # Sleep for the target time (timePt) minus the elapsed time (time.time()-startTime)
    time.sleep(sleepTime)
    for j,pwm in enumerate(pwmLevels):
        for chan in range(nChannels):
            tmp = zeros((nChannels,1),'uint16')
            tmp[chan] = pwm
            pwmCmd = "[m,%d,%d,%d,%d,%d,%d]\n" % (tmp[0],tmp[1],tmp[2],tmp[3],tmp[4],tmp[5])
            ledSer.write(pwmCmd)
            out = ledSer.readlines()
            #for l in out: print(l),
            time.sleep(0.2)
            gamma[chan,j,t] = pr650.measureLum()
            # Note the time of this measurement
            curTime[chan,j,t] = time.time() - startTime
            # Go back to the baseline level
            if t==0:
                ledSer.write(offCmd)
            else:
                ledSer.write(meanCmd)
            [nm,s] = pr650.getSpectrum()
            specPow[:,chan,j,t] = s
            # Plot these measurements
            spectAx.plot(nm,specPow[:,chan,j,t],color=col[chan])
            gammaAx.plot(curTime[chan,j,t],gamma[chan,j,t],'o',color=col[chan],alpha=0.7)
            pylab.draw()

# Turn off all LEDs
ledSer.write(offCmd)

# Save the data in npz format
board = "mega1"
# manufacturer name _ manufacturer product # _ led number (0 or 1?)
ledName = "Rebel_stars"
calDate = time.strftime("%Y-%m-%d %H:%M:%S")
outName = calDir+"stability_"+board+"_"+time.strftime("%y%m%d%H%M")
savez(outName, board=board, ledName=ledName, calDate=calDate, nm=nm, specPow=specPow, 
      pwmLevels=pwmLevels, gamma=gamma, meanLevel=meanLevel, timePts=timePts, curTime=curTime)

# Save in matlab mat format
scipy.io.savemat(outName, {'board':board, 'ledName':ledName, 'calDate':calDate, 'nm':nm, 'specPow':specPow, 'pwmLevels':pwmLevels, 'gamma':gamma, 'timePts':timePts, 'curTime':curTime, 'meanLevel':meanLevel}, appendmat=True, format='5', long_field_names=True)




#for i in range(nRepeats):
#    for j,pwm in enumerate(pwmLevels):
#        for chan in range(nChannels):
#            pylab.plot(curTime[chan,j,:,i]/60.0,gamma[chan,j,:,i],'o-',color=col[chan],alpha=0.7)




