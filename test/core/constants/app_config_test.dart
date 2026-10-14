import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/constants/app_config.dart';

void main() {
  group('AppConfig', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    group('baseUrl & origin', () {
      test('defaults to localhost on desktop and iOS platforms', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        expect(AppConfig.baseUrl, 'http://localhost:5000/api');
        expect(AppConfig.origin, 'http://localhost:5000');
      });

      test('defaults to 10.0.2.2 on Android platform', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        expect(AppConfig.baseUrl, 'http://10.0.2.2:5000/api');
        expect(AppConfig.origin, 'http://10.0.2.2:5000');
      });
    });

    group('mediaUrl', () {
      test('returns empty string when path is empty', () {
        expect(AppConfig.mediaUrl(''), '');
      });

      test('returns full http/https URLs unchanged', () {
        expect(
          AppConfig.mediaUrl('http://example.com/images/sample.jpg'),
          'http://example.com/images/sample.jpg',
        );
        expect(
          AppConfig.mediaUrl('https://example.com/images/sample.jpg'),
          'https://example.com/images/sample.jpg',
        );
      });

      test('prepends origin for relative path with leading slash', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        expect(
          AppConfig.mediaUrl('/uploads/prescriptions/file.jpg'),
          'http://localhost:5000/uploads/prescriptions/file.jpg',
        );
      });

      test('prepends origin and ensures slash for relative path without leading slash', () {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        expect(
          AppConfig.mediaUrl('uploads/prescriptions/file.jpg'),
          'http://localhost:5000/uploads/prescriptions/file.jpg',
        );
      });
    });
  });
}
