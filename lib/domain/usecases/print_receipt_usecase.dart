import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:injectable/injectable.dart' hide Order;
import 'package:flowhub/domain/exception/base_exception.dart';
import 'package:flowhub/domain/repositories/receipt_printer_repository.dart';
import 'package:flowhub/domain/usecases/usecase.dart';

@injectable
class PrintReceiptUseCase extends UseCase<void, ({String orderNo, List<String> menus})> {
  final ReceiptPrinterRepository _repository;

  PrintReceiptUseCase(this._repository);

  @override
  Future<Either<BaseException, void>> call(({String orderNo, List<String> menus}) params) async {
    try {
      await _repository.printReceipt(orderNo: params.orderNo, menus: params.menus);
      return const Right(null);
    } catch (e) {
      return Left(exceptionHandler.handle(e));
    }
  }
}
