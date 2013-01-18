"""
Class to control a PhotoResearch PR650 spectrophotometer
(http://www.photoresearch.com/)

Copyright 2010 Bob Dougherty

Based on code from the PsychoPy library (http://www.psychopy.org/)
Copyright (C) 2009 Jonathan Peirce
Distributed under the terms of the GNU General Public License (GPL).

"""

import numpy, sys, time, serial, string

class PR650:
    # An interface to the PR650 via the serial port. 

    def __init__(self, port):
        self.port = port
        self.isOpen = False
        self.com = False 
        self.quality = 0
        self.lum = None
        self.OK = True
        self.codes = {'OK':'000\r\n',#this is returned after measure 
                      '18':'Light Low',#these is returned at beginning of data 
                      '10':'Light Low', 
                      '00':'OK' 
                     } 
        self.com = serial.Serial(self.port, 9600, timeout=10) 
        try: 
            self.com.open() 
            self.isOpen=True 
            print("Successfully opened PR650 on port %s" %self.port)
            self.OK = True
            time.sleep(1.0) # pause to allow connection to come up
            reply = self.sendMessage('b1')  # turn on the backlight
            print 'PR650 reply: ', reply
        except: 
            print("PR650: Couldn't open serial port %s" %self.port) 
            print("Check permissions and lock files.")
            self.OK = False
            self.com.close()
            return None
        if reply != self.codes['OK']: 
            print("PR650 isn't communicating") 
            self.OK = False 
            self.com.close() # in this case we need to close the port again 
        else:
            reply = self.sendMessage('s01,,,,,,01,1') # send the 'set' command

    def sendMessage(self, message, timeout=0.5, DEBUG=False):
        # send command and wait specified timeout for response (must be long 
        # enough for low light measurements, which can take up to 30 secs)
        if message[-1]!='\n': message+='\n'
        # flush the read buffer
        self.com.read(self.com.inWaiting())
        #send the message
        self.com.write(message)
        self.com.flush()
        time.sleep(0.5) # Allow PR650 to keep up
        # get the reply
        self.com.setTimeout(timeout)
        if message in ['d5', 'd5\n']: # spectrum returns multiple lines
            return self.com.readlines()
        else:
            return self.com.readline()

    def measure(self, timeOut=30.0):
        t1 = time.clock()
        reply = self.sendMessage('m0', timeOut) # m0 = measure and hold data
        if reply==self.codes['OK']:
            raw = self.sendMessage('d2')
            xyz = string.split(raw,',') # parse into words
            self.quality = str(xyz[0])
            if self.codes[self.quality]=='OK':
                self.lum = float(xyz[3])
            else:
                self.lum = 0.0
        else:
            print("PR650 returned no data-- try a longer timeout") 

    def measureLum(self):
        self.measure()
        return self.lum

    def measureSpectrum(self):
        self.measure()
        raw = self.sendMessage('d5')
        return self.parseSpectrumOutput(raw), self.lum

    def getLum(self):
        return self.lum 

    def getSpectrum(self):
        # returns spectrum in a num array with 100 rows [nm, power] 
        raw = self.sendMessage('d5')
        return self.parseSpectrumOutput(raw)

    def parseSpectrumOutput(self, raw):
        # Parses the spectrum strings from the PR650 (command 'd5')
        nPoints = len(raw) 
        raw = raw[2:] 
        power = []
        nm = []
        for n, point in enumerate(raw):
            thisNm, thisPower = string.split(point,',')
            nm.append(float(thisNm))
            power.append(float(thisPower.replace('\r\n','')))
        # If the PR650 doesn't get enough photons, it won't update the spec buffer.
        # So, we need to check for that condition to avoid returning an old (incorrect) spectrum.
        
        if self.lum==0.0:
            return numpy.asfarray(nm), numpy.zeros(nPoints-2)
        else:
            return numpy.asfarray(nm), numpy.asfarray(power) 

