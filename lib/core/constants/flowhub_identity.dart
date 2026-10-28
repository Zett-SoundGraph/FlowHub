import 'dart:io';

import 'package:flowhub/core/utils/log.dart';

enum FlowHubRole { leader, follower }

/// Resolves which physical FlowHub unit this build is running on — from a
/// build-time override if one was baked in, otherwise from this device's own
/// local IP's last octet. Only 3 units are deployed as FlowHub right now —
/// add more cases to [_applyKnownRole]/[resolve] if that changes.
///
/// Call [resolve] once, early at app startup (before anything connects to
/// MQTT — see [setupLocator]), then read [role]/[deviceId]/[deviceName].
class FlowHubIdentity {
  const FlowHubIdentity._();

  static const _tag = 'FlowHubIdentity';

  /// Build-time override — pass e.g. `--dart-define=FLOWHUB_ROLE=leader`
  /// when building to bake a fixed identity into that specific APK, skipping
  /// IP detection entirely. Lets you build 3 distinct, clearly-labeled APKs
  /// ahead of time (for a USB install where the network might not be set up
  /// yet) instead of relying on each tablet's IP being correct at first
  /// launch. Empty string ('') means "not set — fall back to IP detection".
  static const String _buildTimeRole = String.fromEnvironment('FLOWHUB_ROLE');

  static FlowHubRole role = FlowHubRole.follower;
  static String deviceId = 'flowhub-unresolved';
  static String deviceName = 'FlowHub-Unresolved';

  static Future<void> resolve() async {
    if (_applyKnownRole(_buildTimeRole)) {
      Log.d(_tag, 'Resolved identity from build-time FLOWHUB_ROLE="$_buildTimeRole": deviceId=$deviceId');
      return;
    }

    final octet = await _detectLastOctet();
    final roleNameForOctet = switch (octet) {
      200 => 'leader',
      201 => 'follower01',
      202 => 'follower02',
      _ => null,
    };
    if (roleNameForOctet != null && _applyKnownRole(roleNameForOctet)) {
      Log.d(_tag, 'Resolved identity from IP octet $octet: deviceId=$deviceId');
      return;
    }

    // Neither a build-time override nor a known IP octet matched — a
    // dev/test box on some other IP, or FLOWHUB_ROLE was misspelled. Safe
    // fallback that can't collide with any real unit's MQTT client ID.
    final label = octet != null ? 'flowhub-unknown-$octet' : 'flowhub-unknown';
    role = FlowHubRole.follower;
    deviceId = label;
    deviceName = label;
    Log.w(
      _tag,
      'Could not resolve a known FlowHub identity (FLOWHUB_ROLE="$_buildTimeRole", IP octet=$octet) — using fallback "$label"',
    );
  }

  /// Applies [roleName] ('leader'/'follower01'/'follower02') if recognized,
  /// returning whether it matched. The single source of truth for what each
  /// of the 3 deployed units is actually called.
  static bool _applyKnownRole(String roleName) {
    switch (roleName) {
      case 'leader':
        role = FlowHubRole.leader;
        // deviceId stays a lowercase/hyphenated slug — it's embedded
        // directly into MQTT topic paths (beta/system/heartbeat/<deviceId>,
        // beta/flowhub/follower/<deviceId>/update), where spaces/mixed case
        // stand out against every other (all-lowercase) topic in the
        // protocol. deviceName is the free-form "pretty" display label —
        // see the Fixed identity / Display label doc comment pattern this
        // mirrors in pickup_table/app_constants.dart etc.
        deviceId = 'flowhub-leader';
        deviceName = 'FlowHub Leader';
        return true;
      case 'follower01':
        role = FlowHubRole.follower;
        // Numbered so each unit's own beta/system/heartbeat/<deviceId>
        // topic stays distinct — two followers publishing retained
        // heartbeats to the same topic would overwrite each other, making
        // the fleet monitor unable to tell if one or both are actually online.
        deviceId = 'flowhub-follower-01';
        deviceName = 'FlowHub Follower 01';
        return true;
      case 'follower02':
        role = FlowHubRole.follower;
        deviceId = 'flowhub-follower-02';
        deviceName = 'FlowHub Follower 02';
        return true;
      default:
        return false;
    }
  }

  /// Reads this device's own local IPv4 address (first non-loopback
  /// interface — Android tablets only have one active interface, WiFi) and
  /// returns its last octet, or null if no address could be determined.
  static Future<int?> _detectLastOctet() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
        includeLinkLocal: false,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final parts = addr.address.split('.');
          if (parts.length == 4) {
            final octet = int.tryParse(parts.last);
            if (octet != null) return octet;
          }
        }
      }
    } catch (e) {
      Log.e(_tag, 'Failed to enumerate network interfaces: $e');
    }
    return null;
  }
}
