import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kds/core/di/di.dart';
import 'package:kds/domain/entities/index.dart';
import 'package:kds/domain/enums/index.dart';
import 'package:kds/presentation/cubit/index.dart';

import 'kds_main_texts.dart';

class KdsMainScreen extends StatefulWidget {
  const KdsMainScreen({super.key});

  @override
  State<KdsMainScreen> createState() => _KdsMainScreenState();
}

class _KdsMainScreenState extends State<KdsMainScreen> {
  late final KdsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<KdsCubit>();
  }

  Future<void> _onCompleteCooking(Order order) async {
    final success = await _cubit.completeCooking(order);
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(KdsMainTexts.cookingSignalSent(order.orderNo))),
    );
  }

  Future<void> _onCompletePickup(Order order) async {
    await _cubit.completePickup(order);
    if (!mounted) return;
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
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
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red[700],
            ),
          );
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text(
                KdsMainTexts.appTitle,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueGrey[900],
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    state.isConnected ? Icons.wifi : Icons.wifi_off,
                    color: state.isConnected
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: state.displayOrders.length,
                itemBuilder: (context, index) {
                  final order = state.displayOrders[index];
                  return _OrderCard(
                    order: order,
                    onCompleteCooking: _onCompleteCooking,
                    onCompletePickup: _onCompletePickup,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Future<void> Function(Order) onCompleteCooking;
  final Future<void> Function(Order) onCompletePickup;

  const _OrderCard({
    required this.order,
    required this.onCompleteCooking,
    required this.onCompletePickup,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = order.status == OrderStatus.ready;
    return Container(
      decoration: BoxDecoration(
        color: isReady ? Colors.indigo[900] : Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? Colors.blueAccent : Colors.white10,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${KdsMainTexts.orderPrefix} ${order.orderNo}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Divider(color: Colors.white24, height: 20),
          Expanded(
            child: Text(
              order.menuName,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isReady ? null : () => onCompleteCooking(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                  ),
                  child: const Text(
                    KdsMainTexts.completeCooking,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: !isReady ? null : () => onCompletePickup(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                  ),
                  child: const Text(
                    KdsMainTexts.completePickup,
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
