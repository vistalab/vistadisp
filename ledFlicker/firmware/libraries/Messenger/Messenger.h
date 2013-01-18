/*
 * Messenger library for Arduino.
 * 
 * This is a modified version of Thomas Ouellet Fredericks' Messenger library:
 *    
 *    http://www.arduino.cc/playground/Code/Messenger
 *
 * I added support for floats and changed the message parser so that messages must
 * be wrapped in a pair of characters, the prefix and the suffix (defaults to "[]").
 * This makes the message passing more robust, since we can ignore characters 
 * outside of the prefix/suffix pair.
 *
 * 2010.03.19 Bob Dougherty (bobd@stanford.edu)
 */

#ifndef Messenger_h
#define Messenger_h
#define MESSENGERBUFFERSIZE 128

#include <inttypes.h>

extern "C" {
// callback function
    typedef void (*messengerCallbackFunction)(void);
}

class Messenger{

public:
  Messenger();
  Messenger(char separator);
  Messenger(char separator, char prefix, char suffix);  // Added by Bob Dougherty
  int readInt();
  long readLong(); // Added based on a suggestion by G. Paolo Sani
  float readFloat(); // Added by Bob Dougherty
  char readChar();
  void copyString(char *string, uint8_t size);
  uint8_t checkString(char *string);
  void echoBuffer();
  uint8_t process(int serialByte);
  uint8_t available();
  void attach(messengerCallbackFunction newFunction);
  // Reports the number of free bytes of RAM
  unsigned int FreeMemory();
  
private:
  void init(char separator, char prefix, char suffix);  // termChar option added by Bob Dougherty
  uint8_t next();
  void reset();
  
  uint8_t messageState;
  
  messengerCallbackFunction callback;
  
  char* current; // Pointer to current data
  char* last;
  
  char token[2];
  uint8_t dumped;
  char prefixChar; // added by Bob Dougherty
  char suffixChar;
  
  uint8_t bufferIndex; // Index where to write the data
  char buffer[MESSENGERBUFFERSIZE]; // Buffer that holds the data
  char *bufferScratch;
  uint8_t bufferLength; // The length of the buffer (defaults to 64)
  uint8_t bufferLastIndex; // The last index of the buffer
};

#endif

