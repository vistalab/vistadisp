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
 
 //ADDED FOR COMPATIBILITY WITH WIRING
extern "C" {
  #include <stdlib.h>
}

#include "WProgram.h"
#include "Messenger.h"

Messenger::Messenger(){
  init(' ', '[', ']');
}

Messenger::Messenger(char separator){
  if (separator == 10 || separator == 13 || separator == 0)  separator = 32;
  init(separator, '[', ']');
}

Messenger::Messenger(char separator, char prefix, char suffix){
  // RFD: must sanity-check prefix/suffix. E.g., cannot be 0, etc.
  if (separator == 10 || separator == 13 || separator == 0)  separator = 32;
  init(separator, prefix, suffix);
}

void Messenger::init(char separator, char prefix, char suffix) {
  callback = NULL;
  token[0] = separator; 
  token[1] = 0;
  bufferLength = MESSENGERBUFFERSIZE;
  bufferLastIndex = MESSENGERBUFFERSIZE -1;
  prefixChar = prefix;
  suffixChar = suffix;
  reset();
}

void Messenger::attach(messengerCallbackFunction newFunction) {
  callback = newFunction;
}

void Messenger::reset() {
  bufferIndex = 0;
  messageState = 0;
  current = NULL;
  last = NULL;
  dumped = 1;
  bufferScratch = buffer;
}

int Messenger::readInt() {
  if (next()) {
    dumped = 1;
    return atoi(current);
  }
  return 0;
}

// Added based on a suggestion by G. Paolo Sanino
long Messenger::readLong() {
  if (next()) {
    dumped = 1;
    return atol(current); // atol for long instead of atoi for int variables
  }
  return 0;
}

// Added by Bob Doughety
float Messenger::readFloat() {
  if (next()) {
    dumped = 1;
    return atof(current);
  }
  return 0;
}

char Messenger::readChar() {
  if (next()) {
    dumped = 1;
    return current[0];
  }
  return 0;
}

void Messenger::copyString(char *string, uint8_t size) {	
  if (next()) {
    dumped = 1;
    strlcpy(string,current,size);
  }else{
    if ( size ) string[0] = '\0';
  }
}

uint8_t Messenger::checkString(char *string) {
  if(next()) {
    if ( strcmp(string,current) == 0 ) {
      dumped = 1;
      return 1;
    }else{
      return 0;
    }
  } 
}

uint8_t Messenger::next() {
  if(messageState==2){
      if(dumped){
        current = strtok_r(bufferScratch,token,&last);
        // The first time through, bufferScratch should point to buffer (see reset)
        // to initialize strtok. On subsequent calls, it must be null for strok to 
        // return the remaining tokens.
        bufferScratch = NULL;
      }
      if(current != NULL) {
    	dumped = 0;
    	return 1; 
      }
  }
  return 0;
}

void Messenger::echoBuffer(){
  Serial.println((char *)buffer);
}

uint8_t Messenger::available() {
  return next();
}


uint8_t Messenger::process(int serialByte) {
  // To get a complete message (ie. messageState == 2) we need to first get the 
  // prefix and then get a suffix. 
  if (serialByte > 0) {
    if(serialByte==prefixChar) {
      reset();
      messageState = 1;
    }else if(serialByte==suffixChar) {
      if(messageState==1){
        buffer[bufferIndex]=0;
        reset();
        messageState = 2;
        //current = buffer;
      }else{
        // We got a suffix but hadn't received a prefix. Just reset and start over.
        reset();
      }
    }else if(messageState==1){
      // Not zero, prefix or suffix- parse it as content, as long as the prefix has
      // already been received (ie. messageState==1).
      buffer[bufferIndex] = serialByte;
      bufferIndex++;
      if (bufferIndex >= bufferLastIndex) reset();
    }
  }
  if(messageState == 2 && callback != NULL){
    (*callback)();
    messageState = 0;
  }
  return messageState;
}

/*
 * FreeMemory returns the number of free RAM bytes. It doesn't really fit in here,
 * but it is a useful little utility.
 */
extern unsigned int __data_start;
extern unsigned int __data_end;
extern unsigned int __bss_start;
extern unsigned int __bss_end;
extern unsigned int __heap_start;
extern void *__brkval;

unsigned int Messenger::FreeMemory(){
  int free_memory;
  if((int)__brkval == 0)
     free_memory = ((int)&free_memory) - ((int)&__bss_end);
  else
    free_memory = ((int)&free_memory) - ((int)__brkval);
  return free_memory;
}



