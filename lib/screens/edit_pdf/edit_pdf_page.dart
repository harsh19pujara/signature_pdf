import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/screens/add_signature/draw_signature.dart';
import 'package:signature_pdf/screens/edit_pdf/edit_pdf_controller.dart';
import 'package:signature_pdf/utils/theme_const.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:math' as math;

class EditPDFPage extends StatelessWidget {
  EditPDFPage({super.key});
  final EditPDFController controller = Get.put(EditPDFController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  debugPrint("yoo");
                },
                child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blue[200]!)),

            ///PDF
            SfPdfViewer.file(
              controller.updatedFile ?? controller.pickedFile,
              onDocumentLoaded: (details) {
                controller.pdfController.jumpToPage(controller.pageNumber);
              },
              canShowPasswordDialog: true,
              pageLayoutMode: PdfPageLayoutMode.single,

              controller: controller.pdfController,
              canShowScrollHead: false,
              enableDoubleTapZooming: false,
              onTap: (details) {
                if (controller.ignoring == true) {
                  debugPrint(
                      "pdf position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition},  sign ${controller.signatureScreenPos}");

                    controller.signatureSelected = !controller.signatureSelected;
                    controller.signaturePDFPos = details.pagePosition;
                    controller.ignoring = false;

                  controller.update();
                  // if (!signatureSelected) {
                  //   downloadPDF(download: false);
                  // }
                }
              },
              onPageChanged: (details) {
                controller.pageNumber = details.newPageNumber;
              },
            ),

            ///Signature Image
            Positioned(
              left: controller.signatureScreenPos.dx,
              top: controller.signatureScreenPos.dy,
              child: IgnorePointer(
                ignoring: controller.ignoring,
                child: Transform.rotate(
                  angle: controller.rotation,
                  filterQuality: FilterQuality.high,
                  child: GestureDetector(
                      onTapUp: (tapDetails) {
                        if (controller.signatureSelected == true) {

                            debugPrint("tapped00 ${tapDetails.localPosition}");
                            controller.signatureImageLocalPos = tapDetails.localPosition;
                            controller.ignoring = true;
                            controller.signatureSelected = !controller.signatureSelected;

                        } else {

                            controller.signatureSelected = true;

                        }
                        controller.update();
                        Future.delayed(
                          const Duration(
                            milliseconds: 500,
                          ),
                          () {

                              controller.ignoring = false;
                            controller.update();
                          },
                        );
                      },
                      onScaleUpdate: (details) {
                        debugPrint("pan update $details");

                          if (controller.signatureSelected) {
                            controller.rotation = details.rotation != 0.0 ? details.rotation : controller.rotation;
                            if (details.scale != 1) {
                              controller.scale = details.scale;
                            }
                            controller.scale = details.scale != 1 ? details.scale : controller.scale;
                            Offset imageOffset =
                                Offset(details.focalPoint.dx - (150 * controller.scale) / 2, details.focalPoint.dy - (150 * controller.scale) / 2);
                            controller.signatureScreenPos = imageOffset;
                          }
                        controller.update();
                      },
                      child: controller.signatureImg != null
                          ? Container(
                              width: controller.imageWidth * controller.scale,
                              height: controller.imageHeight * controller.scale,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: controller.signatureSelected ? primaryColor : Colors.transparent,
                              )),
                              child: Image.file(
                                controller.signatureImg!,
                                fit: BoxFit.contain,
                                isAntiAlias: true,
                              ))
                          : Container()),
                ),
              ),
            ),

            /// Previous page
            Positioned(
              top: 40,
              left: 0,
              child: InkWell(
                onTap: () {
                  controller.previousPage();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10))),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_sharp,
                      color: secondaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            /// Next page
            Positioned(
              top: 40,
              right: 0,
              child: InkWell(
                onTap: () {
                  controller.nextPage();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10))),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_sharp,
                      color: secondaryColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),

            /// Instruction Text
            Positioned(
              top: 40,
              right: MediaQuery.of(context).size.width / 2 - 100,
              child: Center(
                child: SizedBox(
                    width: 200,
                    child: Text(
                      "Double Tap to Place Signature on PDF",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.black45,
                          shadows: [Shadow(color: secondaryColor, blurRadius: 1, offset: const Offset(1, 1))]),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    )),
              ),
            )
          ],
        ),
      ),

      /// Download and Draw Signature Button
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: ElevatedButton(
                onPressed: () {
                  controller.drawSignature();
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text("Add Signature")),
          ),
          FloatingActionButton.small(
              heroTag: 'Download',
              backgroundColor: primaryColor,
              onPressed: () async {
                /// Download PDF
                // if (!signatureSelected) {
                  controller.downloadPDF(download: true);
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Make changes to PDF")));
                // }
              },
              child: Icon(
                Icons.download_sharp,
                color: secondaryColor,
              )),
        ],
      ),
    );
  }




// downloadPDF({required bool download}) async {
  //   Uint8List pdfList = updatedPDF != null ? await updatedPDF!.readAsBytes() : await widget.pdf.absolute.readAsBytes();
  //
  //   //Create a new PDF document
  //   PdfDocument document = PdfDocument(inputBytes: pdfList);
  //   debugPrint(
  //       "pages list ${document.pages.count} , ${(rotation == 0 ? 1 : rotation) * (180 / math.pi)}, ${signatureScreenPos.dx}, ${signatureScreenPos.dy}, ${imageWidth * scale}, ${imageHeight * scale}");
  //
  //   // Add image
  //   document.pages[pageNumber - 1].graphics.drawImage(
  //       PdfBitmap(await signatureImg!.readAsBytes()),
  //       Rect.fromLTWH((signaturePDFPos - signatureImageLocalPos).dx - 40, (signaturePDFPos - signatureImageLocalPos).dy - 35,
  //           imageWidth * scale * 1.5, imageHeight * scale * 1.5));
  //
  //   Directory saveDir = await getTemporaryDirectory();
  //   if (download == true) {
  //     saveDir = Directory('/storage/emulated/0/Download');
  //   }
  //
  //   if (await saveDir.exists()) {
  //   } else {
  //     await saveDir.create(recursive: true);
  //   }
  //   debugPrint("path $saveDir");
  //   String path = '${saveDir.path}/Output_${DateTime.now().millisecondsSinceEpoch}.pdf';
  //   await File(path).writeAsBytes(await document.save()).then((saveFile) {
  //     // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloaded, Check Download Folder in File Manager")));
  //     debugPrint("fileWritten");
  //     updatedPDF = saveFile;
  //     signatureImg = null;
  //     signatureSelected = true;
  //     scale = 1;
  //     rotation = 0.0;
  //     //Disposes the document
  //     document.dispose();
  //
  //     setState(() {});
  //   });
  // }
}
