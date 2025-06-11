class ServerException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const ServerException({
    required this.message,
    required this.code,
    required this.statusCode,
  });
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});
}

class ClientException implements Exception {
  final String message;
  final String code;
  final int statusCode;

  const ClientException({
    required this.message,
    required this.code,
    required this.statusCode,
  });
}
