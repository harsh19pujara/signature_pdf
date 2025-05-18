import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature_pdf/screens/home/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}


