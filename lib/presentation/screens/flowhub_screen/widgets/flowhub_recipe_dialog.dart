import 'package:flutter/material.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/index.dart';

String _titleCase(String s) => s
    .split(' ')
    .map(
      (w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
    )
    .join(' ');

/// Recipe popup opened by tapping a beverage row inside an expanded order
/// (figmaImage/4_recipe-3.png, 4_recipe-4.png — the current layout: recipe
/// image on the left, a scrollable ingredient list on the right. An earlier
/// version overlaid ingredient pills directly on the image instead, which
/// looked fine for one or two ingredients but overlapped and mis-ordered
/// once a drink had several — this side-list replaces that entirely).
class FlowHubRecipeDialog extends StatelessWidget {
  final double scale;
  final SubItem subItem;
  final MenuInfo? menuInfo;
  final List<MenuIngredient> ingredients;
  final String? recipeImageUrl;

  const FlowHubRecipeDialog({
    super.key,
    required this.scale,
    required this.subItem,
    required this.menuInfo,
    required this.ingredients,
    required this.recipeImageUrl,
  });

  static Future<void> show({
    required BuildContext context,
    required double scale,
    required SubItem subItem,
    required MenuInfo? menuInfo,
    required List<MenuIngredient> ingredients,
    required String? recipeImageUrl,
  }) {
    return showDialog(
      context: context,
      // Transparent — showDialog's own barrier would dim the WHOLE screen,
      // including FlowHubBottomSummaryBar (the orders/waiting bar), which must
      // stay undimmed. The dialog paints its own scrim instead, sized to
      // stop short of that bar — see build()'s first Stack child.
      barrierColor: Colors.transparent,
      builder: (dialogContext) => FlowHubRecipeDialog(
        scale: scale,
        subItem: subItem,
        menuInfo: menuInfo,
        ingredients: ingredients,
        recipeImageUrl: recipeImageUrl,
      ),
    );
  }

  // Prefers the real per-order temp a kiosk order carries. Falls back to
  // "HOT only if this menu item is HOT-only" for orders with no real data
  // yet (e.g. the dev test-order button), since which one a customer chose
  // isn't knowable in that case.
  bool get _isHot => subItem.temp.isNotEmpty
      ? subItem.temp.toUpperCase() == 'HOT'
      : (menuInfo != null && menuInfo!.hot && !menuInfo!.iced);

  // Middle section (image + ingredient list) height — fixed at 834
  // regardless of ingredient count; the list itself scrolls internally
  // (see _RecipeIngredientList's own 800 max height) rather than growing
  // this section any further.
  static const _middleSectionHeight = 834.0;

  // Recipe illustration position/size — shared with the ingredient list's
  // own left-offset/maxWidth math below so moving/resizing the image can't
  // silently make it overlap the list.
  static const _glassLeft = 158.42 - 30; // 30 further left than the 158.42 spec value
  static const _glassWidth = 558.0;
  static const _glassHeight = 731.0;

  @override
  Widget build(BuildContext context) {
    // Material(transparency) rather than returning the Stack directly:
    // unlike FlowHubReprintLabelDialog (which uses Flutter's Dialog widget and
    // gets a Material ancestor for free), this popup needs a specific
    // top/left position rather than centering, so it builds the Stack
    // itself — but the close button's InkWell still needs a Material
    // ancestor to paint its splash, which is what was missing (and what
    // rendered as a red error box in its place).
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Manual scrim standing in for showDialog's own barrier (disabled
          // above, see show()) — stops 96*scale short of the bottom edge so
          // FlowHubBottomSummaryBar (the orders/waiting bar) stays undimmed.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 96 * scale,
            child: const IgnorePointer(
              child: ColoredBox(color: Color(0x571A1C1E)),
            ),
          ),
          Positioned(
            // Anchored to the bottom bar instead of the screen top — the
            // popup's own height is dynamic (grows with the ingredient
            // list/wrapped Ingredients line), so pinning by `bottom` lets it
            // grow upward without needing to know its total height here.
            // Spec: 244 above FlowHubBottomSummaryBar's own top edge, i.e.
            // 244 + that bar's 96 height above the screen bottom.
            bottom: (244 + 96) * scale,
            // Was 314 (centered for the old 653-wide popup: 1280-653=627,
            // 627/2≈314). The popup grew to 1144 wide but this was never
            // rebalanced, so the right edge sat at 314+1144=1458 — well past
            // the 1280-wide frame (FlowHubScale.figmaWidth). Recentered the same
            // way: (1280-1144)/2=68.
            left: 68 * scale,
            child: Container(
              width: 1144 * scale,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAE3),
                borderRadius: BorderRadius.circular(40 * scale),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1F1A1C1E),
                    blurRadius: 120 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                  BoxShadow(
                    color: const Color(0x611A1C1E),
                    blurRadius: 40 * scale,
                    offset: Offset(0, 8 * scale),
                  ),
                ],
              ),
              // No overall fixed height (unlike the original spec) — the
              // bottom Ingredients line can wrap to 2 lines depending on how
              // many options got added, and the popup needs to grow to fit
              // that rather than overflow past its own bottom edge.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _RecipeHeader(
                    scale: scale,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  // Fixed height — see _middleSectionHeight.
                  Container(
                    width: double.infinity,
                    height: _middleSectionHeight * scale,
                    color: const Color(0xFFFFFCF7),
                    child: Stack(
                      children: [
                        Positioned(
                          left: _glassLeft * scale,
                          // The spec's 137.79 is measured from the popup's
                          // very top (same origin as the header/app bar),
                          // not from where THIS container starts (i.e.
                          // already below the header) — using 137.79
                          // directly here double-counted the header's own
                          // 96, pushing the image 96px too far down.
                          top: (137.79 - 96) * scale,
                          child: _GlassIllustration(
                            scale: scale,
                            imageUrl: recipeImageUrl,
                            width: _glassWidth,
                            height: _glassHeight,
                          ),
                        ),
                        // Bottom-anchored (not top-anchored) so it grows
                        // upward as ingredients are added, capped at its own
                        // 800 max height (scrolls beyond that) — see
                        // _RecipeIngredientList.
                        Positioned(
                          left: (_glassLeft + _glassWidth + 66.56) * scale,
                          bottom: 70 * scale,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (1144 - _glassLeft - _glassWidth - 66.56) * scale,
                            ),
                            child: _RecipeIngredientList(
                              scale: scale,
                              ingredients: ingredients,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFF0EAE3),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(40 * scale, 57 * scale, 40 * scale, 40 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _MiniTag(
                                scale: scale,
                                text: _isHot ? 'HOT' : 'ICE',
                                bg: _isHot
                                    ? const Color(0xFFE93C3C)
                                    : const Color(0xFF3895C4),
                                width: 84,
                                hPadding: 20,
                              ),
                              SizedBox(width: 8 * scale),
                              _MiniTag(
                                scale: scale,
                                text: 'MD',
                                bg: FlowHubColors.navy,
                                hPadding: 8,
                              ),
                              SizedBox(width: 24 * scale),
                              Expanded(
                                child: Text(
                                  subItem.menuName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: flowhubFontFamily,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 36 * scale,
                                    height: 50 / 36,
                                    letterSpacing: -0.36 * scale,
                                    color: FlowHubColors.textPrimary87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32 * scale),
                          _InfoSection(
                            scale: scale,
                            label: 'Ingredients',
                            items: ingredients,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A label + comma-joined ingredient-name line (matches
/// figmaImage/4_recipe-1.png's "Ice, Cold Milk, Tea Base" style — names
/// only, no amounts). Uses [MenuIngredient.name] rather than [groupName] —
/// for recipe-matched entries the two are identical, but two DIFFERENT
/// added options that happen to share a group (e.g. two different Toppings)
/// would otherwise both show as the same generic group name twice.
class _InfoSection extends StatelessWidget {
  final double scale;
  final String label;
  final List<MenuIngredient> items;

  const _InfoSection({required this.scale, required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 24 * scale,
            height: 34 / 24,
            letterSpacing: -0.24 * scale,
            color: const Color(0x941A1C1E),
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          items.isEmpty ? '-' : items.map((i) => _titleCase(i.name)).join(', '),
          style: TextStyle(
            fontFamily: flowhubFontFamily,
            fontWeight: FontWeight.w400,
            fontSize: 28 * scale,
            height: 36 / 28,
            letterSpacing: -0.28 * scale,
            color: FlowHubColors.textPrimary87,
          ),
        ),
      ],
    );
  }
}

class _RecipeHeader extends StatelessWidget {
  final double scale;
  final VoidCallback onClose;

  const _RecipeHeader({required this.scale, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96 * scale,
      child: Stack(
        children: [
          Positioned(
            left: 48 * scale,
            top: 30 * scale,
            child: Text(
              'Recipe',
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 28 * scale,
                height: 36 / 28,
                letterSpacing: -0.28 * scale,
                color: FlowHubColors.navy,
              ),
            ),
          ),
          Positioned(
            right: 44.66 * scale,
            top: 32.66 * scale,
            child: InkWell(
              onTap: onClose,
              child: Image.asset(
                'assets/images/close.png',
                width: 30.68 * scale,
                height: 30.68 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The recipe illustration alone (figmaImage/4_recipe-3.png) — no ingredient
/// overlay anymore; ingredients render in [_RecipeIngredientList] instead.
class _GlassIllustration extends StatelessWidget {
  final double scale;
  final String? imageUrl;
  final double width;
  final double height;

  const _GlassIllustration({
    required this.scale,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return SizedBox(
      width: width * scale,
      height: height * scale,
      // Menus with no Recipe_Image row/value yet just show blank space here
      // — same "silently fall back, never a broken-image icon" behavior as
      // the order-list thumbnail (_MenuThumbnail).
      child: url == null
          ? null
          : Image.network(
              url,
              width: width * scale,
              height: height * scale,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }
}

/// Maps a [MenuIngredient.source] bullet label to its icon asset.
String? _iconAssetForSource(String? source) => switch (source) {
      'Coffee Machine' => 'assets/images/coffeemachine.png',
      'Dispenser' => 'assets/images/dispenser.png',
      'Manual' => 'assets/images/hand.png',
      _ => null,
    };

/// The scrollable ingredient card to the right of the recipe image
/// (figmaImage/4_recipe-3.png / -4.png) — each line is the ingredient's
/// name + amount, then a "• [icon] source" line underneath (Dispenser /
/// Coffee Machine / Manual). Replaces the old on-image pill overlay, which
/// overlapped and mis-ordered once a drink had more than a couple of
/// ingredients.
class _RecipeIngredientList extends StatelessWidget {
  final double scale;
  final List<MenuIngredient> ingredients;

  const _RecipeIngredientList({
    required this.scale,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 800 * scale),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F1A1C1E),
              blurRadius: 6 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Scrollbar(
          thumbVisibility: ingredients.length > 1,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < ingredients.length; i++) ...[
                  if (i > 0) SizedBox(height: 24 * scale),
                  _RecipeIngredientRow(scale: scale, ingredient: ingredients[i]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeIngredientRow extends StatelessWidget {
  final double scale;
  final MenuIngredient ingredient;

  const _RecipeIngredientRow({required this.scale, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                // ingredient.name, not groupName — for recipe-matched
                // entries they're identical, but two different added
                // options sharing a group (e.g. two different Toppings)
                // need their own specific names here, not the same generic
                // group name twice.
                text: _titleCase(ingredient.name),
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 24 * scale,
                  color: FlowHubColors.textPrimary87,
                ),
              ),
              TextSpan(
                text: ' ( ${ingredient.amount} )',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 24 * scale,
                  color: FlowHubColors.textPrimary87,
                ),
              ),
            ],
          ),
        ),
        if (ingredient.source != null) ...[
          SizedBox(height: 4 * scale),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '•  ',
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontSize: 24 * scale,
                  height: 34 / 24,
                  letterSpacing: 24 * scale * -0.01,
                  color: const Color(0x941A1C1E),
                ),
              ),
              if (_iconAssetForSource(ingredient.source) case final asset?)
                Image.asset(
                  asset,
                  width: 24 * scale,
                  height: 24 * scale,
                  color: const Color(0x941A1C1E),
                ),
              SizedBox(width: 8 * scale),
              Text(
                ingredient.source!,
                style: TextStyle(
                  fontFamily: flowhubFontFamily,
                  fontWeight: FontWeight.w400,
                  fontSize: 24 * scale,
                  height: 34 / 24,
                  letterSpacing: 24 * scale * -0.01,
                  color: const Color(0x941A1C1E),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _MiniTag extends StatelessWidget {
  final double scale;
  final String text;
  final Color bg;
  final double? width;
  final double hPadding;

  const _MiniTag({
    required this.scale,
    required this.text,
    required this.bg,
    this.width,
    required this.hPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width != null ? width! * scale : null,
      height: 48 * scale,
      alignment: Alignment.center,
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
          fontFamily: flowhubFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 24 * scale,
          height: 40 / 24,
          letterSpacing: -0.48 * scale,
          color: Colors.white,
        ),
      ),
    );
  }
}
