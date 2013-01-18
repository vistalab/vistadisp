

# Read the saved data: 
import numpy
import scpipy
import scipy.io
fname = 'mega1_led0_1008201750.npz'
npz = numpy.load(fname)
# To re-save in matlab mat format:
scipy.io.savemat(fname[:-4], {'board':npz['board'], 'ledName':npz['ledName'], 'calDate':npz['calDate'], 'nm':npz['nm'], 'specLum':npz['specLum'], 'specPow':npz['specPow'], 'pwmLevels':npz['pwmLevels'], 'gamma':npz['gamma']}, appendmat=True, format='5', long_field_names=True)

nm = npz['nm']
specPow = npz['specPow']
spec = numpy.mean(specPow[:,1:,:],2)
spec.tofile('spec.txt',sep=",")


sensors = numpy.fromfile('stockman4.txt',sep=' ')
sensors = sensors.reshape(101,4)
snm = sensors[:,0]
sensors = sensors[:,1:4]
if numpy.any(snm!=nm):
    raise NameError('Mismatch between sensor wavelengths and measured wavelengths!')

pylab.figure
pylab.plot(nm,sensors[:,0],'r',nm,sensors[:,1],'g',nm,sensors[:,2],'b')
pylab.xlabel('Wavelength (nm)')
pylab.ylabel('Relative absorption')
pylab.title('Cone Fundamentals')
pylab.show()

rgb2lms = numpy.dot(numpy.transpose(sensors), specMn[:,1:4])
lms2rgb = numpy.linalg.inv(rgb2lms)
#rgb2lms = numpy.round(rgb2lms/rgb2lms.max()*32767)
rgb2lms = rgb2lms/rgb2lms.max()

# Set the rgb2lms xform in the device
cmd = "[l,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f,%0.6f]\n" % (rgb2lms[0,0],rgb2lms[0,1],rgb2lms[0,2],rgb2lms[1,0],rgb2lms[1,1],rgb2lms[1,2],rgb2lms[2,0],rgb2lms[2,1],rgb2lms[2,2])
ledSer.write(cmd)
time.sleep(0.5)
out = ledSer.readlines()
for l in out: print(l),

# E.g., cmd='[l,0.407322,0.313378,0.226669,0.094211,0.361131,0.316449,0.026011,0.037678,1.000000]\n'

stimLMS = numpy.array([2,-1,0])
contrast = 1.0

lmsBack = numpy.dot(rgb2lms,(numpy.array([0.5,0.5,0.5])))
# Scale stimulus LMS by the background LMSscaledStimLMS = stimLMS * lmsBack
# Determine the stimulus RGB direction 
# Scale the stimLMS by the lms of the background and multiply by lms2rgbstimRGB = numpy.dot(lms2rgb,stimLMS * lmsBack)
# scale by the max so that it is physically realizablestimRGB = stimRGB/abs(stimRGB).max()*contrast
# compute the actual LMS contrast
actualLMS = numpy.dot(rgb2lms,stimRGB) / lmsBack / 2
print("ActualLMS contrast = [%0.2f, %0.2f, %0.2f]\n" % (actualLMS[0],actualLMS[1],actualLMS[2]) )

# ledSer = serial.Serial('/dev/ttyUSB0', 57600, timeout=1)
# Reset means and currents
#ledSer.write("[m,0.5,0.5,0.5,0.5,0.5,0.5][c,64,64,64]\n")
cmd = "[e,10,.2][w,0,1,0,%0.4f,%0.4f,%0.4f,0,0,0][p]\n" % (stimRGB[0],stimRGB[1],stimRGB[2])
ledSer.write(cmd)


