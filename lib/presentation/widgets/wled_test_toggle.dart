import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flowhub/core/di/di.dart';
import 'package:flowhub/domain/usecases/publish_wled_api_usecase.dart';
import 'package:flowhub/domain/usecases/publish_wled_power_usecase.dart';

/// TEMPORARY bench-test control for a WLED strip being tested over MQTT —
/// not part of any real feature.
///
/// The power pill toggles ON/OFF via a plain "ON"/"OFF" string published to
/// `beta/flowhub/wled/power` (see PublishWledPowerUseCase /
/// MqttDataSource.publishWledPower). The 3 color circles below it each
/// toggle a solid color via WLED's JSON API, published to
/// `beta/flowhub/wled/power/api` (see PublishWledApiUseCase /
/// MqttDataSource.publishWledApi) with `"transition":0` so the change is
/// instant rather than fading — tapping an already-active color turns the
/// strip off (`{"on":false}`) instead of re-sending the same color. The
/// star button next to them fires saved preset 1 (`{"on":true,"ps":1}`) on
/// the same topic. Point the WLED unit's own MQTT "Device Topic" setting at
/// `beta/flowhub/wled/power` and it picks up both automatically (WLED's own
/// convention: plain commands on the Device Topic itself, JSON API commands
/// on Device Topic + "/api") — no extra parsing needed on the WLED side.
///
/// Local-only toggle state (not synced via KdsState/LeaderUpdateMessage) —
/// this is a one-off physical bench test, not a feature that needs to agree
/// across leader/follower devices.
///
/// Delete this file + its one call site + PublishWledPowerUseCase +
/// PublishWledApiUseCase + publishWledPower/publishWledApi
/// (mqtt_data_source.dart / order_repository*.dart) once WLED testing is
/// done.
class WledTestToggle extends StatefulWidget {
  final double scale;

  const WledTestToggle({super.key, required this.scale});

  @override
  State<WledTestToggle> createState() => _WledTestToggleState();
}

class _WledColorOption {
  final String label;
  final Color swatch;
  final int r;
  final int g;
  final int b;

  const _WledColorOption(this.label, this.swatch, this.r, this.g, this.b);
}

const _wledColorOptions = [
  _WledColorOption('Red', Colors.red, 255, 0, 0),
  _WledColorOption('Green', Colors.green, 0, 255, 0),
  _WledColorOption('Blue', Colors.blue, 0, 0, 255),
];

class _WledTestToggleState extends State<WledTestToggle> {
  final _publishWledPower = getIt<PublishWledPowerUseCase>();
  final _publishWledApi = getIt<PublishWledApiUseCase>();
  bool _isOn = false;
  // Only one color can really be lit on the physical strip at a time —
  // tracked here (rather than per-button) so picking a new color always
  // correctly clears whichever one was previously shown as active.
  _WledColorOption? _activeColor;

  void _togglePower() {
    final next = !_isOn;
    setState(() => _isOn = next);
    unawaited(_publishWledPower(next));
  }

  void _toggleColor(_WledColorOption option) {
    if (_activeColor == option) {
      setState(() => _activeColor = null);
      unawaited(_publishWledApi(const {'on': false}));
      return;
    }
    setState(() => _activeColor = option);
    unawaited(_publishWledApi({
      'on': true,
      // No fade — see the request that added this: color buttons are for
      // seeing each color immediately, not watching a transition.
      'transition': 0,
      'bri': 255,
      'seg': [
        {
          'col': [
            [option.r, option.g, option.b],
          ],
        },
      ],
    }));
  }

  void _runPreset(int presetId) {
    // A preset can be an animated effect, not just a solid color — the
    // currently-highlighted color button would no longer reflect what's
    // actually showing, so clear it.
    setState(() => _activeColor = null);
    unawaited(_publishWledApi({'on': true, 'ps': presetId}));
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
              for (final option in _wledColorOptions) ...[
                if (option != _wledColorOptions.first) SizedBox(width: 8 * scale),
                _WledColorButton(
                  scale: scale,
                  option: option,
                  active: _activeColor == option,
                  onTap: () => _toggleColor(option),
                ),
              ],
              SizedBox(width: 8 * scale),
              _WledPresetButton(scale: scale, presetId: 1, onTap: () => _runPreset(1)),
            ],
          ),
        ),
      ],
    );
  }
}

class _WledColorButton extends StatelessWidget {
  final double scale;
  final _WledColorOption option;
  final bool active;
  final VoidCallback onTap;

  const _WledColorButton({
    required this.scale,
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: option.label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40 * scale,
          height: 40 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: option.swatch,
            border: Border.all(
              color: active ? Colors.white : Colors.transparent,
              width: 3 * scale,
            ),
          ),
          child: active
              ? Icon(Icons.check, size: 20 * scale, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// One-shot trigger — presets can be animated effects, not just a solid
/// color, so unlike [_WledColorButton] this has no "currently active" state
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
