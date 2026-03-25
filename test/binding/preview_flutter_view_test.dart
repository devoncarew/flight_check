import 'package:flutter_test/flutter_test.dart';

import 'package:bezel/src/binding/preview_flutter_view.dart';
import 'package:bezel/src/devices/device_database.dart';
import 'package:bezel/src/preview_controller.dart';

void main() {
  // Initialize the test binding so we have a real FlutterView to use as _real.
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  late PreviewController controller;
  late PreviewFlutterView view;

  setUp(() {
    controller = PreviewController();
    view = PreviewFlutterView(
      binding.platformDispatcher.implicitView!,
      controller,
    );
  });

  tearDown(() {
    controller.dispose();
  });

  test(
    'devicePixelRatio maps real physical width onto emulated logical width',
    () {
      final realPhysical =
          binding.platformDispatcher.implicitView!.physicalSize;
      final emulatedLogical = controller.emulatedLogicalSize;
      expect(
        view.devicePixelRatio,
        closeTo(realPhysical.width / emulatedLogical.width, 0.001),
      );
    },
  );

  test('physicalSize delegates to the real view', () {
    final realPhysical = binding.platformDispatcher.implicitView!.physicalSize;
    expect(view.physicalSize, realPhysical);
  });

  test('devicePixelRatio updates when orientation toggles', () {
    final realPhysical = binding.platformDispatcher.implicitView!.physicalSize;
    controller.toggleOrientation();
    final emulatedLogical = controller.emulatedLogicalSize; // now landscape
    expect(
      view.devicePixelRatio,
      closeTo(realPhysical.width / emulatedLogical.width, 0.001),
    );
  });

  test('padding.top returns the profile safe area top', () {
    final profile = DeviceDatabase.defaultProfile;
    expect(view.padding.top, profile.safeAreaPortrait.top);
  });

  test('viewPadding matches padding', () {
    expect(view.viewPadding.top, view.padding.top);
    expect(view.viewPadding.bottom, view.padding.bottom);
    expect(view.viewPadding.left, view.padding.left);
    expect(view.viewPadding.right, view.padding.right);
  });

  test('viewInsets is zero', () {
    expect(view.viewInsets.top, 0.0);
    expect(view.viewInsets.bottom, 0.0);
    expect(view.viewInsets.left, 0.0);
    expect(view.viewInsets.right, 0.0);
  });
}
