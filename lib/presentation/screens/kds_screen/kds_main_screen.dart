import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kds/core/di/di.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/enums/index.dart';
import 'package:kds/presentation/cubit/index.dart';
import 'package:kds/presentation/screens/caye_management_screen/caye_management_screen.dart';
import 'package:kds/presentation/widgets/fleet_monitor_dialog.dart';

import 'extraction_monitor_dialog.dart';
import 'kds_main_texts.dart';

class KdsMainScreen extends StatefulWidget {
  const KdsMainScreen({super.key});

  @override
  State<KdsMainScreen> createState() => _KdsMainScreenState();
}

class _KdsMainScreenState extends State<KdsMainScreen> {
  late final KdsCubit _cubit;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<KdsCubit>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _onCompleteCooking(Order order, SubItem subItem) async {
    final success = await _cubit.completeCooking(order, subItem);
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(KdsMainTexts.cookingSignalSent(order.orderNo))),
    );
  }

  Future<void> _onCompletePickup(Order order) async {
    await _cubit.completePickup(order);
  }

  void _showCalibrationDialog() {
    final controller = TextEditingController(text: '1000');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Start Calibration',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the current sensor height (mm).\nRequired for accurate calibration.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                labelText: 'Height (mm)',
                labelStyle: const TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () {
              final height = double.tryParse(controller.text) ?? 1000.0;
              Navigator.pop(context);
              _cubit.startCalibration(height);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Height ${height.toInt()}mm — starting calibration!')),
              );
            },
            child: const Text('Start Calibration',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showFleetMonitorDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider(
        create: (_) => getIt<FleetMonitorCubit>(),
        child: const FleetMonitorDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<KdsCubit, KdsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null || message.isEmpty) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text(message),
              backgroundColor: Colors.red[700],
            ));
        },
        builder: (context, state) {
          final size = MediaQuery.sizeOf(context);
          final orientation = MediaQuery.orientationOf(context);

          // responsive grid calculation
          int crossAxisCount;
          if (size.width < 600) {
            crossAxisCount = 1;
          } else if (size.width < 1000) {
            crossAxisCount = 2;
          } else if (size.width < 1400) {
            crossAxisCount = 3;
          } else {
            crossAxisCount = 4;
          }

          int rowCount;
          if (orientation == Orientation.portrait) {
            rowCount = 3;
          } else {
            rowCount = (size.height / 320.0).floor().clamp(1, 3);
          }

          final itemsPerPage = crossAxisCount * rowCount;
          final pageCount = state.orders.isEmpty
              ? 1
              : (state.orders.length / itemsPerPage).ceil();

          return Scaffold(
            backgroundColor: Colors.black,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: Colors.blueGrey[900],
              centerTitle: true,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('KDS',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  _ConnectionBadge(isConnected: state.isConnected),
                ],
              ),
              actions: [
                // Machine Control button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (_) => getIt<CayeManagementCubit>(),
                          child: const CayeManagementScreen(),
                        ),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.greenAccent, width: 1.5),
                      foregroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Machine Control',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                // Calibration button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: OutlinedButton(
                    onPressed: _showCalibrationDialog,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.orangeAccent, width: 1.5),
                      foregroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Calibration',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                // Fleet Status button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: OutlinedButton(
                    onPressed: _showFleetMonitorDialog,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
                      foregroundColor: Colors.cyanAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Fleet Status',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _showQueueDialog(context, state),
              backgroundColor: state.manufacturingQueueLength == 0
                  ? Colors.blueGrey[800]
                  : Colors.orange[800],
              icon: Icon(
                Icons.format_list_numbered,
                color: state.manufacturingQueueLength == 0
                    ? Colors.white54
                    : Colors.white,
              ),
              label: Text(
                state.manufacturingQueueLength == 0
                    ? 'Queue Empty'
                    : '${state.manufacturingQueueLength} in Queue',
                style: TextStyle(
                  color: state.manufacturingQueueLength == 0
                      ? Colors.white54
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Stack(
              children: [
                // order list
                state.orders.isEmpty
                    ? const Center(
                        child: Text('No orders in queue.',
                            style: TextStyle(color: Colors.white)))
                    : Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: pageCount,
                              onPageChanged: (page) =>
                                  setState(() => _currentPage = page),
                              itemBuilder: (context, pageIndex) {
                                final start = pageIndex * itemsPerPage;
                                final end = (start + itemsPerPage)
                                    .clamp(0, state.orders.length);
                                final pageOrders =
                                    state.orders.sublist(start, end);
                                return LayoutBuilder(
                                  builder: (context, constraints) {
                                    final totalSpacing =
                                        (rowCount + 1) * 12.0;
                                    final dynamicHeight =
                                        (constraints.maxHeight - totalSpacing) /
                                            rowCount;
                                    return Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          mainAxisExtent: dynamicHeight,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                        ),
                                        itemCount: pageOrders.length,
                                        itemBuilder: (context, index) =>
                                            _OrderCard(
                                          order: pageOrders[index],
                                          onCompleteCooking: _onCompleteCooking,
                                          onCompletePickup: _onCompletePickup,
                                          onPrintOrder: (order) =>
                                              _cubit.printOrderLabels(order),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          if (pageCount > 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '${_currentPage + 1} / $pageCount',
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),

                // calibration overlay
                if (state.isCalibrating)
                  GestureDetector(
                    onTap: () => _cubit.stopCalibration(),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.9),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                                color: Colors.orangeAccent, strokeWidth: 6),
                            const SizedBox(height: 30),
                            const Text('Calibration in Progress...',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            const Text(
                              'Please follow the instructions on the Pickup Table.',
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 18),
                            ),
                            const SizedBox(height: 30),
                            TextButton(
                              onPressed: () => _cubit.stopCalibration(),
                              child: const Text('Close',
                                  style: TextStyle(color: Colors.white54)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showQueueDialog(BuildContext context, KdsState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.list_alt, color: Colors.orangeAccent),
            SizedBox(width: 10),
            Text('Brewing Queue',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 350,
          height: 300,
          child: state.manufacturingQueueLength == 0
              ? const Center(
                  child: Text('No brewing commands in queue.',
                      style: TextStyle(color: Colors.white54)))
              : const Center(
                  child: Text('Loading queue...',
                      style: TextStyle(color: Colors.white54))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final bool isConnected;

  const _ConnectionBadge({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 6),
          Text(
            isConnected ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Future<void> Function(Order, SubItem) onCompleteCooking;
  final Future<void> Function(Order) onCompletePickup;
  final void Function(Order) onPrintOrder;

  const _OrderCard({
    required this.order,
    required this.onCompleteCooking,
    required this.onCompletePickup,
    required this.onPrintOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isFullReady = order.isAllReady;

    return Container(
      decoration: BoxDecoration(
        color: isFullReady ? Colors.indigo[900] : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isFullReady ? Colors.blueAccent : Colors.white10, width: 2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header: order number + print button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'NO. ${order.orderNo}',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.print, color: Colors.cyanAccent, size: 28),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Print label',
                onPressed: () => onPrintOrder(order),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 15),

          // sub-item list
          Expanded(
            child: ListView.builder(
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final subItem = order.items[index];
                final isReady = subItem.status == OrderStatus.ready;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              subItem.menuName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: isReady
                                    ? Colors.white38
                                    : Colors.white,
                              ),
                            ),
                          ),
                          if (isReady)
                            const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 22)
                          else if (!subItem.isExtracting && !subItem.isError)
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () =>
                                    onCompleteCooking(order, subItem),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[800],
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                ),
                                child: const Text(
                                    KdsMainTexts.completeCooking,
                                    style: TextStyle(fontSize: 10)),
                              ),
                            ),
                        ],
                      ),
                      // brewing progress gauge (extracting or error) — tap to show detail dialog
                      if (subItem.isExtracting || subItem.isError)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: GestureDetector(
                            onTap: () => showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) => BlocProvider.value(
                                value: context.read<KdsCubit>(),
                                child: ExtractionMonitorDialog(
                                  orderNo: order.orderNo,
                                  subItemIndex: index,
                                  menuName: subItem.menuName,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: subItem.progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.white10,
                                    color: subItem.isError
                                        ? Colors.redAccent
                                        : Colors.orangeAccent,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        subItem.currentStage,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: subItem.isError
                                              ? Colors.redAccent
                                              : Colors.orangeAccent,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${(subItem.progress * 100).toInt()}%',
                                      style: const TextStyle(
                                          fontSize: 10, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // pickup complete button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isFullReady ? () => onCompletePickup(order) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                disabledBackgroundColor: Colors.white10,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
