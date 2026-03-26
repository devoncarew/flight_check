import 'package:flutter/painting.dart' show EdgeInsets, Size;

import 'device_profile.dart';
import 'screen_cutout.dart';

/// The curated list of supported device profiles.
///
/// **iOS geometry** is sourced from community measurements — Apple does not
/// publish machine-readable cutout geometry. Safe-area insets are from
/// useyourloaf.com; Dynamic Island dimensions and corner radii are
/// design-community approximations cross-referenced with iosresolution.com.
///
/// **Android (Pixel) geometry** is converted from AOSP device-tree XML:
///   `device/google/<codename>/overlay/.../config.xml`
/// `config_mainBuiltInDisplayCutout` gives the cutout shape in physical pixels;
/// `config_mainDisplayShape` gives the screen outline. Divide physical
/// coordinates by `devicePixelRatio` to get logical (dp) values.
///
/// **Android (Samsung) geometry** uses community approximations; Samsung does
/// not publish device-tree cutout configs.
const List<DeviceProfile> kDeviceProfiles = [
  // ── iOS ─────────────────────────────────────────────────────────────────

  // iPhone SE (3rd gen): traditional 4.7" LCD with large bezels; no cutout
  // and a flat-edged display — screenCornerRadius 0 is intentional.
  // Safe-area: status bar 20pt (no home indicator; hardware home button).
  // Source: iosresolution.com, useyourloaf.com
  DeviceProfile(
    id: 'iphone_se_3',
    name: 'iPhone SE (3rd gen)',
    platform: DevicePlatform.iOS,
    logicalSize: Size(375, 667),
    devicePixelRatio: 2.0,
    safeAreaPortrait: EdgeInsets.only(top: 20),
    safeAreaLandscape: EdgeInsets.zero,
    screenCornerRadius: 0,
    cutout: NoCutout(),
  ),

  // iPhone 15: 6.1" Super Retina XDR, Dynamic Island.
  // Corner radius: ~44pt (community measurement; Apple HIG Figma kit).
  // Dynamic Island: ~126×37pt pill, ~11pt from screen top
  //   (community measurement; hardware cutout, not the expanded software UI).
  // Safe-area: useyourloaf.com iPhone 15 Screen Sizes
  DeviceProfile(
    id: 'iphone_15',
    name: 'iPhone 15',
    platform: DevicePlatform.iOS,
    logicalSize: Size(393, 852),
    devicePixelRatio: 3.0,
    safeAreaPortrait: EdgeInsets.only(top: 59, bottom: 34),
    safeAreaLandscape: EdgeInsets.only(left: 59, right: 59, bottom: 21),
    screenCornerRadius: 44,
    cutout: DynamicIslandCutout(size: Size(126, 37), topOffset: 11),
  ),

  // iPhone 15 Pro: same screen size as iPhone 15, Pro chassis.
  // Geometry identical to iPhone 15 — same DI hardware cutout.
  // Source: useyourloaf.com, iosresolution.com
  DeviceProfile(
    id: 'iphone_15_pro',
    name: 'iPhone 15 Pro',
    platform: DevicePlatform.iOS,
    logicalSize: Size(393, 852),
    devicePixelRatio: 3.0,
    safeAreaPortrait: EdgeInsets.only(top: 59, bottom: 34),
    safeAreaLandscape: EdgeInsets.only(left: 59, right: 59, bottom: 21),
    screenCornerRadius: 44,
    cutout: DynamicIslandCutout(size: Size(126, 37), topOffset: 11),
  ),

  // iPhone 15 Pro Max: 6.7" variant; same DI cutout geometry.
  // Corner radius: ~44pt (same family as 15/15 Pro; community measurement).
  // Source: useyourloaf.com, iosresolution.com
  DeviceProfile(
    id: 'iphone_15_pro_max',
    name: 'iPhone 15 Pro Max',
    platform: DevicePlatform.iOS,
    logicalSize: Size(430, 932),
    devicePixelRatio: 3.0,
    safeAreaPortrait: EdgeInsets.only(top: 59, bottom: 34),
    safeAreaLandscape: EdgeInsets.only(left: 59, right: 59, bottom: 21),
    screenCornerRadius: 44,
    cutout: DynamicIslandCutout(size: Size(126, 37), topOffset: 11),
  ),

  // iPad (10th gen): thin-bezel design; rounded display corners visible.
  // Corner radius: ~18pt (community approximation).
  // No camera cutout — front camera sits in the top bezel.
  // Source: iosresolution.com, useyourloaf.com
  DeviceProfile(
    id: 'ipad_10',
    name: 'iPad (10th gen)',
    platform: DevicePlatform.iOS,
    logicalSize: Size(820, 1180),
    devicePixelRatio: 2.0,
    safeAreaPortrait: EdgeInsets.only(top: 24, bottom: 20),
    safeAreaLandscape: EdgeInsets.only(top: 20, bottom: 20),
    screenCornerRadius: 18,
    cutout: NoCutout(),
  ),

  // iPad mini (6th gen): compact form factor with thin bezels.
  // Corner radius: ~18pt (community approximation; same family as iPad 10).
  // No camera cutout — front camera in the top bezel.
  // Source: iosresolution.com, useyourloaf.com
  DeviceProfile(
    id: 'ipad_mini_6',
    name: 'iPad mini (6th gen)',
    platform: DevicePlatform.iOS,
    logicalSize: Size(744, 1133),
    devicePixelRatio: 2.0,
    safeAreaPortrait: EdgeInsets.only(top: 24, bottom: 20),
    safeAreaLandscape: EdgeInsets.only(top: 20, bottom: 20),
    screenCornerRadius: 18,
    cutout: NoCutout(),
  ),

  // ── Android ──────────────────────────────────────────────────────────────

  // Samsung Galaxy S24: community approximation — Samsung does not publish
  // device-tree cutout geometry (config is proprietary).
  // Corner radius: ~26pt (community measurement).
  // Punch hole: ~10pt diameter, centered, ~12pt from screen top (center Y).
  DeviceProfile(
    id: 'samsung_galaxy_s24',
    name: 'Samsung Galaxy S24',
    platform: DevicePlatform.android,
    logicalSize: Size(360, 780),
    devicePixelRatio: 2.625,
    safeAreaPortrait: EdgeInsets.only(top: 24, bottom: 24),
    safeAreaLandscape: EdgeInsets.only(bottom: 24),
    screenCornerRadius: 26, // community approximation
    cutout: PunchHoleCutout(diameter: 10, topOffset: 12),
  ),

  // Pixel 7a (codename: lynx).
  // Cutout: AOSP config_mainBuiltInDisplayCutout, lynx device tree.
  //   Circle ~28px physical diameter, center ~34px from screen top.
  //   28px / 2.625 DPR ≈ 11dp diameter; 34px / 2.625 ≈ 13dp center Y.
  // Corner radius: ~22pt (community measurement; AOSP config_mainDisplayShape
  //   for lynx not publicly indexed at time of authoring).
  // Safe area portrait: status bar 24dp covers the cutout
  //   (cutout bottom = topOffset + radius = 13 + 5.5 = 18.5dp).
  // Safe area landscape: punch hole rotates to left edge; left inset =
  //   edgeOffset + diameter = 13 + 11 = 24dp.
  DeviceProfile(
    id: 'pixel_7a',
    name: 'Google Pixel 7a',
    platform: DevicePlatform.android,
    logicalSize: Size(411, 914),
    devicePixelRatio: 2.625,
    safeAreaPortrait: EdgeInsets.only(top: 24, bottom: 24),
    safeAreaLandscape: EdgeInsets.only(left: 24, bottom: 24),
    screenCornerRadius: 22,
    cutout: PunchHoleCutout(diameter: 11, topOffset: 13),
  ),

  // Pixel 8 (codename: shiba).
  // Cutout: AOSP config_mainBuiltInDisplayCutout, shiba device tree.
  //   Circle ~28px physical diameter, center ~34px from screen top.
  //   28px / 2.625 DPR ≈ 11dp diameter; 34px / 2.625 ≈ 13dp center Y.
  // Corner radius: ~25pt (AOSP config_mainDisplayShape, shiba;
  //   physical arc ~65px / DPR 2.625 ≈ 25dp).
  // Safe area portrait: cutout bottom = 13 + 5.5 = 18.5dp < 24dp status bar.
  // Safe area landscape: left = edgeOffset + diameter = 13 + 11 = 24dp.
  DeviceProfile(
    id: 'pixel_8',
    name: 'Google Pixel 8',
    platform: DevicePlatform.android,
    logicalSize: Size(411, 914),
    devicePixelRatio: 2.625,
    safeAreaPortrait: EdgeInsets.only(top: 24, bottom: 24),
    safeAreaLandscape: EdgeInsets.only(left: 24, bottom: 24),
    screenCornerRadius: 25,
    cutout: PunchHoleCutout(diameter: 11, topOffset: 13),
  ),

  // Pixel 8 Pro (codename: husky, in shusky repo).
  // Cutout: AOSP config_mainBuiltInDisplayCutout, shusky device tree:
  //   M 626.5,75.5 a 45,45 0 1 0 90,0 a 45,45 0 1 0 -90,0 Z @left
  //   Circle: center (671.5, 75.5)px physical, radius 45px physical.
  //   671.5px / 3.0 DPR ≈ screen center (screen is 1344px wide).
  //   Diameter: 90px / 3.0 = 30dp. Center Y: 75.5px / 3.0 ≈ 25dp.
  // Corner radius: ~36pt (AOSP config_mainDisplayShape, shusky;
  //   physical arc ~108px / DPR 3.0 ≈ 36dp).
  // Safe area portrait: AOSP config_mainBuiltInDisplayCutoutRectApproximation,
  //   shusky: M 615.5,0 h 110 v 151 h -110 Z → height 151px / 3.0 = 50dp.
  //   Cutout bottom = topOffset + radius = 25 + 15 = 40dp; status bar padded
  //   to bounding-box height ≈ 50dp to clear the full hardware area.
  // Safe area landscape: punch hole rotates to left edge;
  //   left = edgeOffset + diameter = 25 + 30 = 55dp.
  DeviceProfile(
    id: 'pixel_8_pro',
    name: 'Google Pixel 8 Pro',
    platform: DevicePlatform.android,
    logicalSize: Size(448, 998),
    devicePixelRatio: 3.0,
    safeAreaPortrait: EdgeInsets.only(top: 50, bottom: 24),
    safeAreaLandscape: EdgeInsets.only(left: 55, bottom: 24),
    screenCornerRadius: 36,
    cutout: PunchHoleCutout(diameter: 30, topOffset: 25),
  ),
];

/// Provides access to the built-in device profile catalog.
abstract final class DeviceDatabase {
  /// All supported device profiles.
  static List<DeviceProfile> get all => kDeviceProfiles;

  /// Profiles filtered to [platform].
  static List<DeviceProfile> forPlatform(DevicePlatform platform) =>
      kDeviceProfiles.where((p) => p.platform == platform).toList();

  /// Returns the profile with [id], or `null` if not found.
  static DeviceProfile? findById(String id) {
    for (final profile in kDeviceProfiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  /// The default profile used when no selection has been made.
  static DeviceProfile get defaultProfile => findById('iphone_15')!;
}
