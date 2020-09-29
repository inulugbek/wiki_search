import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

///Platform related actions
class PlatformActions {
  ///copy provided [String] text to device clipboard
  static Future<bool> copyToClipBoard(String text) =>
      Clipboard.setData(ClipboardData(text: text)).then((_) => true);

  /// launches provided URL [String]
  static Future<bool> launchURL(String url) async {
    if (await canLaunch(url)) {
      return launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }
}
