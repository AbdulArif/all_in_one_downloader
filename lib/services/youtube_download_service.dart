import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'facebook_download_service.dart' show DownloadException;
import 'video_file_saver.dart';
import 'resolver_endpoint.dart';

class YouTubeDownloadService {
  YouTubeDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _apiToken = String.fromEnvironment('COBALT_API_TOKEN');

  final Dio _dio;

  Future<String> download(
    String youtubeUrl, {
    required ValueChanged<double> onProgress,
  }) async {
    final mediaUrl = await _resolveMediaUrl(youtubeUrl);
    final fileName = 'youtube_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      return await saveVideoFile(_dio, mediaUrl, fileName, onProgress);
    } on DioException catch (error) {
      final message = error.response?.statusMessage ?? error.message;
      throw DownloadException(
        'Video download failed: ${message ?? 'unknown error'}',
      );
    }
  }

  Future<String> _resolveMediaUrl(String youtubeUrl) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        resolverEndpoint,
        data: {'url': youtubeUrl, 'downloadMode': 'auto'},
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
        'This link did not return a downloadable public YouTube video.',
      );
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        throw const DownloadException(
          'The local downloader is offline. Run start_downloader.ps1 and try again.',
        );
      }
      final responseData = error.response?.data;
      final responseError = responseData is Map ? responseData['error'] : null;
      final responseCode = responseError is Map ? responseError['code'] : null;
      if (responseCode is String && responseCode.isNotEmpty) {
        if (responseCode.contains('Sign in to confirm')) {
          throw const DownloadException(
            'YouTube blocked the hosting server. Add YOUTUBE_COOKIES_B64 in Render and redeploy.',
          );
        }
        throw DownloadException(responseCode.replaceFirst('ERROR: ', ''));
      }
      throw DownloadException(
        'Could not resolve this YouTube link (${error.response?.statusCode ?? 'network error'}).',
      );
    }
  }
}
