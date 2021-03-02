import 'package:MicroMote/tabs/smiledetection.dart';
import 'package:MicroMote/tabs/primarytab.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(
    home: Controller(),
  ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: const Color.fromRGBO(216, 44, 44, 1),
  ));
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
}

class Controller extends StatefulWidget {
  Controller({Key key}) : super(key: key);

  final List<Widget> pages = [PrimaryTab(), SmileDetection()];

  @override
  _ControllerState createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Micromote Controller'),
        centerTitle: true,
      ),
      body: widget.pages[selectedIndex],
      bottomNavigationBar: FFNavigationBar(
        theme: FFNavigationBarTheme(
          barBackgroundColor: Colors.white,
          selectedItemBorderColor: Colors.yellow,
          selectedItemBackgroundColor: Colors.green,
          selectedItemIconColor: Colors.white,
          selectedItemLabelColor: Colors.black,
        ),
        selectedIndex: selectedIndex,
        onSelectTab: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          FFNavigationBarItem(
            iconData: Icons.color_lens,
            label: 'LED Colors',
          ),
          FFNavigationBarItem(
            iconData: Icons.remove_red_eye,
            label: 'Smile Detection',
          ),
        ],
      ),
    );
  }
}
