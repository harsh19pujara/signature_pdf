import 'dart:io';
import 'package:flutter/material.dart';
import 'package:signature_pdf/draw_signature.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPDFPage extends StatelessWidget {
  ViewPDFPage({Key? key, required this.pdf}) : super(key: key);
  final File pdf;
  Paint myPaint = Paint();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SfPdfViewer.file(pdf,
          onTap: (details) {
          debugPrint("position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition}");
        },
          canShowPasswordDialog: true,

        ),
      ),
      floatingActionButton: FloatingActionButton.small(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((myPaint) {

        });
      }, child: const Icon(Icons.format_paint)),
    );
  }
}
