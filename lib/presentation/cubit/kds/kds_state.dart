import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kds/domain/entities/order/order.dart';

part 'kds_state.freezed.dart';

@freezed
abstract class KdsState with _$KdsState {
  const factory KdsState({
    required List<Order> orders,
    @Default(false) bool isConnected,
    String? errorMessage,
  }) = _KdsState;

  factory KdsState.initial() {
    return KdsState(
      orders: List.generate(
        15,
        (index) => Order(
          orderNo: '${100 + index + 1}',
          menuName: '주문 메뉴 ${index + 1}',
        ),
      ),
    );
  }
}

extension KdsStateX on KdsState {
  List<Order> get displayOrders => orders.take(9).toList();
}
