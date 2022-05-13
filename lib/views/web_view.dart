
import 'package:com_uken_system/views/pdf_url.dart';
import 'package:com_uken_system/views/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/const.dart';

class HeadlessInAppWebViewExampleScreen extends StatefulWidget {
  const HeadlessInAppWebViewExampleScreen({Key? key}) : super(key: key);

  @override
  _HeadlessInAppWebViewExampleScreenState createState() =>
      _HeadlessInAppWebViewExampleScreenState();
}

class _HeadlessInAppWebViewExampleScreenState
    extends State<HeadlessInAppWebViewExampleScreen> {
  HeadlessInAppWebView? headlessWebView;
  dynamic webConroller;

  //String url = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (webConroller != null) {
          webConroller.goBack();
          return Future.value(false);
        } else {
          return Future.value(true);
        }
      },
      child: Scaffold(
          body: SafeArea(
              child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useOnDownloadStart: true,
                cacheEnabled: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
            ),
            onWebViewCreated: (controller) {
              setState(() {
                webConroller = controller;
              });
              if (kDebugMode) {
                print('HeadlessInAppWebView created!');
              }
            },
            onDownloadStart: (controller, cUrl) async {
              if (kDebugMode) {
                print("onDownloadStart $url");
              }

              Get.to(() => PdfView(pdfUrl: cUrl.toString()));

              ///  FileStorage().download2(url: cUrl.toString(), showDownloadProgress: showDownloadProgress);

              //myDownloadFile(cUrl.toString());
            },
            onConsoleMessage: (controller, consoleMessage) {
              if (kDebugMode) {
                print("CONSOLE MESSAGE: " + consoleMessage.message);
              }
            },
            onLoadStart: (controller, curl) async {
              if (kDebugMode) {
                print("onLoadStart $curl to string ${curl.toString()}");
              }
              if (curl.toString().contains("https://api.whatsapp.com/") ||
                  curl.toString().contains("sms:") ||
                  curl.toString().contains("tel:") ||
                  curl.toString().contains("mailto:")) {
                await controller.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(url)));
                setState(() {
                  webConroller = controller;
                });

                await launch(curl.toString());
              }
            },
            onLoadStop: (controller, curl) async {
              if (kDebugMode) {
                print("onLoadStop $url");
              }
              setState(() {
                url = curl.toString();
                webConroller = controller;
              });
            },
            onUpdateVisitedHistory: (controller, curl, androidIsReload) {
              if (kDebugMode) {
                print("onUpdateVisitedHistory $curl");
              }
              setState(() {
                url = curl.toString();
              });
            },
          ),
          if (isLoading == false) buildSplashScreen(),
        ],
      ))),
    );
  }

  SplashScreen buildSplashScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        isLoading = true;
        if (kDebugMode) {
          print('isLoading: $isLoading');
        }
      });
    });

    return const SplashScreen();
  }
}
