#include <Arduino.h>
#include <main.h>
#if CONFIG_FREERTOS_UNICORE
#define ARDUINO_RUNNING_CORE 0
#else
#define ARDUINO_RUNNING_CORE 1
#endif

// the setup function runs once when you press reset or power the board
void setup()
{

  // initialize serial communication at 115200 bits per second:
  Serial.begin(115200);
  // Handling LED
  RGBLEDHandle();

  // Task1: Handling the OTA
  /* xTaskCreatePinnedToCore(
    OTA
    ,  "OTA"   // A name just for humans
    ,  16384  // This stack size can be checked & adjusted by reading the Stack Highwater
    ,  NULL
    ,  2  // Priority, with 3 (configMAX_PRIORITIES - 1) being the highest, and 0 being the lowest.
    ,  NULL 
    ,  0);*/

  // Setting up WIFI
  WifiHandle();

  // Now the task scheduler, which takes over control of scheduling individual tasks, is automatically started.
}

void loop()
{
  // Things are done in Tasks.
  //delay(100000000000000000000000000000000000000);
}