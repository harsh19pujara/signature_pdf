import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:signature_pdf/main.dart';
import 'package:signature_pdf/view_pdf_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? pickedPDF;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            "assets/appIcon.png",
            height: MediaQuery.of(context).size.width - 60,
          ),
          const SizedBox(
            height: 20,
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor, width: 2),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              ///Pick PDF from device
              pickPDF();
            },
            child: const Text("Select a PDF"),
          ),
        ],
      )),
    );
  }

  Future<void> pickPDF() async {
    await FilePicker.platform.pickFiles(allowMultiple: false).then((pickedFile) {
      if (pickedFile != null) {
        debugPrint("files $pickedFile");
        if (pickedFile.files.isNotEmpty) {
          // File picked
          PlatformFile selectedFile = pickedFile.files[0];
          pickedPDF = File(selectedFile.path.toString());
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewPDFPage(pdf: pickedPDF!),
              ));
        } else {
          // No file Picked
        }
      }
    });
  }
}
