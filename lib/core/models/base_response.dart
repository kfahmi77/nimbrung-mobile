import 'package:equatable/equatable.dart';

import 'api_error.dart';
import 'meta.dart';

abstract class BaseResponse<T> extends Equatable {
  final bool success;
  final String message;
  final int statusCode;
  final T? data;
  final ApiError? error;
  final Meta meta;

  const BaseResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
    this.error,
    required this.meta,
  });

  @override
  List<Object?> get props => [success, message, statusCode, data, error, meta];
}
