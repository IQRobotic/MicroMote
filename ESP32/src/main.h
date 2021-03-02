// Declaration

void WifiHandle();
void RGBLEDHandle();
void MQTTHandle(void *pvParameters);
void OTA(void *pvParameters);
void LEDLoop(void *pvParameters);

#define LED_PIN     5
#define NUM_LEDS    8
extern int LEDConfigs[NUM_LEDS][5]; 
