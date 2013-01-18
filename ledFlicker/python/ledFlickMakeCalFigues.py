import numpy, pylab, scipy, scipy.io

# load the data
calData = numpy.load('/home/bob/svn/vistadisp/ledFlicker/python/calData/stability_mega1_1009221112.npz')
nm = calData['nm']
specPow = calData['specPow']
curTime = calData['curTime']
gamma = calData['gamma']

pylab.ion()
col = ['m','g','r','b','c','y']
fig = pylab.figure(figsize=(14,14))
# initialize the spectra subplot
spectAx = fig.add_subplot(1,2,1,title='Spectra',xlabel='Wavelength (nm)',ylabel='Power (watts/sr/m^2/nm)')
spectAx.grid(True)
# initialize the gamma figure
gammaAx = fig.add_subplot(1,2,2,title='Luminance',xlabel='time',ylabel='Luminance (cd/m^2)')
gammaAx.grid(True)
pylab.draw()

for chan in range(specPow.shape[1]):
    for pwm in range(specPow.shape[2]):
        for t in range(specPow.shape[3]):
            lh = spectAx.plot(nm,specPow[:,chan,pwm,t],color=col[chan])
        lh = gammaAx.plot(curTime[chan,pwm,:],gamma[chan,pwm,:],'o-',color=col[chan],alpha=0.7)
        pylab.draw()



