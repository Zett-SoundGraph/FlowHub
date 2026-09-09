import 'package:flutter/material.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/domain/enums/index.dart';

/// The 4 status buckets shown as tabs on the KDS main screen.
enum OrderTab { newOrder, brew, call, done }

/// Past this, an order's elapsed/countdown pill switches to the "delayed" style.
const kDelayThreshold = Duration(minutes: 10);

/// Per-item classification shown as the New/Brew/Call/Done pill in the
/// expanded order panel — the same 4 buckets as [OrderTab], just at
/// sub-item granularity.
extension SubItemTabClassifier on SubItem {
  OrderTab get tab {
    if (status == OrderStatus.pickedUp) return OrderTab.done;
    if (status == OrderStatus.ready) return OrderTab.call;
    if (isExtracting || isError) return OrderTab.brew;
    return OrderTab.newOrder;
  }
}

extension OrderTabClassifier on Order {
  /// An order's tab is whichever of its items is furthest BEHIND — e.g. an
  /// order only reaches BREW once every item has left NEW (one item
  /// starting to brew while the others are still queued keeps the whole
  /// order in NEW), and only reaches DONE once every item is picked up.
  OrderTab get currentTab {
    if (items.isEmpty) return OrderTab.newOrder;
    return items
        .map((i) => i.tab)
        .reduce((a, b) => a.index < b.index ? a : b);
  }

  /// DONE orders are never "delayed" (no red styling applies there either).
  bool get isDelayed {
    if (currentTab == OrderTab.done) return false;
    final enteredAt = stateEnteredAt;
    if (enteredAt == null) return false;
    return DateTime.now().difference(enteredAt) >= kDelayThreshold;
  }
}

extension OrderTabLabel on OrderTab {
  String get label => switch (this) {
    OrderTab.newOrder => 'NEW',
    OrderTab.brew => 'BREW',
    OrderTab.call => 'CALL',
    OrderTab.done => 'DONE',
  };

  /// Page background — also used for the app bar, status bar, and the
  /// selected tab's pill background, which all match whichever tab is active.
  Color get pageBackground => switch (this) {
    OrderTab.newOrder => const Color(0xFFE3ECF0),
    OrderTab.brew => const Color(0xFFF0EAE3),
    OrderTab.call => const Color(0xFFE0E7E0),
    OrderTab.done => const Color(0xFFE4E4E4),
  };

  /// Background of an order row once it's expanded
  /// (figmaImage/4_orderSpread-*.png) — a more saturated tint than
  /// [pageBackground], not the same color.
  Color get expandedCardTint => switch (this) {
    OrderTab.newOrder => const Color(0xFFB0DDF2),
    OrderTab.brew => const Color(0xFFE6C698),
    OrderTab.call => const Color(0xFFAFD4AD),
    OrderTab.done => const Color(0xFFD2D8DD),
  };

  /// The tab reached by dragging an order forward one step
  /// (figmaImage/3_orderSlide-*.png — right-drag) — null for DONE, the last tab.
  OrderTab? get nextTab => switch (this) {
    OrderTab.newOrder => OrderTab.brew,
    OrderTab.brew => OrderTab.call,
    OrderTab.call => OrderTab.done,
    OrderTab.done => null,
  };

  /// The tab reached by dragging an order backward one step (left-drag) —
  /// null for NEW, the first tab.
  OrderTab? get previousTab => switch (this) {
    OrderTab.newOrder => null,
    OrderTab.brew => OrderTab.newOrder,
    OrderTab.call => OrderTab.brew,
    OrderTab.done => OrderTab.call,
  };
}
