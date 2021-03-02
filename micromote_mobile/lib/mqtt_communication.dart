import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'JsonConversion.dart';
import 'dart:convert';

class Mqtt {
  final MqttClient client = MqttClient('192.168.1.63', '');

  static final Mqtt _singleton = new Mqtt._internal();

  factory Mqtt() {
    return _singleton;
  }

  Mqtt._internal() {
    setup();
  }

  Future<int> setup() async {
    client.logging(on: false);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 20;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = onDisconnected;

    /// Add the successful connection callback
    client.onConnected = onConnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier('MicroMote-Mobile')
        .keepAliveFor(20) // Must agree with the keep alive set above or not set
        /*  .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')*/
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    debugPrint("MQTT Server Connecting...");

    // try {
    await client.connect();
    //}
    /*on Exception catch (e) {
      debugPrint('EXCEPTION::client exception - $e');
      client.disconnect();
    }*/

    /// Check we are connected
    if (client.connectionStatus.state == MqttConnectionState.connected) {
      debugPrint("MQTT Connected!");

      /// If needed you can listen for published messages that have completed the publishing
      /// handshake which is Qos dependant. Any message received on this stream has completed its
      /// publishing handshake with the broker.
      client.published.listen((MqttPublishMessage message) {
        debugPrint(
            'Published notification:: topic is ${message.variableHeader.topicName}, with Qos ${message.header.qos}');
      });
    }
    return 0;
  }

  // Publish The Message to MQTT Server
  int publishMessage(String pubTopic, String message) {
    // While Loop for Connection
    if (client.connectionStatus.state != MqttConnectionState.connected)
      setup();
    else {
      /// Lets publish to our topic
      /// Use the payload builder rather than a raw buffer
      /// Our known topic to publish to
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);

      /// Publish it
      client.publishMessage(pubTopic, MqttQos.atMostOnce, builder.payload);
      return 1;
    }
  }

  /// The unsolicited disconnect callback
  void onDisconnected() {
    if (client.connectionStatus.returnCode ==
        MqttConnectReturnCode.solicited) {}
    exit(-1);
  }

  /// The successful connect callback
  void onConnected() {}

  void publishMsg(
      {dynamic lednumber,
      currentcolor,
      double frequency,
      dutycycle,
      brightness}) {
    JsonEncode encodeInstance = JsonEncode(
        LEDNum: lednumber == "All" ? 0 : lednumber,
        LEDColor: currentcolor,
        Frequency: frequency.toInt(),
        DutyCycle: dutycycle.toInt(),
        Brightness: brightness.toInt());
    String jsonProperties = json.encode(encodeInstance.toJson());
    debugPrint(jsonProperties);
    publishMessage("MicromoteController/API", jsonProperties);
  }
}
