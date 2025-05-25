import 'dart:io';
import 'dart:ui';

class SignatureModel {
  final File signatureImage;
  Offset signatureScreenPos;
  Offset signPositionOnPDF;
  Offset signatureImageLocalPos;
  int imgHeight;
  int imgWidth;
  bool isPlaced;
  int pageNumber;
  bool isSignatureSelected;
  double rotation;
  double scale;

  /// This [ignoring] is used for placing signature on PDF
  /// It measures the tap interval on signature
  /// if double taps the signature in 500ms then the placement position of sign will be considered that
  /// ignoring measure the tap time, the second tap needs to be within 500ms,
  /// else sign placement will not be considered
  bool ignoring;


  SignatureModel({
    required this.signatureImage,
    this.signatureScreenPos = const Offset(0, 0),
    this.signPositionOnPDF = const Offset(0, 0),
    this.signatureImageLocalPos = const Offset(0, 0),
    required this.imgHeight,
    required this.imgWidth,
    this.isPlaced = false,
    required this.pageNumber,
    this.isSignatureSelected = true,
    this.rotation = 0.0,
    this.scale = 1.0,
    this.ignoring = false,
  });
}
