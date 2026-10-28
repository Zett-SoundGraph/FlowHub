import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';

/// Hamburger-menu side panel (figmaImage/8_calibration-1.png / -2.png).
/// Rendered as a plain absolutely-positioned panel (not Flutter's built-in
/// [Drawer]) so the caller can keep the bottom summary bar visible/undimmed
/// alongside it — see the custom overlay in flowhub_main_screen.dart.
class FlowHubNavigationDrawer extends StatelessWidget {
  final double scale;
  final bool isCalibrating;
  final VoidCallback onClose;
  final VoidCallback onDeviceManagement;
  final VoidCallback onMachineControl;
  final VoidCallback onNudofControl;
  final VoidCallback onPickupTableTheme;
  final VoidCallback onCalibration;
  final VoidCallback onReboot;
  final Future<void> Function() onRecipeSync;

  static const double width = 640;

  const FlowHubNavigationDrawer({
    super.key,
    required this.scale,
    required this.onClose,
    required this.onDeviceManagement,
    required this.onMachineControl,
    required this.onNudofControl,
    required this.onPickupTableTheme,
    required this.onCalibration,
    required this.onReboot,
    required this.onRecipeSync,
    this.isCalibrating = false,
  });

  @override
  Widget build(BuildContext context) {
    // Height comes from the parent Positioned(top, bottom) instead of a
    // fixed value — the caller's bottom offset already accounts for the
    // device's real system inset, so a hardcoded height here would drift
    // out of sync with that on devices with a different inset.
    //
    // The background/shadow fill still starts at the true screen top (so it
    // correctly tints the status bar area — see flowhub_main_screen.dart), but
    // the actual content (app bar, back button, rows) is pushed down by the
    // real status bar height first — the Figma spec's own offsets (e.g. the
    // back button's top:24.82) are measured from where the app bar itself
    // starts, i.e. *below* the status bar, not from the true device edge.
    final statusBarHeight = MediaQuery.paddingOf(context).top;
    return Container(
      width: width * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5ED),
        boxShadow: [
          BoxShadow(color: const Color(0x1F000000), blurRadius: 48 * scale),
          BoxShadow(
            color: const Color(0x0D000000),
            blurRadius: 16 * scale,
            offset: Offset(8 * scale, 3 * scale),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Stack(
          children: [
            // App bar
            Container(
              width: width * scale,
              height: 88 * scale,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0x0F1A1C1E),
                    width: 4 * scale,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 47 * scale,
              top: 24.82 * scale,
              child: GestureDetector(
                onTap: onClose,
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 32 * scale,
                  color: const Color(0xFF33383C),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 112 * scale,
              child: _DrawerRow(
                scale: scale,
                iconAsset: 'assets/images/management.png',
                iconWidth: 40,
                iconHeight: 36,
                label: 'Device Management',
                onTap: onDeviceManagement,
              ),
            ),
            Positioned(
              left: 0,
              top: 242 * scale,
              child: _DrawerRow(
                scale: scale,
                iconAsset: 'assets/images/Caye.png',
                iconWidth: 32,
                iconHeight: 40,
                label: 'Caye Machine Control',
                onTap: onMachineControl,
              ),
            ),
            Positioned(
              left: 0,
              top: 372 * scale,
              child: _DrawerRow(
                scale: scale,
                iconAsset: 'assets/images/dispenser.png',
                iconWidth: 36,
                iconHeight: 36,
                label: 'Nudof Machine Control',
                onTap: onNudofControl,
              ),
            ),
            // The original Pickup Table Theme picker/screen/cubit was
            // deleted outright (it was never actually used); what used to
            // be "Theme 2" was renamed to take over as the only Pickup
            // Table Theme feature, since that's the one actually used for
            // exhibition test orders.
            Positioned(
              left: 0,
              top: 502 * scale,
              child: _DrawerRow(
                scale: scale,
                iconAsset: 'assets/images/pickuptable.png',
                iconWidth: 36,
                iconHeight: 32,
                label: 'Pickup Table Theme',
                onTap: onPickupTableTheme,
              ),
            ),
            Positioned(
              left: 48 * scale,
              bottom: 76 * scale + (98 * scale + 24 * scale) * 2,
              child: _RecipeSyncButton(
                scale: scale,
                onTap: onRecipeSync,
              ),
            ),
            Positioned(
              left: 48 * scale,
              bottom: 76 * scale + 98 * scale + 24 * scale,
              child: _CalibrationButton(
                scale: scale,
                selected: isCalibrating,
                onTap: onCalibration,
              ),
            ),
            Positioned(
              left: 48 * scale,
              bottom: 76 * scale,
              child: _RebootButton(
                scale: scale,
                onTap: onReboot,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Device Management" / "Caye Machine Control" row — 640x130, icon at
/// left:52, label starting 40 past the icon, both vertically centered.
class _DrawerRow extends StatelessWidget {
  final double scale;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final VoidCallback onTap;

  const _DrawerRow({
    required this.scale,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: FlowHubNavigationDrawer.width * scale,
        height: 130 * scale,
        child: Stack(
          children: [
            Positioned(
              left: 52 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  iconAsset,
                  width: iconWidth * scale,
                  height: iconHeight * scale,
                  color: const Color(0xFF33383C),
                ),
              ),
            ),
            Positioned(
              left: 132 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 36 * scale,
                    height: 50 / 36,
                    letterSpacing: -0.36 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Recipe Sync" button — same 544x98 tan-outline style as
/// [_CalibrationButton], positioned just above it. Tapping shows a brief
/// spinner in place of the icon while [onTap] (a full Recipe/Menu/Option
/// sheet re-fetch) is in flight — for applying a just-edited sheet
/// (timing/pkey/ingredients/etc.) without waiting for the periodic
/// 2-minute Version Info check to notice on its own.
class _RecipeSyncButton extends StatefulWidget {
  final double scale;
  final Future<void> Function() onTap;

  const _RecipeSyncButton({required this.scale, required this.onTap});

  @override
  State<_RecipeSyncButton> createState() => _RecipeSyncButtonState();
}

class _RecipeSyncButtonState extends State<_RecipeSyncButton> {
  bool _isPressed = false;
  bool _isSyncing = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  Future<void> _handleTap() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    try {
      await widget.onTap();
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final tinted = _isPressed || _isSyncing;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _handleTap,
      child: Container(
        width: 544 * scale,
        height: 98 * scale,
        decoration: BoxDecoration(
          color: tinted ? const Color(0x26A37B42) : const Color(0x0DA37B42),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFA37B42), width: 1 * scale),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: _isSyncing
                    ? SizedBox(
                        width: 32 * scale,
                        height: 32 * scale,
                        child: CircularProgressIndicator(
                          strokeWidth: 3 * scale,
                          color: const Color(0xFF33383C),
                        ),
                      )
                    : Icon(
                        Icons.sync,
                        size: 36 * scale,
                        color: const Color(0xFF33383C),
                      ),
              ),
            ),
            Positioned(
              left: 104 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  'Recipe Sync',
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 36 * scale,
                    height: 50 / 36,
                    letterSpacing: -0.36 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Calibration" button — 544x98, radius 16, tan outline; fills with a tan
/// tint while [selected] (figmaImage/8_calibration-2.png — shown while
/// calibration is actually in progress, since there's no mouse hover on a
/// touchscreen kiosk).
class _CalibrationButton extends StatefulWidget {
  final double scale;
  final bool selected;
  final VoidCallback onTap;

  const _CalibrationButton({
    required this.scale,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_CalibrationButton> createState() => _CalibrationButtonState();
}

class _CalibrationButtonState extends State<_CalibrationButton> {
  // Tracked explicitly (rather than relying on InkWell's own ink/highlight
  // layer, which paints onto the ancestor Material and can be subtle/easy to
  // miss) so the background color change while held down is unambiguous.
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final tinted = _isPressed || widget.selected;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: Container(
        width: 544 * scale,
        height: 98 * scale,
        decoration: BoxDecoration(
          // Default (unpressed) fill is a faint 5% tan tint — not fully
          // transparent — so the ~15% pressed/selected fill actually reads
          // as a visible change instead of "transparent vs. tinted".
          color: tinted ? const Color(0x26A37B42) : const Color(0x0DA37B42),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFA37B42), width: 1 * scale),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/calbtn.png',
                  width: 32 * scale,
                  height: 40 * scale,
                  color: const Color(0xFF33383C),
                ),
              ),
            ),
            Positioned(
              left: 104 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  'Calibration',
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 36 * scale,
                    height: 50 / 36,
                    letterSpacing: -0.36 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Reboot" button — same 544x98 tan-outline pill as [_CalibrationButton],
/// the new bottom-most drawer action. No dedicated icon asset exists for
/// this (unlike Calibration's calbtn.png), so it uses a Material icon the
/// same way [_RecipeSyncButton] does for its sync glyph.
class _RebootButton extends StatefulWidget {
  final double scale;
  final VoidCallback onTap;

  const _RebootButton({required this.scale, required this.onTap});

  @override
  State<_RebootButton> createState() => _RebootButtonState();
}

class _RebootButtonState extends State<_RebootButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: Container(
        width: 544 * scale,
        height: 98 * scale,
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0x26A37B42) : const Color(0x0DA37B42),
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: const Color(0xFFA37B42), width: 1 * scale),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 40 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.restart_alt,
                  size: 36 * scale,
                  color: const Color(0xFF33383C),
                ),
              ),
            ),
            Positioned(
              left: 104 * scale,
              top: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  'Reboot',
                  style: TextStyle(
                    fontFamily: flowhubFontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: 36 * scale,
                    height: 50 / 36,
                    letterSpacing: -0.36 * scale,
                    color: const Color(0xFF1A1C1E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
