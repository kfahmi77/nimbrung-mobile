import 'package:dio/dio.dart';
import 'package:nimbrung_mobile/core/constants/api_constant.dart';

import '../../features/daily-readings/models/resension_model.dart';

class ReadingReviewService {
  final Dio _dio;

  ReadingReviewService(this._dio);

  Future<ReadingReviewResponse> getReadingReviews() async {
    try {
      final response = await _dio.get(ApiConstant.readDailyResension);
      return ReadingReviewResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load reading reviews: ${e.message}');
    }
  }
}
