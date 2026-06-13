import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'facebook_download_service.dart' show DownloadException;
import 'video_file_saver.dart';

class InstagramDownloadService {
  InstagramDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _apiUrl = String.fromEnvironment(
    'COBALT_API_URL',
    defaultValue: 'http://localhost:9000/',
  );
  static const _apiToken = String.fromEnvironment('COBALT_API_TOKEN');

  final Dio _dio;

  Future<String> download(
    String instagramUrl, {
    required ValueChanged<double> onProgress,
  }) async {
    final mediaUrl = await _resolveMediaUrl(instagramUrl);
    final fileName = 'instagram_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      return await saveVideoFile(_dio, mediaUrl, fileName, onProgress);
    } on DioException catch (error) {
      final message = error.response?.statusMessage ?? error.message;
      throw DownloadException(
        'Video download failed: ${message ?? 'unknown error'}',
      );
    }
  }

  Future<String> _resolveMediaUrl(String instagramUrl) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _apiUrl,
        data: {'url': instagramUrl, 'downloadMode': 'auto'},
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
      throw const DownloadException(
        'This link did not return downloadable public Instagram media.',
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        throw const DownloadException(
          'The local downloader is offline. Run start_downloader.ps1 and try again.',
        );
      }
      throw DownloadException(
        'Could not resolve this Instagram link (${error.response?.statusCode ?? 'network error'}).',
      );
    }
  }
}
