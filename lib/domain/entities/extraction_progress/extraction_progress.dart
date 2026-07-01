import 'package:freezed_annotation/freezed_annotation.dart';

part 'extraction_progress.freezed.dart';

@freezed
abstract class ExtractionProgress with _$ExtractionProgress {
  const factory ExtractionProgress({
    required int code,
    required Map<String, dynamic> data,
  }) = _ExtractionProgress;
}
