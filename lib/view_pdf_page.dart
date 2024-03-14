import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature_pdf/draw_signature.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:math' as math;

class ViewPDFPage extends StatefulWidget {
  const ViewPDFPage({Key? key, required this.pdf}) : super(key: key);
  final File pdf;

  @override
  State<ViewPDFPage> createState() => _ViewPDFPageState();
}

class _ViewPDFPageState extends State<ViewPDFPage> {
  PdfViewerController controller = PdfViewerController();
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
  File? updatedPDF;
  late InterstitialAd interstitialAd;
  late RewardedAd rewardedAd;
  bool interstitialAdLoaded = false;
  bool rewardedAdLoaded = false;
  String adUnitId = 'ca-app-pub-7342648461123301/4299974481';

  Future<void> initAd() async {
    await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (ad) {
              debugPrint("ad loaded");
              rewardedAd = ad;
              rewardedAdLoaded = true;

              rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {

                },
                onAdClicked: (ad) {

                },
                onAdFailedToShowFullScreenContent: (ad, error) {

                },
              );
            },
            onAdFailedToLoad: (error) {

            },
        )
    );


    // await InterstitialAd.load(
    //     adUnitId: adUnitId,
    //     request: AdRequest(),
    //     adLoadCallback: InterstitialAdLoadCallback(
    //         onAdLoaded: (ad) {
    //           interstitialAd = ad;
    //           interstitialAdLoaded = true;
    //
    //           interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
    //             onAdDismissedFullScreenContent: (ad) {
    //
    //             },
    //             onAdClicked: (ad) {
    //
    //             },
    //             onAdFailedToShowFullScreenContent: (ad, error) {
    //
    //             },
    //           );
    //         },
    //         onAdFailedToLoad: (error) {
    //
    //         },
    //     )
    // );
  }

  @override
  void initState() {
    super.initState();
    initAd();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GestureDetector(onTap: (){
              debugPrint("yoo");
            },child: Container(height: MediaQuery.of(context).size.height, width: MediaQuery.of(context).size.width, color: Colors.red[200]!.withOpacity(0.2))),

            ///PDF
            SfPdfViewer.file(
              updatedPDF ?? widget.pdf,
              onDocumentLoaded: (details) {
                controller.jumpToPage(pageNumber);
              },
              canShowPasswordDialog: true,
              pageLayoutMode: PdfPageLayoutMode.single,
              controller: controller,
              canShowScrollHead: false,
              enableDoubleTapZooming: false,
              onTap: (details) {
                if (ignoring == true) {
                  debugPrint("pdf position: ${details.position}, pageNo: ${details.pageNumber}, pagePos : ${details.pagePosition},  sign $signatureScreenPos");
                  setState(() {
                    signatureSelected = !signatureSelected;
                    signaturePDFPos = details.pagePosition;
                    ignoring = false;
                  });
                  if (!signatureSelected) {
                    downloadPDF(download: false);
                  }
                }
              },
              onPageChanged: (details) {
                pageNumber = details.newPageNumber;
              },
            ),

            ///Signature Image
            Positioned(
             left: signatureScreenPos.dx,
              top: signatureScreenPos.dy,
                child: IgnorePointer(
                  ignoring: ignoring,
                  child: Transform.rotate(
                    angle: rotation,
                    filterQuality: FilterQuality.high,
                    child: GestureDetector(
                      onTapUp: (tapDetails) {
                        if (signatureSelected == true) {
                          setState(() {
                            debugPrint("tapped00 ${tapDetails.localPosition}");
                            signatureImageLocalPos = tapDetails.localPosition;
                            ignoring = true;
                            // signatureSelected = !signatureSelected;
                          });
                        } else {
                          setState(() {
                            signatureSelected = true;
                          });
                        }
                        Future.delayed(const Duration(milliseconds: 500,), () {
                          setState(() {
                            ignoring = false;
                          });
                        },);
                      },
                      onScaleUpdate: (details) {
                        debugPrint("pan update $details");
                        setState(() {
                          if (signatureSelected) {
                            rotation = details.rotation != 0.0 ? details.rotation : rotation ;
                            if(details.scale != 1){

                              scale = details.scale;
                            }
                            scale = details.scale != 1 ? details.scale : scale;
                            Offset imageOffset = Offset(details.focalPoint.dx - (150 * scale)/2, details.focalPoint.dy - (150 * scale)/2);
                            signatureScreenPos = imageOffset;
                          }
                        });
                      },
                      child: signatureImg != null
                          ? Container(
                              width: imageWidth * scale,
                              height: imageHeight * scale,
                              decoration: BoxDecoration(border: Border.all(color: signatureSelected ? Colors.red[400]! : Colors.transparent,)),
                              child: Image.file(signatureImg!, fit: BoxFit.contain, isAntiAlias: true, )
                            ): Container()
                    ),
                  ),
                ),
            ),

            /// Previous page
            Positioned(
              top: 40,
              left: 0,
              child: InkWell(
                onTap: () {
                  if (pageNumber > 0) {
                    pageNumber--;
                    controller.jumpToPage(pageNumber);
                  }
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10), topRight: Radius.circular(10))
                  ),
                  child: const Center(child: Icon(Icons.arrow_back_sharp, color: Colors.black54, size: 20,),),
                ),
              ),
            ),

            /// Next page
            Positioned(
              top: 40,
              right: 0,
              child: InkWell(
                onTap: () {
                  if (pageNumber < controller.pageCount) {
                    pageNumber++;
                    controller.jumpToPage(pageNumber);
                  }
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(10), topLeft: Radius.circular(10))
                  ),
                  child: const Center(child: Icon(Icons.arrow_forward_sharp, color: Colors.black54, size: 20,),),
                ),
              ),
            ),

            /// Instruction Text
            Positioned(
              top: 40,
              right: MediaQuery.of(context).size.width/2 - 100 ,
              child: Center(
                child: SizedBox(
                    width: 200,
                    child: Text(
                      "Double Tap to Place Signature on PDF",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black45,
                        shadows: [Shadow(color: Colors.grey[400]!, blurRadius: 1, offset: const Offset(1, 1))]
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    )),
              ),
            )
          ],
        ),
      ),

      /// Download and Draw Signature Button
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
              heroTag: 'Download', backgroundColor: Colors.purple[100],
              onPressed: () async {
               /// Download PDF
               //  if (!signatureSelected) {
                 await rewardedAd.show(onUserEarnedReward: (ad, reward) {
                   downloadPDF(download: true);
                 },);
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Make changes to PDF")));
                // }
              },
              child: const Icon(Icons.download_sharp)),
          FloatingActionButton.small(
              heroTag: 'Draw Signature', backgroundColor: Colors.purple[100],
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DrawSignature(),)).then((image) async{
                  if (image != null) {
                    ui.Image byteList = await decodeImageFromList(await image.readAsBytes());
                    imageHeight = byteList.height;
                    imageWidth = byteList.width;
                    signatureImg = image;
                    setState(() {});
                  }
                });
              },
              child: const Icon(Icons.format_paint)),
        ],
      ),
    );
  }

  downloadPDF({required bool download}) async {
    Uint8List pdfList =  updatedPDF != null ? await updatedPDF!.readAsBytes() : await widget.pdf.absolute.readAsBytes();

    //Create a new PDF document
    PdfDocument document = PdfDocument(inputBytes: pdfList);
    debugPrint("pages list ${document.pages.count} , ${(rotation == 0 ? 1 : rotation) * (180/math.pi)}, ${signatureScreenPos.dx}, ${signatureScreenPos.dy}, ${imageWidth * scale}, ${imageHeight * scale}");

    // Add image
    document.pages[pageNumber - 1].graphics.drawImage(
        PdfBitmap(await signatureImg!.readAsBytes()),
        Rect.fromLTWH((signaturePDFPos - signatureImageLocalPos).dx - 40, (signaturePDFPos - signatureImageLocalPos).dy - 35, imageWidth * scale * 1.5, imageHeight * scale * 1.5)
    );

    Directory saveDir = await getTemporaryDirectory();
    if(download == true) {
      saveDir = Directory('/storage/emulated/0/Download');
    }

    if(await saveDir.exists()){

    } else {
      await saveDir.create(recursive: true);
    }
    debugPrint("path $saveDir");
    String path = '${saveDir.path}/Output_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await document.save()).then((saveFile) {
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Downloaded, Check Download Folder in File Manager")));
      debugPrint("fileWritten");
      updatedPDF = saveFile;
      signatureImg = null;
      signatureSelected = true;
      scale = 1;
      rotation = 0.0;
      //Disposes the document
      document.dispose();

      setState(() {});
    });
  }
}