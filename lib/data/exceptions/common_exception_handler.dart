import 'package:injectable/injectable.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/exception/base_exception_handler.dart';

@Injectable(as: BaseExceptionHandler)
class CommonExceptionHandler implements BaseExceptionHandler {
  @override
  BaseException handle(dynamic error) {
    if (error is BaseException) return error;
    return CommonException(message: error.toString());
  }
}
