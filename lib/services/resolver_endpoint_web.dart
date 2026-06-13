import 'package:web/web.dart' as web;

String get resolverEndpoint {
  const override = String.fromEnvironment('COBALT_API_URL');
  if (override.isNotEmpty) return override;

  final host = web.window.location.hostname;
  if (host == 'localhost' || host == '127.0.0.1') {
    return 'http://localhost:9000/';
  }
  return '/api/resolve';
}
