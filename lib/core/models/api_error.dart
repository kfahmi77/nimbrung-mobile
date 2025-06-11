import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  final String code;
  final String message;

  const ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(code: json['code'] ?? '', message: json['message'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'message': message};
  }

  @override
  List<Object?> get props => [code, message];
}
