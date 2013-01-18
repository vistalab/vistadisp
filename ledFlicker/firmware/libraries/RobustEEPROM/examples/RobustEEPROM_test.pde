
#include "RobustEEPROM.h"

RobustEEPROM re = RobustEEPROM();

void setup()
{
  Serial.begin(56700);
}

byte cnt;
void loop()
{
  byte recoveredVal;
  byte testVal = random(0,255);
  unsigned int hc = re.EncodeByte(testVal);
  byte err = re.DecodeByte(hc, &recoveredVal);
  if(testVal!=recoveredVal||err!=0) Serial.println("CODE 0 ERROR!");
  byte errBit = random(0,15);
  hc = hc^(1<<errBit);
  err = re.DecodeByte(hc, &recoveredVal);
  if(testVal!=recoveredVal) Serial.println("CODE 1 ERROR!");
  errBit = random(0,15);
  hc ^= (1<<errBit);
  err = re.DecodeByte(hc, &recoveredVal);
  if(testVal!=recoveredVal&&err<2) Serial.println("CODE 2 ERROR (OK)");
  cnt++;
  if(cnt==255){
    Serial.println("255 tests passed...");
    cnt = 0;
  }
}

