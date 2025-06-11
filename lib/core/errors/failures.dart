import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;
  final int? statusCode;

  const Failure({required this.message, required this.code, this.statusCode});

  @override
  List<Object?> get props => [message, code, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    required super.code,
    super.statusCode,
  });
}

class ClientFailure extends Failure {
  const ClientFailure({
    required super.message,
    required super.code,
    super.statusCode,
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unknown error occurred',
    super.code = 'UNKNOWN_ERROR',
  });
}
