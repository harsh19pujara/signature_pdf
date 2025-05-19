import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/screens/add_signature/draw_signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditPDFController extends GetxController{
  File pickedFile = Get.arguments as File;

  PdfViewerController pdfController = PdfViewerController();
  Offset signatureScreenPos = const Offset(0, 0);
  Offset signaturePDFPlacingPos = const Offset(0, 0);
  Offset signaturePDFPos = const Offset(0, 0);
  Offset signatureImageLocalPos = const Offset(0, 0);
  File? signatureImg;
  int imageHeight = 0;
  int imageWidth = 0;
  double oldRotation = 0.0;
  double rotation = 0.0;
  double scale = 1.0;
  bool signatureSelected = true;
  bool ignoring = false;
  int pageNumber = 1;
  File? updatedFile;
  bool interstitialAdLoaded = false;
  bool rewardedAdLoaded = false;
  String adUnitId = 'ca-app-pub-7342648461123301/4299974481';

  downloadPDF({required bool download}) async {
    Uint8List pdfList = updatedFile != null
        ? await updatedFile!.readAsBytes()
        : await pickedFile.absolute.readAsBytes();

    // Create a new PDF document
    PdfDocument document = PdfDocument(inputBytes: pdfList);

    // Only add the signature if it exists
    if (signatureImg != null) {
      debugPrint(
          "pages list ${document.pages.count}, ${(rotation == 0 ? 1 : rotation) * (180 / math.pi)}, ${signatureScreenPos.dx}, ${signatureScreenPos.dy}, ${imageWidth * scale}, ${imageHeight * scale}");
      int number = pageNumber > 0 ? pageNumber - 1 : 0;
      document.pages[number].graphics.drawImage(
        PdfBitmap(await signatureImg!.readAsBytes()),
        Rect.fromLTWH(
          (signaturePDFPos - signatureImageLocalPos).dx - 40,
          (signaturePDFPos - signatureImageLocalPos).dy - 35,
          imageWidth * scale * 1.5,
          imageHeight * scale * 1.5,
        ),
      );
    }

    // Save to path
    Directory saveDir = await getTemporaryDirectory();
    if (download) {
      saveDir = Directory('/storage/emulated/0/Download');
    }

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    String path = '${saveDir.path}/${pickedFile.path.split("/").last.split(".").first}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await document.save()).then((saveFile) {
      debugPrint("fileWritten at $path");
      updatedFile = saveFile;

      // Reset signature state if it was used
      signatureImg = null;
      signatureSelected = true;
      scale = 1;
      rotation = 0.0;

      document.dispose();

      Get.showSnackbar(
        GetSnackBar(title: "PDF downloaded successfully to $path"),
      );
    });
  }

  drawSignature() {
    Get.to(() => const DrawSignature(),
        )?.then((image) async {
      if (image != null) {
        ui.Image byteList = await decodeImageFromList(await image.readAsBytes());
        imageHeight = byteList.height;
        imageWidth = byteList.width;
        signatureImg = image;
        debugPrint("signature img: $signatureImg");
      }
    });
  }

  previousPage() {
    if (pageNumber > 0) {
      pageNumber--;
      pdfController.jumpToPage(pageNumber);
    }
  }

  nextPage() {
    if (pageNumber < pdfController.pageCount) {
      pageNumber++;
      pdfController.jumpToPage(pageNumber);
    }
  }
}