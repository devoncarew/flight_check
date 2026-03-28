// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/src/devices/device_database.dart';
import 'package:bezel/src/devices/device_profile.dart';
import 'package:bezel/src/devices/screen_cutout.dart';

void main() {
  group('DeviceDatabase.all', () {
    test('is non-empty', () {
      expect(DeviceDatabase.all, isNotEmpty);
    });

    test(
      'every profile has a non-null cutout (uses NoCutout rather than null)',
      () {
        for (final profile in DeviceDatabase.all) {
          // cutout is non-nullable; this confirms no profile omits the field.
          expect(profile.cutout, isA<ScreenCutout>());
        }
      },
    );

    test('every profile id is unique', () {
      final ids = DeviceDatabase.all.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('prints device list in markdown format', () {
      final devices = DeviceDatabase.all;

      String sizeStr(DeviceProfile d) =>
          '${d.logicalSize.width.toInt()} × ${d.logicalSize.height.toInt()}';

      String platformStr(DeviceProfile d) =>
          d.platform == DevicePlatform.iOS ? 'iOS' : 'Android';

      final nameW = devices
          .map((d) => d.name.length)
          .fold('Device'.length, (w, l) => l > w ? l : w);
      final platformW = devices
          .map((d) => platformStr(d).length)
          .fold('Platform'.length, (w, l) => l > w ? l : w);
      final sizeW = devices
          .map((d) => sizeStr(d).length)
          .fold('Logical size'.length, (w, l) => l > w ? l : w);

      final header =
          '| ${'Device'.padRight(nameW)} | ${'Platform'.padRight(platformW)} | ${'Logical size'.padRight(sizeW)} |';
      final divider =
          '|-${'-' * nameW}-|-${'-' * platformW}-|-${'-' * sizeW}-|';

      print(header);
      print(divider);
      for (final d in devices) {
        print(
          '| ${d.name.padRight(nameW)} | ${platformStr(d).padRight(platformW)} | ${sizeStr(d).padRight(sizeW)} |',
        );
      }
    });
  });

  group('DeviceDatabase.forPlatform', () {
    test('returns only iOS profiles', () {
      final ios = DeviceDatabase.forPlatform(DevicePlatform.iOS);
      expect(ios, isNotEmpty);
      expect(ios.every((p) => p.platform == DevicePlatform.iOS), isTrue);
    });

    test('returns only Android profiles', () {
      final android = DeviceDatabase.forPlatform(DevicePlatform.android);
      expect(android, isNotEmpty);
      expect(
        android.every((p) => p.platform == DevicePlatform.android),
        isTrue,
      );
    });

    test('iOS and Android lists together cover all profiles', () {
      final ios = DeviceDatabase.forPlatform(DevicePlatform.iOS);
      final android = DeviceDatabase.forPlatform(DevicePlatform.android);
      expect(ios.length + android.length, DeviceDatabase.all.length);
    });
  });

  group('DeviceDatabase.findById', () {
    test('returns the matching profile', () {
      final profile = DeviceDatabase.findById('iphone_15');
      expect(profile, isNotNull);
      expect(profile!.id, 'iphone_15');
      expect(profile.name, 'iPhone 15');
    });

    test('returns null for an unknown id', () {
      expect(DeviceDatabase.findById('does_not_exist'), isNull);
    });
  });

  group('DeviceDatabase.defaultProfile', () {
    test('is contained in all', () {
      expect(DeviceDatabase.all, contains(DeviceDatabase.defaultProfile));
    });

    test('is the iPhone 15', () {
      expect(DeviceDatabase.defaultProfile.id, 'iphone_15');
    });
  });
}
