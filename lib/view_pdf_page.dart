import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/draw_signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPDFPage extends StatefulWidget {
  const ViewPDFPage({Key? key, required this.pdf}) : super(key: key);
  final File pdf;

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> {
  PdfViewerController controller = PdfViewerController();
  Offset signaturePos = const Offset(0, 0);
  File? signatureImg;
  int imageHeight = 0;
  int imageWidth = 0;
  double oldRotation = 0.0;
  double rotation = 0.0;
  double scale = 1.0;
  bool signatureSelected = true;
  int pageNumber = 0;
  File? updatedPDF;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            ///PDF
            SfPdfViewer.file(
              updatedPDF ?? widget.pdf,
              canShowPasswordDialog: true,
              pageLayoutMode: PdfPageLayoutMode.single,
              controller: controller,
              onTap: (details) {
                debugPrint("pdf position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition},  sign $signaturePos");
              },
              onPageChanged: (details) {
                pageNumber = details.newPageNumber;
              },
            ),

            /// Tick above Signature
            signatureImg != null && signatureSelected? Positioned(left: signaturePos.dx, top: signaturePos.dy - 50,
                // child: InkWell(

                  // behavior: HitTestBehavior.translucent,
                  // onTap: () {
                  //   debugPrint("rtt tap ${controller.scrollOffset}");
                  //   setState(() {
                  //     signatureSelected = false;
                  //   });
                  // },
                  child: Container(height: 30, width: 30, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.transparent, border: Border.all(color: Colors.black, width: 3)),))
            // )
                : Container(),

            ///Signature Image
            Positioned(
             left: signaturePos.dx,
              top: signaturePos.dy,
                child: Transform.rotate(
                  angle: rotation,
                  filterQuality: FilterQuality.high,
                  child: GestureDetector(
                    onTap: () {
                    debugPrint("tapped00");
                      setState(() {
                        signatureSelected = !signatureSelected;
                      });
                    },
                    onScaleUpdate: (details) {
                      // debugPrint("pan update $details");
                      setState(() {
                        if (signatureSelected) {
                          rotation = details.rotation != 0.0 ? details.rotation : rotation ;
                          scale = details.scale != 1 ? details.scale : scale;
                          Offset imageOffset = Offset(details.focalPoint.dx - (150 * scale)/2, details.focalPoint.dy - (150 * scale)/2);
                          signaturePos = imageOffset;
                        }
                      });
                    },
                    child: signatureImg != null
                        ? Container(
                          width: imageWidth * scale,
                          height: imageHeight * scale,
                          decoration: BoxDecoration(border: Border.all(color: signatureSelected ? Colors.red[400]! : Colors.transparent,)),
                          child: Image.file(signatureImg!, fit: BoxFit.contain, isAntiAlias: true, )
                        ) : Container()
                  ),
                ),
            ),
          ],
        ),
      ),

      /// Download and Draw Signature Button
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
              heroTag: 'Download', backgroundColor: Colors.purple[100],
              onPressed: () {
               /// Download PDF
                downloadPDF();
              },
              child: const Icon(Icons.download_sharp)),
          FloatingActionButton.small(
              heroTag: 'Draw Signature', backgroundColor: Colors.purple[100],
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((image) async{
                  if (image != null) {
                    ui.Image byteList = await decodeImageFromList(await image.readAsBytes());
                    imageHeight = byteList.height;
                    imageWidth = byteList.width;

                    signatureImg = image;
                    setState(() {});
                  }
                });
              },
              child: const Icon(Icons.format_paint)),
        ],
      ),
    );
  }

  downloadPDF() async {
    Uint8List pdfList =  updatedPDF != null ? await updatedPDF!.readAsBytes() : await widget.pdf.absolute.readAsBytes();

    //Create a new PDF document
    PdfDocument document = PdfDocument(inputBytes: pdfList);
    debugPrint("pages list ${document.pages.count} ");

    // Add image
    document.pages[pageNumber - 1].graphics.drawImage(
        PdfBitmap(await signatureImg!.readAsBytes()),
        Rect.fromLTWH(signaturePos.dx, signaturePos.dy, imageWidth * scale, imageHeight * scale)
    );

    document.pages[pageNumber - 1].graphics.rotateTransform(rotation);

    //Saves the document
    Directory saveDir = await getApplicationDocumentsDirectory();
    String path = '${saveDir.path}/Output.pdf';
    File saveFile = await File(path).writeAsBytes(await document.save());
    updatedPDF = saveFile;

    signatureImg = null;
    controller.jumpToPage(pageNumber);
    setState(() {});

    //Disposes the document
    document.dispose();
  }
}