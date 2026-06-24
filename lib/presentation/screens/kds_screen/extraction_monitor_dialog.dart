import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kds/domain/enums/order_status.dart';
import 'package:kds/presentation/cubit/kds/kds_cubit.dart';
import 'package:kds/presentation/cubit/kds/kds_state.dart';

class ExtractionMonitorDialog extends StatelessWidget {
  final String orderNo;
  final int subItemIndex;
  final String menuName;

  const ExtractionMonitorDialog({
    super.key,
    required this.orderNo,
    required this.subItemIndex,
    required this.menuName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KdsCubit, KdsState>(
      builder: (context, state) {
        final order = state.orders.where((o) => o.orderNo == orderNo).firstOrNull;
        final subItem = (order != null && subItemIndex < order.items.length)
            ? order.items[subItemIndex]
            : null;

        final bool isFinished = subItem?.status == OrderStatus.ready;
        final bool isError = subItem?.isError ?? false;
        final bool isExtracting = subItem?.isExtracting ?? false;
        final double progress = subItem?.progress ?? 0;
        final String currentStage = subItem?.currentStage ?? '';
        final List<String> logs = subItem?.logs ?? [];
        final String? errorCode = subItem?.errorCode;

        final Color themeColor = isError
            ? Colors.redAccent
            : (isFinished ? Colors.greenAccent : Colors.orangeAccent);

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: themeColor.withValues(alpha: 0.5)),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  menuName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (isError)
                const Icon(Icons.error_outline, color: Colors.redAccent),
              if (isFinished)
                const Icon(Icons.check_circle_outline,
                    color: Colors.greenAccent),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 15,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        currentStage,
                        style: TextStyle(
                            color: themeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(color: themeColor),
                    ),
                  ],
                ),
                if (isError && errorCode != null)
                  Container(
                    margin: const EdgeInsets.only(top: 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Colors.redAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error Code: $errorCode\n(Please check and try again)',
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(color: Colors.white24, height: 30),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    itemCount: logs.length,
                    itemBuilder: (context, i) => Text(
                      logs[i],
                      style: TextStyle(
                        color: i == 0 ? themeColor : Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                if (isExtracting && !isFinished && !isError)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: OutlinedButton(
                        onPressed: () =>
                            context.read<KdsCubit>().cancelBrewing(orderNo),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          'Stop Brewing',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFinished
                          ? Colors.green
                          : (isError ? Colors.red[900] : Colors.blueGrey[800]),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      (isFinished || !isExtracting || isError)
                          ? 'OK'
                          : 'Close (Continue)',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
