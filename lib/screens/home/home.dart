import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature_pdf/main.dart';
import 'package:signature_pdf/screens/home/home_controller.dart';
import 'package:signature_pdf/utils/extension_functions.dart';
import 'package:signature_pdf/utils/image_const.dart';
import 'package:signature_pdf/utils/theme_const.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final HomeController controller = Get.put(HomeController());

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
                homeIcon,
                height: MediaQuery.of(context).size.width - 60,
              ),
              20.sizeBoxHeight(),
              pickFileButton(),
            ],
          )),
    );
  }

  Widget pickFileButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      onPressed: () => controller.pickPDF(),
      child: const Text("Select a PDF"),
    );
  }
}
