import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/presentation/cubit/kds/kds_cubit.dart';
import 'package:flowhub/presentation/enums/index.dart';

import 'kds_recipe_dialog.dart';
import 'kds_reprint_label_dialog.dart';

/// A single order row card, matching the Figma list-item layout.
///
/// The avatar/order-no/badge cluster on the left is laid out with absolute
/// (Positioned) offsets rather than a Row, by design request: the drink/food
/// badges are anchored a fixed distance from the card's left edge so they
/// never shift if the order number's width changes.
class KdsOrderListItem extends StatelessWidget {
  final double scale;
  final Order order;
  final OrderTab tab;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onPrint;
  final void Function(int subItemIndex) onPrintItem;
  final Future<void> Function(Order order, SubItem subItem) onCompleteCooking;

  const KdsOrderListItem({
    super.key,
    required this.scale,
    required this.order,
    required this.tab,
    required this.expanded,
    required this.onTap,
    required this.onPrint,
    required this.onPrintItem,
    required this.onCompleteCooking,
  });

  String get _drinkBadgeAsset => switch (tab) {
    OrderTab.newOrder => 'assets/images/new-drink.png',
    OrderTab.brew => 'assets/images/brew-drink.png',
    OrderTab.call => 'assets/images/call-drink.png',
    OrderTab.done => 'assets/images/done-drink.png',
  };

  String get _foodBadgeAsset => switch (tab) {
    OrderTab.newOrder => 'assets/images/new-food.png',
    OrderTab.brew => 'assets/images/brew-food.png',
    OrderTab.call => 'assets/images/call-food.png',
    OrderTab.done => 'assets/images/done-food.png',
  };

  // Native asset pixel sizes (identical across the 4 tab color variants).
  static const _drinkBadgeSize = Size(60, 62);
  static const _foodBadgeSize = Size(65, 63);

  @override
  Widget build(BuildContext context) {
    // Ticks once a second so the elapsed-in-tab text counts up live (DONE
    // included, just without the delayed red styling — see _build). Only the
    // currently selected tab's rows exist in the tree at all (kds_main_screen
    // builds one ListView for _selectedTab), so switching away from DONE
    // disposes these timers immediately — the growing DONE backlog never
    // costs anything while it's off-screen.
    return StreamBuilder<void>(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final now = DateTime.now();
    final receivedAt = order.receivedAt ?? now;
    final elapsed = now.difference(order.stateEnteredAt ?? now);
    final isDelayed = tab != OrderTab.done && elapsed >= kDelayThreshold;
    final orderNoColor = isDelayed
        ? const Color(0xFFE93C3C)
        : KdsColors.orderNoText;
    final avgProgress = order.aggregateProgress;

    const drinkBadgeLeft = 405.0;
    final foodBadgeLeft = drinkBadgeLeft + _drinkBadgeSize.width + 43;
    const dividerLeft = 682.0;
    const receivedTimeLeft = dividerLeft + 4 + 58;

    // Expanded rows drop their own card background/shadow and blend straight
    // into the page — the same trick the Figma reference uses: the selected
    // row's tint is just the page's own background color showing through,
    // with the menu breakdown panel (white) sitting underneath it.
    final rowRadius = expanded
        ? BorderRadius.vertical(top: Radius.circular(24 * scale))
        : BorderRadius.circular(24 * scale);

    return Material(
      color: expanded ? tab.expandedCardTint : KdsColors.cardBg,
      borderRadius: BorderRadius.circular(24 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: rowRadius,
            onTap: onTap,
            child: Container(
              height: 122 * scale,
              decoration: BoxDecoration(
                // Without an opaque color here, the shadow below paints
                // straight over the Material fill across the whole card
                // instead of just its edges (a pre-existing bug — 4% black
                // blended uniformly into #FFFCF7 measures as #F5F2ED, which
                // is exactly what was showing up as "slightly darker").
                color: expanded ? null : KdsColors.cardBg,
                borderRadius: rowRadius,
                boxShadow: expanded
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 32 * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _MenuThumbnail(
                        scale: scale,
                        menuName: order.items.isNotEmpty ? order.items.first.menuName : '',
                        size: 74,
                        painterSize: const Size(32, 39),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (32 + 74 + 16) * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fixed-width channel-letter box: "K" and "M" render at
                          // different natural widths, which used to shift the
                          // digits after it — pinning both to the same 46px box
                          // keeps the number's start position constant.
                          SizedBox(
                            width: 46 * scale,
                            child: Text(
                              splitOrderNoForDisplay(order.orderNo).prefix,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontFamily: kdsFontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 44 * scale,
                                height: 1.35,
                                letterSpacing: -0.66 * scale,
                                color: orderNoColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 126 * scale,
                            child: Text(
                              splitOrderNoForDisplay(order.orderNo).number,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontFamily: kdsFontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 44 * scale,
                                height: 1.35,
                                letterSpacing: -0.66 * scale,
                                color: orderNoColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: drinkBadgeLeft * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ImageBadge(
                        scale: scale,
                        asset: _drinkBadgeAsset,
                        nativeSize: _drinkBadgeSize,
                        count: order.drinkCount,
                      ),
                    ),
                  ),
                  if (order.foodCount > 0)
                    Positioned(
                      left: foodBadgeLeft * scale,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _ImageBadge(
                          scale: scale,
                          asset: _foodBadgeAsset,
                          nativeSize: _foodBadgeSize,
                          count: order.foodCount,
                        ),
                      ),
                    ),

                  // Progress gauge (BREW tab only): sits under the drink/food
                  // badge cluster, 7 below its bottom edge (drink=62 tall,
                  // food=63 — using the taller one to derive the icons' shared
                  // bottom within the vertically-centered 122-tall card).
                  if (tab == OrderTab.brew)
                    Positioned(
                      left: drinkBadgeLeft * scale,
                      top: ((122 + _foodBadgeSize.height) / 2 + 7) * scale,
                      child: Container(
                        width: 176 * scale,
                        height: 10 * scale,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: const Color(0x0F1A1C1E),
                          borderRadius: BorderRadius.circular(5 * scale),
                          border: Border.all(
                            color: const Color(0x1F1A1C1E),
                            width: 1 * scale,
                          ),
                        ),
                        child: FractionallySizedBox(
                          widthFactor: avgProgress.clamp(0.0, 1.0),
                          child: Container(
                            height: 10 * scale,
                            decoration: BoxDecoration(
                              color: isDelayed
                                  ? const Color(0xFFE93C3C)
                                  : (expanded
                                        ? Colors.white
                                        : KdsColors.progressFill),
                              borderRadius: BorderRadius.circular(5 * scale),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: dividerLeft * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 4 * scale,
                        height: 80 * scale,
                        color: KdsColors.divider,
                      ),
                    ),
                  ),
                  // Received-time text is anchored from the divider (left side),
                  // right-aligned within a 166-wide slot. The designer's exact
                  // spec: letter-spacing -30% PLUS the 'fwid' (full-width
                  // forms) font feature — 'fwid' is what was missing earlier,
                  // which is why -30% letter-spacing alone looked squished
                  // (it was pulling normal-width digits together with nothing
                  // widening them first).
                  Positioned(
                    left: receivedTimeLeft * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: SizedBox(
                        width: 166 * scale,
                        child: Text(
                          '${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}:${receivedAt.second.toString().padLeft(2, '0')}',
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: kdsFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 28 * scale,
                            height: 36 / 28,
                            letterSpacing: -0.3 * 28 * scale,
                            fontFeatures: const [FontFeature('fwid')],
                            color: const Color(0x941A1C1E),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pill and print button are anchored from the card's right
                  // edge directly, so the print button's 32 margin can never
                  // drift even if the received-time text's measured width is off.
                  Positioned(
                    right: (32 + 80 + 24) * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: 162 * scale,
                        height: 68 * scale,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isDelayed
                              ? const Color(0xFFE93C3C)
                              : (expanded
                                    ? Colors.white
                                    : const Color(0x0DA37B42)),
                          borderRadius: BorderRadius.circular(34 * scale),
                        ),
                        child: Text(
                          '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontFamily: kdsFontFamily,
                            fontWeight: FontWeight.w700,
                            fontSize: 36 * scale,
                            height: 50 / 36,
                            letterSpacing: -0.36 * scale,
                            color: isDelayed
                                ? Colors.white
                                : KdsColors.orderNoText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 32 * scale,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40 * scale),
                        onTap: () => KdsReprintLabelDialog.show(
                          context: context,
                          scale: scale,
                          title: 'Reprint All Labels?',
                          subtitle:
                              'This will reprint the labels for all beverages in this order.',
                          onReprint: onPrint,
                        ),
                        child: Container(
                          width: 80 * scale,
                          height: 80 * scale,
                          decoration: BoxDecoration(
                            color: expanded
                                ? const Color(0x4DFFFFFF)
                                : const Color(0x0F1A1C1E),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/print.png',
                              width: 40 * scale,
                              height: 36 * scale,
                              color: const Color(0x941A1C1E),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            _OrderExpandPanel(
              scale: scale,
              order: order,
              elapsed: elapsed,
              onPrintItem: onPrintItem,
              onCompleteCooking: onCompleteCooking,
            ),
        ],
      ),
    );
  }
}

/// Menu thumbnail from the Menu List sheet's Google Drive image, falling
/// back to a generic drink-glass illustration when there's no thumbnail URL
/// (menu not found) or the network image fails to load.
class _MenuThumbnail extends StatelessWidget {
  final double scale;
  final String menuName;
  final double size;
  final Size painterSize;

  const _MenuThumbnail({
    required this.scale,
    required this.menuName,
    required this.size,
    required this.painterSize,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = context.read<KdsCubit>().menuInfoFor(menuName)?.thumbnailImageUrl;
    final placeholder = CustomPaint(
      size: Size(painterSize.width * scale, painterSize.height * scale),
      painter: _DrinkGlassPainter(),
    );
    return ClipOval(
      child: Container(
        width: size * scale,
        height: size * scale,
        color: KdsColors.avatarBg,
        alignment: Alignment.center,
        child: thumbnailUrl == null
            ? placeholder
            : Image.network(
                thumbnailUrl,
                width: size * scale,
                height: size * scale,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _DrinkGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glass = Path()
      ..moveTo(size.width * 0.12, size.height * 0.18)
      ..lineTo(size.width * 0.88, size.height * 0.18)
      ..lineTo(size.width * 0.76, size.height)
      ..lineTo(size.width * 0.24, size.height)
      ..close();

    canvas.drawPath(glass, Paint()..color = const Color(0xFF3B1E12));
    canvas.drawPath(
      glass,
      Paint()
        ..color = const Color(0xFF5C4033)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05,
    );

    final icePaint = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final iceSize = size.width * 0.28;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, size.height * 0.06, iceSize, iceSize),
        Radius.circular(size.width * 0.07),
      ),
      icePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.5, 0, iceSize * 0.9, iceSize * 0.9),
        Radius.circular(size.width * 0.07),
      ),
      icePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Drink/food quantity badge: the pre-colored PNG asset with the count
/// centered on top.
class _ImageBadge extends StatelessWidget {
  final double scale;
  final String asset;
  final Size nativeSize;
  final int count;

  const _ImageBadge({
    required this.scale,
    required this.asset,
    required this.nativeSize,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: nativeSize.width * scale,
      height: nativeSize.height * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            asset,
            width: nativeSize.width * scale,
            height: nativeSize.height * scale,
          ),
          Padding(
            padding: EdgeInsets.only(top: 6 * scale),
            child: Text(
              '$count',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontFamily: kdsFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 36 * scale,
                height: 50 / 36,
                letterSpacing: -0.36 * scale,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu breakdown panel shown below an expanded order row
/// (figmaImage/4_orderSpread-*.png). Per-item elapsed time reuses the
/// order-level [elapsed] — [SubItem] has no per-item timestamp of its own —
/// and the option tags are a structural placeholder derived only from the
/// menu name, since customization data (ice/hot, size, shots, flavors) isn't
/// modeled anywhere yet. Food sub-items aren't rendered: [Order.items] only
/// ever contains drink entries today (foodCount is a bare count with no
/// backing SubItem), so there's nothing real to show for them.
///
/// NOTE: the old grid-icon button (manual complete-cooking / extraction
/// monitor trigger) was replaced by the spec'd per-item QR print button —
/// [onCompleteCooking] and the extraction monitor dialog have no trigger
/// point in this panel anymore until told where they should live instead.
class _OrderExpandPanel extends StatelessWidget {
  final double scale;
  final Order order;
  final Duration elapsed;
  final void Function(int subItemIndex) onPrintItem;
  final Future<void> Function(Order order, SubItem subItem) onCompleteCooking;

  const _OrderExpandPanel({
    required this.scale,
    required this.order,
    required this.elapsed,
    required this.onPrintItem,
    required this.onCompleteCooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Card content is 1232 wide (screen 1280 minus the list's 24+24
      // padding); a 20 margin on each side lands the panel at exactly 1192.
      margin: EdgeInsets.fromLTRB(20 * scale, 0, 20 * scale, 32 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < order.items.length; i++) ...[
            if (i != 0)
              const Divider(height: 1, thickness: 1, color: KdsColors.divider),
            _OrderItemRow(
              scale: scale,
              index: i + 1,
              orderNo: order.orderNo,
              subItemIndex: i,
              subItem: order.items[i],
              onPrint: () => onPrintItem(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final double scale;
  final int index;
  final String orderNo;
  final int subItemIndex;
  final SubItem subItem;
  final VoidCallback onPrint;

  const _OrderItemRow({
    required this.scale,
    required this.index,
    required this.orderNo,
    required this.subItemIndex,
    required this.subItem,
    required this.onPrint,
  });

  // Every element in row 1 (circle/icon/name/status/time/qr) is centered on
  // this same vertical line, derived from the two exactly-given offsets:
  // circle (top 28, height 48) and the qr button (top 24, height 56) both
  // center at 52.
  static const _row1Center = 52.0;
  static const _row1Height = 80.0;

  void _openRecipe(BuildContext context) {
    final cubit = context.read<KdsCubit>();
    KdsRecipeDialog.show(
      context: context,
      scale: scale,
      subItem: subItem,
      menuInfo: cubit.menuInfoFor(subItem.menuName),
      ingredients: cubit.recipePopupIngredientsFor(subItem),
      recipeImageUrl: cubit.recipeImageFor(subItem),
    );
  }

  @override
  Widget build(BuildContext context) {
    const circleLeft = 24.0;
    const circleSize = 48.0;
    const iconSize = 56.0;
    const iconLeft = circleLeft + circleSize + 16;
    const nameLeft = iconLeft + iconSize + 16;
    const statusRight = 294.0;
    const statusWidth = 176.0;
    const elapsedRight = statusRight - 16 - 162;
    const nameMaxWidth = 1192 - nameLeft - (statusRight + statusWidth);

    // The whole row opens the recipe popup on tap, EXCEPT the QR button and
    // the status pill — their own gesture detectors are more specific
    // (nested deeper) and win the gesture arena for taps within their own
    // bounds, so they don't also trigger this outer handler.
    return GestureDetector(
      onTap: () => _openRecipe(context),
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 1192 * scale,
        constraints: BoxConstraints(minHeight: 240 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: _row1Height * scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: circleLeft * scale,
                    top: 28 * scale,
                    child: _CircleIndex(scale: scale, number: index),
                  ),
                  Positioned(
                    left: iconLeft * scale,
                    top: (_row1Center - iconSize / 2) * scale,
                    child: _MenuThumbnail(
                      scale: scale,
                      menuName: subItem.menuName,
                      size: 56,
                      painterSize: const Size(24, 29),
                    ),
                  ),
                  Positioned(
                    left: nameLeft * scale,
                    top: (_row1Center - 25) * scale,
                    width: nameMaxWidth * scale,
                    height: 50 * scale,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subItem.menuName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kdsFontFamily,
                          fontWeight: FontWeight.w700,
                          fontSize: 36 * scale,
                          height: 50 / 36,
                          letterSpacing: -0.36 * scale,
                          color: const Color(0xFF262E32),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    // The pill's touch target is padded beyond its visible
                    // bounds ([_StatusPill.touchPadding]) — offset by the
                    // same amount here so the visible pill stays exactly
                    // where the 176x54 geometry above expects it.
                    right: (statusRight - _StatusPill.touchPadding) * scale,
                    top: ((_row1Center - 27) - _StatusPill.touchPadding) * scale,
                    child: _StatusPill(
                      scale: scale,
                      tab: subItem.tab,
                      progress: subItem.progress,
                      onTap: () => context
                          .read<KdsCubit>()
                          .cycleItemStatus(orderNo, subItemIndex),
                    ),
                  ),
                  Positioned(
                    right: elapsedRight * scale,
                    top: (_row1Center - 28) * scale,
                    child: _ElapsedChip(scale: scale),
                  ),
                  Positioned(
                    right: 24 * scale,
                    top: 24 * scale,
                    child: _QrButton(
                      scale: scale,
                      onTap: () => KdsReprintLabelDialog.show(
                        context: context,
                        scale: scale,
                        title: 'Reprint Label?',
                        subtitle:
                            'This will reprint the label for this specific beverage.',
                        onReprint: onPrint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * scale),
            Padding(
              padding: EdgeInsets.only(left: 88 * scale, right: 24 * scale),
              child: Wrap(
                spacing: 12 * scale,
                runSpacing: 8 * scale,
                children: _tagsFor(context, subItem, scale),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Size is fixed at MD until real per-order size data exists — the Menu List
/// sheet only says which sizes a menu *can* be sold as, not which one a
/// given order actually picked. HOT/ICE is now real per-menu availability
/// (Menu List's HOT/ICED columns), defaulting to ICE when both are possible
/// since which one a customer actually chose isn't recorded anywhere yet.
/// The remaining tags are, in order: the item's base recipe (Caye + Nudof
/// device/ingredient labels, resolved from "Recipe List" + "CAYE PKey List")
/// followed by the customer's actual added options beyond that base recipe
/// (resolved from Menu List + Option List) — both shown by name only, no
/// amounts.
List<Widget> _tagsFor(BuildContext context, SubItem subItem, double scale) {
  final cubit = context.read<KdsCubit>();
  final menuInfo = cubit.menuInfoFor(subItem.menuName);
  // Prefer the real per-order temp/size a kiosk order carries; only fall
  // back to the static hot-only/"MD" placeholder for orders with no real
  // data yet (e.g. the dev test-order button).
  final isHot = subItem.temp.isNotEmpty
      ? subItem.temp.toUpperCase() == 'HOT'
      : (menuInfo != null && menuInfo.hot && !menuInfo.iced);
  final sizeLabel = subItem.size.isNotEmpty ? subItem.size.toUpperCase() : 'MD';

  final tags = <Widget>[
    isHot
        ? _Tag(
            text: 'HOT',
            scale: scale,
            bg: const Color(0xFFE93C3C),
            fg: const Color(0xFFFCFCFC),
            hPadding: 20,
          )
        : _Tag(
            text: 'ICE',
            scale: scale,
            bg: const Color(0xFF3895C4),
            fg: const Color(0xFFFCFCFC),
            hPadding: 20,
          ),
    _Tag(
      text: sizeLabel,
      scale: scale,
      bg: KdsColors.navy,
      fg: const Color(0xFFFCFCFC),
      hPadding: 15,
    ),
  ];

  for (final label in cubit.recipeIngredientLabelsFor(subItem)) {
    tags.add(_ingredientTag(label, scale));
  }
  for (final ingredient in cubit.ingredientsFor(subItem.menuName, subItem.selectedOptions)) {
    tags.add(_ingredientTag(_rowTagLabel(ingredient), scale));
  }
  return tags;
}

/// Matches figmaImage/4_orderSpread-*.png's style: quantity-type options show
/// as "{count} {shortLabel}" (e.g. "2 Shot", not "2 Espresso Shot (60g)"),
/// single/multi options show their plain name (e.g. "Regular Ice") — no
/// amounts in this compact row view (those only show in the recipe popup).
String _rowTagLabel(MenuIngredient ingredient) {
  if (ingredient.quantity > 0) {
    final shortLabel = switch (ingredient.groupName) {
      'Espresso' => 'Shot',
      'Syrup' => ingredient.name.replaceAll(' Syrup', ''),
      _ => ingredient.name,
    };
    return '${ingredient.quantity} $shortLabel';
  }
  return _titleCase(ingredient.name);
}

String _titleCase(String s) => s
    .split(' ')
    .map(
      (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    )
    .join(' ');

Widget _ingredientTag(String text, double scale) => _Tag(
  text: text,
  scale: scale,
  bg: const Color(0x0F1A1C1E),
  fg: const Color(0xFF1A1C1E),
  hPadding: 12,
  fontWeight: FontWeight.w400,
);

class _Tag extends StatelessWidget {
  final String text;
  final double scale;
  final Color bg;
  final Color fg;
  final double hPadding;
  final FontWeight fontWeight;

  const _Tag({
    required this.text,
    required this.scale,
    required this.bg,
    required this.fg,
    required this.hPadding,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // No `alignment` here on purpose: Container.alignment wraps the child
      // in an Align, which expands to fill all available width under loose
      // (but bounded) constraints — exactly what a Wrap hands its children —
      // stretching every tag full-width instead of shrink-wrapping to its
      // text. The height + padding math (4+4+40 line-height = 48) already
      // centers the text vertically without needing Align at all.
      height: 48 * scale,
      padding: EdgeInsets.symmetric(
        horizontal: hPadding * scale,
        vertical: 4 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(2 * scale),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kdsFontFamily,
          fontWeight: fontWeight,
          fontSize: 24 * scale,
          height: 40 / 24,
          letterSpacing: -0.48 * scale,
          color: fg,
        ),
      ),
    );
  }
}

class _CircleIndex extends StatelessWidget {
  final double scale;
  final int number;

  const _CircleIndex({required this.scale, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48 * scale,
      height: 48 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x611A1C1E), width: 2 * scale),
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kdsFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 28 * scale,
          height: 36 / 28,
          letterSpacing: -0.28 * scale,
          color: const Color(0xFF353D40),
        ),
      ),
    );
  }
}

/// Per-item status pill — shows the same 4 buckets as the main tabs
/// (New/Brew/Call/Done) and doubles as a manual override: tapping it cycles
/// New→Brew→Call→Done→New for whenever automatic production tracking
/// doesn't (or can't) advance an item on its own.
class _StatusPill extends StatelessWidget {
  final double scale;
  final OrderTab tab;
  final double progress;
  final VoidCallback onTap;

  const _StatusPill({
    required this.scale,
    required this.tab,
    required this.progress,
    required this.onTap,
  });

  /// The pill's visible geometry (176x54) is small relative to a finger, so
  /// the tap target extends this far beyond it on every side — the caller
  /// ([_OrderItemRow.build]) shrinks its Positioned offsets by the same
  /// amount so the visible pill doesn't shift.
  static const touchPadding = 16.0;

  // Geometry (176x54, radius16, padding 5 vertical/24 horizontal) is shared
  // across tabs. Padding(5)*2 + line-height(44) = 54, exactly filling the
  // pill's fixed height.
  Widget _solid(String text, Color bg, Color fg) {
    return Container(
      width: 176 * scale,
      height: 54 * scale,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kdsFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 24 * scale,
          height: 44 / 24,
          color: fg,
        ),
      ),
    );
  }

  Widget _pill() {
    switch (tab) {
      case OrderTab.newOrder:
        return _solid('New', const Color(0xFFE5F0F7), const Color(0x941A1C1E));
      case OrderTab.brew:
        return _BrewPill(scale: scale, progress: progress);
      case OrderTab.call:
        return _solid('Call', const Color(0xFF6BC467), Colors.white);
      case OrderTab.done:
        return _solid('Done', const Color(0x421A1C1E), Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(touchPadding * scale),
        child: _pill(),
      ),
    );
  }
}

/// The Brew pill doubles as a mini progress gauge — track/fill match the
/// figma spec (#FFEDD5 track, #EEB123 fill), pill-shaped. Geometry matches
/// [_StatusPill._solid] (176x54, radius16) — only colors differ per phase.
class _BrewPill extends StatelessWidget {
  final double scale;
  final double progress;

  const _BrewPill({required this.scale, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 176 * scale,
      height: 54 * scale,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Positioned.fill forces this to occupy the whole pill (tight
          // constraints) instead of shrinking itself to widthFactor and
          // letting the Stack's own alignment (center) place that smaller
          // box in the middle — which is what made the fill visually grow
          // from the center instead of the left.
          Positioned.fill(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: KdsColors.progressFill),
            ),
          ),
          Text(
            'Brew',
            style: TextStyle(
              fontFamily: kdsFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 24 * scale,
              height: 44 / 24,
              color: KdsColors.textPrimary87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Static "00:00" for now — the per-tab elapsed-time design for this pill
/// needs to be reconfirmed before wiring it to anything real.
class _ElapsedChip extends StatelessWidget {
  final double scale;

  const _ElapsedChip({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 162 * scale,
      height: 56 * scale,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: 24 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: const Color(0x0A1A1C1E),
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      child: Text(
        '00:00',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: kdsFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 32 * scale,
          height: 40 / 32,
          letterSpacing: 0.32 * scale,
          fontFeatures: const [FontFeature.tabularFigures()],
          color: const Color(0x421A1C1E),
        ),
      ),
    );
  }
}

/// Prints just this one sub-item's label (unlike the header print button,
/// which prints every item in the order).
class _QrButton extends StatelessWidget {
  final double scale;
  final VoidCallback onTap;

  const _QrButton({required this.scale, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28 * scale),
      onTap: onTap,
      child: Container(
        width: 56 * scale,
        height: 56 * scale,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0x0A1A1C1E),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/images/QR.png',
          width: 24.89 * scale,
          height: 24.89 * scale,
        ),
      ),
    );
  }
}
