#include <Arduino.h>
#include <main.h>
#include <FastLED.h>

CRGB leds[NUM_LEDS];
int LEDConfigs[NUM_LEDS][5];

int LEDLoopNumber;

// Handling the LED Loop
void RGBLEDHandle()  // This is a task.
{
  // initialize digital LED_BUILTIN on pin 13 as an output.
  FastLED.addLeds<WS2812, LED_PIN, GRB>(leds, NUM_LEDS);

 // randomSeed(analogRead(A0));

  FastLED.setBrightness(150);

  for(int i = 0; i < NUM_LEDS; i++){
  LEDConfigs[i][0] = 10;
  LEDConfigs[i][1] = 100;
  LEDConfigs[i][2] = 0;
  LEDConfigs[i][3] = 0;
  LEDConfigs[i][4] = 255;
  }

  Serial.println("Starting the LED Loop!");

 for(int i = 0; i < NUM_LEDS; i++){
   LEDLoopNumber = i;
  xTaskCreatePinnedToCore(
    LEDLoop
    ,  "LEDLoop"   // A name just for humans
    ,  8096  // This stack size can be checked & adjusted by reading the Stack Highwater
    ,  (void*)&LEDLoopNumber
    ,  3  // Priority, with 3 (configMAX_PRIORITIES - 1) being the highest, and 0 being the lowest.
    ,  NULL 
    ,  1);

 }
}
// LED Cycle
void LEDLoop(void *pvParameters)
{
  int LEDNumber = *((int*)pvParameters);
  for(;;)
  {
  int FreqDelay = (1000/LEDConfigs[LEDNumber][0]);
  double OnDutyCycle = (LEDConfigs[LEDNumber][1] / 100.00);
  leds[LEDNumber] = CRGB(LEDConfigs[LEDNumber][2], LEDConfigs[LEDNumber][3], LEDConfigs[LEDNumber][4]);
  FastLED.show();
  delay((FreqDelay) * (OnDutyCycle));
  leds[LEDNumber] = CRGB::Black;
  FastLED.show();
  delay((FreqDelay) * (1 - OnDutyCycle));
  }
} 