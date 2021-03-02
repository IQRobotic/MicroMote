#include <PubSubClient.h>
#include <WiFi.h>
#include <main.h>
#include <ArduinoJson.h>
#include <FastLED.h>
#include <ESPmDNS.h>
#include <WiFiUdp.h>
#include "soc/timer_group_struct.h"
#include "soc/timer_group_reg.h"

//                           WIFI
/* Access Point */
const char *ssid = "Fire";
const char *password = "MohammadRezaN2002";

/* WIFI Settngs */
// Set your Static IP address
IPAddress local_IP(192, 168, 1, 184);
// Set your Gateway IP address
IPAddress gateway(192, 168, 1, 1);

IPAddress subnet(255, 255, 0, 0);
IPAddress primaryDNS(8, 8, 8, 8);   //optional
IPAddress secondaryDNS(8, 8, 4, 4); //optional

//                         MQTT setting
/* Domain Address */
//const char* mqttServer    = "test.mosquitto.org";
/* Ip Address */
IPAddress mqttServer(192, 168, 1, 63);
const int mqttPort = 1883;
//const char* mqttUser      = "wbpwjaso";
//const char* mqttPassword  = "eO-kjpnhyvrI";
const char *mqttClientID = "Micromote-ESP32";

const char *mqttSubscribe = "MicromoteController/API";

WiFiClient espClient;
PubSubClient client(espClient);

// Declaration
void parseJson(char *msg);
void MQTTCallback(char *topic, byte *payload, unsigned int length);
void MQTTSetup();

void WifiHandle()
{
  // Configures static IP address
  if (!WiFi.config(local_IP, gateway, subnet, primaryDNS, secondaryDNS))
  {
    Serial.println("STA Failed to configure");
  }

  //  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  while (WiFi.waitForConnectResult() != WL_CONNECTED)
  {
    Serial.println("Connection Failed! Rebooting...");
    delay(5000);
    ESP.restart();
  }
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Configuring MQTT
  MQTTSetup();

  // TASK2: Handling the MQTT
  xTaskCreatePinnedToCore(
      MQTTHandle, "MQTTHandle" // A name just for humans
      ,
      16384 // This stack size can be checked & adjusted by reading the Stack Highwater
      ,
      NULL, 2 // Priority, with 3 (configMAX_PRIORITIES - 1) being the highest, and 0 being the lowest.
      ,
      NULL, 0);
}
void MQTTSetup()
{

  client.setServer(mqttServer, mqttPort);
  client.setCallback(MQTTCallback);

  while (!client.connected())
  {
    if (client.connect(mqttClientID))
    {
      Serial.println("MQTT Connected!");
    }
    else
    {

      Serial.print("Failed with state: ");
      Serial.println(client.state());

      delay(2000);
    }
  }
  delay(2000);

  client.subscribe(mqttSubscribe);

  Serial.println("Subscribed!");
}
// Handling the MQTT Instance
void MQTTHandle(void *pvParameters)
{
  for (;;)
  {
    {
      // Watchdog Satisfy
      TIMERG0.wdt_wprotect = TIMG_WDT_WKEY_VALUE;
      TIMERG0.wdt_feed = 1;
      TIMERG0.wdt_wprotect = 0;
      // Start the Loop !
      client.loop();
    }
    if (!client.connected())
    {
      Serial.println("Reconnecting...");
      MQTTSetup();
      ;
    }
  }
}
// Message Subscription Callback
void MQTTCallback(char *topic, byte *payload, unsigned int length)
{
  {
    Serial.println("Message arrived.");

    Serial.println("Topic:");
    Serial.println(topic);

    Serial.println("Message:");
    char message[length + 1];
    for (int i = 0; i < length; i++)
    {
      message[i] = (char)payload[i];
    }
    message[length] = '\0';
    Serial.println(message);

    Serial.println();
    Serial.println("-----------------------");

    parseJson(message);
  }
}
// Parse Json Object
// Setting LEDConfigs for each LED
void parseJson(char *msg)
{
  const size_t capacity = JSON_OBJECT_SIZE(3) + JSON_OBJECT_SIZE(5) + 70;
  DynamicJsonDocument doc(capacity);

  deserializeJson(doc, msg);

  JsonObject Color = doc["Color"];

  FastLED.setBrightness(doc["Brightness"]);

  if (doc["LEDNum"] == 0)
  {
    for (int i = 0; i < NUM_LEDS; i++)
    {
      LEDConfigs[i][0] = doc["Frequency"];
      LEDConfigs[i][1] = doc["DutyCycle"];
      LEDConfigs[i][2] = Color["Red"];
      LEDConfigs[i][3] = Color["Green"];
      LEDConfigs[i][4] = Color["Blue"];
    }
  }
  else
  {
    int LEDNum = doc["LEDNum"];
    // Decrease value for Array slot
    LEDNum -= 1;

    LEDConfigs[LEDNum][0] = doc["Frequency"];
    LEDConfigs[LEDNum][1] = doc["DutyCycle"];

    LEDConfigs[LEDNum][2] = Color["Red"];
    LEDConfigs[LEDNum][3] = Color["Green"];
    LEDConfigs[LEDNum][4] = Color["Blue"];
  }
}