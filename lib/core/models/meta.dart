import 'package:equatable/equatable.dart';

class Meta extends Equatable {
  final String timestamp;
  final String requestId;

  const Meta({required this.timestamp, required this.requestId});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      timestamp: json['timestamp'] ?? '',
      requestId: json['request_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'timestamp': timestamp, 'request_id': requestId};
  }

  @override
  List<Object?> get props => [timestamp, requestId];
}
