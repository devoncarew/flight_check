import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../devices/device_database.dart';
import '../devices/device_profile.dart';
import '../preview_controller.dart';
import '../theme.dart';

/// Width of the control panel card.
const double _kPanelWidth = 315;

/// Width of the control panel card.
const double _kPanelHeight = 565;

/// Corner radius used for all non-flush panel corners.
const double _kPanelRadius = 10;

/// Shape for the panel: top-right corner is flush with the window edge (same
/// as the badge), all other corners are rounded.
const _kPanelBorderRadius = BorderRadius.only(
  topLeft: Radius.circular(_kPanelRadius),
  bottomLeft: Radius.circular(_kPanelRadius),
  bottomRight: Radius.circular(_kPanelRadius),
);

/// Floating panel that slides down from the [ControlBadge] in the top-right
/// corner of the preview window.
///
/// Contains:
/// 1. An action icon row (orientation toggle, passthrough toggle, shortcuts).
/// 2. An expandable keyboard shortcuts reference.
/// 3. A tabbed device list (iOS / Android / Tablets).
///
/// Visibility is driven by [PreviewController.devicePickerVisible]. The widget
/// wraps a full-window backdrop so tapping outside the card dismisses it.
class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key, required this.controller});

  final PreviewController controller;

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _slideAnim;

  bool _shortcutsExpanded = false;
  late int _selectedTab;

  @override
  void initState() {
    super.initState();

    final profile = widget.controller.activeProfile;
    _selectedTab = profile.tablet
        ? 2
        : profile.platform == DevicePlatform.android
        ? 1
        : 0;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    if (widget.controller.devicePickerVisible) {
      _animController.value = 1.0;
    }

    widget.controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (widget.controller.devicePickerVisible) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        MediaQuery.sizeOf(context).height - kControlBadgeHeight * 2 - 16;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) =>
          IgnorePointer(ignoring: _animController.isDismissed, child: child!),
      child: Stack(
        children: [
          // Full-window backdrop — tap to dismiss.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.controller.toggleDevicePicker,
            ),
          ),

          // Panel card anchored below the badge, slides in from the right.
          // ClipRect prevents the card from being visible while off-screen.
          Positioned(
            top: kControlBadgeHeight,
            right: 0,
            child: ClipRect(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(_slideAnim),
                child: SizedBox(
                  height: math.min(maxHeight, _kPanelHeight),
                  child: _buildContents(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    final iOS = DeviceDatabase.all
        .where((d) => d.platform == DevicePlatform.iOS && !d.tablet)
        .toList();
    final android = DeviceDatabase.all
        .where((d) => d.platform == DevicePlatform.android && !d.tablet)
        .toList();
    final tablets = DeviceDatabase.all.where((d) => d.tablet).toList();

    // SegmentedButton requires MaterialLocalizations; provide them here so the
    // panel works even when no MaterialApp ancestor exists.
    return SizedBox(
      width: _kPanelWidth,
      child: Localizations(
        locale: const Locale('en'),
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Material(
          color: kPreviewBackground,
          borderRadius: _kPanelBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _ActionRow(
                controller: widget.controller,
                shortcutsExpanded: _shortcutsExpanded,
                onToggleShortcuts: () =>
                    setState(() => _shortcutsExpanded = !_shortcutsExpanded),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeInOut,
                child: _shortcutsExpanded
                    ? const _ShortcutsSection()
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _createSegmentedButton(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: IndexedStack(
                  index: _selectedTab,
                  alignment: AlignmentDirectional.topStart,
                  children: [
                    _DeviceList(profiles: iOS, controller: widget.controller),
                    _DeviceList(
                      profiles: android,
                      controller: widget.controller,
                    ),
                    _DeviceList(
                      profiles: tablets,
                      controller: widget.controller,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  SegmentedButton<int> _createSegmentedButton() {
    return SegmentedButton<int>(
      expandedInsets: EdgeInsets.zero,
      segments: const [
        ButtonSegment(
          value: 0,
          label: Text('iOS'),
          icon: Icon(Icons.phone_iphone),
        ),
        ButtonSegment(
          value: 1,
          label: Text('Android'),
          icon: Icon(Icons.phone_android),
        ),
        ButtonSegment(
          value: 2,
          label: Text('Tablets'),
          icon: Icon(Icons.tablet),
        ),
      ],
      selected: {_selectedTab},
      onSelectionChanged: (s) => setState(() => _selectedTab = s.first),
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? kPreviewForegroundEmphasis
              : kPreviewForeground,
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? const Color(0x33FFFFFF)
              : Colors.transparent,
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: kPreviewForeground.withValues(alpha: 0.3)),
        ),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12)),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      showSelectedIcon: false,
    );
  }
}

// ── Action icon row ───────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.controller,
    required this.shortcutsExpanded,
    required this.onToggleShortcuts,
  });

  final PreviewController controller;
  final bool shortcutsExpanded;
  final VoidCallback onToggleShortcuts;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_outlined),
              color: shortcutsExpanded
                  ? kPreviewForegroundEmphasis
                  : kPreviewForeground,
              iconSize: 16,
              onPressed: onToggleShortcuts,
            ),
            const Spacer(),
            const Text(
              'Flight Check',
              style: TextStyle(
                color: Color(0x99FFFFFF),
                fontSize: 14,
                // fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // IconButton(
            //   icon: Icon(
            //     controller.passthroughMode
            //         ? Icons.visibility_off_outlined
            //         : Icons.visibility_outlined,
            //   ),
            //   color: controller.passthroughMode
            //       ? kPreviewForegroundEmphasis
            //       : kPreviewForeground,
            //   iconSize: 16,
            //   onPressed: controller.togglePassthrough,
            // ),
            IconButton(
              icon: const Icon(Icons.screen_rotation),
              color: kPreviewForeground,
              iconSize: 16,
              onPressed: controller.toggleOrientation,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Keyboard shortcuts reference ──────────────────────────────────────────────

class _ShortcutsSection extends StatelessWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context) {
    final modifier = Platform.isMacOS ? '⌘' : 'Ctrl-';
    final shortcuts = [
      ('Toggle device picker', '${modifier}D'),
      ('Toggle orientation', '${modifier}L'),
      ('Next device', '$modifier]'),
      ('Previous device', '$modifier['),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, thickness: 1, color: Color(0x33FFFFFF)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (label, key) in shortcuts)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: kPreviewForeground,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        key,
                        style: const TextStyle(
                          color: kPreviewForeground,
                          fontSize: 12,
                          fontFamilyFallback: [
                            'Menlo',
                            'Consolas',
                            'Courier New',
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Device list (one per tab) ─────────────────────────────────────────────────

class _DeviceList extends StatelessWidget {
  const _DeviceList({required this.profiles, required this.controller});

  final List<DeviceProfile> profiles;
  final PreviewController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            for (final profile in profiles)
              _DeviceItem(
                profile: profile,
                isActive: profile.id == controller.activeProfile.id,
                onTap: () {
                  controller.setProfile(profile);
                },
              ),
          ],
        );
      },
    );
  }
}

// ── Device item ───────────────────────────────────────────────────────────────

class _DeviceItem extends StatelessWidget {
  const _DeviceItem({
    required this.profile,
    required this.isActive,
    required this.onTap,
  });

  final DeviceProfile profile;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = profile.logicalSize;
    final w = size.width.truncate();
    final h = size.height.truncate();

    const activeBg = Color(0x22FFFFFF);
    const borderColor = Color(0x18FFFFFF);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? activeBg : null,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    profile.name,
                    style: const TextStyle(
                      color: kPreviewForegroundEmphasis,
                      // fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$w×$h',
                  style: const TextStyle(
                    color: kPreviewForeground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (profile.description != null) ...[
              const SizedBox(height: 2),
              Text(
                profile.description!,
                style: const TextStyle(color: kPreviewForeground),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
