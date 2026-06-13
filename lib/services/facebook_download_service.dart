import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'video_file_saver.dart';
import 'resolver_endpoint.dart';

class FacebookDownloadService {
  FacebookDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  static const _apiToken = String.fromEnvironment('COBALT_API_TOKEN');

  final Dio _dio;

  Future<String> download(
    String facebookUrl, {
    required ValueChanged<double> onProgress,
  }) async {
    final mediaUrl = await _resolveMediaUrl(facebookUrl);
    final fileName = 'facebook_${DateTime.now().millisecondsSinceEpoch}.mp4';

    try {
      return await saveVideoFile(_dio, mediaUrl, fileName, onProgress);
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
        resolverEndpoint,
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
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        throw const DownloadException(
          'The local downloader is offline. Start docker-compose.cobalt.yml and try again.',
        );
      }
      throw DownloadException(
        'Could not contact the downloader server${status == null ? '' : ' ($status)'}.',
      );
    }
  }
}

class DownloadException implements Exception {
  const DownloadException(this.message);

  final String message;

  @override
  String toString() => message;
}
