import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<String> saveVideoFile(
  Dio dio,
  String mediaUrl,
  String fileName,
  ValueChanged<double> onProgress,
) async {
  final directory = await _downloadDirectory();
  final savePath = '${directory.path}${Platform.pathSeparator}$fileName';

  await dio.download(
    mediaUrl,
    savePath,
    options: Options(followRedirects: true),
    onReceiveProgress: (received, total) {
      if (total > 0) onProgress(received / total);
    },
  );
  return savePath;
}

Future<Directory> _downloadDirectory() async {
  final downloads = await getDownloadsDirectory();
  if (downloads != null) return downloads;
  if (Platform.isAndroid) {
    final external = await getExternalStorageDirectory();
    if (external != null) return external;
  }
  return getApplicationDocumentsDirectory();
}
