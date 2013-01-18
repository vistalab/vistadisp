/*
 * ledFlicker sketch for Arduino.
 * 
 * 
 * Six-channel, 12-bit, 2 kHz LED oscillator for visual experiments. 
 * 
 *
 * Copyright 2010 Bob Dougherty.
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You might have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * TO DO:
 *   - Store calibration emission spectra in EEPROM and allow the user to get 
 *     it out to compute color transforms.
 *   - Add general-purpose commands to set/get some digital pins and ADC reads.
 *     This would be useful for, e.g., interfacing with EEG or MR scanner.
 *   - Keep track of the number of hours of service for the LEDs. This would be
 *     helpful in keeping a good calibration schedule. (E.g., if you wanted to
 *     calibrate every 10 hours of operation.)
 *
 * HISTORY:
 * 2010.03.19 Bob Dougherty (bobd@stanford.edu) finished a working version.
 * 2010.04.02 Bob Dougherty: Major overhaul to allow 6 channels on Arduino Mega.
 * I also changed the code to allow each waveform to play out on multiple channels.
 * 2010.06.30 Bob: Major overhaul to the hardware design to support high-power 
 * LEDs. We no longer use the Allegro A6280 for a constant current source, so
 * I've elimated all the code related to the current adjustment. I've also removed
 * support for non-mega Arduinos.
 * 2010.09.13 Bob: Removed old color transform code and increased resolution to
 * 12-bits. 
 * 2010.10.13 Bob: Converted most of the waveform playout code to integer math
 * for better efficiency and added gamma correction (257 points per channel, 
 * with linear interpolation). 
 * 2010.12.11 Bob: Added the l (lobe flag) command to allow waveforms mono-phasic 
 * waveforms to be specified.
 */

#define VERSION "0.9"

#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/eeprom.h>

// Flash library is available from http://arduiniana.org/libraries/Flash/
// We make extensive use of this so that we can be verbose in our messages
// without using up precious RAM. (Using Flash saved us over 2Kb of RAM!)
#include <Flash.h>
#include <Messenger.h>

// atmega 168  has  16k flash, 512 EEPROM, 1k RAM
// atmega 328  has  32k flash,  1k EEPROM, 2k RAM
// atmega 1280 has 128k flash,  4k EEPROM, 8k RAM
// The code below is very tight on RAM because of the wave table.

// Serial port baud rate. 115.2 kbs seems to work fine. That's ~12 bytes/msec, 
// which should keep latencies low for short (30-50 byte) commands. Data integrity
// shouldn't be a problem since we are effectively communicating over USB. But, 
// just to be sure, we'll use 57.6 kbs.
#define BAUD 57600

// Waveform types
#define SQUAREWAVE 0
#define SINEWAVE 1

// F_CPU and __AVR_ATmega1280__ are defined for us by the arduino environment
// NOTE: we only support Arduino Mega!
#define PIN_LED1 11
#define PIN_LED2 12
#define PIN_LED3 13
#define PIN_LED4 2
#define PIN_LED5 3
#define PIN_LED6 5
// These must be powers of 2! (We use bit-shifting tricks to speed some calcualtions below.)
// See http://graphics.stanford.edu/~seander/bithacks.html#ModulusDivisionEasy
#define WAVE_SAMP_SHIFT 10
#define ENV_SAMP_SHIFT 7
#define NUM_WAVE_SAMPLES (1UL << WAVE_SAMP_SHIFT)
#define NUM_ENV_SAMPLES (1UL << ENV_SAMP_SHIFT)

#define PIN_TEMP 0     // Analog input pin for temperture sensor
#define PIN_FAN  4     // Digital input for fan speed detector
// NUM_CHANNELS should be 6 for now.
// Values <6 should work, but only 2 and 6 have been tested.
#define NUM_CHANNELS 6

// This pin will be used for general digital output
#define DIGITAL_OUT_PIN 8

#define NUM_WAVES 2

// g_interruptFreq is the same as the INTERRUPT_FREQ, except for qunatization
// error. E.g., INTERRUPT_FREQ might be 3000, but the actual frequency achieved
// is 3003.4 Hz. All calculations should use this actual frequency.
static float g_interruptFreq;

#define PI 3.14159265358979
#define TWOPI 6.28318530717959

// The maxval determines the resolution of the PWM output. E.g.:
// 255 for 8-bit, 511 for 9-bit, 1023 for 10-bit, 2047 for 11-bit, 4095 for 12 bit.
// Higher resolution means slower PWM frequency. I.e., 
//    PWM freq = F_CPU/(PWM_MAXVAL+1) 
// for fast PWM and
//    PWM freq = F_CPU/PWM_MAXVAL/2 
// for phase/freq correct PWM. E.g., for non-fast 12-bit PWM freq will be 1.95kHz.
#define PWM_MAXVAL 4095
#define PWM_MIDVAL (PWM_MAXVAL/2.0)
// Fast PWM goes twice as fast, but the pulses aren't as spectrally nice as
// the non-fast ("phase and frequency correct") PWM mode. Also, 'zero' is
// not quite zero (there is a narrow spike that is visible on the LEDs). All
// the spectral ugliness is way beyond what we can see, so fast PWM is fine if
// you don't need true zero. And, you can trade off some of the extra speed 
// for better resolution (see PWM_MAXVAL).
#define PWM_FAST_FLAG false

// We use globals because of the interrupt service routine (ISR) that is used to
// play out the waveforms. ISRs can't take parameters, but can access globals.
// TODO: maybe bundle all the globals into a single struct to keep them neat?
static int g_sineWave[NUM_WAVE_SAMPLES];
static int g_envelope[NUM_ENV_SAMPLES];

static unsigned int g_envelopeTicsDuration;
static unsigned int g_envelopeStartEnd;
static unsigned int g_envelopeEndStart;
static unsigned int g_envelopeDwell;

// We'll make the main clock counter a long int so that we can run for many
// hours before wrapping. Users generally want to run for a few seconds or
// run forever. So, we keep the other tic counters as ints for efficiency.
// With this configuration, we run precisely timed, temporally enveloped stimuli
// up to ~30 sec duration, or we run forever with no temporal envelope.
volatile unsigned long int g_envelopeTics;

static int g_amplitude[NUM_WAVES][NUM_CHANNELS];
static unsigned long int g_mean[NUM_CHANNELS];
static float g_sineInc[NUM_WAVES];
static byte  g_waveType[NUM_WAVES];
static unsigned int g_phase[NUM_WAVES];

// A set of flags to allow positive or negative lobes of the waveform to be clipped.
static byte g_lobe[NUM_CHANNELS];
#define LOBE_BIP 0
#define LOBE_POS 1
#define LOBE_NEG 2

//
// Define EEPROM variables for static configuration vars
//
// We don't bother setting defaults here; we'll check for valid values and set 
// the necessary defaults in the code.
//
char EEMEM gee_deviceId[16];
// The invGamma LUT maps the 257 values [0:256:65536] to the 0-4095 PWM values.
// This will use 3084 bytes (of the 4096 bytes available in the Arduino Mega EEPROM)
unsigned int EEMEM gee_gammaMagic;
char EEMEM gee_gammaNotes[64];
unsigned int EEMEM gee_invGamma[257*NUM_CHANNELS];
// The magic word ('LF' in ASCII) must be set to indicate that valid data has 
// been stored there. Anything else in that part of the EEPROM will trigger the 
// firmware to reload the default gamma when booting up.
#define EEMEM_MAGIC_WORD 0x4C46

// To use the inverse gamma params, we'll need to copy them to RAM. This uses a
// big chunk of our limited RAM.
unsigned int g_invGamma[257][NUM_CHANNELS];

// Instantiate Messenger object used for serial port communication.
Messenger g_message = Messenger(',','[',']');

char g_errorMessage[128];
// 0 for very quiet, 1 for some stuff, 2 for more stuff, etc.
byte g_verboseMode;

// I can't figure out how to pass the PROGMEM stuff via a function call, so 
// we'll just use a macro.
#define ERROR(str) {strncpy_P(g_errorMessage,PSTR(str),128);error();}

void error(){
  Serial << F("ERR");
  if(g_verboseMode>0)
    Serial << F(": ") << g_errorMessage;
  Serial << F("\n");
}

void commandOk(){
  strcpy_P(g_errorMessage, PSTR("OK")); // Copy up to 128 characters
  Serial << F("OK\n");
}

// Create the Message callback function. This function is called whener a complete 
// message is received on the serial port.
void messageReady() {
  if(g_verboseMode>1) g_message.echoBuffer();
  float val[max(2*NUM_CHANNELS,12)];
  int i = 0;
  if(g_message.available()) {
    // get the command byte
    char command = g_message.readChar();
    switch(command) {
    
    case '?': // display help text
      Serial << F("All ledFlicker commands must be enclosed in square brackets ([]); all characters\n");
      Serial << F("outside of the brackets are ignored. Each command begins with a single letter\n");
      Serial << F("(defined below), followed by some parameters. Parameters are separated by a comma.\n\n");
      Serial << F("Commands (optional params are enclosed in parens with default value):\n\n");
      Serial << F("[?]\n");
      Serial << F("    Help (displays this text).\n");
      Serial << F("[m"); for(i=1; i<=NUM_CHANNELS; i++){ Serial << F(",val") << i; } Serial << F("]\n");
      Serial << F("    Set the mean outputs (0 - ") << PWM_MAXVAL << F(") for all channels.\n");
      Serial << F("[e,duration,riseFall]\n");
      Serial << F("    Set the envelope duration and rise/fall times (in seconds, max = ") << 65535.0/g_interruptFreq << F(" secs).\n");
      Serial << F("    Set duration=0 for no envelope and infinite duration. The envelope setting is preserved\n");
      Serial << F("    until the firmware is rebooted.\n");
      Serial << F("[l,l0,l1,l2,l3,l4,l5]\n");
      Serial << F("    Set six flags (one for each channel) that determine if the waveforms are played in full\n");
      Serial << F("    (0, the default), only the positive lobe is played (1), or only the negative lobe is played (-1).\n");
      Serial << F("    As with the envelope, this setting is preserved until the firmware is rebooted.\n");
      Serial << F("[w,waveNum,frequency,phase,amp0,amp1,...]\n");
      Serial << F("    Set waveform parameters for the specified waveform number (up to ") << NUM_WAVES << F(").\n");
      Serial << F("    Phase is 0-1, with 0.5 = pi radians. Amplitudes are -1 to 1.\n");
      Serial << F("[p]\n");
      Serial << F("    Play the waveforms. If the duration is infinite, then you only need to run\n");
      Serial << F("    this command once, even if waveform parmeters are changed.\n");
      Serial << F("[h]\n");
      Serial << F("    Halt waveform playout. This is especially useful with an infinite duration.\n");
      Serial << F("[s]\n");
      Serial << F("    Status information. If the previous command failed with an ERR, you can use this\n");
      Serial << F("    to see the error message. Also shows the time remaining for current playout.\n");
      Serial << F("[v,mode]\n");
      Serial << F("    Set verbosity mode. 0 for very quiet (just OK or ERR), 1 to show errors, 2 or higher for everything.\n");
      Serial << F("[c,waveNum]\n");
      Serial << F("    Check the currently specified waveform. Prints some internal variables and waveform stats.\n");
      Serial << F("[d,waveNum]\n");
      Serial << F("    Dump the specified wavform. (Dumps a lot of data to your serial port!\n\n"); 
      Serial << F("[g,lutSlice,ch0,ch1,ch2.ch3,ch4,ch5]\n");
      Serial << F("    Set the inverse gamma LUT values and store them in EEPROM. The gamma tables will \n");
      Serial << F("    be loaded automatically each time the board boots up. The computed (internal) modulation\n");
      Serial << F("    values (s) are in the range [0,65536]. The PWM value produced for internal modulation value s is:\n");
      Serial << F("       pwm = ((s%16)*lut[s>>4] + (16-s%16)*lut[s>>4+1]) / 16 \n");
      Serial << F("    There are 6 gamma tables (one for each output channel). Each gamma maps 257 internal modulation\n");
      Serial << F("    values ([0:256:65536]) to the 0-4095 PWM values according to the formula above, which includes\n");
      Serial << F("    linear interpolation for values between the 257 entries in the gamma LUTs. When setting the gamma\n");
      Serial << F("    tables, pass the 6 pwm values for one of the 257 slices through the 6 tables.\n");
      Serial << F("    Call this with no args to see the all the LUT values currently stored in EEPROM.\n"); 
      Serial << F("    Call this with just lutSlice to see the the LUT values for the specified slice of the gamma tables.\n");
      Serial << F("\nFor example:\n");
      Serial << F("[e,10,0.2][w,0,3,0,.3,-.3,0,0,0,.9][p]\n\n");
      break;
      
    case 'm': // Set mean outputs
      while(g_message.available()) val[i++] = g_message.readFloat();
      if(i!=1 && i!=NUM_CHANNELS){
        ERROR("ERROR: Set outputs requires one param or 6 params.");
      }else{
        stopISR();
        if(i==1){
          setAllMeans(val[0]);
        }else{
          for(i=0; i<NUM_CHANNELS; i++)
            setMean(i, val[i]);
        }
        applyMeans();
        commandOk();
        if(g_verboseMode>1) 
          Serial << F("Means set to ["); for(i=0; i<NUM_CHANNELS; i++) Serial << (g_mean[i]>>19) << F(" "); Serial << F("]\n");
      }
      break;
      
    case 'e': // Set envelope params
      while(g_message.available()) val[i++] = g_message.readFloat();
      if(i<2){
        ERROR("ERROR: envelope setup requires 2 parameters.\n");
      }else{
        stopISR();
        float dur = setupEnvelope(val[0], val[1]);
        commandOk();
        if(g_verboseMode>1)
          Serial << F("Envelope configured; actual duration is ") << dur << F(" seconds.\n");
      }
      break;

    case 'l': // Set lobe-cutting flags
      while(g_message.available()) val[i++] = g_message.readFloat();
      if(i<6){
        ERROR("ERROR: lobe setup requires 6 parameters.\n");
      }else{
        for(i=0; i<NUM_CHANNELS; i++){
          if(val[i]<0)      g_lobe[i] = LOBE_NEG;
          else if(val[i]>0) g_lobe[i] = LOBE_POS;
          else              g_lobe[i] = LOBE_BIP;
        }
        commandOk();
      }
      break;


    case 'w': // setup waveforms
      while(g_message.available()) val[i++] = g_message.readFloat();
      if(i<3+NUM_CHANNELS){ // wave num, freq, phase, and amplitudes are mandatory
        ERROR("ERROR: waveform setup requires at least 3 parameters.\n");
      }else{
        //stopISR();
        // setup the waveform. params are: wave num, freq, phase, amp[]
        if(val[0]>=0&&val[0]<NUM_WAVES){
          setupWave((byte)val[0], val[1], val[2], &val[3]);
          commandOk();
        }else{
          ERROR("ERROR: waveform setup requires first param to be a valid wave number.\n");
        }
      }
      break;

    case 'p': // play waveforms
      // Reset state variables
      g_envelopeTics = 0;
      // NOTE: g_sineInc is not reset here. So, you must call setupWave before playing.
      startISR();
      commandOk();
      break;

    case 'h': // halt waveform playout
      stopISR();
      applyMeans();
      commandOk();
      break;

    case 's': // return status
      Serial << F("Last status message: ") << g_errorMessage << F("\n");
      Serial.println(((float)g_envelopeTicsDuration-g_envelopeTics)/g_interruptFreq,3);
      Serial << F("LED temperature: ") << (float)getTemp() << F(" C");
      Serial << F(", Fan speed: ") << getFanSpeed() << F(" RPMs\n");
      commandOk();
      break;

    case 'v':
      if(g_message.available()){
        val[0] = g_message.readInt();
        if(val[0]<=0)      g_verboseMode = 0;
        else if(val[0]>10) g_verboseMode = 10;
        else               g_verboseMode = val[0];
        commandOk();
      }
      break;
      
    case 'c':
      if(g_message.available()){
        val[0] = g_message.readInt();
        validateWave(val[0]);
        commandOk();
      }
      else ERROR("ERROR: check command requires a channel parameter.\n");
      break;

    case 'd':
      if(g_message.available()){
        stopISR();
        val[0] = g_message.readInt();
        dumpWave((byte)val[0]);
        commandOk();
      }
      else ERROR("ERROR: dump command requires a channel parameter.\n");
      break;
      
    case 'g': 
      // Set inverse gamma LUT. We can't pass too much data at one time, so we set one slice at a time.
      // *** WORK HERE: allow a string to be sent in to set the gamma note string.
      while(g_message.available()) val[i++] = g_message.readFloat();
      if(i<1){
        dumpInvGamma();
        commandOk();
      }else if(i==1){
        dumpInvGammaSlice((int)val[0]);
        commandOk();
      }else if(i!=7){
        ERROR("ERROR: g requires either 0 or 1 args (to dump current vals), or 7 values to set the inv gamma for a LUT entry!\n");
      }else if(val[0]<0 || val[0]>=257){
        ERROR("ERROR: First argument is the LUT entry number and must be >=0 and <257.\n");
      }else{
        setInvGamma((int)val[0], &(val[1]));
        commandOk();
      }
      break;
    default:
      Serial << F("[") << command << F("]\n");
      ERROR("ERROR: Unknown command. ");
    } // end switch
  } // end while
}

// Precompute the digital output register and bitmask.
// TO DO: wrap this in a fast I/O class
#include "pins_arduino.h"
volatile uint8_t *g_digOutReg;
uint8_t g_digOutBit;

void setup(){
  Serial.begin(BAUD);
  Serial << F("*********************************************************\n");
  Serial << F("* ledFlicker firmware version ") << VERSION << F("\n");
  Serial << F("* Copyright 2010 Bob Dougherty <bobd@stanford.edu>\n");
  Serial << F("* http://vistalab.stanford.edu/newlm/index.php/LedFlicker\n");
  Serial << F("*********************************************************\n\n");
  
  pinMode(DIGITAL_OUT_PIN, OUTPUT);
  digitalWrite(DIGITAL_OUT_PIN, HIGH); 
  g_digOutReg =  portOutputRegister(digitalPinToPort(DIGITAL_OUT_PIN));
  g_digOutBit = digitalPinToBitMask(DIGITAL_OUT_PIN);
  
  // Compute the wave and envelope LUTs. We could precompute and store them in 
  //flash, but they only take a few 10's of ms to compute when we boot up and it
  // simplifies the code. However, they do use much precious RAM. If the RAM 
  // limit becomes a problem, we might considerlooking into storing them in 
  // flash and using PROGMEM to force the compiler to read directly from flash.
  // However, the latency of such reads might be too long.
  Serial << F("Computing wave LUT: \n");
  unsigned long ms = millis();
  // Sumary of waveform int32 integer math:
  // sinewave:  11 bits (10 bit value + sign bit)
  // envelope:   8 bits
  // amplitude: 13 bits (12 bit value + sign bit)
  //     total: 32 bits
  // The sinewave is represented by 11 bits (10 + sign bit):
  for(int i=0; i<NUM_WAVE_SAMPLES; i++)
    g_sineWave[i] = (int)round(sin(TWOPI*(float)i/NUM_WAVE_SAMPLES)*1024.0f);
  // The envelope is represented by 8 bits:
  // This will be a gaussian envelope with an SD of ~2
  float twoSigmaSquared = 2.0f*(NUM_ENV_SAMPLES/3)*(NUM_ENV_SAMPLES/3);
  for(int i=0; i<NUM_ENV_SAMPLES; i++)
    g_envelope[i] = (int)round(exp(-(NUM_ENV_SAMPLES-1.0f-i)*(NUM_ENV_SAMPLES-1.0f-i)/twoSigmaSquared) * 256.0f);
    //g_envelope[i] = (int)round((0.5f - cos(PI*i/(NUM_ENV_SAMPLES-1.0f))/2.0f) * 256.0f);
  ms = millis()-ms;
  Serial << NUM_WAVE_SAMPLES << F(" samples in ") << ms << F(" miliseconds.\n");

  if(PWM_FAST_FLAG) Serial << F("Initializing fast PWM on timer 1.\n");
  else              Serial << F("Initializing phase/frequency correct PWM on timer 1.\n");
  float pwmFreq = SetupTimer1(PWM_MAXVAL, PWM_FAST_FLAG);
  Serial << F("PWM Freq: ") << pwmFreq << F(" Hz; Max PWM value: ") << PWM_MAXVAL << F("\n");

  g_interruptFreq = pwmFreq;
  Serial << F("Interrupt Freq: ") << g_interruptFreq << F(" Hz\n");
  
  
  //setInvGammaNotes("FIXME: implement gamma notes.");
  // Load inverse gamma from EEPROM into RAM
  Serial << F("Loading stored inverse gamma LUT.\n");
  const char *gammaNotes = loadInvGamma();
  if(gammaNotes!=NULL)
    Serial.println(gammaNotes);
  else
    Serial << F("Inv gama data is invalid- loaded default linear gamma.\n");

  // Set waveform defaults
  Serial << F("Initializing all waveforms to zero amplitude.\n");
  float amp[6] = {0.0,0.0,0.0,0.0,0.0,0.0};
  for(int i=0; i<NUM_WAVES; i++) setupWave(i, 0.0, 0.0, amp);
  Serial << F("Initializing all means to ") << 0.5 << F("\n");
  setAllMeans(0.5f);
  applyMeans();
  setupEnvelope(3.0, 0.2);
  float amps[6] = {0.9,0.9,0.9,0.9,0.9,0.9};
  setupWave(0, 1.0, 0, amps);
  // Default is bi-phaseic waveform
  for(int i=0; i<NUM_CHANNELS; i++) 
    g_lobe[i] = LOBE_BIP;
  
  // Attach the callback function to the Messenger
  g_message.attach(messageReady);
  
  // Configure analog inputs to use the internal 1.1v reference.
  // See: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1264707156
  analogReference(2);
  //pinMode(PIN_TEMP, INPUT);  // Make sure temperature pin is set for input 
  pinMode(PIN_FAN, INPUT);

  // Set to quiet
  Serial << F("Setting verbose mode to quiet; use [v,1] or [v,2] to increase verbosity.\n");
  g_verboseMode = 0;
  
  Serial << F("ledFlicker Ready. Send the ? command ([?]) for help.\n");
  Serial << F("There are ") << g_message.FreeMemory() << F(" bytes of RAM free.\n\n");
  digitalWrite(DIGITAL_OUT_PIN, LOW);
}

void loop(){
  // The most effective way of using Serial and Messenger's callback:
  while(Serial.available())  g_message.process(Serial.read());
}

bool isGammaValid(){
  unsigned int magicWord = eeprom_read_word(&gee_gammaMagic);
  if(magicWord==EEMEM_MAGIC_WORD) return(true);
  return(false);
}
void setGammaValid(){
  // EEPROM has a limited # of write cycles, so we avoid unecessary writes.
  if(!isGammaValid()) eeprom_write_word(&gee_gammaMagic, EEMEM_MAGIC_WORD);
}

const char * getGammaNotes(){
  static char notes[64];
  eeprom_read_block((void*)notes, (const void*)gee_gammaNotes, 64);
  return(notes);
}

// Copies the global inverse gamma LUT from EEPROM.
// The inv gamma tables are arranged as a [257][6] int16 array.
const char * loadInvGamma(){
  if(isGammaValid()){
    for(int lutIndex=0; lutIndex<257; lutIndex++)
      eeprom_read_block((void*)&g_invGamma[lutIndex][0], (const void*)&gee_invGamma[lutIndex*6], 6*sizeof(unsigned int));
    return(getGammaNotes());
  }else{
    // gamma data are not valid- load a default LUT.
    for(int i=0; i<257; i++)
      for(byte j=0; j<6; j++)
        g_invGamma[i][j] = (unsigned int)round(i*15.99609375); // less than 16 to get to 4095 rather than 4096.
    return(NULL);
  }
}

// Copies the global inverse gamma parameters from EEPROM.
// If invGamma is not null, then the EEPROM data is updated with the new matrix before setting the globals.
void setInvGamma(int lutIndex, float invGammaSlice[]){
  // The inv gamma tables is arranged as a [6][257] uint16 array. 
  // We accept data as a float array and convert to an int array.
  if(lutIndex<257){
    if(invGammaSlice!=NULL){
      unsigned int slice[6];
      for(byte i=0; i<6; i++) slice[i] = (unsigned int)round(invGammaSlice[i]);
      eeprom_write_block((void*)slice, (void*)&gee_invGamma[lutIndex*6], 6*sizeof(unsigned int));
      // When the last slice is saved, set the gamma as valid
      if(lutIndex==256){
        setGammaValid();
      }
    }
    eeprom_read_block((void*)&g_invGamma[lutIndex][0], (const void*)&gee_invGamma[lutIndex*6], 6*sizeof(unsigned int));
  }
}

void setInvGammaNotes(char notes[]){
  // Load a notes string into the gamma notes EEMEM.
  // We want to save the null-terminator too, so we +1.
  unsigned int n = strlen(notes)+1;
  if(n>=64)
    eeprom_write_block((void*)notes, (void*)&gee_gammaNotes, 64);
  else
    eeprom_write_block((void*)notes, (void*)&gee_gammaNotes, n);
}

void dumpInvGamma(){
  for(int i=0; i<257; i++){
    dumpInvGammaSlice(i);
  }
  Serial.println(getGammaNotes());
}

void dumpInvGammaSlice(int i){
    Serial << F("[g,") << i << F(",") << g_invGamma[i][0] << F(",") << g_invGamma[i][1] << F(",") << g_invGamma[i][2] << F(",")
                                      << g_invGamma[i][3] << F(",") << g_invGamma[i][4] << F(",") << g_invGamma[i][5] << F("];\n");
}


void setupWave(byte wvNum, float freq, float ph, float *amp){
  static unsigned int maxWaveIndex = NUM_WAVE_SAMPLES-1;
  byte i;
  
  // Phase comes in as a relative value (0-1); convert to the index offset.
  g_phase[wvNum] = (unsigned int)round(ph*maxWaveIndex);
  // Amplitude is -1 to 1 (negative inverts phase)
  if(amp!=NULL){
    // Now set the amplitudes in the global.
    // The amplitude is represented by 13 bits (12 + sign bit):
    for(i=0; i<NUM_CHANNELS; i++)
      g_amplitude[wvNum][i] = (int)round((amp[i]*4096.0f));
  }else{
    for(i=0; i<NUM_CHANNELS; i++)
      g_amplitude[wvNum][i] = 0;
  }
  // the incremetor determines the output freq.
  // Wew scale by NUM_WAVE_SAMPLES/g_interruptFreq to convert freq in Hz to the incremeter value.
  g_sineInc[wvNum] = fabs(freq)*NUM_WAVE_SAMPLES/g_interruptFreq;
  if(freq<0)
    g_waveType[wvNum] = SQUAREWAVE;
  else
    g_waveType[wvNum] = SINEWAVE;
    
}

/* WOKRK HERE */
//void initWaves(){
//  for(byte wv=0; wv<NUM_WAVES; wv++)
//    g_sineInd[wv] = g_phase[wv];
//}

void setOutput(byte chan, unsigned int val){
  // Set PWM output to the specified level
  if(val>PWM_MAXVAL) val = PWM_MAXVAL;
  switch(chan){
  case 0: 
    OCR1A = val; 
    break;
  case 1: 
    OCR1B = val; 
    break;
#ifdef __AVR_ATmega1280__
  case 2: 
    OCR1C = val; 
    break;
  case 3: 
    OCR3B = val; 
    break;
  case 4: 
    OCR3C = val; 
    break;
  case 5: 
    OCR3A = val; 
    break;
#endif
  }
}

void setAllMeans(float val){
  for(byte i=0; i<NUM_CHANNELS; i++)
    setMean(i,val);
}

void setMean(byte chan, float val){
  if(val<0.0)      val = 0.0;
  else if(val>1.0) val = 1.0;
  // To save some ops during waveform playout, we save the means as scaled values (scale factor is 2^19).
  g_mean[chan] = ((unsigned long int)round(val*4095))<<19;
}

void applyMeans(){
  // Set PWM output to mean level for all channels
  // The means range from 0-4095 (2^12), but are stored as scaled by 2^19, so range from 0 - 2^31. 
  // getPwmFromLUT is expecting them to be 0 - 2^16, so we need to divide by 2^15.
  for(byte i=0; i<NUM_CHANNELS; i++)
    setOutput(i, getPwmFromLUT(i, g_mean[i]>>15));
}

float setupEnvelope(float duration, float envRiseFall){
  // Configure the envelope global values
  // envelope rise/fall time is translated to the g_envelope incrementer
  // g_envelopeTicsDuration is an unsigned int, so the max number of tics is 65535.
  // A duration of 0 means no envelope- run forever.
  if(duration*g_interruptFreq>65535.0)
    duration = 65535.0/g_interruptFreq;
  g_envelopeTicsDuration = (unsigned int)(duration*g_interruptFreq);
  if(g_envelopeTicsDuration==0){
    duration = 0.0f;
    g_envelopeDwell = 0;
  }else{
    g_envelopeDwell = (unsigned int)round(envRiseFall/((float)NUM_ENV_SAMPLES/g_interruptFreq));
    g_envelopeStartEnd = (NUM_ENV_SAMPLES-1)*g_envelopeDwell;
    g_envelopeEndStart = g_envelopeTicsDuration-g_envelopeStartEnd;
  }
  // initialize the state variable
  g_envelopeTics = 0;
  return(duration);
}

inline int getEnvelopeVal(unsigned long int curTics){
  static const unsigned int maxEnvelopeIndex = NUM_ENV_SAMPLES-1;
  unsigned int envIndex;

  // Must be careful of overflow. For interrupt freq of 2kHz, max duation is ~ 32 secs. For 4kHz it is ~16.
  // We could switch to long ints if needed.
  
  // TO DO: switch to interger arithmatic, make dwell a power of 2, and use bit-shifting for the division.

  if(g_envelopeDwell==0 || (curTics>g_envelopeStartEnd && curTics<g_envelopeEndStart)){
    return(256);
  }
  if(curTics<=g_envelopeStartEnd){
    envIndex = ((unsigned int)curTics/g_envelopeDwell);
  }else{
    envIndex = (g_envelopeTicsDuration-(unsigned int)curTics)/g_envelopeDwell;
  }
  // TO DO: replace with properly-rounded integer math.
  return(g_envelope[envIndex]);
}


// This is the core function for waveform generation. It is called in the 
// ISR to output the waveform to the PWNM channels. 
inline void updateWave(unsigned long int curTics, unsigned int envVal, unsigned int *vals){
  // This function takes about 280us to run (NUM_WAVES==1, at 16MHz).
  // Matlab code illustrating the principle behind the integer-math used here:
  // s = int32(round(sin(linspace(0,2*pi,1024))*2048)); % 12 bits for the sinewave (-2048 to 2048)
  // amp = int32(2048);                        % 12-bits for the amplitude (-2048 to 2048)
  // env = int32(256);                         % 8-bits for the envelope (0 to 256)
  // mean = bitshift(uint32(2048),19);         % actual mean PWM value is scaled by 2^19
  // % Note that we are using signed int32's, so we have 31 bits. 31-12 = 19.
  // The resulting waveform (in the range 0-4096) is given by:
  // w = bitshift(s*amp*env+mean,-19);
  // 
  byte wv, ch;
  long int envSine;
  unsigned long int lvals[NUM_CHANNELS];
  unsigned long int sineIndex;
  static byte lastWaveSign = 0;
  
  // Initialize each channel to the mean value
  for(ch=0; ch<NUM_CHANNELS; ch++)
    lvals[ch] = g_mean[ch];
  
  for(wv=0; wv<NUM_WAVES; wv++){
    //unsigned int sineIndex = (unsigned long int)((g_sineInc[wv]*curTics+0.5)+g_phase[wv])%NUM_WAVE_SAMPLES;
    sineIndex = (unsigned long int)((g_sineInc[wv]*curTics+0.5)+g_phase[wv]);
    // As long as NUM_WAVE_SAMPLES is a power of 2, this is equivalent to sineIndex = sineIndex % NUM_WAVE_SAMPLES
    // This should be a little faster than %.
    sineIndex = sineIndex & (NUM_WAVE_SAMPLES - 1);
    if(g_waveType[wv]==SQUAREWAVE){
      // squarewave (thresholded sine)
      if(g_sineWave[sineIndex]>0)      envSine =  1024L*(long int)envVal;
      else if(g_sineWave[sineIndex]<0) envSine = -1024L*(long int)envVal;
      else{
        // Special case for zero alternate so that we have a symmetric duty cycle (on average)
        if(lastWaveSign==0){
          envSine =  1024L*(long int)envVal;
          lastWaveSign = 1;
        }else{
          envSine = -1024L*(long int)envVal;
          lastWaveSign = 0;
        }
      }
    }else{
      // Only other option is a sinewave.
      envSine = (long int)envVal*g_sineWave[sineIndex];
    }
    for(ch=0; ch<NUM_CHANNELS; ch++){
      if(g_lobe[ch]==LOBE_BIP || (g_lobe[ch]==LOBE_NEG && envSine<0) || (g_lobe[ch]==LOBE_POS && envSine>0))
        lvals[ch] += (envSine*g_amplitude[wv][ch]);
    }
  }
  for(ch=0; ch<NUM_CHANNELS; ch++) {
    // Convert to 0-65536 for gamma correction:
    vals[ch] = getPwmFromLUT(ch, lvals[ch]>>15);
  }
  //Serial << vals[0] << F(",") << envSine<< F(",") << lvals[0] << F(";");
}

unsigned int getPwmFromLUT(byte ch, unsigned long int rawVal){
  // Input values should be 0-65536- run them through the invGamma LUT.
  unsigned int outVal;
  // Treat the ends as special cases:
  if(rawVal>65535){
    outVal = g_invGamma[256][ch];
  }else if(rawVal==0){
    outVal = g_invGamma[0][ch];
  }else{
    // Get the index into the 257-entry gamma table that is at the lower bound of tmp:
    unsigned int lowerInd = (unsigned int)(rawVal>>8);
    // This is a fast way to compute tmp % 16:
    unsigned int mod = rawVal & (unsigned int)15;
    // The following calc should just fit into an unsigned int. The highest possible value is
    // 1*4095 + 15*4095. (That's assuming the invGamma has values in the proper range.)
    // We are doing a simple linear interpolation using pure integer math for speed. 
    // The +8 assures proper rounding.
    outVal = ((16-mod)*g_invGamma[lowerInd][ch] + mod*g_invGamma[lowerInd+1][ch] + 8)>>4;
  }
  return(outVal);
}

//unsigned int getPwmFromLUT(byte ch, float rawVal){
//  return(getPwmFromLUT(ch, (unsigned long int)round(rawVal*65536.0f)));
//}

void validateWave(byte chan){
  unsigned int maxVal = 0;
  unsigned int minVal = 65535;
  float mnVal = 0.0;
  unsigned int val[NUM_CHANNELS];
  byte wvNum = 0;

  Serial << F("sineInc: ") << g_sineInc[wvNum] << F("\n");
  Serial << F("envTicsDwell: ") << g_envelopeDwell << F("\n");
  Serial << F("envTicsDuration: ") << g_envelopeTicsDuration << F("\n");
  Serial << F("envelopeStartEnd: ")<< g_envelopeStartEnd << F("\n");
  Serial << F("envelopeEndStart: ") << g_envelopeEndStart << F("\n");
  
  Serial << F("Channel ") << (int)chan << F(":\n");
  Serial << F("      amplitude: ") << (float)g_amplitude[0][chan]/4096.0f << F("\n");
  Serial << F("           mean: ") << (g_mean[chan]>>19) << F(" (PWM=") << getPwmFromLUT(chan,g_mean[chan]>>15) << F(")\n");
  for(unsigned int i=0; i<g_envelopeTicsDuration; i++){
    updateWave(i, getEnvelopeVal(i), val);
    if(val[chan]>maxVal) maxVal = val[chan];
    if(val[chan]<minVal) minVal = val[chan];
    mnVal += (float)val[chan]/g_envelopeTicsDuration;
  }
  Serial << F(" [min,mean,max]: ") << minVal << F(",") << (int)(mnVal+0.5) << F(",") << maxVal << F("\n");
}

void dumpWave(byte chan){
  unsigned int val[NUM_CHANNELS];
  
  Serial << F("wave=[");
  for(unsigned int i=0; i<g_envelopeTicsDuration; i++){
    updateWave(i, getEnvelopeVal(i), val);
    Serial << val[chan] << F(",");
  }
  Serial << F("];\n");
}


// 
// Timer 1 (and 3, if on a Mega) Configuration
// 
// See: http://www.uchobby.com/index.php/2007/11/24/arduino-interrupts/
// 
// Bit-primer:
//   Setting a bit: byte |= 1 << bit;
//   Clearing a bit: byte &= ~(1 << bit);
//   Toggling a bit: byte ^= 1 << bit;
//   Checking if a bit is set: if (byte & (1 << bit))
//   Checking if a bit is cleared: if (~byte & (1 << bit)) OR if (!(byte & (1 << bit)))
//
float SetupTimer1(unsigned int topVal, bool fastPwm){
  // Set pwm clock divider for timer 1 (the 16-bit timer)
  // For CS12,CS11,CS10: 001 is /1 prescaler (010 is /8 prescaler)
  TCCR1B &= ~(1 << CS12); 
  TCCR1B &= ~(1 << CS11); 
  TCCR1B |= (1 << CS10);

  if(fastPwm){
    // mode 14 (fast, topVal is ICR1): 1,1,1,0
    TCCR1B |=  (1 << WGM13);
    TCCR1B |=  (1 << WGM12);
    TCCR1A |=  (1 << WGM11); 
    TCCR1A &= ~(1 << WGM10);
  }else{
    // mode 8 (phase & freq correct, topVal is ICR1): 1,0,0,0
    TCCR1B |=  (1 << WGM13);
    TCCR1B &=  ~(1 << WGM12);
    TCCR1A &=  ~(1 << WGM11); 
    TCCR1A &=  ~(1 << WGM10);
  }

  // Now load the topVal into the register. We can only do this after setting the mode:
  //   The ICRn Register can only be written when using a Waveform Generation mode that utilizes
  //   the ICRn Register for defining the counter’s TOP value. In these cases the Waveform Genera-
  //   tion mode (WGMn3:0) bits must be set before the TOP value can be written to the ICRn
  //   Register. (from the ATmega1280 data sheet)
  ICR1 = topVal;

  // Make sure all our pins are set for pwm
  pinMode(PIN_LED1, OUTPUT);
  pinMode(PIN_LED2, OUTPUT);
  TCCR1A |= (1 << COM1A1); 
  TCCR1A &= ~(1 << COM1A0); 
  TCCR1A |=  (1 << COM1B1); 
  TCCR1A &= ~(1 << COM1B0);   
#if NUM_CHANNELS > 2
  // For arduino mega, we can use 4 more outputs
  pinMode(PIN_LED3, OUTPUT);
  TCCR1A |=  (1 << COM1C1); 
  TCCR1A &= ~(1 << COM1C0);
  
  TCCR3B &= ~(1 << CS32); 
  TCCR3B &= ~(1 << CS31); 
  TCCR3B |=  (1 << CS30);
  if(fastPwm){
    TCCR3B |=  (1 << WGM33);
    TCCR3B |=  (1 << WGM32);
    TCCR3A |=  (1 << WGM31); 
    TCCR3A &= ~(1 << WGM30);
  }else{
    TCCR3B |=  (1 << WGM33);
    TCCR3B &= ~(1 << WGM32);
    TCCR3A &= ~(1 << WGM31); 
    TCCR3A &= ~(1 << WGM30);
  }
  ICR3 = topVal;
  pinMode(PIN_LED4, OUTPUT);
  pinMode(PIN_LED5, OUTPUT);
  pinMode(PIN_LED6, OUTPUT);
  TCCR3A |=  (1 << COM3A1); 
  TCCR3A &= ~(1 << COM3A0); 
  TCCR3A |=  (1 << COM3B1); 
  TCCR3A &= ~(1 << COM3B0);   
  TCCR3A |=  (1 << COM3C1); 
  TCCR3A &= ~(1 << COM3C0);
#endif

  // for fast PWM, PWM_freq = F_CPU/(N*(1+TOP))
  // for phase-correct PWM, PWM_freq = F_CPU/(2*N*TOP)
  // F_CPU = CPU freq, N = prescaler = 1 and TOP = counter top value 
  float pwmFreq;
  if(fastPwm)
    pwmFreq = (float)F_CPU/(1.0+topVal)+0.5;
  else
    pwmFreq = (float)F_CPU/(2.0*topVal)+0.5;

  return(pwmFreq);
}

void startISR(){  // Starts the ISR
  //TIMSK1 |= (1<<OCIE1A);        // enable output compare interrupt (calls ISR(TIMER1_COMPA_vect)
  TIMSK1 |= (1<<TOIE1);        // enable overflow interrupt (calls ISR(TIMER1_OVF_vect_vect)
}

void stopISR(){    // Stops the ISR
  //TIMSK1 &= ~(1<<OCIE1A);      // disable output compare interrupt 
  TIMSK1 &= ~(1<<TOIE1);      // disable overflow compare interrupt 
} 

// Timer1 interrupt vector handler
// (for overflow, use TIMER1_OVF_vect)
// see http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1215675974/0
// and http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1216085233
//ISR(TIMER1_COMPA_vect) {
ISR(TIMER1_OVF_vect) {
  digitalOutHigh(); // test ISR timing
  static unsigned int envInd;
  static byte i;
  unsigned int val[NUM_CHANNELS];
  
  // We skip computing the envelope value when there is no envelope. This
  // should make the serial port more responsive during playout.
  if(g_envelopeTicsDuration>0){
    updateWave(g_envelopeTics, getEnvelopeVal(g_envelopeTics), val);
    // Make the interrupt self-terminating
    if(g_envelopeTicsDuration>0 && g_envelopeTics>=g_envelopeTicsDuration)
      stopISR();
  }else{
    updateWave(g_envelopeTics, 256, val);
  }
  OCR1A = val[0];
  OCR1B = val[1];
  #if NUM_CHANNELS > 2
  OCR1C = val[2];
  OCR3B = val[3]; 
  OCR3C = val[4]; 
  OCR3A = val[5];
  #endif

  g_envelopeTics++;
  // NOTE: this will wrap after ~500 hours!

  // Note: there is no assurance that the PWMs will get set to their mean values
  // when the waveform play-out finishes. Thus, g_envelope must be designed to
  // provide this assurance; e.g., have 0 as it's first value and rise/fall >0 tics.
  digitalOutLow(); // test ISR timing
}

float getTemp(){
  const byte numReadings = 2*-0;
  float reading;
  for(byte i=0; i<numReadings; i++){
    reading += analogRead(PIN_TEMP);
    delay(1);
  }
  reading /= numReadings;
  // converting that reading to voltage. We assume that we're using the internal 1.1v reference
  float voltage = reading * 1.1 / 1024; 
  // convert from 10 mv per degree with 500 mV offset to degrees ((volatge - 500mV) * 100)
  float temp = (voltage - 0.5) * 100;
  //if(fFlag) temp = (temp * 9 / 5) + 32;
  return(temp);
}

unsigned int getFanSpeed(){
  const unsigned long timeoutMicrosecs = 6e4; // timeout in 60 milliseconds; allows us to measure down to 1000 rpms
  unsigned long pulseDelta = pulseIn(PIN_FAN, HIGH, timeoutMicrosecs);
  //Serial << "pulseDelta=" << pulseDelta << "\n";
  unsigned int rpms = 60e6/pulseDelta;
  return(rpms);
}

inline void digitalOutLow(){
   *g_digOutReg &= ~g_digOutBit;
}

inline void digitalOutHigh(){
   *g_digOutReg |= g_digOutBit;
}

