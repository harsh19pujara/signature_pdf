import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  Offset signaturePos = const Offset(0, 0);
  File? signatureImg;


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
            // mySignaturePainter != null ?
            Positioned(
             left: signaturePos.dx,
              top: signaturePos.dy,
              child: Draggable(
                feedback: Container(),
                onDragUpdate: (details) => setState(() => signaturePos = details.globalPosition),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,

                  onInteractionUpdate: (details) {
                    debugPrint("interaction ${details.localFocalPoint}");
                  },
                  child: signatureImg != null ?Container(child: Image.file(signatureImg!)) : Container()
                  // child: CustomPaint(
                  //   willChange: true,
                  //   size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  //   painter: mySignaturePainter,
                  // ),
                ),
              ),
            )
                // : Container(height: 40, width: 40, color: Colors.green,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((myCanvas) {
              debugPrint("object $myCanvas");
              if (myCanvas != null) {
                setState(() {
                  mySignaturePainter = myCanvas[0];
                  signatureImg = myCanvas[1];
                });
              }
            });
          },
          child: const Icon(Icons.format_paint)),
    );
  }
}

