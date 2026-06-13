import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

Future<String> saveVideoFile(
  Dio dio,
  String mediaUrl,
  String fileName,
  ValueChanged<double> onProgress,
) async {
  final anchor = web.HTMLAnchorElement()
    ..href = mediaUrl
    ..download = fileName
    ..target = '_blank'
    ..rel = 'noopener';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  onProgress(1);
  return 'your browser Downloads folder';
}
