import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature_pdf/models/signature_model.dart';
import 'package:signature_pdf/screens/edit_pdf/edit_pdf_controller.dart';
import 'package:signature_pdf/utils/theme_const.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditPDFPage extends StatelessWidget {
  EditPDFPage({super.key});

  final EditPDFController getController = Get.put(EditPDFController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<EditPDFController>(
          builder: (controller) {
            debugPrint( "page :: ${getController.pdfController.pageCount .toString()}");
            return Stack(
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
                    controller.pdfController.jumpToPage(controller.pdfPageNumber.value);
                    debugPrint( "page :: ${getController.pdfController.pageCount .toString()}");
                    controller.isDocumentedLoaded.value = true;

                  },
                  canShowPasswordDialog: true,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  controller: controller.pdfController,
                  canShowScrollHead: false,
                  enableDoubleTapZooming: false,
                  // onZoomLevelChanged: (details) {
                  //   details.
                  // },
                  onTap: (details) {
                    if (controller.selectedSign?.ignoring == true) {
                      debugPrint(
                          "pdf position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition},  sign ${controller.selectedSign?.signatureScreenPos}");

                      controller.selectedSign?.isSignatureSelected = !(controller.selectedSign?.isSignatureSelected ?? true);
                      controller.selectedSign?.signPositionOnPDF = details.pagePosition;
                      controller.selectedSign?.ignoring = false;

                      controller.update();
                      // if (!signatureSelected) {
                      //   downloadPDF(download: false);
                      // }
                    }
                  },
                  // undoController: ,
                  onPageChanged: (details) {
                    // controller.pdfController.;
                    debugPrint("page :: ${details.newPageNumber}");
                    controller.pdfPageNumber.value = details.newPageNumber;
                    getController.update();
                  },

                  maxZoomLevel: 1,
                ),

                ///Signature Image
                for (SignatureModel sign in controller.signatureList) renderSignatureWidget(sign),

                /// Previous page
                Obx(() => renderPreviousPageIcon()),

                /// Next page
                Obx(() => renderNextPageIcon()),

                /// Instruction Text
                renderInfoText()
              ],
            );
          },
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
                  getController.drawSignature();
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
                getController.downloadPDF(download: true);
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

  Widget renderSignatureWidget(SignatureModel sign) {
    return sign.pageNumber == getController.pdfPageNumber.value
        ? Positioned(
            left: sign.signatureScreenPos.dx,
            top: sign.signatureScreenPos.dy,
            child: IgnorePointer(
              ignoring: sign.ignoring,
              child: Transform.rotate(
                angle: sign.rotation,
                filterQuality: FilterQuality.high,
                child: GestureDetector(
                    onTapUp: (tapDetails) {
                      if (sign.isSignatureSelected == true) {
                        debugPrint("tapped00 ${tapDetails.localPosition}");
                        sign.signatureImageLocalPos = tapDetails.localPosition;
                        sign.ignoring = true;
                        // sign.isSignatureSelected = !sign.isSignatureSelected;
                      } else {
                        sign.isSignatureSelected = true;
                      }
                      getController.selectedSign = sign;
                      getController.update();
                      Future.delayed(
                        const Duration(
                          milliseconds: 500,
                        ),
                        () {
                          sign.ignoring = false;
                          getController.update();
                        },
                      );
                    },
                    onScaleUpdate: (details) {
                      debugPrint("pan update $details");

                      if (sign.isSignatureSelected) {
                        sign.rotation = details.rotation != 0.0 ? details.rotation : sign.rotation;
                        if (details.scale != 1) {
                          sign.scale = details.scale;
                        }
                        sign.scale = details.scale != 1 ? details.scale : sign.scale;
                        Offset imageOffset = Offset(
                            details.focalPoint.dx - (150 * sign.scale) / 2, details.focalPoint.dy - (150 * sign.scale) / 2);
                        sign.signatureScreenPos = imageOffset;
                      }
                      getController.update();
                    },
                    child: Container(
                        width: sign.imgWidth * sign.scale,
                        height: sign.imgHeight * sign.scale,
                        decoration: BoxDecoration(
                            border: Border.all(
                          color: sign.isSignatureSelected ? primaryColor : Colors.transparent,
                        )),
                        child: Image.file(
                          sign.signatureImage,
                          fit: BoxFit.contain,
                          isAntiAlias: true,
                        ))),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget renderPreviousPageIcon() {
    return (!getController.isDocumentedLoaded.value)
        ? const SizedBox.shrink()
        : (getController.pdfPageNumber.value == 1  || getController.pdfController.pageCount == 1)
        ? const SizedBox.shrink()
        : Positioned(
            top: Get.height / 2,
            left: 0,
            child: InkWell(
              onTap: () => getController.previousPage(),
              child: Container(
                height: 80,
                width: 50,
                decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10))),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_sharp,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
  }

  Widget renderNextPageIcon() {
    return !getController.isDocumentedLoaded.value
        ? const SizedBox.shrink()
        : (getController.pdfPageNumber.value == getController.pdfController.pageCount) || getController.pdfController.pageCount <= 1
        ? const SizedBox.shrink()
        : Positioned(
            top: Get.height / 2,
            right: 0,
            child: InkWell(
              onTap: () => getController.nextPage(),
              child: Container(
                height: 80,
                width: 50,
                decoration: BoxDecoration(
                    color: secondaryColor.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10))),
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_sharp,
                    color: primaryColor,
                    size: 40,
                  ),
                ),
              ),
            ),
          );
  }

  Widget renderInfoText() {
    return Positioned(
      top: 40,
      right: Get.width / 2 - 100,
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
    );
  }
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
