// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SelectedOption _$SelectedOptionFromJson(Map<String, dynamic> json) =>
    _SelectedOption(
      optionNo: json['optionNo'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$SelectedOptionToJson(_SelectedOption instance) =>
    <String, dynamic>{
      'optionNo': instance.optionNo,
      'quantity': instance.quantity,
    };
