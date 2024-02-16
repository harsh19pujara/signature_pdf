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
            Positioned(
             left: signaturePos.dx,
              top: signaturePos.dy,
              child: Draggable(
                feedback: Container(),
                onDragUpdate: (details) {
                  setState(() {
                    signaturePos = signaturePos + details.delta;
                  });
                },
                child: InteractiveViewer(
                  onInteractionUpdate: (details) {
                    debugPrint("interaction ${details.localFocalPoint}");
                  },
                  child: signatureImg != null ?Container(decoration: BoxDecoration(border: Border.all(color: Colors.red[400]!,)),child: Image.file(signatureImg!)) : Container()
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((image) {
              debugPrint("object $image");
              if (image != null) {
                setState(() {
                  signatureImg = image;
                });
              }
            });
          },
          child: const Icon(Icons.format_paint)),
    );
  }
}

