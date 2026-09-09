import 'package:flowhub/domain/exception/base_exception.dart';

abstract class BaseExceptionHandler {
  BaseException handle(dynamic any);
}
