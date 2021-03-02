import 'package:MicroMote/mqtt_communication.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

List<CameraDescription> cameras;

class SmileDetection extends StatefulWidget {
  SmileDetection({Key key}) : super(key: key);

  @override
  _SmileDetectionState createState() => _SmileDetectionState();
}

class _SmileDetectionState extends State<SmileDetection> {
  Mqtt mqtt;
  CameraController controller;
  FaceDetector facedetector;
  bool _isDetecting = false;

  void resetLEDColors() {
    mqtt = new Mqtt();
    mqtt.publishMsg(
        lednumber: "All",
        currentcolor: Color(0x00d60e),
        frequency: 1.0,
        dutycycle: 100.0,
        brightness: 0);
  }

  void cameraInitialization() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[1], ResolutionPreset.low);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
      blinkStreamDetection();
    });
  }

  void fireBaseInitilization() async {
    facedetector = FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        enableClassification: true, mode: FaceDetectorMode.accurate));
  }

  void blinkStreamDetection() async {
    await controller.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      detectBlink(image);
    });
  }

  void detectBlink(CameraImage image) async {
    //   List<Face> faces;
    final FirebaseVisionImageMetadata metadata = FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes
          .map((currentPlane) => FirebaseVisionImagePlaneMetadata(
              bytesPerRow: currentPlane.bytesPerRow,
              height: currentPlane.height,
              width: currentPlane.width))
          .toList(),
    );
    FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromBytes(image.planes[0].bytes, metadata);
    facedetector.processImage(visionImage).then(
      (dynamic result) {
        //     setState(() {
        //     faces = result;
        // });
        print("Detecting...");

        if (result.length != 0) {
          for (Face face in result) {
            print("Left Eye: " + face.leftEyeOpenProbability.toString());
            print("Right Eye: " + face.rightEyeOpenProbability.toString());
            print("Smile: " + face.smilingProbability.toString());
            changeColorBySmile(face.smilingProbability);
          }
        }
        _isDetecting = false;
      },
    ).catchError(
      (_) {
        _isDetecting = false;
      },
    );
  }

  void changeColorBySmile(double smileprobability) {
    mqtt.publishMsg(
        lednumber: "All",
        currentcolor: Color(0x00d60e),
        frequency: 1.0,
        dutycycle: 100.0,
        brightness: smileprobability * 100);
  }

  @override
  void initState() {
    super.initState();
    resetLEDColors();
    cameraInitialization();
    fireBaseInitilization();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    //  return new Container(
    //     child: new Stack(
    //   children: <Widget>[
    return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller));
    /*         new Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                onPressed: () {
                  blinkStreamDetection();
                },
                child: Icon(Icons.photo_camera)),
          )*/
    //  );
  }
}
