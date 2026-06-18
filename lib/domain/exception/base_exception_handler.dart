import 'package:kds/domain/exception/base_exception.dart';

abstract class BaseExceptionHandler {
  BaseException handle(dynamic any);
}
