/*
 * Allegro A6280/81 library for Arduino.
 * 
 * The Allegro A6280 and A6281 ICs are digitally controlled constant-current
 * sources useful for driving LEDs. Both chips have 3 channels of output 
 * (ideal for tricolor LEDs) and allow 7-bits of control over the current 
 * limit for each output. Both also have three 10-bit PWMs to modulate LED 
 * brightness rapidly; the 81 has an internal oscillator for the PWM while
 * the 80 does not. 
 *
 * Some of the code here was borrowed from http://www.pololu.com/catalog/product/1240.
 * 
 * 2010.03.23 Bob Dougherty (bobd@stanford.edu)
 */
 
//ADDED FOR COMPATIBILITY WITH WIRING
extern "C" {
  #include <stdlib.h>
}

#include "WProgram.h"
#include "LedShift.h"
#include "pins_arduino.h"


LedShift::LedShift(uint8_t nRegs, uint8_t dataPin, uint8_t latchPin, uint8_t enablePin, uint8_t clockPin){
  
  pinMode(dataPin, OUTPUT);
  pinMode(latchPin, OUTPUT);
  pinMode(enablePin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  
  // Precompute the clock and data register/bitmasks to speed up the ISR
  dataReg =  portOutputRegister(digitalPinToPort(dataPin));
  dataBit = digitalPinToBitMask(dataPin);
  latchReg =  portOutputRegister(digitalPinToPort(latchPin));
  latchBit = digitalPinToBitMask(latchPin);
  enableReg = portOutputRegister(digitalPinToPort(enablePin));
  enableBit = digitalPinToBitMask(enablePin);
  clockReg = portOutputRegister(digitalPinToPort(clockPin));
  clockBit = digitalPinToBitMask(clockPin);

  // Set up the data buffer
  numRegisters = nRegs;
  //curDataPacket = new dataPacket [numRegisters];
  curDataPacket = (dataPacket*)malloc(numRegisters*sizeof(dataPacket));
  // *** NOTE: no error checking!

  // Initialize pin states
  Latch();
  Enable();
}

LedShift::~LedShift(){
  free(curDataPacket);
}

// SetColorPacket sets the current dataPacket for LED brightness PWM.
//
// red, green, and blue are brightness values from 0 (off) to 1023 (full).
// 
void LedShift::SetColorPacket(uint8_t regNum, unsigned int red, unsigned int green, unsigned int blue){
    // initialize all of the bits to zero.
    curDataPacket[regNum].value = 0;

    curDataPacket[regNum].red   = red;
    curDataPacket[regNum].green = green;
    curDataPacket[regNum].blue  = blue;
    // command bit stays 0: dp.command = 0;
}

// SetCommandPacket: sets the data packet bits for sending commands to the A6280/1.
//
// redDotCorrect, greenDotCorrect, and blueDotCorrect lets you control what 
// percentage of current is flowing to each color diode. 
// Refer to page 8 of the datasheet for more information.
// clockMode lets you set the PWM frequency for the diodes (A6281 only). 
// Refer to page 7 of the datasheet for more information.  
//
void LedShift::SetCommandPacket(uint8_t regNum, uint8_t red, uint8_t green, uint8_t blue, uint8_t clockMode){
    // initialize all of the bits to zero.
    curDataPacket[regNum].value = 0;

    curDataPacket[regNum].redCurrent   = red;
    curDataPacket[regNum].greenCurrent = green;
    curDataPacket[regNum].blueCurrent  = blue;
    curDataPacket[regNum].clockMode  = blue;
    curDataPacket[regNum].command  = 1;
}

// Same as above, but don't bother setting clock mode
void LedShift::SetCommandPacket(uint8_t regNum, uint8_t red, uint8_t green, uint8_t blue){
    SetCommandPacket(regNum, red, green, blue, 0);
}

// Same as above, but all currents in an array that is numRegisters long
void LedShift::SetCommandPacket(uint8_t currents[]){
  uint8_t off;
  for(unsigned char regNum=0; regNum<numRegisters; regNum++){
    off = regNum*3;
    SetCommandPacket(regNum, currents[off], currents[off+1], currents[off+2], 0);
  }
}

void LedShift::SendPacket(){
  // Loop over the 31 data bits
  // Looping over all 31 bits would be simpler, but that code is much slower. Bit-shifting each 
  // of the four bytes is *much* faster.
  for(unsigned char regNum=0; regNum<numRegisters; regNum++){
    for(signed char curByte=3; curByte>=0; curByte--){
      for(signed char bitNum=7; bitNum>=0; bitNum--){
        // Data is read on rising edge of the clock pin, so set clock low here
        // TO DO: if the clock and data pins are on the same port, we could save an instruction
        // by setting the clock low when we set the data bit.
        *clockReg &= ~clockBit;
        // Set the appropriate Data In value
        if((curDataPacket[regNum].byte[curByte] >> bitNum) & 1)
          *dataReg |= dataBit;
        else
          *dataReg &= ~dataBit;
        // Now set the clock high to send data
        *clockReg |= clockBit;
      }
    }
  }
  *clockReg &= ~clockBit;
  Latch();
}

void LedShift::SetCurrents(uint8_t currents[]){
  // Set pwms to full-on:  
  for(uint8_t regNum=0; regNum<numRegisters; regNum++)
    SetColorPacket(regNum, 1023, 1023, 1023);
  // Not sure why I have to do this many times for it to 'take'.
  for(uint8_t i=0; i<100; i++)
    SendPacket();
  // Now set the current source values
  SetCommandPacket(currents);
  SendPacket();
}

void LedShift::SendABit(uint8_t regNum, uint8_t bitNum){
  // TO DO: if the clock and data pins are on the same port, we could save an instruction
  // by setting the clock low when we set the data bit.
  *clockReg &= ~clockBit;
  // Set the appropriate Data In value
  unsigned char curByte = bitNum/8;
  bitNum = bitNum%8;
  //if((curDataPacket[regNum].byte[curByte] >> bitNum) & 1)
  if((curDataPacket[regNum].value >> bitNum) & 1)
    *dataReg |= dataBit;
  else
    *dataReg &= ~dataBit;
  // Clock in the data
  *clockReg |= clockBit;
}

float LedShift::GetCurrentPercent(uint8_t currentByte){
  float currentPercent = 0.5*currentByte+36.5;
  return(currentPercent);
}

void LedShift::Latch(){
   *latchReg |= latchBit;
   *latchReg |= latchBit;
   *latchReg &= ~latchBit;
}

void LedShift::Enable(){
   *enableReg &= ~enableBit;
}

void LedShift::Disable(){
   *enableReg |= enableBit;
}
