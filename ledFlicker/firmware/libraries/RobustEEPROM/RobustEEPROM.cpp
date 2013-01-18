//ADDED FOR COMPATIBILITY WITH WIRING
extern "C" {
  #include <stdlib.h>
}

#include "WProgram.h"
#include <avr/eeprom.h>
#include <util/crc16.h>
#include "RobustEEPROM.h"

void RobustEEPROM::readBytes(unsigned int address, unsigned int nBytes, byte *data){
  eeprom_read_block((void *)data, const void *pointer_eeprom, size_t n) 
  return;
}

void RobustEEPROM::writeBytes(int address, unsigned int address, unsigned int nBytes, byte *data){
  eeprom_write_byte((unsigned char *) address, value);
}

byte RobustEEPROM::readByte(int address){
  return eeprom_read_byte((unsigned char *) address);
}

void RobustEEPROM::writeByte(int address, byte value){
  eeprom_write_byte((unsigned char *) address, value);
}

/* 
  Extracted from http://pdc.ro.nu/hamming.html:

  Encoding:
    data = [b3 b2 b1 b0];
    hammingCode = [b3, b3^b2^b1, b2, !b2^b1^b0, b1, !b3^b1^b0, b0, !b3^b2^b0];
  where ^ represents bitwise exclusive-or and ! is bitwise not

  Decoding:
    hammingCode = [h7, h6, h5, h4, h3, h2, h1, h0]
    parity  = h7 ^ h6 ^ h5 ^ h4 ^ h3 ^ h2 ^ h1 ^ h0
    c0 = h7 ^ h5 ^ h1 ^ h0
    c1 = h7 ^ h3 ^ h2 ^ h1
    c2 = h5 ^ h4 ^ h3 ^ h1
  If parity==1 then either 0 or 2 errors occurred. If all check bits (c0, c1, c2) == 1,
  then byte was received without error. Otherwise it had 2 (uncorrectable) errors.
  If parity==0, then there was a single bit error which can be corrected:
    c0 c1 c2    meaning
    1  1  1    error in bit h6
    1  1  0    error in bit h4
    1  0  1    error in bit h2
    0  1  1    error in bit h0
    0  0  1    error in bit h7
    0  1  0    error in bit h5
    1  0  0    error in bit h3
    0  0  0    error in bit h1
  To correct, flip the erroneous bit. There is no need to fix errors in bits h6, 
  h4, h2 and h0 since they are not used in the decoded byte.
  After flipping erroneous bits, the decoded byte is: [h7, h5, h3, h1]
*/

/*
  Returns a Hamming 8,4 encoded word given a byte of data bits.
*/
word RobustEEPROM::EncodeByte(byte data){
  word hc;
  byte nib, lsb, msb, b0, b1, b2, b3;

  // data = [b3 b2 b1 b0];
  // hammingCode = [b3, b3^b2^b1, b2, !b2^b1^b0, b1, !b3^b1^b0, b0, !b3^b2^b0];
  nib = data&B00001111;
  b0 = nib&(1<<0);
  b1 = (nib&(1<<1))>>1;
  b2 = (nib&(1<<2))>>2;
  b3 = (nib&(1<<3))>>3;
  lsb = b3<<7 | (b3^b2^b1)<<6 | b2<<5 | (!b2^b1^b0)<<4 | b1<<3 | (!b3^b1^b0)<<2 | b0<<1 | (!b3^b2^b0);

  nib = (data&B11110000)>>4;
  b0 =  nib&(1<<0);
  b1 = (nib&(1<<1))>>1;
  b2 = (nib&(1<<2))>>2;
  b3 = (nib&(1<<3))>>3;
  msb = b3<<7 | (b3^b2^b1)<<6 | b2<<5 | (!b2^b1^b0)<<4 | b1<<3 | (!b3^b1^b0)<<2 | b0<<1 | (!b3^b2^b0);

  hc = (msb<<8) | lsb;
  return(hc);
}

/* 
 * Returns the error corrected data byte, decoded from the two-byte code.
   Uses global variable <DataSize> to determine position of the
   Updates private var ErrFlag to indicate status i.e.:
     ErrFlag==0: No errors found
     ErrFlag==1: error, corrected
     ErrFlag==2: error, uncorrected (invalid data)
*/
byte RobustEEPROM::DecodeByte(byte lsb, byte msb){
  byte data;

  // avr-gcc uses little-endian (lsb first)
  lsb = DecodeNibble(lsb);
  if(ErrFlag<2) 
    msb = DecodeNibble(msb);
  if(ErrFlag<2)
    data = (msb<<4) | lsb;
  return(data);
}

byte RobustEEPROM::DecodeByte(word code, byte *data){
  byte err, lsb, msb;

  // avr-gcc uses little-endian (lsb first)
  lsb = DecodeNibble((byte)(code&0x00ff));
  if(ErrFlag==2)
    err = 8;
  else
    err = ErrFlag;
  msb = DecodeNibble((byte)(code>>8));
  if(ErrFlag==2)
    err += 8;
  else
    err += ErrFlag;
  *data = (msb<<4) | lsb;
  return(err);
}


byte RobustEEPROM::DecodeNibble(byte hc){
  bool parity, c0, c1, c2;
  byte data;

  // Decode the Hamming 8,4 byte into the 4-bit nibble of data
  // parity  = h7 ^ h6 ^ h5 ^ h4 ^ h3 ^ h2 ^ h1 ^ h0
  // c0 = h7 ^ h5 ^ h1 ^ h0
  // c1 = h7 ^ h3 ^ h2 ^ h1
  // c2 = h5 ^ h4 ^ h3 ^ h1
  // data = [h7, h5, h3, h1]
  // This is not likely the most efficient way to code this, but
  // at least it keeps my head from hurting too much.
  byte h0 =  hc&(1<<0);
  byte h1 = (hc&(1<<1))>>1;
  byte h2 = (hc&(1<<2))>>2;
  byte h3 = (hc&(1<<3))>>3;
  byte h4 = (hc&(1<<4))>>4;
  byte h5 = (hc&(1<<5))>>5;
  byte h6 = (hc&(1<<6))>>6;
  byte h7 = (hc&(1<<7))>>7;
  parity = h7 ^ h6 ^ h5 ^ h4 ^ h3 ^ h2 ^ h1 ^ h0;
  c0 = h7 ^ h5 ^ h1 ^ h0;
  c1 = h7 ^ h3 ^ h2 ^ h1;
  c2 = h5 ^ h4 ^ h3 ^ h1;
  if(parity){
    // Either no error or 2 errors.
    if(c0&c1&c2) ErrFlag = 0;
    else         ErrFlag = 2;
  }else{
    // single-bit error- correct it with an XOR toggle
    ErrFlag = 1;
    if     (!c0 & !c1 &  c2) h7 = !h7;
    else if(!c0 &  c1 & !c2) h5 = !h5;
    else if( c0 & !c1 & !c2) h3 = !h3;
    else if(!c0 & !c1 & !c2) h1 = !h1;
  }
  data = h7<<3 | h5<<2 | h3<<1 | h1;
  return(data);
}

