/// Caye machine fault/warning code classification — shared across every
/// packet type that can carry one: 0x30's dedicated Fault Report, and the
/// `errorCode` field 0x12 (Rinsing Event)/0x22 (Making Event) include when
/// their own operation fails. The E/S/W prefix meaning is identical
/// everywhere on the machine (confirmed by the manufacturer) — only the
/// JSON shape differs per packet:
/// - 0x30: `{"errors": [{"code": "S048", "status": 0}]}` — an array of
///   objects, each entry carrying its OWN triggered(0)/cleared(1) state,
///   independent of any single operation. Use [describeEntry].
/// - 0x12 / 0x22 (on failure only): `{"status": 99, "errorCode": ["E005"]}`
///   — a flat array of bare code strings with no per-code status; the
///   packet's own `status` field describes the OPERATION's outcome (e.g.
///   0x22's 1=started/3=complete/6,99=failed), not each code individually.
///   Use [describe].
class CayeFaultCode {
  const CayeFaultCode._();

  // Prefix letter -> category label. Matches the FlowHub alert-tier split: E =
  // red siren (stop service, call engineer), S = yellow alert (staff can
  // resolve on-site — refill beans/milk, empty the grounds bin), W =
  // maintenance reminder (no immediate action needed). An undocumented
  // code still resolves to the correct tier from its prefix alone, so
  // nothing is silently unreadable while more specific codes get added to
  // [_descriptions] over time.
  static const Map<String, String> _categoryLabels = {
    'E': 'HARDWARE FAULT (critical — stop service, call engineer)',
    'S': 'SYSTEM WARNING (staff can resolve on-site)',
    'W': 'MAINTENANCE REMINDER (no immediate action needed)',
  };

  // Only a partial set of specific codes is documented so far.
  static const Map<String, String> _descriptions = {
    'E002': 'Inlet water pressure too low',
    'E005': 'Water pump failure or disconnected',
    'E057': 'Brewing unit rotation error (inoperable)',
    'S041': 'Grounds container full',
    'S046': 'Left hopper bean low',
    'S047': 'Right hopper bean low',
    'S049': 'Milk 1 low',
    'S050': 'Milk 2 low',
    'W002': 'Descaling required',
    'W003': 'Coffee system cleaning cycle due',
    'W005': 'Grinder burr replacement due',
  };

  static ({String category, String? description}) _resolve(String code) {
    final prefix = code.isNotEmpty ? code[0].toUpperCase() : '';
    return (
      category: _categoryLabels[prefix] ?? 'UNKNOWN CATEGORY',
      description: _descriptions[code],
    );
  }

  /// Formats a bare code string with no per-code status — see the 0x12/0x22
  /// shape in the class doc comment.
  static String describe(String code) {
    final r = _resolve(code);
    return r.description != null
        ? '$code [${r.category}] — ${r.description}'
        : '$code [${r.category}]';
  }

  /// Formats one `errors[]` entry from a 0x30 packet — see the 0x30 shape
  /// in the class doc comment. [status] is the entry's own 0=Triggered/
  /// 1=Cleared value.
  static String describeEntry(String code, int? status) {
    final r = _resolve(code);
    final statusLabel = status == 1 ? 'CLEARED' : 'TRIGGERED';
    return r.description != null
        ? '$code [${r.category}] $statusLabel — ${r.description}'
        : '$code [${r.category}] $statusLabel';
  }
}
