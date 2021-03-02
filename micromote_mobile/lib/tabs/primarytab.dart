import 'package:flutter/material.dart';
import '../mqtt_communication.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:color_pick/color_pick.dart';

class PrimaryTab extends StatefulWidget {
  PrimaryTab({Key key}) : super(key: key);
  @override
  _PrimaryTabState createState() => new _PrimaryTabState();
}

class _PrimaryTabState extends State<PrimaryTab> {
  var mQTTinstance = new Mqtt();

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: Center(
            child: new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text("LED Number: "),
            new DropdownButton<dynamic>(
              value: lednumber,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.deepPurple),
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: lednumChanged,
              items: <dynamic>["All", 1, 2, 3, 4, 5, 6, 7, 8]
                  .map<DropdownMenuItem<dynamic>>((dynamic value) {
                return DropdownMenuItem<dynamic>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new ColorPickView(
              selectColor: const Color(0xFF00faf2),
              selectRadius: 10,
              selectColorCallBack: colorPickerChanged,
              size: const Size(225, 225),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Frequency: " + frequency.toStringAsFixed(0)),
            new Slider(
              onChanged: frequencyChanged,
              value: frequency,
              min: 1,
              max: 10,
              activeColor: const Color(0xFF00faf2),
              inactiveColor: const Color(0xFFffffff),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Duty Cycle: " + dutycycle.toStringAsFixed(0) + "%"),
            new Slider(
              onChanged: dutycycleChanged,
              value: dutycycle,
              min: 1,
              max: 100,
              activeColor: const Color(0xFF00faf2),
              inactiveColor: const Color(0xFFffffff),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text("Brightness: " + brightness.toStringAsFixed(0)),
            new Slider(
              onChanged: brightnessChanged,
              value: brightness,
              min: 0,
              max: 255,
              activeColor: const Color(0xFF00faf2),
              inactiveColor: const Color(0xFFffffff),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Text("Connection Status"
                ": "
                " ${mQTTinstance.client.connectionStatus.state == MqttConnectionState.connected ? "Connected" : "Disconnected"}")
          ],
        )
      ],
    )));
  }

// Led number state
  dynamic lednumber = "All";
  void lednumChanged(dynamic value) {
    setState(() {
      lednumber = value;
      debugPrint("$lednumber");
    });
  }

// Frequency stsate
  double frequency = 1;
  void frequencyChanged(double value) {
    setState(() {
      frequency = value.roundToDouble();
      debugPrint("$frequency");
    });
    mQTTinstance.publishMsg(
        frequency: frequency,
        dutycycle: dutycycle,
        brightness: brightness,
        currentcolor: currentcolor,
        lednumber: lednumber);
  }

  // Duty Cycle state
  double dutycycle = 1;
  void dutycycleChanged(double value) {
    setState(() {
      dutycycle = value.roundToDouble();
      debugPrint("$dutycycle");
    });
    mQTTinstance.publishMsg(
        frequency: frequency,
        dutycycle: dutycycle,
        brightness: brightness,
        currentcolor: currentcolor,
        lednumber: lednumber);
  }

  // Brightness State
  double brightness = 255;
  void brightnessChanged(double value) {
    setState(() {
      brightness = value.roundToDouble();
      debugPrint("$brightness");
    });
    mQTTinstance.publishMsg(
        frequency: frequency,
        dutycycle: dutycycle,
        brightness: brightness,
        currentcolor: currentcolor,
        lednumber: lednumber);
  }

  // Color slider state
  Color currentcolor = Color(0XFFf50000);
  Color colorPickerChanged(Color value) {
    setState(() {
      currentcolor = value;
      debugPrint("$currentcolor" "\n" "RGB(" +
          currentcolor.red.toString() +
          "," +
          currentcolor.green.toString() +
          "," +
          currentcolor.blue.toString() +
          ")");
    });
    mQTTinstance.publishMsg(
        frequency: frequency,
        dutycycle: dutycycle,
        brightness: brightness,
        currentcolor: currentcolor,
        lednumber: lednumber);
    return currentcolor;
  }
}
