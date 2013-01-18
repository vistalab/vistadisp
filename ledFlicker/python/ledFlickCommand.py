#!/usr/bin/python
"""ledFlickCommand: simple wrapper to send ledFlicker commands from the shell.

Usage: python ledFlickCommand.py [options] [command] [command] ...in ("-h", "--help"):

Options:
  -d ..., --device=...    device (defaults to /dev/ttyUSB0)
  -h, --help              show this help
  -v, --verbose           show ledFlicker output

Examples:
  ledFlickCommand.py -d /dev/ttyUSB2 e,3,.2 w,0,1,0,1,-1,1,-1,1,-1 p

"""

__author__ = "Bob Dougherty <bobd@stanford.edu>"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: 2010.10.11 $"
__copyright__ = "Copyright (c) 2010 Bob Dougherty"
__license__ = "GPL"

import sys
import getopt
import serial

def usage():
    print __doc__

def main(argv):
    device = "/dev/ttyUSB0"
    verbose = False
    if(len(argv)==0):
        usage()
        sys.exit(2)

    try:
        opts, remainingArgs = getopt.getopt(argv, "hd:v", ["help", "device=","verbose"])
    except getopt.GetoptError, err:
        usage()
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-v", "--verbose"):
            verbose = True
        elif opt in ("-d", "--device"):
            device = arg
    
    if verbose:
        print "Opening Arduino device (%s)" % device

    ledSer = serial.Serial(device, 57600, timeout=1)
    cmdStr = ""
    for cmd in remainingArgs:
        cmdStr = cmdStr + "["+cmd+"]\n"
    if verbose:
        print(cmdStr)

    ledSer.write(cmdStr)
    if verbose:
        out = ledSer.readlines()
        for l in out: print(l),

if __name__ == "__main__":
    main(sys.argv[1:])

