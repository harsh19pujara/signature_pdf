import 'package:flutter/material.dart';
import 'package:signature_pdf/home.dart';

Color primaryColor = const Color(0xFF147fda);
Color secondaryColor = Colors.grey[200]!;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}


