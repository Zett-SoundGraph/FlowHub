import 'package:flowhub/domain/entities/cloud/cloud_identity.dart';
import 'package:flowhub/domain/entities/order/order.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_ack.dart';
import 'package:flowhub/domain/entities/pos_order/pos_order_message.dart';
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/cloud_repository.dart';
import 'package:flowhub/domain/repositories/pos_order_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;

/// What the Hub does with one `pos-order` message.
sealed class PosOrderDecision {
  const PosOrderDecision();
}

/// Change nothing; just send [ack].
class PosOrderAnswer extends PosOrderDecision {
  const PosOrderAnswer(this.ack);
  final PosOrderAck ack;
}

/// Create [order], commit it, then ack ACCEPTED.
class PosOrderCreate extends PosOrderDecision {
  const PosOrderCreate(this.order);
  final Order order;
}

/// Cancel the existing order, then ack CANCELLED with its stage.
class PosOrderCancel extends PosOrderDecision {
  const PosOrderCancel(this.order);
  final Order order;
}

/// No such order: store a tombstone, then ack NOT_FOUND.
class PosOrderTombstone extends PosOrderDecision {
  const PosOrderTombstone(this.cancelledAt);
  final DateTime cancelledAt;
}

/// Params: the message and the Hub's local order with the same orderNo.
typedef DecidePosOrderParams = ({PosOrderMessage message, Order? existing});

/// Applies the pos-order rules to one message against local state. The same
/// message always gets the same answer, so resends are safe.
/// 1. schemaVersion above [supportedSchemaVersion] → REJECTED
///    UNSUPPORTED_SCHEMA_VERSION.
/// 2. storeId / hubId not this Hub → REJECTED STORE_MISMATCH.
/// 3. Unreadable fields → REJECTED with the field error.
/// 4. NEW: existing order → DUPLICATE (its orderedAt); tombstone →
///    ALREADY_CANCELLED; Hub clock ≥ expiresAt → EXPIRED; else create.
/// 5. CANCEL: existing and not cancelled → cancel; already cancelled →
///    ALREADY_CANCELLED; not found → tombstone + NOT_FOUND.
@injectable
class DecidePosOrderUseCase
    extends UseCase<PosOrderDecision, DecidePosOrderParams> {
  DecidePosOrderUseCase(this._cloud, this._posOrders);

  /// Highest pos-order schemaVersion this Hub reads.
  static const int supportedSchemaVersion = 1;

  final CloudRepository _cloud;
  final PosOrderRepository _posOrders;

  @override
  Future<Either<BaseException, PosOrderDecision>> call(
    DecidePosOrderParams params,
  ) async {
    try {
      return Right<BaseException, PosOrderDecision>(await _decide(params));
    } catch (e) {
      return Left<BaseException, PosOrderDecision>(exceptionHandler.handle(e));
    }
  }

  Future<PosOrderDecision> _decide(DecidePosOrderParams params) async {
    final PosOrderMessage message = params.message;
    final Order? existing = params.existing;
    if (message.schemaVersion > supportedSchemaVersion) {
      return _reject(PosOrderAckError.unsupportedSchemaVersion);
    }
    final CloudIdentity? identity = _cloud.identity;
    if (identity == null ||
        message.storeId != identity.storeId ||
        message.hubId != identity.hubId) {
      return _reject(PosOrderAckError.storeMismatch);
    }
    final String? error = message.error;
    if (error != null) {
      return _reject(error);
    }
    switch (message.type) {
      case PosOrderMessageType.newOrder:
        if (existing != null) {
          return PosOrderAnswer(PosOrderAck(
            status: PosOrderAckStatus.duplicate,
            orderedAt: existing.receivedAt,
          ));
        }
        if (await _posOrders.hasTombstone(message.orderNo)) {
          return const PosOrderAnswer(
            PosOrderAck(status: PosOrderAckStatus.alreadyCancelled),
          );
        }
        final DateTime? expiresAt = message.expiresAt;
        if (expiresAt == null || !DateTime.now().isBefore(expiresAt)) {
          return const PosOrderAnswer(
            PosOrderAck(status: PosOrderAckStatus.expired),
          );
        }
        final Order? order = message.order;
        if (order == null) {
          return _reject(PosOrderAckError.missingField);
        }
        return PosOrderCreate(order);
      case PosOrderMessageType.cancel:
        if (existing == null) {
          return PosOrderTombstone(message.cancelledAt ?? DateTime.now());
        }
        if (existing.isCancelled) {
          return PosOrderAnswer(PosOrderAck(
            status: PosOrderAckStatus.alreadyCancelled,
            orderedAt: existing.receivedAt,
          ));
        }
        return PosOrderCancel(existing);
      case PosOrderMessageType.unknown:
        return _reject(PosOrderAckError.missingField);
    }
  }

  PosOrderAnswer _reject(String error) => PosOrderAnswer(
    PosOrderAck(status: PosOrderAckStatus.rejected, error: error),
  );
}
