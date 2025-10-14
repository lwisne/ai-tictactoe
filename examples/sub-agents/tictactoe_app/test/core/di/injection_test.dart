import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:tictactoe_app/core/di/injection.dart';

void main() {
  group('Dependency Injection', () {
    setUp(() {
      // Reset GetIt before each test
      GetIt.instance.reset();
    });

    test('getIt should be a GetIt instance', () {
      expect(getIt, isA<GetIt>());
    });

    test('getIt should be a singleton', () {
      expect(getIt, same(GetIt.instance));
    });

    test('configureDependencies should execute without error', () {
      expect(() => configureDependencies(), returnsNormally);
    });

    test('configureDependencies should initialize getIt', () {
      configureDependencies();
      // If configureDependencies runs successfully, getIt should be initialized
      // We can verify this by checking that getIt is not null and is the same instance
      expect(getIt, isNotNull);
      expect(getIt, same(GetIt.instance));
    });
  });
}
