import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class FacebookDownloadService {
  FacebookDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _apiUrl = String.fromEnvironment('COBALT_API_URL');
  static const _apiToken = String.fromEnvironment('COBALT_API_TOKEN');

  final Dio _dio;

  Future<String> download(
    String facebookUrl, {
    required ValueChanged<double> onProgress,
  }) async {
    if (kIsWeb) {
      throw const DownloadException('Direct saving is unavailable on web.');
    }
    if (_apiUrl.isEmpty) {
      throw const DownloadException(
        'Downloader server is not configured. Set COBALT_API_URL when running the app.',
      );
    }

    final mediaUrl = await _resolveMediaUrl(facebookUrl);
    final directory = await _downloadDirectory();
    final fileName = 'facebook_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final savePath = '${directory.path}${Platform.pathSeparator}$fileName';

    try {
      await _dio.download(
        mediaUrl,
        savePath,
        options: Options(followRedirects: true),
        onReceiveProgress: (received, total) {
          if (total > 0) onProgress(received / total);
        },
      );
      return savePath;
    } on DioException catch (error) {
      final message = error.response?.statusMessage ?? error.message;
      throw DownloadException(
        'Video download failed: ${message ?? 'unknown error'}',
      );
    }
  }

  Future<String> _resolveMediaUrl(String facebookUrl) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _apiUrl,
        data: {'url': facebookUrl, 'downloadMode': 'auto'},
        options: Options(
          headers: {
            Headers.acceptHeader: 'application/json',
            Headers.contentTypeHeader: 'application/json',
            if (_apiToken.isNotEmpty) 'Authorization': 'Api-Key $_apiToken',
          },
        ),
      );
      final data = response.data;
      final status = data?['status'] as String?;
      final url = data?['url'] as String?;
      if ((status == 'tunnel' || status == 'redirect') && url != null) {
        return url;
      }
      final error = data?['error'];
      final code = error is Map ? error['code'] : null;
      throw DownloadException(
        code is String
            ? 'Facebook could not resolve this link ($code).'
            : 'This link did not return a downloadable public video.',
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw DownloadException(
        'Could not contact the downloader server${status == null ? '' : ' ($status)'}.',
      );
    }
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
}

class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
