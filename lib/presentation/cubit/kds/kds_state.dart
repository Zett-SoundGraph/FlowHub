import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/index.dart';

part 'kds_state.freezed.dart';

@freezed
abstract class KdsState with _$KdsState {
  const factory KdsState({
    required List<Order> orders,
    @Default(false) bool isConnected,
    @Default(false) bool isLabelAttached,
    @Default(false) bool isCalibrating,
    @Default(0) int manufacturingQueueLength,
    String? errorMessage,
  }) = _KdsState;

  factory KdsState.initial() {
    int seq = 1001;
    Order make(List<String> menus) {
      final no = '${seq++}';
      return Order(
        orderNo: no,
        rawOrderId: 'MOCK_$no',
        drinkCount: menus.length,
        items: menus.map((m) => SubItem.initial(m)).toList(),
      );
    }

    return KdsState(
      orders: [
        make(['ICED Americano']),
        make(['ICED Cafe Latte']),
        make(['Banana Milk Latte']),
        make(['Espresso']),
        make(['ICED Americano', 'ICED Cafe Latte']),
        make(['ICED Americano', 'Banana Milk Latte']),
        make(['ICED Cafe Latte', 'Banana Milk Latte']),
        make(['ICED Americano', 'ICED Americano']),
        make(['ICED Cafe Latte', 'ICED Cafe Latte']),
        make(['ICED Americano', 'ICED Cafe Latte', 'Banana Milk Latte']),
      ],
    );
  }
}
