import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/models/signature_model.dart';
import 'package:signature_pdf/screens/add_signature/draw_signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditPDFController extends GetxController {
  File pickedFile = Get.arguments as File;
  PdfViewerController pdfController = PdfViewerController();
  File? updatedFile;
  List<SignatureModel> signatureList = [];
  int? currentSelectedSign;
  SignatureModel? selectedSign;
  RxInt pdfPageNumber = 1.obs;
  double zoomLevel = 1;
  RxBool isDocumentedLoaded = false.obs;

  // Signature
  // Offset signatureScreenPos = const Offset(0, 0);
  // Offset signPositionOnPDF = const Offset(0, 0);
  // Offset signatureImageLocalPos = const Offset(0, 0);
  // File? signatureImg;
  // int imageHeight = 0;
  // int imageWidth = 0;
  // double rotation = 0.0;
  // double scale = 1.0;
  // bool signatureSelected = true;
  // bool ignoring = false;
  // int pageNumber = 1;

  // Advertisement
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
    if (signatureList.isNotEmpty) {
      for (SignatureModel sign in signatureList) {
        debugPrint(
            "pages list ${document.pages.count}, ${(sign.rotation == 0 ? 1 : sign.rotation) * (180 / math.pi)}, ${sign
                .signatureScreenPos.dx}, ${sign.signatureScreenPos.dy}, ${sign.imgWidth * sign.scale}, ${sign.imgHeight *
                sign.scale}");

        int number = sign.pageNumber > 0 ? sign.pageNumber - 1 : 0;
        document.pages[number].graphics.drawImage(
          PdfBitmap(await sign.signatureImage.readAsBytes()),
          Rect.fromLTWH(
            (sign.signPositionOnPDF - sign.signatureImageLocalPos).dx - 40,
            (sign.signPositionOnPDF - sign.signatureImageLocalPos).dy - 35,
            sign.imgWidth * sign.scale * 1.5,
            sign.imgHeight * sign.scale * 1.5,
          ),
        );

        // document.pages[number].graphics.
      }
    }

    // Save to path
    Directory saveDir = await getTemporaryDirectory();
    if (download) {
      saveDir = Directory('/storage/emulated/0/Download');
    }

    if (!await saveDir.exists()) {
      await saveDir.create(recursive: true);
    }

    String path = '${saveDir.path}/${pickedFile.path
        .split("/")
        .last
        .split(".")
        .first}_${DateTime
        .now()
        .millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await document.save()).then((saveFile) {
      debugPrint("fileWritten at $path");
      updatedFile = saveFile;

      // Reset signature state if it was used
      // signatureImg = null;
      // signatureSelected = true;
      // scale = 1;
      // rotation = 0.0;
      signatureList.clear();

      document.dispose();

      Get.showSnackbar(
        GetSnackBar(title: "PDF downloaded successfully to $path", message: "Success",),
      );
    });
  }

  drawSignature() {
    Get.to(() => const DrawSignature(),
    )?.then((image) async {
      if (image != null) {
        ui.Image byteList = await decodeImageFromList(await image.readAsBytes());
        signatureList.add(SignatureModel(signatureImage: image,
            imgHeight: byteList.height,
            imgWidth: byteList.width,
            pageNumber: pdfPageNumber.value));
        update();
        debugPrint("signature img: ${pdfController.pageCount},,,$image");
      }
    });
  }

  previousPage() {
    if (pdfPageNumber.value > 1) {
      pdfPageNumber.value--;
      pdfController.jumpToPage(pdfPageNumber.value);
    }
  }

  nextPage() {
    if (pdfPageNumber.value < pdfController.pageCount) {
      pdfPageNumber.value++;
      pdfController.jumpToPage(pdfPageNumber.value);
    }
  }
}