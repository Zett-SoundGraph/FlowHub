import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/constants/network.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/presentation/cubit/fleet_monitor/fleet_monitor_cubit.dart';
import 'package:flowhub/presentation/cubit/fleet_monitor/fleet_monitor_state.dart';
import 'package:flowhub/presentation/cubit/flowhub/flowhub_cubit.dart';
import 'package:flowhub/presentation/cubit/flowhub/flowhub_state.dart';
import 'package:flowhub/presentation/widgets/flowhub_sub_screen_scaffold.dart';

/// Fixed heartbeat deviceId for the leader unit — same "always check the
/// fixed id, regardless of what this build itself identifies as" reasoning
/// as [_flowHubFollowerDeviceIds] below, just for the other half of the
/// pair (see FlowHubIdentity._applyKnownRole: the leader's fixed deviceId is
/// always 'FlowHub Leader').
const _flowHubLeaderDeviceId = 'flowhub-leader';

/// Fixed heartbeat deviceIds for the FlowHub Follower units — deliberately
/// NOT [NetworkConstants.mqttDeviceId], which is THIS build's own identity
/// (leader/follower is the same codebase, just built/detected differently —
/// see FlowHubIdentity). This screen is meant to be viewed from either role,
/// watching whether the OTHER physical units are alive, so the row must
/// check the followers' fixed ids regardless of what this build identifies
/// as. Up to 2 followers are deployed right now ('FlowHub Follower 01' /
/// 'FlowHub Follower 02', per FlowHubIdentity.resolve — numbered so their
/// heartbeat topics don't collide) — the single "FlowHub Follower" row
/// shows ON if EITHER is alive.
const _flowHubFollowerDeviceIds = ['flowhub-follower-01', 'flowhub-follower-02'];

/// Confirmed from pickup_table's own source
/// (lib/core/constants/app_constants.dart: `mqttDeviceId = "Flow Pickup
/// Table"`) — a single hardcoded device, no build flavors, so this one's solid.
const _pickupTableDeviceId = 'flow-pickup-table';

/// Confirmed from pickup_board's own source
/// (lib/core/constants/network_constants.dart: `mqttDeviceId = "Flow Pickup
/// Board"`) — same single-hardcoded-device situation as the pickup table
/// above.
const _pickupBoardDeviceId = 'flow-pickup-board';

/// Confirmed from flow_board's own source (lib/core/constants/network.dart:
/// `mqttDeviceId = "Flow Board"`).
const _flowBoardDeviceId = 'flow-board';

/// tof_camera/MqttPublisher.kt's HEARTBEAT_DEVICE_ID is "Flow ToF Camera"
/// (this device used to be a Raspberry Pi running PiMqttManager, swapped to
/// an Android STB running tof_camera on 2026-10-13 — see MqttPublisher.kt's
/// own doc comment for that port's history).
const _raspberryPiDeviceId = 'flow-tof-camera';

/// The 3 physical "Frame TV" QR scanners are each a build of qr_reader with
/// a different [DeviceRole] selected at runtime (see
/// qr_reader/lib/domain/entities/device_role.dart) — one per role in the
/// MQTT Topic spec sheet's beta/qr/order / beta/qr/complete / beta/qr/customer
/// topics. Confirmed mapping (per Cafe Beta MQTT Protocol.xlsx + user
/// confirmation). Labels shown on-screen match the New/Brew/Call/Done tab
/// naming (order-station scan starts Brew, complete-station scan moves the
/// item to Call, customer-station scan is the pickup/effectCircle trigger).
const _scannerOrderDeviceId = 'flow-qr-reader-brew';
const _scannerCompleteDeviceId = 'flow-qr-reader-call';
const _scannerCustomerDeviceId = 'flow-qr-reader-pickup';

/// Not a fixed id like the other rows — kiosk builds are tested/deployed
/// under varying names (Flow Kiosk, Flow Kiosk 02, kioskTest, ...), so this
/// row matches ANY heartbeat deviceId that CONTAINS "kiosk"
/// (case-insensitive, anywhere in the string — not just a prefix) instead of
/// one exact id (see [_HeartbeatDeviceRow.idPrefix]). Deliberately loose
/// since the kiosk's deviceId is a free-typed Settings-screen value, not a
/// compiled constant like every other device's.
const _kioskIdPrefix = 'kiosk';

/// A heartbeat is considered stale (device offline) after this long with no
/// new message — matches the same threshold fleet_monitor_dialog.dart uses.
const _heartbeatStaleAfter = Duration(seconds: 60);

/// figmaImage/10_Device Management.png. Originally 12 rows split into two
/// columns of 6 purely for layout balance; now 15 after Nudof Machine and
/// the two WLED rows were added later — every label already carries its
/// own (M)/(T) transport suffix, so the columns don't need to (an even 8/3
/// split by transport looked lopsided).
///
/// Real, live data sources per row:
/// - FlowHub Leader / FlowHub Follower / Flow QR Reader Brew / Flow QR
///   Reader Call / Flow QR Reader Pickup / Flow Pickup Table / Flow Kiosk /
///   Flow Pickup Board / Flow Board: MQTT heartbeat
///   ([FleetMonitorCubit.state.deviceLastSeen]) — online iff a heartbeat for
///   that deviceId arrived within [_heartbeatStaleAfter]. FlowHub
///   Leader/Follower check the fixed [_flowHubLeaderDeviceId]/
///   [_flowHubFollowerDeviceIds], independent of this build's own identity —
///   this screen watches both physical roles regardless of which one it's
///   being viewed from. Flow Pickup Table, Flow Pickup Board, Flow Board,
///   and the 3 QR reader ids are all confirmed real, fixed values. Flow
///   Kiosk is the one exception — it matches any deviceId CONTAINING "kiosk"
///   instead of one fixed id (see [_kioskIdPrefix]), since test/sample kiosk
///   builds get flashed under varying names (kiosk-01, flow-kiosk,
///   kioskTest02, ...) rather than one registered device.
/// - Raspberry Pi: MQTT heartbeat ([FleetMonitorCubit.state.deviceLastSeen]),
///   same mechanism as the other (M) rows above — see
///   [_raspberryPiDeviceId]. Was [FlowHubState.isConnected] (this app's local
///   WebSocket server, true whenever at least one client — Pi OR pickup
///   table OR anything else that dials in — was connected; mirrored to
///   followers via [LeaderUpdateMessage]) until the Pi moved its ToF/control
///   traffic to MQTT (PiMqttManager) and picked up its own heartbeat, which
///   is both more specific (this WAS "is anything connected", not "is the
///   Pi specifically connected") and needs no leader/follower mirroring —
///   the retained heartbeat is visible to every flowhub instance directly.
/// - Label Printer: [FlowHubState.isPrinterConnected] — the native Android
///   printer's TCP connection state (NOT the ATTACHED/DETACHED paper-sensor
///   signal, which is a different thing entirely), kept live by a
///   continuous native-side status poll (not just the startup attempt) —
///   flips off if the printer stops responding (e.g. sleep/power loss), with
///   no automatic retry after that. Tapping this row while off asks the
///   native side to retry immediately ([FlowHubCubit.reconnectPrinter]).
/// - Caye Machine: [FlowHubState.isCayeConnected] (not CayeManagementCubit —
///   that cubit is recreated every time the Caye Machine Control screen
///   opens/closes, and a follower's own Caye socket never actually opens
///   since it forwards commands to the leader instead — so it can't be this
///   row's source of truth). Real TCP socket state, mirrored to followers
///   the same way as the printer. Tapping this row while off asks the
///   machine to (re)sync its clock ([FlowHubCubit.reconnectCaye]) — the same
///   lightweight, side-effect-free command already used for the 1-minute
///   heartbeat, which as a side effect (re)opens the socket if it was closed.
/// - Nudof Machine: [FlowHubState.isNudofOnline] — the Shelly Plug M Gen3's own
///   `beta/nudof/online` topic (its Gen2+ online/LWT signal), NOT a TCP
///   socket FlowHub owns, hence the "(M)" suffix rather than "(T)" like
///   Caye/Printer above. Sourced the same way as the Raspberry Pi row above
///   (no leader/follower mirroring — the retained MQTT topic is visible to
///   every flowhub instance directly), just via FlowHubState instead of
///   FleetMonitorCubit since Shelly's own online-topic convention doesn't
///   match our beta/system/heartbeat/+ one. No tap-to-reconnect action
///   exists (FlowHub has no way to nudge the plug's own WiFi back up), so
///   unlike Caye/Printer this row has no onTapWhenOff.
/// - WLED Nudof 01 / WLED Caye 01: [FlowHubState.isNudofWledOnline] /
///   [FlowHubState.isCayeWledOnline] — each WLED guidance light's own native
///   `<Device Topic>/status` presence topic (WLED publishes "online" on
///   connect, retained, with that same topic set as its Last Will so the
///   broker announces "offline" automatically on an ungraceful disconnect).
///   Same sourcing pattern as Nudof Machine above (own non-heartbeat topic,
///   no leader/follower mirroring needed, no tap-to-reconnect action) — see
///   MqttDataSource.wledOnlineStream's doc comment.
class DeviceManagementScreen extends StatelessWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = FlowHubScale.of(context);

    return FlowHubSubScreenScaffold(
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
                    label: 'FlowHub Leader(M)',
                    deviceIds: const [_flowHubLeaderDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/flowhub.png',
                    iconWidth: 36.67,
                    iconHeight: 30,
                    label: 'FlowHub Follower(M)',
                    deviceIds: _flowHubFollowerDeviceIds,
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow QR Reader Brew(M)',
                    deviceIds: const [_scannerOrderDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow QR Reader Call(M)',
                    deviceIds: const [_scannerCompleteDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow QR Reader Pickup(M)',
                    deviceIds: const [_scannerCustomerDeviceId],
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/pickuptable.png',
                    iconWidth: 36.67,
                    iconHeight: 32.33,
                    label: 'Flow Pickup Table(M)',
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
                    label: 'Flow Kiosk(M)',
                    idPrefix: _kioskIdPrefix,
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/monitor.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow Pickup Board(M)',
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
                  BlocBuilder<FlowHubCubit, FlowHubState>(
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
                          context.read<FlowHubCubit>().reconnectPrinter(),
                    ),
                  ),
                  _HeartbeatDeviceRow(
                    scale: scale,
                    iconAsset: 'assets/images/raspberry.png',
                    iconWidth: 33.33,
                    iconHeight: 30,
                    label: 'Flow ToF Camera(M)',
                    deviceIds: const [_raspberryPiDeviceId],
                  ),
                  BlocBuilder<FlowHubCubit, FlowHubState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/Caye.png',
                      iconWidth: 26.67,
                      iconHeight: 33.33,
                      label: 'Caye Machine(T)',
                      isOn: state.isCayeConnected,
                      onTapWhenOff: () =>
                          context.read<FlowHubCubit>().reconnectCaye(),
                    ),
                  ),
                  BlocBuilder<FlowHubCubit, FlowHubState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/dispenser.png',
                      iconWidth: 33.33,
                      iconHeight: 33.33,
                      label: 'Nudof Machine(M)',
                      isOn: state.isNudofOnline,
                    ),
                  ),
                  BlocBuilder<FlowHubCubit, FlowHubState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/monitor.png',
                      iconWidth: 33.33,
                      iconHeight: 30,
                      label: 'WLED Nudof 01(M)',
                      isOn: state.isNudofWledOnline,
                    ),
                  ),
                  BlocBuilder<FlowHubCubit, FlowHubState>(
                    builder: (context, state) => _DeviceRow(
                      scale: scale,
                      iconAsset: 'assets/images/monitor.png',
                      iconWidth: 33.33,
                      iconHeight: 30,
                      label: 'WLED Caye 01(M)',
                      isOn: state.isCayeWledOnline,
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
  // When set, ANY heartbeat deviceId CONTAINING this (case-insensitive,
  // anywhere in the string) counts as online, instead of requiring an exact
  // match against [deviceIds] — for a role like Kiosk where multiple
  // differently-named physical/test units (kiosk-01, flow-kiosk,
  // kioskTest02, ...) should all count as "the kiosk", not just one fixed id.
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
        // contains, not startsWith — the kiosk's own deviceId is a
        // free-typed Settings-screen value (not a compiled constant like
        // every other device), so this stays deliberately loose: any
        // heartbeat deviceId with "kiosk" anywhere in it counts, regardless
        // of what prefix/suffix a given unit happens to be configured with
        // (kiosk-01, flow-kiosk, kioskTest02, ...).
        final isOn = prefix != null
            ? state.deviceLastSeen.entries.any(
                (e) => e.key.toLowerCase().contains(prefix) && isFresh(e.value),
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
                  fontFamily: flowhubFontFamily,
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
