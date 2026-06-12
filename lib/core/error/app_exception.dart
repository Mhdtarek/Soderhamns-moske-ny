sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException() : super('network_error');
}

class CacheException extends AppException {
  const CacheException() : super('cache_error');
}

class ParseException extends AppException {
  const ParseException() : super('parse_error');
}
