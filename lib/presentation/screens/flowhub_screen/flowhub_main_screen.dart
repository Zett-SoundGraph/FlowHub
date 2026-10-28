import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flowhub/core/di/di.dart';
import 'package:flowhub/core/theme/app_theme.dart';
import 'package:flowhub/domain/entities/index.dart';
import 'package:flowhub/presentation/cubit/index.dart';
import 'package:flowhub/presentation/enums/index.dart';
import 'package:flowhub/presentation/screens/caye_management_screen/caye_management_screen.dart';
import 'package:flowhub/presentation/screens/device_management_screen/device_management_screen.dart';
import 'package:flowhub/presentation/screens/nudof_management_screen/nudof_management_screen.dart';
import 'package:flowhub/presentation/screens/pickup_table_theme_screen/pickup_table_theme_screen.dart';
import 'package:flowhub/presentation/widgets/wled_test_toggle.dart';

import 'flowhub_main_texts.dart';
import 'widgets/index.dart';

class FlowHubMainScreen extends StatefulWidget {
  const FlowHubMainScreen({super.key});

  @override
  State<FlowHubMainScreen> createState() => _FlowHubMainScreenState();
}

class _FlowHubMainScreenState extends State<FlowHubMainScreen> {
  late final FlowHubCubit _cubit;
  final ScrollController _orderListController = ScrollController();
  OrderTab _selectedTab = OrderTab.newOrder;
  String? _expandedOrderNo;
  bool _showDelayedOnly = false;
  bool _isSearching = false;
  String _searchInput = '';
  bool _searchCommitted = false;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<FlowHubCubit>();
  }

  @override
  void dispose() {
    _orderListController.dispose();
    _cubit.close();
    super.dispose();
  }

  /// Marks a sub-item as cooked via [FlowHubCubit] and confirms it to the operator.
  /// 1. Delegate to [FlowHubCubit.completeCooking]
  /// 2. Return early on failure or if the widget was unmounted meanwhile
  /// 3. Show a confirmation snackbar
  Future<void> _onCompleteCooking(Order order, SubItem subItem) async {
    final success = await _cubit.completeCooking(order, subItem);
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(FlowHubMainTexts.cookingSignalSent(order.orderNo))),
    );
  }

  void _showCalibrationDialog(double scale, int currentHeight) {
    FlowHubCalibrationDialog.show(
      context: context,
      scale: scale,
      initialHeight: currentHeight,
      initialDisplayModel: 'AIO_550A',
      initialEdgeMarginMm: 40.0,
      onStart: (height, displayModel, edgeMarginMm, displayWidthMm,
              displayHeightMm) =>
          _cubit.startCalibration(
        height.toDouble(),
        displayModel: displayModel,
        edgeMarginMm: edgeMarginMm,
        displayWidthMm: displayWidthMm,
        displayHeightMm: displayHeightMm,
      ),
    );
  }

  void _showRebootDialog(double scale) {
    FlowHubRebootDialog.show(
      context: context,
      scale: scale,
      onConfirm: _cubit.rebootPreservingOrders,
    );
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchInput = '';
      _searchCommitted = false;
    });
  }

  void _closeSearch() {
    setState(() {
      _isSearching = false;
      _searchInput = '';
      _searchCommitted = false;
    });
  }

  void _appendSearchDigit(String digit) {
    setState(() => _searchInput += digit);
  }

  void _backspaceSearch() {
    if (_searchInput.isEmpty) return;
    setState(
      () => _searchInput = _searchInput.substring(0, _searchInput.length - 1),
    );
  }

  /// Reopens the keypad to edit a search that's already been committed
  /// (tapping the field itself, in either color state).
  void _editSearch() {
    if (!_isSearching) return;
    setState(() => _searchCommitted = false);
  }

  /// Buckets [orders] into one of the 4 Figma tabs. Sorted oldest-first
  /// (longest time waiting at the top) normally, or ascending by order
  /// number once a search has been committed.
  List<Order> _ordersForTab(List<Order> orders, OrderTab tab) {
    final bucket = orders.where((o) => o.currentTab == tab).toList();
    if (_searchCommitted && _searchInput.isNotEmpty) {
      bucket.sort(
        (a, b) => (int.tryParse(a.orderNo) ?? 0).compareTo(
          int.tryParse(b.orderNo) ?? 0,
        ),
      );
    } else {
      bucket.sort((a, b) {
        final aTime = a.stateEnteredAt ?? DateTime.now();
        final bTime = b.stateEnteredAt ?? DateTime.now();
        return aTime.compareTo(bTime);
      });
    }
    return bucket;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<FlowHubCubit, FlowHubState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red[700],
              ),
            );
        },
        builder: (context, state) {
          final scale = FlowHubScale.of(context);
          final visibleOrdersPool = state.orders.where((o) {
            if (_showDelayedOnly && !o.isDelayed) return false;
            if (_searchCommitted &&
                _searchInput.isNotEmpty &&
                !o.orderNo.startsWith(_searchInput)) {
              return false;
            }
            return true;
          }).toList();
          final tabOrders = {
            for (final tab in OrderTab.values)
              tab: _ordersForTab(visibleOrdersPool, tab),
          };
          final visibleOrders = tabOrders[_selectedTab]!;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              // Transparent rather than a fixed color: the status bar strip
              // needs to show two different colors at once while the side
              // panel is open (cream above the drawer, dimmed everywhere
              // else — figmaImage/8_calibration-1.png), which a single
              // statusBarColor can't do. The app's own Stack now draws all
              // the way up to the true screen top (see body: Stack below),
              // so whatever it paints there shows through instead.
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              // The Android gesture-nav bar at the very bottom of the screen
              // is drawn by the OS *on top of* the app's own content, so the
              // calibration overlay's dark Positioned.fill (however far it
              // extends within Flutter's own Stack) can never show through
              // it — this flat color has to be switched to a near-black
              // itself while calibrating, to visually match the overlay
              // dimming the rest of the screen. Same reasoning for the icon
              // brightness: light icons read against the now-dark strip.
              systemNavigationBarColor: state.isCalibrating
                  ? Colors.black
                  : FlowHubColors.bottomBarBg,
              systemNavigationBarIconBrightness: state.isCalibrating
                  ? Brightness.light
                  : Brightness.dark,
            ),
            child: Scaffold(
              backgroundColor: _selectedTab.pageBackground,
              resizeToAvoidBottomInset: false,
              // SafeArea only wraps the main Column below, not the whole
              // Stack — the drawer/scrim overlays need to reach the true
              // screen top (y:0, above the status bar) so the status bar
              // area itself picks up their color instead of one flat OS
              // status-bar color (figmaImage/8_calibration-1.png: the
              // status bar is cream above the drawer, dimmed everywhere
              // else — not achievable with a single statusBarColor value).
              body: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        FlowHubTopBar(
                          scale: scale,
                          backgroundColor: _selectedTab.pageBackground,
                          onMenuTap: () => setState(() => _isDrawerOpen = true),
                          onSearchTap: _startSearch,
                          isSearching: _isSearching,
                          searchInput: _searchInput,
                          searchCommitted: _searchCommitted,
                          onSearchFieldTap: _editSearch,
                          onCloseSearch: _closeSearch,
                        ),
                        FlowHubStatusTabBar(
                          scale: scale,
                          selected: _selectedTab,
                          counts: {
                            for (final tab in OrderTab.values)
                              tab: tabOrders[tab]!.length,
                          },
                          hasDelayed: {
                            for (final tab in OrderTab.values)
                              tab: tabOrders[tab]!.any((o) => o.isDelayed),
                          },
                          onSelect: (tab) => setState(() => _selectedTab = tab),
                        ),
                        Expanded(
                          child: visibleOrders.isEmpty
                              ? _EmptyState(scale: scale, tab: _selectedTab)
                              : RawScrollbar(
                                  controller: _orderListController,
                                  thumbVisibility: true,
                                  thickness: 13 * scale,
                                  radius: Radius.circular(8 * scale),
                                  thumbColor: const Color(0x421A1C1E),
                                  // List padding puts the first card 24 below
                                  // the viewport top; inset the scrollbar
                                  // itself by (24 - 16) so it starts 16 above
                                  // that first card instead of at the raw top.
                                  padding: EdgeInsets.only(top: 8 * scale),
                                  child: ListView.separated(
                                    controller: _orderListController,
                                    padding: EdgeInsets.fromLTRB(
                                      24 * scale,
                                      24 * scale,
                                      24 * scale,
                                      24 * scale,
                                    ),
                                    itemCount: visibleOrders.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(height: 12 * scale),
                                    itemBuilder: (context, index) {
                                      final order = visibleOrders[index];
                                      final isExpanded =
                                          _expandedOrderNo == order.orderNo;
                                      return _SwipeableOrderRow(
                                        scale: scale,
                                        order: order,
                                        fromTab: _selectedTab,
                                        onMoveToTab: (target) =>
                                            _cubit.moveOrderToTab(
                                              order.orderNo,
                                              target,
                                            ),
                                        child: FlowHubOrderListItem(
                                          scale: scale,
                                          order: order,
                                          tab: _selectedTab,
                                          expanded: isExpanded,
                                          onTap: () => setState(
                                            () => _expandedOrderNo = isExpanded
                                                ? null
                                                : order.orderNo,
                                          ),
                                          onPrint: () =>
                                              _cubit.printOrderLabels(order),
                                          onPrintItem: (itemIndex) =>
                                              _cubit.printSingleLabel(
                                                order,
                                                itemIndex,
                                              ),
                                          onCompleteCooking: _onCompleteCooking,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                        ),
                        // The real FlowHubBottomSummaryBar now lives as a
                        // separate Stack overlay below (painted after/on top
                        // of the drawer+scrim) — this just reserves the same
                        // layout space so the list doesn't scroll under it.
                        SizedBox(height: 96 * scale),
                      ],
                    ),
                  ),

                  // TEMPORARY — WLED bench-test toggle, see WledTestToggle's
                  // doc comment. Floats above the order list, clear of the
                  // top bar/status tabs and the bottom summary bar. Hidden by
                  // default (see kWledTestToggleEnabled) — its all-off button
                  // sends a real power-off, which now conflicts with the
                  // always-on/idle-black guidance-light design.
                  if (kWledTestToggleEnabled)
                    Positioned(
                      right: 24 * scale,
                      bottom: 120 * scale,
                      child: WledTestToggle(scale: scale),
                    ),

                  // search keypad — shown while typing, hidden once the
                  // search is committed (matching figmaImage/7_search_1-4.png,
                  // where the field stays but the keypad is gone).
                  if (kSearchFeatureEnabled &&
                      _isSearching &&
                      !_searchCommitted) ...[
                    // Dims the order list behind the keypad.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(color: const Color(0x941A1C1E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 896 * scale,
                      child: FlowHubSearchKeypad(
                        scale: scale,
                        currentInput: _searchInput,
                        onDigit: _appendSearchDigit,
                        onBackspace: _backspaceSearch,
                        onCancel: _closeSearch,
                        onSearch: () => setState(() => _searchCommitted = true),
                      ),
                    ),
                  ],

                  // Side panel (figmaImage/8_calibration-1.png) — a plain
                  // overlay rather than Scaffold's built-in Drawer, so the
                  // bottom summary bar can stay visible/undimmed alongside
                  // it instead of being covered by the drawer's own scrim.
                  // Both simply extend to the true screen bottom (no bottom-
                  // inset math needed) — FlowHubBottomSummaryBar is painted as
                  // its own Stack layer *after* this block (see below), so it
                  // naturally sits on top and covers/hides whatever these
                  // paint underneath it, shadow included.
                  if (_isDrawerOpen) ...[
                    // Simply to the true bottom — nothing inside it is
                    // positioned relative to its own edge, and the bottom
                    // bar (painted on top, below) covers/hides the excess.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => setState(() => _isDrawerOpen = false),
                        child: Container(color: const Color(0x941A1C1E)),
                      ),
                    ),
                    // The panel itself keeps its real height (matching
                    // figmaImage/8_calibration-1.png) rather than also
                    // extending to the true bottom — its Calibration button
                    // is positioned relative to *this* Container's own
                    // bottom edge, so stretching the panel further down would
                    // drag the button down with it, behind the bottom bar.
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: MediaQuery.paddingOf(context).bottom + 96 * scale,
                      child: FlowHubNavigationDrawer(
                        scale: scale,
                        isCalibrating: state.isCalibrating,
                        onClose: () => setState(() => _isDrawerOpen = false),
                        onDeviceManagement: () {
                          setState(() => _isDrawerOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // FlowHubCubit is provided locally inside this
                              // screen's own build() (BlocProvider.value
                              // above), not above the Navigator, so a pushed
                              // route can't reach it via context.read unless
                              // re-provided here — needed for the Label
                              // Printer/Raspberry Pi rows' real status.
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: _cubit),
                                  BlocProvider(
                                    create: (_) => getIt<CayeManagementCubit>(),
                                  ),
                                  BlocProvider(
                                    create: (_) => getIt<FleetMonitorCubit>(),
                                  ),
                                ],
                                child: const DeviceManagementScreen(),
                              ),
                            ),
                          );
                        },
                        onMachineControl: () {
                          setState(() => _isDrawerOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // FlowHubCubit is provided locally inside this
                              // screen's own build() (BlocProvider.value
                              // above), not above the Navigator — re-provided
                              // here (same reasoning as onDeviceManagement
                              // above) so the shot-test button can reach the
                              // manufacturing queue.
                              builder: (_) => MultiBlocProvider(
                                providers: [
                                  BlocProvider.value(value: _cubit),
                                  BlocProvider(
                                    create: (_) => getIt<CayeManagementCubit>(),
                                  ),
                                ],
                                child: const CayeManagementScreen(),
                              ),
                            ),
                          );
                        },
                        onNudofControl: () {
                          setState(() => _isDrawerOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => getIt<NudofControlCubit>(),
                                child: const NudofManagementScreen(),
                              ),
                            ),
                          );
                        },
                        onPickupTableTheme: () {
                          setState(() => _isDrawerOpen = false);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => getIt<PickupTableThemeCubit>(),
                                child: const PickupTableThemeScreen(),
                              ),
                            ),
                          );
                        },
                        onRecipeSync: () => _cubit.syncRecipeData(),
                        onCalibration: () {
                          setState(() => _isDrawerOpen = false);
                          _showCalibrationDialog(
                            scale,
                            state.calibrationHeight,
                          );
                        },
                        onReboot: () {
                          setState(() => _isDrawerOpen = false);
                          _showRebootDialog(scale);
                        },
                      ),
                    ),
                  ],

                  // Painted after the drawer/scrim (regardless of
                  // _isDrawerOpen), so it sits on top of them and reads as
                  // staying in place, undimmed, with its own existing shadow
                  // showing naturally against them — no separate
                  // shadow-matching needed. The calibration overlay below
                  // still paints after *this*, since that one case should
                  // dim the bottom bar too.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SafeArea(
                      top: false,
                      child: FlowHubBottomSummaryBar(
                        scale: scale,
                        totalOrders: state.orders
                            .where((o) => o.currentTab != OrderTab.done)
                            .length,
                        totalWaiting: state.orders
                            .where((o) => o.currentTab != OrderTab.done)
                            .fold<int>(0, (sum, o) => sum + o.totalCups),
                        isFilteringDelayed: _showDelayedOnly,
                        onToggleViewDelayed: () => setState(
                          () => _showDelayedOnly = !_showDelayedOnly,
                        ),
                      ),
                    ),
                  ),

                  // Calibration overlay (figmaImage/8_calibration-4.png).
                  // Painted absolutely last so it also covers the bottom
                  // summary bar (which is otherwise always painted on top of
                  // everything else, including the drawer/scrim — see that
                  // block's comments above) — during calibration, unlike the
                  // drawer, EVERYTHING including the bottom bar should read
                  // as blocked/dimmed. No tap-to-dismiss here on purpose —
                  // while the pickup table is calibrating, every other
                  // control must stay blocked; the overlay only clears
                  // itself automatically once the real device status stream
                  // reports calibration finished (_handleCalibrationStatus,
                  // driven by sg/aio_pickup_table's own completion signal).
                  // New orders still arrive/render normally underneath —
                  // only user interaction is blocked, since the opaque
                  // Container already claims every touch in this screen area
                  // itself.
                  if (state.isCalibrating)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.9),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 781 * scale,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Calibration in Progress...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: flowhubFontFamily,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 36 * scale,
                                      height: 50 / 36,
                                      letterSpacing: -0.36 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 24 * scale),
                                  Text(
                                    'Please follow the instructions on the Pickup Table.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: flowhubFontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 32 * scale,
                                      height: 1.43,
                                      letterSpacing: -0.64 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 24 * scale),
                                  Text(
                                    '${state.calibrationHeight}mm',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: flowhubFontFamily,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 32 * scale,
                                      height: 1.43,
                                      letterSpacing: -0.64 * scale,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Wraps an order row in swipe-to-move-tab behavior (figmaImage/
/// 3_orderSlide-*.png). Renders its own full-size, never-clipped
/// [_TabSwipeReveal] backing layer *behind* the [Dismissible] instead of
/// using Dismissible's `background`/`secondaryBackground` params — those get
/// hard-clipped by Dismissible to the exact drag offset (see
/// `_DismissibleClipper` in the Flutter SDK), which doesn't line up with the
/// sliding card's own rounded corner (the corner curves inward before
/// reaching that clip line), leaving a sliver where neither layer paints and
/// the page background peeks through. A full-size backing layer underneath
/// has no such seam — the card's rounded corner just reveals more of it.
class _SwipeableOrderRow extends StatefulWidget {
  final double scale;
  final Order order;
  final OrderTab fromTab;
  final void Function(OrderTab target) onMoveToTab;
  final Widget child;

  const _SwipeableOrderRow({
    required this.scale,
    required this.order,
    required this.fromTab,
    required this.onMoveToTab,
    required this.child,
  });

  @override
  State<_SwipeableOrderRow> createState() => _SwipeableOrderRowState();
}

class _SwipeableOrderRowState extends State<_SwipeableOrderRow> {
  // >0 while dragging toward nextTab (startToEnd), <0 toward previousTab
  // (endToStart), 0 at rest — driven by Dismissible.onUpdate every pointer
  // move (and by its own spring-back animation on release), so this also
  // naturally settles back to 0 when a drag is cancelled.
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final nextTab = widget.fromTab.nextTab;
    final previousTab = widget.fromTab.previousTab;
    final direction = switch ((nextTab != null, previousTab != null)) {
      (true, true) => DismissDirection.horizontal,
      (true, false) => DismissDirection.startToEnd,
      (false, true) => DismissDirection.endToStart,
      (false, false) => DismissDirection.none,
    };

    Widget? backing;
    if (_progress > 0 && nextTab != null) {
      backing = _TabSwipeReveal(
        scale: widget.scale,
        fromTab: widget.fromTab,
        isForward: true,
      );
    } else if (_progress < 0 && previousTab != null) {
      backing = _TabSwipeReveal(
        scale: widget.scale,
        fromTab: widget.fromTab,
        isForward: false,
      );
    }

    return Stack(
      children: [
        if (backing != null) Positioned.fill(child: backing),
        Dismissible(
          key: ValueKey(widget.order.orderNo),
          direction: direction,
          onUpdate: (details) => setState(() {
            _progress = details.direction == DismissDirection.startToEnd
                ? details.progress
                : -details.progress;
          }),
          onDismissed: (dismissDirection) {
            final target = dismissDirection == DismissDirection.startToEnd
                ? nextTab
                : previousTab;
            if (target != null) widget.onMoveToTab(target);
          },
          child: widget.child,
        ),
      ],
    );
  }
}

/// Revealed behind an order row while it's being dragged toward an adjacent
/// tab (figmaImage/3_orderSlide-*.png). Exact per-transition specs given —
/// each (fromTab, isForward) pair has its own base fill, accent gradient,
/// corner radius, and label side, since none of the 6 reachable transitions
/// share identical values.
class _TabSwipeRevealSpec {
  final Color baseColor;
  final Color accentColor;
  // Accent gradient stops/opacities, left-to-right (CSS 90deg): the color
  // ramps between accentOpacities[0]@accentStops[0] and
  // accentOpacities[1]@accentStops[1], clamped flat outside that range.
  final List<double> accentStops;
  final List<double> accentOpacities;
  final double borderRadius;
  final Color textColor;
  final bool labelOnLeft;

  const _TabSwipeRevealSpec({
    required this.baseColor,
    required this.accentColor,
    required this.accentStops,
    required this.accentOpacities,
    required this.borderRadius,
    required this.textColor,
    required this.labelOnLeft,
  });
}

// Keyed by (fromTab, isForward) — isForward true = dragged right/startToEnd
// (reveals the next tab), false = dragged left/endToStart (reveals the
// previous tab). Only the 6 actually-reachable transitions have entries.
final Map<(OrderTab, bool), _TabSwipeRevealSpec> _swipeRevealSpecs = {
  // NEW → BREW (drag right)
  (OrderTab.newOrder, true): const _TabSwipeRevealSpec(
    baseColor: Color(0xFFF9E1C1),
    accentColor: Color(0xFFE9B166),
    accentStops: [0.1154, 0.20],
    accentOpacities: [0.0, 0.2],
    borderRadius: 24,
    textColor: Color(0xFF825412),
    labelOnLeft: true,
  ),
  // BREW → NEW (drag left)
  (OrderTab.brew, false): const _TabSwipeRevealSpec(
    baseColor: Color(0xFFB0DDF2),
    accentColor: Color(0xFF289FD6),
    accentStops: [0.80, 0.8846],
    accentOpacities: [0.2, 0.0],
    borderRadius: 24,
    textColor: Color(0xFF05334A),
    labelOnLeft: false,
  ),
  // BREW → CALL (drag right)
  (OrderTab.brew, true): const _TabSwipeRevealSpec(
    baseColor: Color(0xFFBBE4B9),
    accentColor: Color(0xFF43A940),
    accentStops: [0.1154, 0.20],
    accentOpacities: [0.0, 0.2],
    borderRadius: 24,
    textColor: Color(0xFF254A22),
    labelOnLeft: true,
  ),
  // CALL → BREW (drag left)
  (OrderTab.call, false): const _TabSwipeRevealSpec(
    baseColor: Color(0xFFF9E1C1),
    accentColor: Color(0xFFE9B166),
    accentStops: [0.80, 0.8846],
    accentOpacities: [0.2, 0.0],
    borderRadius: 24,
    textColor: Color(0xFF825412),
    labelOnLeft: false,
  ),
  // CALL → DONE (drag right)
  (OrderTab.call, true): const _TabSwipeRevealSpec(
    baseColor: Color(0x421A1C1E),
    accentColor: Color(0xFF666666),
    accentStops: [0.1154, 0.20],
    accentOpacities: [0.0, 0.2],
    borderRadius: 24,
    textColor: Color(0xFF33383C),
    labelOnLeft: true,
  ),
  // DONE → CALL (drag left)
  (OrderTab.done, false): const _TabSwipeRevealSpec(
    baseColor: Color(0xFFBBE4B9),
    accentColor: Color(0xFF43A940),
    accentStops: [0.80, 0.8846],
    accentOpacities: [0.2, 0.0],
    borderRadius: 24,
    textColor: Color(0xFF254A22),
    labelOnLeft: false,
  ),
};

class _TabSwipeReveal extends StatelessWidget {
  final double scale;
  final OrderTab fromTab;
  final bool isForward;

  const _TabSwipeReveal({
    required this.scale,
    required this.fromTab,
    required this.isForward,
  });

  @override
  Widget build(BuildContext context) {
    final targetTab = isForward ? fromTab.nextTab! : fromTab.previousTab!;
    final spec = _swipeRevealSpecs[(fromTab, isForward)]!;
    // Uniform rounding on all 4 corners is safe here — this widget is now
    // rendered full-size behind the Dismissible (see _SwipeableOrderRow),
    // not clipped to the drag offset, so there's no seam to line up with the
    // sliding foreground card's own corner.
    return Container(
      decoration: BoxDecoration(
        color: spec.baseColor,
        borderRadius: BorderRadius.circular(spec.borderRadius * scale),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: spec.accentStops,
                  colors: [
                    spec.accentColor.withValues(alpha: spec.accentOpacities[0]),
                    spec.accentColor.withValues(alpha: spec.accentOpacities[1]),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: spec.labelOnLeft
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 48 * scale),
                child: Text(
                  targetTab.label,
                  style: TextStyle(
                    fontFamily: 'LineSeedJP',
                    fontWeight: FontWeight.w800,
                    fontSize: 32 * scale,
                    height: 36 / 32,
                    letterSpacing: -0.01 * 32 * scale,
                    color: spec.textColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown in place of the order list when there's nothing to display —
/// either the tab is genuinely empty, or the delayed-only filter has
/// nothing matching (figmaImage/6_none-*.png).
class _EmptyState extends StatelessWidget {
  final double scale;
  final OrderTab tab;

  const _EmptyState({required this.scale, required this.tab});

  String get _asset => switch (tab) {
    OrderTab.newOrder => 'assets/images/Nothing-New.png',
    OrderTab.brew => 'assets/images/Nothing-Brew.png',
    OrderTab.call => 'assets/images/Nothing-Call.png',
    OrderTab.done => 'assets/images/Nothing-Done.png',
  };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 516 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(_asset, width: 134 * scale, height: 114 * scale),
            SizedBox(height: 32 * scale),
            Text(
              'Nothing to display',
              style: TextStyle(
                fontFamily: flowhubFontFamily,
                fontWeight: FontWeight.w400,
                fontSize: 36 * scale,
                height: 50 / 36,
                letterSpacing: -0.36 * scale,
                color: FlowHubColors.textPrimary87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
