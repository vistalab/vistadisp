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

calDir = "calData"

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
gammaAx = fig.add_subplot(1,2,2,title='Gamma Calibration',xlabel='PWM value',ylabel='Luminance (cd/m^2)')
gammaAx.grid(True)
pylab.draw()

# Initialze the calibration params
nRepeats = 3;
nChannels = 6
#nLevels = 48
#pwmLevels = linspace(0,1023,nLevels)/1023
meanLevel = 2047
#pwmLevels = concatenate((array((1,5,10,15,4095,meanLevel)),arange(20,100,20),arange(100,4000,200),arange(4000,4100,20)))
pwmLevels = concatenate((array((1,10,30,60,100,150,4095,meanLevel)),arange(200,4000,200)))
pwmLevels.sort()
nLevels = pwmLevels.shape[0]

offCmd = "[m,0]\n"
meanCmd = "[m,%d]\n" % meanLevel

# Set the mean level before the countdown to allow the LED die temperature to stabilize
ledSer.write(meanCmd)

for i in range(5,0,-1):
    print "Starting %d measurements on %d channels in %d sec..." % (nLevels,nChannels,i)
    time.sleep(1)

# Measure the spectra with all channels turned on at full blast (useful for detecting
# power supply issues when driving everything hard)
specPowAll = zeros((101,nRepeats))
specLumAll = zeros((nRepeats))
for i in range(nRepeats):
    ledSer.write("[m,4095,4095,4095,4095,4095,4095]\n")
    time.sleep(0.1)
    specLumAll[i] = pr650.measureLum()
    ledSer.write(meanCmd)
    [nm,s] = pr650.getSpectrum()
    specPowAll[:,i] = s
    # Plot these measurements
    spectAx.plot(nm,specPowAll[:,i],color='gray')
    gammaAx.plot(4095,specLumAll[i],'o',color='gray',alpha=0.7)
    pylab.draw()
    # Clear ledSerial buffer
    out = ledSer.readlines()

# Measure the dark level
specPowDark = zeros((101,nRepeats))
specLumDark = zeros((nRepeats))
for i in range(nRepeats):
    ledSer.write(offCmd)
    time.sleep(0.1)
    specLumDark[i] = pr650.measureLum()
    ledSer.write(meanCmd)
    [nm,s] = pr650.getSpectrum()
    specPowDark[:,i] = s
    # Plot these measurements
    spectAx.plot(nm,specPowDark[:,i],color='k')
    gammaAx.plot(0,specLumDark[i],'o',color='k',alpha=0.7)
    pylab.draw()
    # Clear ledSerial buffer
    out = ledSer.readlines()

# measure gamma/spectra
gamma = zeros((nChannels,nLevels,nRepeats));
specPow = zeros((101,nChannels,nLevels,nRepeats))
for i in range(nRepeats):
    print "Gamma measurement %d of %d..." % (i+1,nRepeats)
    for j,pwm in enumerate(pwmLevels):
        for chan in range(nChannels):
            ledSer.write(meanCmd)
            tmp = zeros((nChannels,1),'uint16')
            tmp[chan] = pwm
            pwmCmd = "[m,%d,%d,%d,%d,%d,%d]\n" % (tmp[0],tmp[1],tmp[2],tmp[3],tmp[4],tmp[5])
            ledSer.write(pwmCmd)
            out = ledSer.readlines()
            #for l in out: print(l),
            time.sleep(0.2)
            gamma[chan,j,i] = pr650.measureLum()
            # as soon as the measurment is over, go back to the mean
            ledSer.write(meanCmd)
            [nm,s] = pr650.getSpectrum()
            specPow[:,chan,j,i] = s
            # Plot these measurements
            spectAx.plot(nm,specPow[:,chan,j,i],color=col[chan])
            gammaAx.plot(pwm,gamma[chan,j,i],'o',color=col[chan],alpha=0.7)
            pylab.draw()

# Turn off all LEDs
ledSer.write(offCmd)

# Save the data in npz format
board = "mega1"
# manufacturer name _ manufacturer product # _ led number (0 or 1?)
ledName = "Rebel_stars"
calDate = time.strftime("%Y-%m-%d %H:%M:%S")
outName = calDir+board+"_"+time.strftime("%y%m%d%H%M")
savez(outName, board=board, ledName=ledName, calDate=calDate, nm=nm, specPow=specPow, 
      pwmLevels=pwmLevels, gamma=gamma, specLumDark=specLumDark, specPowDark=specPowDark,
      specLumAll=specLumAll, specPowAll=specPowAll, meanLevel=meanLevel)

# Save in matlab mat format
scipy.io.savemat(outName, {'board':board, 'ledName':ledName, 'calDate':calDate, 'nm':nm, 'specPow':specPow, 'pwmLevels':pwmLevels, 'gamma':gamma, 'specLumDark':specLumDark, 'specPowDark':specPowDark, 'specLumAll':specLumAll, 'specPowAll':specPowAll, 'meanLevel':meanLevel}, appendmat=True, format='5', long_field_names=True)






# to read the data: 
# import numpy
# npz = numpy.load('mega1_led0_1004071750.npz')
#  nm = npz['nm']
#  specPow = npz['specPow']
#  spec = numpy.mean(specPow[:,1:,:],2)
#  spec.tofile('spec.txt',sep=",")

specMn = mean(specPow,3)
specSd = std(specPow,3)
col = ['m','g','r','b','c','y']
pylab.figure(2)
for i in range(size(specMn,1)):
    for j in range(size(specMn,2)):
        pylab.errorbar(nm,specMn[:,i,j],specSd[:,i,j],color=col[i],capsize=0)

pylab.errorbar(nm,specPowAll.mean(1),specPowAll.std(1),color='gray',capsize=0)

pylab.xlabel('Wavelength (nm)')
pylab.ylabel('Power (watts/sr/m^2/nm)')
pylab.title('Spectral Calibration')
pylab.grid(True)

gammaMn = gamma.mean(2)
gammaSd = gamma.std(2)
# remove outliers


col = ['m','g','r','b','c','y']
pylab.figure(2)
for i in range(nChannels):
    pylab.errorbar(pwmLevels,gammaMn[i,:],gammaSd[i,:],color=col[i],capsize=0)

pylab.xlabel('PWM value')
pylab.ylabel('Luminance (cd/m^2)')
pylab.title('Gamma Calibration')
pylab.grid(True)


# TODO:
# * Implement a unique board identifier (use USB serial number?)
# * Store mean spectrum, gamma, and rgb2lms in some compact format on the device
# * Compute optimal currents based on calibration data
#   * optimize LMS contrasts?
#   * Set a particular white point?




