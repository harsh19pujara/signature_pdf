import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

class DrawSignature extends StatefulWidget {
  const DrawSignature({Key? key}) : super(key: key);

  @override
  State<DrawSignature> createState() => _DrawSignatureState();
}

Map<int, List<Offset>?> linesMap = {};
Canvas mySketchCanvas = Canvas(PictureRecorder());


class _DrawSignatureState extends State<DrawSignature> {
  int id = 0;
  List<Offset> line = [];
  double strokeWidth = 1;
  Color strokeColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    CustomPainter mySketchPainter = MyPainter(id: id, strokeColor: strokeColor, strokeWidth: strokeWidth, offsetList: line);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          ElevatedButton(onPressed: () {
            Navigator.pop(context, mySketchPainter);
          }, child: const Text("Done")),
          const SizedBox(width: 15,)
        ],
      ),
      body: Stack(
        children: [

          /// [PAINT AREA]
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: InteractiveViewer(
              child: GestureDetector(
                onPanStart: (details) {
                  debugPrint('START ####  Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Kind ${details.kind}');
                  setState(() {
                    line.add(details.localPosition);
                  });
                },
                onPanUpdate: (details) {
                  debugPrint('UPDATE ### Global Pos ${details.globalPosition} - Local Pos ${details.localPosition} - Timestamp ${details.sourceTimeStamp} - Delta ${details.delta} - Primary Delta ${details.primaryDelta}');
                  setState(() {
                    line.add(details.localPosition);
                  });
                },
                onPanEnd: (details) {
                  debugPrint(details.primaryVelocity.toString());
                  id++;
                  line = [];
                },
                child: CustomPaint(
                  painter: mySketchPainter,
                ),
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
                  thumbColor: Colors.purple[100],
                  activeColor: Colors.black38,
                  value: strokeWidth,
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  }, max: 4, min: 0.2,),
              ),
            ),
          )
        ],
      ),

      /// [Undo and Clear screen Button]
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(heroTag: 'Undo', backgroundColor: Colors.purple[100],onPressed: () {
            setState(() {
              if (id > 0) {
                id--;
                linesMap.removeWhere((key, value) => key == id);
                line = [];
                debugPrint("id $id sketch $linesMap");
              }
              linesMap.removeWhere((key, value) => value == []);
            });
          },child: const Icon(Icons.undo_sharp, color: Colors.black54,)),
          FloatingActionButton.small(heroTag: 'Clear All', backgroundColor: Colors.purple[100],onPressed: () {
            setState(() {
              linesMap.clear();
              id = 0;
              line = [];
            });
          },child: const Icon(Icons.file_open_outlined, color: Colors.black54,)),
        ],
      ),
    );
  }
}

class MyPainter extends CustomPainter{
  Offset? start;
  Offset? end;
  List<Offset>? offsetList = [];
  int? id;
  double strokeWidth;
  Color strokeColor;

  MyPainter({this.id, this.offsetList, this.strokeWidth = 1, this.strokeColor = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    Paint myPaint = Paint()..color = strokeColor..strokeWidth = strokeWidth;
    canvas.scale(0.4, 0.2);

    if((!linesMap.keys.contains(id)) && offsetList?.length != 0){
      debugPrint("error $id $offsetList $linesMap");
      linesMap[id!] = offsetList ?? [];
    }

    for (var v = 0; v < linesMap.length; v++) {
      if (linesMap[v] != []) {
        if (linesMap[v] != []) {
          for(int i = 0; i < linesMap[v]!.length; i++) {
            if (i < linesMap[v]!.length - 1) {
              start = linesMap[v]![i];
              end = linesMap[v]![i+1];
              canvas.drawLine(start!, end!, myPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
