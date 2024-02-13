import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature_pdf/draw_signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPDFPage extends StatefulWidget {
  const ViewPDFPage({Key? key, required this.pdf}) : super(key: key);
  final File pdf;

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> {
  Canvas? mySignature;
  CustomPainter? mySignaturePainter;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ///PDF
            SfPdfViewer.file(
              widget.pdf,
              canShowPasswordDialog: true,
              onTap: (details) {
                debugPrint("position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition}");
              },
            ),

            ///Signature
            mySignaturePainter != null
                ? Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(color: Colors.red[400]),
                  child: LayoutBuilder(builder: (context, constraints) {
                    constraints.constrainDimensions(200, 300);
                    return CustomPaint(
                      size: Size(20, 20),
                      willChange: true,
                      foregroundPainter: mySignaturePainter,
                    );
                  },),
                )
                : Container(height: 40, width: 40, color: Colors.green,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((myCanvas) {
              debugPrint("object $myCanvas");
              if (myCanvas != null) {
                setState(() {
                  mySignaturePainter = myCanvas;
                  // mySignaturePainter!.shouldRepaint(oldDelegate)
                });
              }
            });
          },
          child: const Icon(Icons.format_paint)),
    );
  }
}

class MySignaturePainter extends CustomPainter{
  CustomPainter? painter;

  MySignaturePainter({super.repaint, this.painter});
  @override
  void paint(Canvas canvas, Size size) {
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    throw UnimplementedError();
  }
}
