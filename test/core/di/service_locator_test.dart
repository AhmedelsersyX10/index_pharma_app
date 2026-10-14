import 'package:flutter_test/flutter_test.dart';
import 'package:index_pharma/core/di/service_locator.dart';
import 'package:index_pharma/core/network/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('ServiceLocator', () {
    test('setupServiceLocator registers ApiClient', () async {
      expect(getIt.isRegistered<ApiClient>(), isFalse);

      await setupServiceLocator();

      expect(getIt.isRegistered<ApiClient>(), isTrue);
    });

    test('setupServiceLocator avoids duplicate registrations on multiple calls',
        () async {
      await setupServiceLocator();
      expect(getIt.isRegistered<ApiClient>(), isTrue);

      // Calling setupServiceLocator a second time should not throw
      expect(() => setupServiceLocator(), returnsNormally);
      expect(getIt.isRegistered<ApiClient>(), isTrue);
    });

    test('ApiClient registration is lazy (not instantiated until requested)',
        () async {
      await setupServiceLocator();

      // Before accessing it, the instance should not be ready/instantiated yet
      expect(getIt.isReadySync<ApiClient>(), isFalse);
    });
  });
}
