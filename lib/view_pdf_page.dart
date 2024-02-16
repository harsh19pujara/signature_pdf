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
  Offset signaturePos = const Offset(0, 0);
  File? signatureImg;
  double rotation = 0.0;
  double scale = 1.0;


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
                child: Transform.rotate(
                  angle: rotation,
                  filterQuality: FilterQuality.high,
                  child: GestureDetector(
                      onScaleUpdate: (details) {
                        debugPrint("pan update $details");
                        setState(() {
                          rotation = details.rotation != 0.0 ? details.rotation : rotation ;
                          scale = details.scale != 1 ? details.scale : scale;
                          Offset imageOffset = Offset(details.focalPoint.dx - (150 * scale)/2, details.focalPoint.dy - (150 * scale)/2);
                          signaturePos = imageOffset;
                        });
                      },
                      child: signatureImg != null ?Container(width: 150 * scale,decoration: BoxDecoration(border: Border.all(color: Colors.red[400]!,)),child: Image.file(signatureImg!, fit: BoxFit.contain,)) : Container()
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

