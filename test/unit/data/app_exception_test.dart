import 'package:flutter_test/flutter_test.dart';
import 'package:soderhamns_moske_app/core/error/app_exception.dart';

void main() {
  group('AppException', () {
    test('NetworkException has correct message', () {
      const exception = NetworkException();
      expect(exception.message, 'network_error');
      expect(exception.toString(), 'network_error');
    });

    test('CacheException has correct message', () {
      const exception = CacheException();
      expect(exception.message, 'cache_error');
      expect(exception.toString(), 'cache_error');
    });

    test('ParseException has correct message', () {
      const exception = ParseException();
      expect(exception.message, 'parse_error');
      expect(exception.toString(), 'parse_error');
    });

    test('all exceptions are AppException', () {
      const network = NetworkException();
      const cache = CacheException();
      const parse = ParseException();

      expect(network, isA<AppException>());
      expect(cache, isA<AppException>());
      expect(parse, isA<AppException>());
    });

    test('all exceptions are Exception', () {
      const network = NetworkException();
      const cache = CacheException();
      const parse = ParseException();

      expect(network, isA<Exception>());
      expect(cache, isA<Exception>());
      expect(parse, isA<Exception>());
    });

    test('sealed class pattern matching works', () {
      const AppException exception = NetworkException();

      final message = switch (exception) {
        NetworkException() => 'network',
        CacheException() => 'cache',
        ParseException() => 'parse',
      };

      expect(message, 'network');
    });

    test('const constructors work', () {
      const network = NetworkException();
      const cache = CacheException();
      const parse = ParseException();

      expect(identical(network, const NetworkException()), isTrue);
      expect(identical(cache, const CacheException()), isTrue);
      expect(identical(parse, const ParseException()), isTrue);
    });
  });
}
