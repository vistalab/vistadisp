/*
 * RobustEEPROM.h - Robust (error-checking/correcting) EEPROM library
 *
 * Copyright 2010 Bob Dougherty.
 *
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
 *
 * HISTORY:
 * 2010.03.28 Bob Dougherty (bobd@stanford.edu) wrote it, based on code by Richard Soja.
 */

#ifndef RobustEEPROM_h
#define RobustEEPROM_h

#include <inttypes.h>
//#include "WConstants.h"

class RobustEEPROM{
  
  public:
    uint8_t readByte(int);
    void writeByte(int, uint8_t);

    // Hamming code (8,4) methods
    unsigned int EncodeByte(uint8_t data);
    uint8_t DecodeByte(uint8_t lsb, uint8_t msb);
    uint8_t DecodeByte(unsigned int code, uint8_t *data);
    uint8_t DecodeNibble(uint8_t hc);
    
  private:
    uint8_t ErrFlag;
};

#endif

