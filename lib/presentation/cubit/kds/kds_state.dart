import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/index.dart';

part 'kds_state.freezed.dart';

Order _makeMockOrder(List<String> menus, int orderNo) {
  final no = '$orderNo';
  return Order(
    orderNo: no,
    rawOrderId: 'MOCK_$no',
    drinkCount: menus.length,
    items: menus.map((m) => SubItem.initial(m)).toList(),
  );
}

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
    return KdsState(
      orders: [
        _makeMockOrder(['ICED Americano'], seq++),
        _makeMockOrder(['ICED Cafe Latte'], seq++),
        _makeMockOrder(['Banana Milk Latte'], seq++),
        _makeMockOrder(['Espresso'], seq++),
        _makeMockOrder(['ICED Americano', 'ICED Cafe Latte'], seq++),
        _makeMockOrder(['ICED Americano', 'Banana Milk Latte'], seq++),
        _makeMockOrder(['ICED Cafe Latte', 'Banana Milk Latte'], seq++),
        _makeMockOrder(['ICED Americano', 'ICED Americano'], seq++),
        _makeMockOrder(['ICED Cafe Latte', 'ICED Cafe Latte'], seq++),
        _makeMockOrder(['ICED Americano', 'ICED Cafe Latte', 'Banana Milk Latte'], seq++),
      ],
    );
  }
}
