import 'package:fpdart/fpdart.dart';
import 'package:kds/core/di/service_locator.dart';
import 'package:kds/domain/exception/base_exception.dart';
import 'package:kds/domain/exception/base_exception_handler.dart';

abstract class UseCase<Type, Params> {
  BaseExceptionHandler? _exceptionHandler;

  BaseExceptionHandler get exceptionHandler {
    _exceptionHandler ??= getIt<BaseExceptionHandler>();
    return _exceptionHandler!;
  }

  Future<Either<BaseException, Type>> call(Params params);
}

abstract class UseCaseSync<Type, Params> {
  BaseExceptionHandler? _exceptionHandler;

  BaseExceptionHandler get exceptionHandler {
    _exceptionHandler ??= getIt<BaseExceptionHandler>();
    return _exceptionHandler!;
  }

  Either<BaseException, Type> call(Params params);
}

abstract class StreamUseCase<Type> {
  const StreamUseCase();
  Stream<Type> call();
}
