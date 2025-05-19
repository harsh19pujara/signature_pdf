import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature_pdf/screens/edit_pdf/edit_pdf_page.dart';

class HomeController extends GetxController {
  File? pickedPDF;

  Future<void> pickPDF() async {
    await FilePicker.platform.pickFiles(allowMultiple: false, allowedExtensions: ["pdf"], type: FileType.custom).then((pickedFile) {
      if (pickedFile != null) {
        debugPrint("files $pickedFile");
        if (pickedFile.files.isNotEmpty) {
          // File picked
          PlatformFile selectedFile = pickedFile.files[0];
          pickedPDF = File(selectedFile.path.toString());
          Get.to(() => EditPDFPage(), arguments: pickedPDF!);
        } else {
          // No file Picked
        }
      }
    });
  }
}