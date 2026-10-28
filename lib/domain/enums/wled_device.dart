/// One physical WLED guidance light. Each value maps to that unit's own
/// MQTT "Device Topic" (set in the WLED web UI itself) under
/// `beta/flowhub/wled/<key>` — WLED appends `/api` itself for its JSON
/// command sub-topic. Numbered (`01`) from the start since more than one
/// Caye machine (and its own WLED) is expected eventually — add `caye02`
/// etc. here when that happens, no other code needs to change.
enum WledDevice {
  caye01('caye_01'),
  nudof01('nudof_01');

  const WledDevice(this.topicKey);

  /// The segment after `beta/flowhub/wled/` in this device's MQTT topic —
  /// must exactly match what's typed into that physical unit's own MQTT
  /// "Device Topic" setting.
  final String topicKey;
}
