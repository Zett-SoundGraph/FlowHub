import 'package:injectable/injectable.dart';
import 'package:kds/domain/repositories/machine_repository.dart';

@injectable
class SendTodayExtractionHistoryUseCase {
  final MachineRepository _repository;
  const SendTodayExtractionHistoryUseCase(this._repository);
  Future<void> call(String ip) => _repository.sendTodayExtractionHistory(ip);
}
