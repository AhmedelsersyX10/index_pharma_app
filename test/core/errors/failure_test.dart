import 'package:flutter_test/flutter_test.dart' hide Timeout;
import 'package:index_pharma/core/errors/failure.dart';
import 'package:index_pharma/core/network/api_result.dart';

void main() {
  group('Failure sealed hierarchy', () {
    test('exhaustive switch pattern matching compiles and executes', () {
      final List<Failure> allFailures = [
        const Network(serverMessage: 'network'),
        const Timeout(serverMessage: 'timeout'),
        const Validation(serverMessage: 'validation'),
        const Unauthorized(serverMessage: 'unauthorized'),
        const Forbidden(serverMessage: 'forbidden'),
        const NotFound(serverMessage: 'not_found'),
        const Conflict(serverMessage: 'conflict'),
        const RateLimit(serverMessage: 'rate_limit'),
        const Server(serverMessage: 'server'),
        const Unexpected(serverMessage: 'unexpected'),
      ];

      for (final failure in allFailures) {
        final label = switch (failure) {
          Network() => 'network',
          Timeout() => 'timeout',
          Validation() => 'validation',
          Unauthorized() => 'unauthorized',
          Forbidden() => 'forbidden',
          NotFound() => 'not_found',
          Conflict() => 'conflict',
          RateLimit() => 'rate_limit',
          Server() => 'server',
          Unexpected() => 'unexpected',
        };

        expect(label, equals(failure.serverMessage));
      }
    });

    test('equality and hashCode work as expected for Failure subtypes', () {
      const f1 = Validation(serverMessage: 'msg');
      const f2 = Validation(serverMessage: 'msg');
      const f3 = Validation(serverMessage: 'other');
      const f4 = Unauthorized(serverMessage: 'msg');

      expect(f1, equals(f2));
      expect(f1.hashCode, equals(f2.hashCode));
      expect(f1, isNot(equals(f3)));
      expect(f1, isNot(equals(f4)));
    });

    test('toString includes runtimeType and serverMessage', () {
      const f = Validation(serverMessage: 'invalid');
      expect(f.toString(), contains('Validation'));
      expect(f.toString(), contains('invalid'));
    });
  });

  group('ApiResult sealed hierarchy', () {
    test('Success carries data and supports pattern matching', () {
      const ApiResult<String> result = Success('sample');

      final extracted = switch (result) {
        Success(:final data) => data,
        Err(:final failure) => failure.serverMessage ?? '',
      };

      expect(extracted, 'sample');
    });

    test('Err carries failure and supports pattern matching', () {
      const ApiResult<String> result = Err(NotFound(serverMessage: 'not found'));

      final extracted = switch (result) {
        Success(:final data) => data,
        Err(:final failure) => failure.serverMessage,
      };

      expect(extracted, 'not found');
    });

    test('ApiResult equality and hashCode work correctly', () {
      const r1 = Success<int>(42);
      const r2 = Success<int>(42);
      const r3 = Success<int>(99);
      const e1 = Err<int>(Network(serverMessage: 'offline'));
      const e2 = Err<int>(Network(serverMessage: 'offline'));

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1, isNot(equals(r3)));
      expect(e1, equals(e2));
      expect(e1.hashCode, equals(e2.hashCode));
      expect(r1, isNot(equals(e1)));
    });
  });
}
