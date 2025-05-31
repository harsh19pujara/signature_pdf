import 'dart:async';
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

class EditPDFController extends GetxController with GetSingleTickerProviderStateMixin {
  File pickedFile = Get.arguments as File;
  PdfViewerController pdfController = PdfViewerController();
  File? updatedFile;
  List<SignatureModel> signatureList = [];
  int? currentSelectedSign;
  SignatureModel? selectedSign;
  RxInt pdfPageNumber = 1.obs;
  double zoomLevel = 1;
  RxBool isDocumentedLoaded = false.obs;
  RxDouble pdfPageHeight = 0.0.obs;
  RxDouble pdfPageWidth = 0.0.obs;
  RxBool isPageLoaded = false.obs;
  Timer timer = Timer(
    const Duration(milliseconds: 00),
    () {},
  );

  // Advertisement
  bool interstitialAdLoaded = false;
  bool rewardedAdLoaded = false;
  String adUnitId = 'ca-app-pub-7342648461123301/4299974481';

  void setPDFPageDimensions(PdfDocumentLoadedDetails details, BuildContext context) {
    double pdfRatio = (details.document.pageSettings.height) / (details.document.pageSettings.width);
    double availableScreenRation = (context.size?.height ?? 1) / (context.size?.width ?? 1);

    debugPrint("screen height ${Get.height} ,,, ${Get.width}");
    debugPrint("available height ${context.size?.height} ,,, ${context.size?.width}");
    debugPrint("page height ${details.document.pageSettings.height} ,,, ${details.document.pageSettings.width}");

    // [pdfRatio < availableScreenRation] :: Checking if PDF will fill vertical space or horizontal space
    // [context.size?.width] is width of available are in screen for PDF viewer widget
    // In below equation we are using (context.size?.width ?? Get.width),
    // because if we receive null, consider full screen space, to avoid error
    // Formula to get page height width
    //         pdf page height -> pdf page width
    //                          X
    // available screen height -> available screen width
    pdfPageHeight.value = pdfRatio < availableScreenRation
            ? pdfRatio * (context.size?.width ?? Get.width)
            : (context.size?.height ?? Get.height);

    pdfPageWidth.value = pdfRatio < availableScreenRation
            ? details.document.pageSettings.width
            : pdfRatio * (context.size?.height ?? Get.height);
  }

  downloadPDF({required bool download}) async {
    Uint8List pdfList = updatedFile != null ? await updatedFile!.readAsBytes() : await pickedFile.absolute.readAsBytes();

    // Create a new PDF document
    PdfDocument document = PdfDocument(inputBytes: pdfList);

    // Only add the signature if it exists
    if (signatureList.isNotEmpty) {
      for (SignatureModel sign in signatureList) {
        debugPrint(
            "pages list ${document.pages.count}, ${(sign.rotation == 0 ? 1 : sign.rotation) * (180 / math.pi)}, ${sign.signatureScreenPos.value.dx}, ${sign.signatureScreenPos.value.dy}, ${sign.imgWidth * sign.scale}, ${sign.imgHeight * sign.scale}");

        int number = sign.pageNumber > 0 ? sign.pageNumber - 1 : 0;
        document.pages[number].graphics.drawImage(
          PdfBitmap(await sign.signatureImage.readAsBytes()),
          Rect.fromLTWH(
            (sign.signPositionOnPDF.value - sign.signatureImageLocalPos.value).dx - 40,
            (sign.signPositionOnPDF.value - sign.signatureImageLocalPos.value).dy - 35,
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

    String path =
        '${saveDir.path}/${pickedFile.path.split("/").last.split(".").first}_${DateTime.now().millisecondsSinceEpoch}.pdf';
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
        GetSnackBar(
          title: "PDF downloaded successfully to $path",
          message: "Success",
        ),
      );
    });
  }

  drawSignature() {
    Get.to(
      () => const DrawSignature(),
    )?.then((image) async {
      if (image != null) {
        ui.Image byteList = await decodeImageFromList(await image.readAsBytes());
        signatureList.add(SignatureModel(
            signatureImage: image, imgHeight: byteList.height, imgWidth: byteList.width, pageNumber: pdfPageNumber.value));
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
