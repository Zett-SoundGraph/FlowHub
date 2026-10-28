import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowhub/core/di/di.dart';
import 'package:flowhub/domain/enums/index.dart';
import 'package:flowhub/domain/usecases/publish_wled_api_usecase.dart';

/// Hidden for now — its "all-off" button sends a real `{"on":false}` to both
/// guidance lights, which is exactly the actual-power-off behavior FlowHubCubit
/// no longer does on purpose (see _wledIdleCommand's doc comment: toggling
/// real power off/on is the suspected cause of Nudof's brownout reboots, so
/// normal app flow now always keeps both lights powered and just changes
/// color). Leaving this control reachable would let someone undo that by
/// hand. Kept in the tree (not deleted) since it's still a useful bench tool
/// — see flowhub_main_screen.dart's kWledTestToggleEnabled.
const bool kWledTestToggleEnabled = false;

/// Bench-test control for the Caye WLED unit, driven over MQTT via WLED's
/// own JSON API (see PublishWledApiUseCase / MqttDataSource.publishWledApi).
/// Hardcoded to [WledDevice.caye01] — this is a bring-up/debug tool, not the
/// real per-drink guidance-light flow (see FlowHubCubit's label-detach and
/// brew-complete handling for that).
///
/// The power pill toggles `{"on":true}` / `{"on":false}` for [_device] only.
/// The all-off button below it instead sends `{"on":false}` to BOTH real
/// guidance lights ([WledDevice.caye01] and [WledDevice.nudof01]) — added
/// because a WLED unit powering back on after being unplugged resumes
/// whatever color it last showed (its own "Turn LEDs on after power
/// up/reset" setting), so bench-testing needs one quick way to force both
/// back to a known-off state regardless of which one the power pill above
/// happens to be scoped to. The star button fires saved preset 1
/// (`{"on":true,"ps":1}`).
///
/// Local-only toggle state (not synced via FlowHubState/LeaderUpdateMessage) —
/// this is a one-off physical bench test, not a feature that needs to agree
/// across leader/follower devices.
class WledTestToggle extends StatefulWidget {
  final double scale;

  const WledTestToggle({super.key, required this.scale});

  @override
  State<WledTestToggle> createState() => _WledTestToggleState();
}

class _WledTestToggleState extends State<WledTestToggle> {
  static const _device = WledDevice.caye01;

  final _publishWledApi = getIt<PublishWledApiUseCase>();
  bool _isOn = false;

  void _togglePower() {
    final next = !_isOn;
    setState(() => _isOn = next);
    unawaited(_publishWledApi(_device, {'on': next}));
  }

  /// Forces both real guidance lights off — see this class's doc comment.
  void _turnOffAll() {
    setState(() => _isOn = false);
    unawaited(_publishWledApi(WledDevice.caye01, const {'on': false}));
    unawaited(_publishWledApi(WledDevice.nudof01, const {'on': false}));
  }

  void _runPreset(int presetId) {
    setState(() => _isOn = true);
    unawaited(_publishWledApi(_device, {'on': true, 'ps': presetId}));
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28 * scale),
            onTap: _togglePower,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
              decoration: BoxDecoration(
                color: _isOn ? const Color(0xFF2ECC71) : const Color(0xFF33383C),
                borderRadius: BorderRadius.circular(28 * scale),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33000000),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb, size: 20 * scale, color: Colors.white),
                  SizedBox(width: 8 * scale),
                  Text(
                    'WLED ${_isOn ? 'ON' : 'OFF'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20 * scale,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: const Color(0xCC1A1C1E),
            borderRadius: BorderRadius.circular(28 * scale),
            boxShadow: [
              BoxShadow(
                color: const Color(0x33000000),
                blurRadius: 8 * scale,
                offset: Offset(0, 2 * scale),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WledAllOffButton(scale: scale, onTap: _turnOffAll),
              SizedBox(width: 8 * scale),
              _WledPresetButton(scale: scale, presetId: 1, onTap: () => _runPreset(1)),
            ],
          ),
        ),
      ],
    );
  }
}

/// One-shot trigger — forces both real guidance lights (Caye + Nudof) off
/// at once, for whenever a unit powers back on already lit (see this file's
/// class doc comment). No "currently active" state to show, same as
/// [_WledPresetButton].
class _WledAllOffButton extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;

  const _WledAllOffButton({required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'All off',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40 * scale,
          height: 40 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF5C646C),
          ),
          child: Icon(Icons.lightbulb_outline, size: 20 * scale, color: Colors.white),
        ),
      ),
    );
  }
}

/// One-shot trigger — presets can be animated effects, not just a solid
/// color, so (like [_WledAllOffButton]) this has no "currently active" state
/// to show (see [_WledTestToggleState._runPreset]).
class _WledPresetButton extends StatelessWidget {
  final double scale;
  final int presetId;
  final VoidCallback onTap;

  const _WledPresetButton({
    required this.scale,
    required this.presetId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Preset $presetId',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40 * scale,
          height: 40 * scale,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF5C646C),
          ),
          child: Icon(Icons.star, size: 20 * scale, color: Colors.white),
        ),
      ),
    );
  }
}
