import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/main.dart';
import 'package:signature_pdf/utils/theme_const.dart';

class DrawSignature extends StatefulWidget {
  const DrawSignature({Key? key}) : super(key: key);

  @override
  State<DrawSignature> createState() => _DrawSignatureState();
}

Map<int, List<Offset>?> linesMap = {};
CustomPainter? myOldDelegate;
int id = 0;

//Bound
Offset leftBound = Offset.zero;
Offset rightBound = Offset.zero;
Offset topBound = Offset.zero;
Offset bottomBound = Offset.zero;

class _DrawSignatureState extends State<DrawSignature> {
  ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  late Canvas myCanvas;
  ui.Image? sketchImage;
  List<Offset> line = [];
  double strokeWidth = 2;
  Color strokeColor = Colors.black;

  @override
  void initState() {
    super.initState();
    myCanvas = Canvas(pictureRecorder);
  }

  @override
  Widget build(BuildContext context) {
    CustomPainter mySketchPainter = MyPainter(id: id, strokeColor: strokeColor, strokeWidth: strokeWidth, offsetList: line);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: secondaryColor,
        title: Text(
          "Add Signature",
          style: TextStyle(color: primaryColor, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          ElevatedButton(
              onPressed: () async {
                await getImage().then((value) async {
                  Navigator.pop(context, sketchImage != null ? await convertImageToFile(sketchImage!) : null);
                });
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text("Done")),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      body: Stack(
        children: [
          /// [PAINT AREA]
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GestureDetector(
              onPanStart: (details) {
                debugPrint(
                    'START #### Local Pos ${details.localPosition}, l $leftBound, r $rightBound, t $topBound, b $bottomBound');
                setState(() {
                  line.add(details.localPosition);
                });
              },
              onPanUpdate: (details) {
                debugPrint(
                    'UPDATE ### Local Pos ${details.localPosition}, l $leftBound, r $rightBound, t $topBound, b $bottomBound');
                setState(() {
                  line.add(details.localPosition);
                });
              },
              onPanEnd: (details) {
                id++;
                line = [];
              },
              child: CustomPaint(
                painter: mySketchPainter,
              ),
            ),
          ),

          /// [STROKE WIDTH CONTROLLER]
          Positioned(
            right: 10,
            bottom: 60,
            child: RotatedBox(
              quarterTurns: 3,
              child: SizedBox(
                width: 200,
                child: Slider(
                  thumbColor: primaryColor,
                  activeColor: Colors.black38,
                  value: strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  },
                  max: 4,
                  min: 0.2,
                ),
              ),
            ),
          )
        ],
      ),

      /// [Undo and Clear screen Button]
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
              heroTag: 'Undo',
              backgroundColor: primaryColor,
              onPressed: () {
                setState(() {
                  if (id > 0) {
                    id--;
                    linesMap.removeWhere((key, value) => key == id);
                    line = [];
                    debugPrint("id $id sketch $linesMap");
                  }
                  linesMap.removeWhere((key, value) => value == []);
                });
              },
              child: Icon(
                Icons.undo_sharp,
                color: secondaryColor,
              )),
          FloatingActionButton.small(
              heroTag: 'Clear All',
              backgroundColor: primaryColor,
              onPressed: () {
                setState(() {
                  linesMap.clear();
                  id = 0;
                  line = [];
                  leftBound = Offset.zero;
                  rightBound = Offset.zero;
                  topBound = Offset.zero;
                  bottomBound = Offset.zero;
                });
              },
              child: Icon(
                Icons.file_open_outlined,
                color: secondaryColor,
              )),
        ],
      ),
    );
  }

  Future<void> getImage() async {
    if (myOldDelegate != null) {
      Path path = Path();
      path.addPolygon([
        const Offset(0, 0),
        Offset(0, bottomBound.dy + 4),
        Offset(rightBound.dx + 4, bottomBound.dy + 4),
        Offset(rightBound.dx + 4, 0),
      ], true);

      myCanvas.clipPath(path, doAntiAlias: true);
      myCanvas.translate(-leftBound.dx + 2, -topBound.dy + 2);
      myOldDelegate!.paint(myCanvas, Size(rightBound.dx - leftBound.dx + 4, bottomBound.dy - topBound.dy + 4));
      final ui.Picture picture = pictureRecorder.endRecording();
      sketchImage = await picture.toImage((rightBound.dx - leftBound.dx).toInt() + 4, (bottomBound.dy - topBound.dy).toInt() + 4);
    }
  }

  Future<File> convertImageToFile(ui.Image image) async {
    var pngBytes = await image.toByteData(format: ui.ImageByteFormat.png);

    Directory saveDir = await getApplicationDocumentsDirectory();
    String path = '${saveDir.path}/signature_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    File saveFile = File(path);

    if (!saveFile.existsSync()) {
      saveFile.createSync(recursive: true);
    }
    if (pngBytes != null) {
      saveFile.writeAsBytesSync(pngBytes.buffer.asUint8List(), flush: true);
    }
    return saveFile;
  }
}

class MyPainter extends CustomPainter {
  Offset? start;
  Offset? end;
  List<Offset>? offsetList = [];
  int? id;
  double strokeWidth;
  Color strokeColor;

  MyPainter({this.id, this.offsetList, this.strokeWidth = 1, this.strokeColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint myPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth;

    if ((!linesMap.keys.contains(id)) && offsetList?.length != 0) {
      if (offsetList?.length == 1) {
        Offset? newPoint = offsetList != null ? Offset(offsetList![0].dx + 1, offsetList![0].dy + 1) : null;
        if (newPoint != null) offsetList?.add(newPoint);
      }
      debugPrint("error $id $offsetList $linesMap");
      linesMap[id!] = offsetList ?? [];
    }

    for (var v = 0; v < linesMap.length; v++) {
      if (linesMap[v] != [] && linesMap[v] != null) {
        for (int i = 0; i < linesMap[v]!.length; i++) {
          if (i < linesMap[v]!.length - 1) {
            start = linesMap[v]![i];
            end = linesMap[v]![i + 1];
            getBoundOfSketch(start);
            canvas.drawLine(start!, end!, myPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    myOldDelegate = oldDelegate;
    return true;
  }

  getBoundOfSketch(Offset? point) {
    if (point != null) {
      double x = point.dx;
      double y = point.dy;

      if (leftBound.dx > x || leftBound.dx == 0.0) {
        leftBound = point;
      }

      if (rightBound.dx < x) {
        rightBound = point;
      }

      if (topBound.dy > y || topBound.dy == 0.0) {
        topBound = point;
      }

      if (bottomBound.dy < y) {
        bottomBound = point;
      }
    }
  }
}
