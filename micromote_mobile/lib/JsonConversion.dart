import 'package:flutter/rendering.dart';

// Encoding the variables into Json

class JsonEncode {
  dynamic LEDNum;
  int Frequency;
  Color LEDColor;
  int Brightness;
  int DutyCycle;

  JsonEncode(
      {this.LEDNum,
      this.Frequency,
      this.LEDColor,
      this.Brightness,
      this.DutyCycle});

  Map<String, dynamic> toJson() => {
        'LEDNum': LEDNum,
        'Frequency': Frequency,
        'DutyCycle': DutyCycle,
        'Brightness': Brightness,
        'Color': {
          'Red': LEDColor.red,
          'Green': LEDColor.green,
          'Blue': LEDColor.blue,
        },
      };
}
