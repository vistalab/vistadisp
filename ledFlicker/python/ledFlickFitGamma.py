from scipy import *
from scipy.optimize import leastsq
import scipy.io
import numpy, pylab

calData = numpy.load('calData/mega1_1009171423.npz')
nm = calData['nm']
specPow = calData['specPow']
gamma = calData['gamma']
pwmLevels = calData['pwmLevels']

gammaMn = gamma.mean(2)
gammaSd = gamma.std(2)
col = ['m','g','r','b','c','y']

# To compute total power, we need to sum across the spectra bins and multiply by
# the bin size, in nanometers.
nmBinSize = mean(diff(nm))
totalPow = specPow.sum(0)*nmBinSize
powMn = totalPow.mean(2)
powSd = totalPow.std(2)

pylab.ion()
fig = pylab.figure(figsize=(14,6))
gammaAx = fig.add_subplot(1,2,1,title='Gamma',xlabel='PWM value',ylabel='Luminance (cd/m^2)')
gammaAx.grid(True)
powAx = fig.add_subplot(1,2,2,title='Total Power',xlabel='PWM value',ylabel='Total Power (watts/sr/m^2)')
powAx.grid(True)
pylab.draw()
for i in range(gammaMn.shape[0]):
    gammaAx.errorbar(pwmLevels,gammaMn[i,:],gammaSd[i,:],color=col[i],capsize=0)
    powAx.errorbar(pwmLevels,powMn[i,:],powSd[i,:],color=col[i],capsize=0)

pylab.ion()
fig = pylab.figure(figsize=(14,6))
normAx = fig.add_subplot(1,1,1,title='Normalized Luminance and Power',xlabel='PWM value',ylabel='Relative intensity')
normAx.grid(True)
pylab.draw()
for i in range(gammaMn.shape[0]):
    normAx.plot(pwmLevels,gammaMn[i,:]/gammaMn[i,:].mean(),color=col[i])
    normAx.plot(pwmLevels,powMn[i,:]/powMn[i,:].mean(),'--',color=col[i])


# A forth-order polynomial seems to achieve a good fit to the LED gamma curves. 
# These curves are mostly linear, but have two slight inflections; one at the 
# low end and one at the high end. Thus, we need at least a 4th order to fit 
# this shape. Based on trial-and-error, going to higher-order offers no benefit.

def residuals(p, y, x): 
    err = y-peval(x,p)
    return err

# The intercept is fixed at 0
def peval(x, p):
    return p[0]*x + p[1]*x**2 + p[2]*x**3 + p[3]*x**4

fig = pylab.figure(figsize=(14,6))
gammaAx = fig.add_subplot(1,2,1,title='Gamma Fit',xlabel='PWM value',ylabel='Relative Luminance')
gammaAx.grid(True)
invAx = fig.add_subplot(1,2,2,title='Inverse Gamma Fit',ylabel='PWM value',xlabel='Relative Luminance')
invAx.grid(True)
pylab.draw()
pGamma = zeros((gammaMn.shape[0],4))
pInvGamma = zeros((gammaMn.shape[0],4))
for i in range(gammaMn.shape[0]):
    x = pwmLevels
    y = gammaMn[i,:]
    y = y/y.max()
    p0 = array([1,.1,.01,.001])
    plsq = leastsq(residuals, p0, args=(y, x), maxfev=2000)
    pGamma[i,:] = plsq[0]
    gammaAx.plot(x,y,'o',x,peval(x,plsq[0]),'-',color=col[i])
    y = pwmLevels
    x = gammaMn[i,:]
    x = x/x.max()
    p0 = array([2000,6000,-9000,4000])
    plsq = leastsq(residuals, p0, args=(y, x), maxfev=2000)
    pInvGamma[i,:] = plsq[0]
    invAx.plot(x,y,'o',x,peval(x,plsq[0]),'-',color=col[i])
    pylab.draw()

print "Final parameters"
for i in range(pInvGamma.shape[0]):
    print "[g,%d,%4g,%4g,%4g,%4g]" % (i, pInvGamma[i,0], pInvGamma[i,1], pInvGamma[i,2], pInvGamma[i,3])

print "Piecewise inv gamma"
vals = linspace(0.0,1.0,257)
pwm = zeros((pInvGamma.shape[0],vals.shape[0]))
for i in range(pInvGamma.shape[0]):
    pwm[i,:] = peval(vals,pInvGamma[i,:])

# The first value should be at 0 since we forced a zero intercept.
# clip 4095.0 and force the last value to be 4095.0
pwm[pwm>4095.0] = 4095.0
pwm[:,-1] = 4095.0
for j in range(vals.shape[0]):
    print "[g,%d,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f]" % (j, pwm[0,j], pwm[1,j], pwm[2,j], pwm[3,j], pwm[4,j], pwm[5,j])

import serial
device = "/dev/ttyUSB1"
ledSer = serial.Serial(device, 57600, timeout=1)
out = ledSer.readlines()
for l in out: print(l)
# Set verbose mode
ledSer.write('[v,10]\n')
ledSer.flushInput()
for j in range(vals.shape[0]):
    cmd = "[g,%d,%.0f,%.0f,%.0f,%.0f,%.0f,%.0f]\n" % (j, pwm[0,j], pwm[1,j], pwm[2,j], pwm[3,j], pwm[4,j], pwm[5,j])
    ledSer.write(cmd)
    print ledSer.readline()
    ledSer.flushInput()


