import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;
import 'package:kds/domain/entities/order/order.dart';
import 'package:kds/domain/enums/order_status.dart';
import 'package:kds/domain/usecases/complete_cooking_usecase.dart';
import 'package:kds/domain/usecases/complete_pickup_usecase.dart';
import 'package:kds/domain/usecases/connect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/disconnect_order_socket_usecase.dart';
import 'package:kds/domain/usecases/observe_order_connection_usecase.dart';

import 'kds_state.dart';

@injectable
class KdsCubit extends Cubit<KdsState> {
	final CompleteCookingUseCase _completeCooking;
	final CompletePickupUseCase _completePickup;
	final ConnectOrderSocketUseCase _connectOrderSocket;
	final DisconnectOrderSocketUseCase _disconnectOrderSocket;
	final ObserveOrderConnectionUseCase _observeOrderConnection;

	StreamSubscription<bool>? _connectionSubscription;

	KdsCubit({
		required CompleteCookingUseCase completeCooking,
		required CompletePickupUseCase completePickup,
		required ConnectOrderSocketUseCase connectOrderSocket,
		required DisconnectOrderSocketUseCase disconnectOrderSocket,
		required ObserveOrderConnectionUseCase observeOrderConnection,
	})  : _completeCooking = completeCooking,
				_completePickup = completePickup,
				_connectOrderSocket = connectOrderSocket,
				_disconnectOrderSocket = disconnectOrderSocket,
				_observeOrderConnection = observeOrderConnection,
				super(KdsState.initial()) {
		_init();
	}

	void _init() {
		_connectionSubscription = _observeOrderConnection().listen((connected) {
			emit(state.copyWith(isConnected: connected));
		});
		unawaited(_connectOrderSocket());
	}

	Future<bool> completeCooking(Order order) async {
		final result = await _completeCooking(order);
		return result.fold(
			(failure) {
				emit(state.copyWith(errorMessage: failure.message));
				return false;
			},
			(ok) {
				if (!ok) {
					emit(state.copyWith(errorMessage: '제조 완료 처리에 실패했습니다.'));
					return false;
				}
				final updatedOrders = List<Order>.from(state.orders);
				final index = updatedOrders.indexWhere((o) => o.orderNo == order.orderNo);
				if (index != -1) {
					updatedOrders[index] = updatedOrders[index].copyWith(
						status: OrderStatus.ready,
					);
				}
				emit(state.copyWith(orders: updatedOrders, errorMessage: null));
				return true;
			},
		);
	}

	Future<bool> completePickup(Order order) async {
		final result = await _completePickup(order);
		return result.fold(
			(failure) {
				emit(state.copyWith(errorMessage: failure.message));
				return false;
			},
			(ok) {
				if (!ok) {
					emit(state.copyWith(errorMessage: '픽업 완료 처리에 실패했습니다.'));
					return false;
				}
				final movedToBack = [
					...state.orders.where((o) => o.orderNo != order.orderNo),
					order.copyWith(status: OrderStatus.pending),
				];
				emit(state.copyWith(orders: movedToBack, errorMessage: null));
				return true;
			},
		);
	}

	@override
	Future<void> close() async {
		await _connectionSubscription?.cancel();
		_disconnectOrderSocket();
		return super.close();
	}
}
