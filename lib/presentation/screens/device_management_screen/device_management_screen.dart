import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/presentation/cubit/fleet_monitor/fleet_monitor_cubit.dart';
import 'package:flowhub/presentation/cubit/fleet_monitor/fleet_monitor_state.dart';
import 'package:flowhub/presentation/cubit/kds/kds_cubit.dart';
import 'package:flowhub/presentation/cubit/kds/kds_state.dart';
import 'package:flowhub/presentation/widgets/kds_sub_screen_scaffold.dart';

/// Fixed heartbeat deviceId for the leader unit — same "always check the
/// fixed id, regardless of what this build itself identifies as" reasoning
/// as [_flowHubFollowerDeviceIds] below, just for the other half of the
/// pair (see FlowHubIdentity._applyKnownRole: the leader's fixed deviceId is
/// always 'flowhub-leader').
const _flowHubLeaderDeviceId = 'flowhub-leader';

/// Fixed heartbeat deviceIds for the Flow Hub Follower units — deliberately
/// NOT [NetworkConstants.mqttDeviceId], which is THIS build's own identity
/// (leader/follower is the same codebase, just built/detected differently —
/// see FlowHubIdentity). This screen is meant to be viewed from either role,
/// watching whether the OTHER physical units are alive, so the row must
/// check the followers' fixed ids regardless of what this build identifies
/// as. Up to 2 followers are deployed right now (flowhub-follower01 /
/// flowhub-follower02, per FlowHubIdentity.resolve) — the single "Flow Hub
/// Follower" row shows ON if EITHER is alive.
const _flowHubFollowerDeviceIds = ['flowhub-follower01', 'flowhub-follower02'];

/// Confirmed from sg/aio_pickup_table's own source
/// (lib/config/app_constants.dart: `mqttDeviceId = "Cafe Beta PickupTable"`)
/// — a single hardcoded device, no build flavors, so this one's solid.
const _pickupTableDeviceId = 'Cafe Beta PickupTable';

/// Confirmed from sg/pickup_board's own source
/// (lib/core/constants/network_constants.dart: `mqttDeviceId = "Cafe Beta
/// PickupBoard"`) — same single-hardcoded-device situation as the pickup
/// table above. Not to be confused with "Flow Board" below — a different,
/// not-yet-built device.
const _pickupBoardDeviceId = 'Cafe Beta PickupBoard';

// TODO: placeholder — "Flow Board" is a planned device that doesn't exist
// yet (added ahead of time per user request). Replace with its real MQTT
// heartbeat deviceId once it's actually built.
const _flowBoardDeviceId = 'Cafe Beta FlowBoard';

/// Confirmed from ToF-백업파일's PiMqtt_Man.h: HEARTBEAT_DEVICE_ID.
/// The Raspberry Pi moved from the WS-connection-based [KdsState.isConnected]
/// row to this MQTT heartbeat row — see PiMqttManager::heartbeatLoop, which
/// now publishes beta/system/heartbeat/<this id> every 5s (retained), same
/// convention as every other device on this screen.
const _raspberryPiDeviceId = 'Cafe Beta RaspberryPi';

/// The 3 physical "Frame TV" QR scanners are each a separate build of
/// SG/barcode_scanner, hand-edited per device in that project's lib/main.dart
/// (no build flavors/runtime derivation) — one per role in the MQTT Topic
/// spec sheet's beta/qr/order / beta/qr/complete / beta/qr/customer topics.
/// Confirmed mapping (per Cafe Beta MQTT Protocol.xlsx + user confirmation).
/// Labels shown on-screen were renamed to match the New/Brew/Call/Done tab
/// naming (order-station scan starts Brew, complete-station scan moves the
/// item to Call, customer-station scan is the pickup/effectCircle trigger)
/// — the deviceIds themselves are unchanged.
const _scannerOrderDeviceId = 'scanner-order-01';
const _scannerCompleteDeviceId = 'scanner-complete-01';
const _scannerCustomerDeviceId = 'scanner-customer-01';

/// Not a fixed id like the other rows — kiosk builds are tested under
/// varying names (kiosk-01, kiosk01, kioskTest02, ...), so this row matches
/// ANY heartbeat deviceId starting with "kiosk" (case-insensitive) instead
/// of one exact id (see [_HeartbeatDeviceRow.idPrefix]).
const _kioskIdPrefix = 'kiosk';

/// A heartbeat is considered stale (device offline) after this long with no
/// new message — matches the same threshold fleet_monitor_dialog.dart uses.
const _heartbeatStaleAfter = Duration(seconds: 60);

/// figmaImage/10_Device Management.png. 12 rows total, split into two
/// columns of 6 purely for layout balance — every label already carries its
/// own (M)/(T) transport suffix, so the columns don't need to (an even 8/3
/// split by transport looked lopsided).
///
/// Real, live data sources per row:
/// - Flow Hub Leader / Flow Hub Follower / Scanner Brew / Scanner Call /
///   Scanner Pickup / Pickup Table / Kiosk / Pickup Board / Flow Board: MQTT
///   heartbeat ([FleetMonitorCubit.state.deviceLastSeen]) — online iff a
///   heartbeat for that deviceId arrived within [_heartbeatStaleAfter]. Flow
///   Hub Leader/Follower check the fixed [_flowHubLeaderDeviceId]/
///   [_flowHubFollowerDeviceIds], independent of this build's own identity —
///   this screen watches both physical roles regardless of which one it's
///   being viewed from. Pickup Table, Pickup Board, and the 3 scanner ids
///   are all confirmed real, fixed values. Kiosk is the one exception — it
///   matches by prefix instead of one fixed id (see [_kioskIdPrefix]),
///   since test/sample kiosk builds get flashed under varying names (kiosk-
///   01, kioskTest02, ...) rather than one registered device. Flow Board
///   doesn't exist yet at all — added ahead of time with a placeholder id,
///   per request; replace [_flowBoardDeviceId] once it's actually built.
/// - Raspberry Pi: MQTT heartbeat ([FleetMonitorCubit.state.deviceLastSeen]),
///   same mechanism as the other (M) rows above — see
///   [_raspberryPiDeviceId]. Was [KdsState.isConnected] (this app's local
///   WebSocket server, true whenever at least one client — Pi OR pickup
///   table OR anything else that dials in — was connected; mirrored to
///   followers via [LeaderUpdateMessage]) until the Pi moved its ToF/control
///   traffic to MQTT (PiMqttManager) and picked up its own heartbeat, which
///   is both more specific (this WAS "is anything connected", not "is the
///   Pi specifically connected") and needs no leader/follower mirroring —
///   the retained heartbeat is visible to every kds instance directly.
/// - Label Printer: [KdsState.isPrinterConnected] — the native Android
///   printer's TCP connection state (NOT the ATTACHED/DETACHED paper-sensor
///   signal, which is a different thing entirely), kept live by a
///   continuous native-side status poll (not just the startup attempt) —
///   flips off if the printer stops responding (e.g. sleep/power loss), with
///   no automatic retry after that. Tapping this row while off asks the
///   native side to retry immediately ([KdsCubit.reconnectPrinter]).
/// - Caye Machine: [KdsState.isCayeConnected] (not CayeManagementCubit —
///   that cubit is recreated every time the Caye Machine Control screen
///   opens/closes, and a follower's own Caye socket never actually opens
///   since it forwards commands to the leader instead — so it can't be this
///   row's source of truth). Real TCP socket state, mirrored to followers
///   the same way as the printer. Tapping this row while off asks the
///   machine to (re)sync its clock ([KdsCubit.reconnectCaye]) — the same
///   lightweight, side-effect-free command already used for the 1-minute
///   heartbeat, which as a side effect (re)opens the socket if it was closed.
class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = KdsScale.of(context);

    return KdsSubScreenScaffold(
      scale: scale,
      title: 'Device Management',
      headerIconAsset: 'assets/images/management.png',
      headerIconWidth: 40,
      headerIconHeight: 36,
      headerIconLeft: 52,
      headerTitleGap: 44,
      body: Padding(
        padding: EdgeInsets.only(left: 48 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 568 * scale,
              child: Column(
                children: [
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/flowhub.png',
                    iconWidth: 36.67,
                    iconHeight: 30,
                    label: 'Flow Hub Leader(M)',
                    deviceIds: const [_flowHubLeaderDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/flowhub.png',
                    iconWidth: 36.67,
                    iconHeight: 30,
                    label: 'Flow Hub Follower(M)',
                    deviceIds: _flowHubFollowerDeviceIds,
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Scanner Brew(M)',
                    deviceIds: const [_scannerOrderDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Scanner Call(M)',
                    deviceIds: const [_scannerCompleteDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Scanner Pickup(M)',
                    deviceIds: const [_scannerCustomerDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/pickuptable.png',
                    iconWidth: 36.67,
                    iconHeight: 32.33,
                    label: 'Pickup Table(M)',
                    deviceIds: const [_pickupTableDeviceId],
                  ),
                ],
              ),
            ),
            SizedBox(width: 48 * scale),
            SizedBox(
              width: 568 * scale,
              child: Column(
                children: [
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Kiosk(M)',
                    idPrefix: _kioskIdPrefix,
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Pickup Board(M)',
                    deviceIds: const [_pickupBoardDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow Board(M)',
                    deviceIds: const [_flowBoardDeviceId],
                  ),
                  BlocBuilder<KdsCubit, KdsState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/print.png',
                      iconWidth: 33.33,
                      iconHeight: 30,
                      label: 'Label Printer(T)',
                      isOn: state.isPrinterConnected,
                      // No automatic retry once the native side gives up on
                      // the printer — tapping while off retries immediately
                      // instead of waiting for a future print attempt (or an
                      // app restart) to notice it's back.
                      onTapWhenOff: () =>
                          context.read<KdsCubit>().reconnectPrinter(),
                    ),
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/raspberry.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Raspberry Pi(M)',
                    deviceIds: const [_raspberryPiDeviceId],
                  ),
                  BlocBuilder<KdsCubit, KdsState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/Caye.png',
                      iconWidth: 26.67,
                      iconHeight: 33.33,
                      label: 'Caye Machine(T)',
                      isOn: state.isCayeConnected,
                      onTapWhenOff: () =>
                          context.read<KdsCubit>().reconnectCaye(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps [_DeviceRow] for devices tracked via MQTT heartbeat instead of a
/// dedicated connection stream. A heartbeat only arrives when a new message
/// is published, so stale-ness (device went offline with no further
/// message) needs its own periodic recheck — a plain BlocBuilder on
/// [FleetMonitorCubit] alone would never re-render once messages stop.
class _HeartbeatDeviceRow extends StatefulWidget {
  final double scale;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;
  // Multiple ids let one row represent "is ANY of these online" (e.g. the
  // single "Flow Hub Follower" row covering both follower01/02 units).
  // Ignored when [idPrefix] is set.
  final List<String> deviceIds;
  // When set, ANY heartbeat deviceId starting with this (case-insensitive)
  // counts as online, instead of requiring an exact match against
  // [deviceIds] — for a role like Kiosk where multiple differently-named
  // physical/test units (kiosk-01, kioskTest02, ...) should all count as
  // "the kiosk", not just one fixed id.
  final String? idPrefix;

  const _HeartbeatDeviceRow({
    required this.scale,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    this.deviceIds = const [],
    this.idPrefix,
  });

  @override
  State<_HeartbeatDeviceRow> createState() => _HeartbeatDeviceRowState();
}

class _HeartbeatDeviceRowState extends State<_HeartbeatDeviceRow> {
  Timer? _staleRecheckTimer;

  @override
  void initState() {
    super.initState();
    _staleRecheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _staleRecheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FleetMonitorCubit, FleetMonitorState>(
      builder: (context, state) {
        final now = DateTime.now();
        bool isFresh(DateTime? lastSeen) =>
            lastSeen != null && now.difference(lastSeen) <= _heartbeatStaleAfter;

        final prefix = widget.idPrefix?.toLowerCase();
        final isOn = prefix != null
            ? state.deviceLastSeen.entries.any(
                (e) => e.key.toLowerCase().startsWith(prefix) && isFresh(e.value),
              )
            : widget.deviceIds.any((id) => isFresh(state.deviceLastSeen[id]));
        return _DeviceRow(
          scale: widget.scale,
          iconAsset: widget.iconAsset,
          iconWidth: widget.iconWidth,
          iconHeight: widget.iconHeight,
          label: widget.label,
          isOn: isOn,
        );
      },
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final double scale;
  final String iconAsset;
  final double iconWidth;
  final double iconHeight;
  final String label;
  final bool isOn;

  /// Only invoked while [isOn] is false — devices with no real retry action
  /// (most rows) simply omit this.
  final VoidCallback? onTapWhenOff;

  const _DeviceRow({
    required this.scale,
    required this.iconAsset,
    required this.iconWidth,
    required this.iconHeight,
    required this.label,
    required this.isOn,
    this.onTapWhenOff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 114 * scale,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0x421A1C1E), width: 1 * scale),
        ),
      ),
      // Icons vary in width per device, so the label can't just sit a fixed
      // gap after the icon (that made the labels ragged) — instead every
      // label sits at the same fixed left position (116 from the page edge,
      // i.e. 68 from this row's own left edge, since the row itself starts
      // 48 past the page margin) regardless of icon width.
      child: Stack(
        children: [
          Positioned(
            left: 4 * scale,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                iconAsset,
                width: iconWidth * scale,
                height: iconHeight * scale,
                color: const Color(0xFF5C646C),
              ),
            ),
          ),
          Positioned(
            left: 68 * scale,
            right: 106 * scale,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kdsFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 32 * scale,
                  height: 50 / 32,
                  letterSpacing: -0.32 * scale,
                  color: const Color(0xFF1A1C1E),
                ),
              ),
            ),
          ),
          Positioned(
            right: 4 * scale,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: (!isOn && onTapWhenOff != null) ? onTapWhenOff : null,
                child: Image.asset(
                  isOn ? 'assets/images/on.png' : 'assets/images/off.png',
                  width: (isOn ? 102 : 113) * scale,
                  height: 48 * scale,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
