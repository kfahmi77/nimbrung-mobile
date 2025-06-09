// providers/reading_review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:nimbrung_mobile/core/constants/api_constant.dart';

import '../core/services/resension_service.dart';
import '../models/resension_model.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConstant.baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
});

final readingReviewServiceProvider = Provider<ReadingReviewService>((ref) {
  final dio = ref.watch(dioProvider);
  return ReadingReviewService(dio);
});

// providers/reading_review_provider.dart
final readingReviewsProvider =
    FutureProvider.autoDispose<ReadingReviewResponse>((ref) async {
      final service = ref.watch(readingReviewServiceProvider);
      return service.getReadingReviews();
    });
